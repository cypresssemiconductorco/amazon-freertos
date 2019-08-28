/***************************************************************************//**
* \file signature.c
*
* \brief
* signature area for MCUBoot implementation
*
********************************************************************************
* \copyright
* Copyright 2018-2019 Cypress Semiconductor Corporation
* SPDX-License-Identifier: Apache-2.0
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*******************************************************************************/

#if defined(OTA_SUPPORT)

#include <stdint.h>
#include "bootutil/image.h"

#if defined(__APPLE__) && defined(__clang__)
__attribute__ ((__section__("__CY_M0P_IMAGE,cy_mcuboot_sig"), used))
#elif defined(__GNUC__) || defined(__ARMCC_VERSION)
__attribute__ ((__section__(".cy_mcuboot_sig"), used))
#elif defined(__ICCARM__)
#pragma  location=".cy_mcuboot_sig"
#else
#error "An unsupported toolchain"
#endif
const struct image_header header =
{
    .ih_magic = 0,
    .ih_load_addr = 0,
    .ih_hdr_size = 0,
    .ih_protect_tlv_size = 0,
    .ih_img_size = 0,
    .ih_flags = 0,
    .ih_ver = { 0, 0, 0, 0},
    ._pad1 = 0
} ;

#endif /* OTA_SUPPORT */
