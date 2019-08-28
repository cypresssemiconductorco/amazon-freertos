# Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# (c) 2019, Cypress Semiconductor Corporation. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#     http://www.apache.org/licenses/LICENSE-2.0
# or in the "license" file accompanying this file. This file is distributed 
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either 
# express or implied. See the License for the specific language governing 
# permissions and limitations under the License.
#
# AWS IoT OTA Update Script
# Important Note: Requires Python 3

import pathlib
import re
from pathlib import Path
from shutil import copyfile
import random
import boto3
import sys, argparse
import bucket 
from bucket import S3Bucket
import role 
from role import Role
import user 
from user import User
import json
import logging

parser = argparse.ArgumentParser(description='Script to start OTA update')
parser.add_argument("--profile", help="Profile name created using aws configure", required=True)
parser.add_argument("--region", help="Region",default="", required=False)
parser.add_argument("--account", help="Account ID",default="",required=False)
parser.add_argument("--devicetype", help="thing|group",default="thing", required=False)
parser.add_argument("--name", help="Name of thing/group",required=True)
parser.add_argument("--role", help="Role for OTA updates", required=True)
parser.add_argument("--s3bucket", help="S3 bucket to store firmware updates", required=True)
parser.add_argument("--otasigningprofile", help="Signing profile to be created or used", required=True)
parser.add_argument("--signingcertificateid", help="certificate id (not arn) to be used", required=False)
parser.add_argument("--codelocation", help="base folder location (can be relative)",default="../code/amazon-freertos/", required=False)
parser.add_argument("--appversion", help="version of the image being uploade. The appversion value should follow the format APP_VERSION_MAJOR-APP_VERSION_MINOR-APP_VERSION_BUILD that is appended to the filename of the file being uploaded",default="0-0-0",required=True)
args=parser.parse_args()

class AWS_IoT_OTA:


    def BuildFirmwareFileNames(self):
        self.DEMOS_PATH=Path(args.codelocation)
        self.BUILD_PATH=self.DEMOS_PATH / Path("build/cy/ota/CY8CPROTO-062-4343W/Debug")
        # We Should have the versions stored at this point. Build the App name
        self.APP_NAME="ota_" + args.appversion + ".bin"
        self.APP_FULL_NAME=self.BUILD_PATH / Path(self.APP_NAME)
        self.BUILD_FILE_FULL_NAME=self.BUILD_PATH/Path("ota.bin")
        print ("Using App Location: " + str(self.APP_FULL_NAME))
        print ("Build File Name: " + str(self.BUILD_FILE_FULL_NAME))

        # First make a copy of the bin file with the version in the name
        try:
            copyfile(self.BUILD_FILE_FULL_NAME, self.APP_FULL_NAME)
        except Exception as e:
            print("Error copying %s" % self.BUILD_FILE_FULL_NAME)
            logging.error(e)
            sys.exit




    # Copy the file to the s3 bucket
    def CopyFirmwareFileToS3(self):
        self.s3 = boto3.resource('s3')
        try:
            self.s3.meta.client.upload_file(str(self.APP_FULL_NAME), args.s3bucket, str(self.APP_NAME))
        except Exception as e:
            print("Error uploading file to s3: %s", e)
            sys.exit        



    # Get the latest version
    def GetLatestS3FileVersion(self):
        try: 
            versions=self.s3.meta.client.list_object_versions(Bucket=args.s3bucket, Prefix=self.APP_NAME)['Versions']
            latestversion = [x for x in versions if x['IsLatest']==True]
            self.latestVersionId=latestversion[0]['VersionId']
            #print("Using version %s" % self.latestVersionId)
        except Exception as e:
            print("Error getting versions: %s" % e)
            sys.exit




    # Create signing profile if it does not exist
    def CreateSigningProfile(self):
        try:
            signer = boto3.client('signer')
            profiles = signer.list_signing_profiles()['profiles']

            foundProfile=False
            afrProfile=None
            print("Searching for profile %s" % args.otasigningprofile)

            if len(profiles) > 0:
              for profile in profiles:
                if profile['profileName'] == args.otasigningprofile:
                    foundProfile = True
                    afrProfile = profile
            
            if (afrProfile != None):
                foundProfile=True
                print("Found Profile %s in account" % args.otasigningprofile)

            if (foundProfile == False):
                # Create profile
                newProfile = signer.put_signing_profile(
                    signingParameters={
                        'certname':'otasigner.crt'
                    },
                    profileName=args.otasigningprofile,
                    signingMaterial={
                        'certificateArn':self.SIGNINGCERTIFICATEARN   
                    },
                platformId='AmazonFreeRTOS-Default'
                )
                print("Created new signing profile: %s" % newProfile)
        except Exception as e:
            print("Error creating signing profile: %s" % e)
            sys.exit




    def CreateOTAJob(self):
        
        # Create OTA job
        try:
            iot = boto3.client('iot')
            randomSeed=random.randint(1, 65535)
            #Initialize the template to use
            files=[{
                'fileName': self.APP_NAME,
                    'fileVersion': '1',
                    'fileLocation': {
                        's3Location': {
                            'bucket': args.s3bucket,
                            'key': self.APP_NAME,
                            'version': self.latestVersionId
                        }
                    },
                    'codeSigning':{
                        'startSigningJobParameter':{
                            'signingProfileName': args.otasigningprofile,
                            'destination': {
                                's3Destination': {
                                    'bucket': args.s3bucket
                                }
                            }
                        }
                    }    
                }] 

            target="arn:aws:iot:"+args.region+":"+args.account+":"+args.devicetype+"/"+args.name
            updateId="update-"+str(randomSeed)+"-"+args.appversion

            print ("Files for update: %s" % files)
            
            ota_update=iot.create_ota_update(
                otaUpdateId=updateId,
                targetSelection='SNAPSHOT',
                files=files,
                targets=[target],
                roleArn="arn:aws:iam::"+args.account+":role/"+args.role
            )

            print("OTA Update Status: %s" % ota_update)

        except Exception as e:
            print("Error creating OTA Job: %s" % e)
            sys.exit


    def __init__(self):
        boto3.setup_default_session(profile_name=args.profile)
        self.Session = boto3.session.Session()
        if args.region=='':
            args.region = self.Session.region_name

        if args.account=='':
            # Get account Id
            args.account=boto3.client('sts').get_caller_identity().get('Account')
        with open('certarn.json',"r") as file:
            cert_text = json.load(file)
        self.SIGNINGCERTIFICATEARN=cert_text["CertificateArn"]
        print("Certificate ARN: %s" % self.SIGNINGCERTIFICATEARN)
    

    def DoUpdate(self):
        self.BuildFirmwareFileNames()
        self.CopyFirmwareFileToS3()
        self.GetLatestS3FileVersion()
        self.CreateSigningProfile()
        self.CreateOTAJob()


def main(argv):
    ota = AWS_IoT_OTA()
    ota_bucket = S3Bucket(args.s3bucket,args.region)
    if(False == ota_bucket.exists()):
        if(True == ota_bucket.create()):print("Created bucket")
        else:
            sys.exit()
    ota_role = Role(args.role)
    if(False == ota_role.exists()):
        ota_role.init_role_policies(account_id=args.account,bucket_name=args.s3bucket)
    ota.DoUpdate()
   

if __name__ == "__main__":
    main(sys.argv[1:])