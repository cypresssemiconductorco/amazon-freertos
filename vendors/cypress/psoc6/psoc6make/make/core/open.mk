################################################################################
# \file open.mk
# \version 1.0
#
# \brief
# Opens/launches a specified tool 
#
################################################################################
# \copyright
# Copyright 2018-2019 Cypress Semiconductor Corporation
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

ifeq ($(WHICHFILE),true)
$(info Processing $(lastword $(MAKEFILE_LIST)))
endif

# Supported tool types
CY_OPEN_TYPE_LIST+=\
	device-configurator\
	capsense-configurator\
	capsense-tuner\
	qspi-configurator\
	seglcd-configurator\
	smartio-configurator\
	bt-configurator\
	usbdev-configurator\
	cype-tool\
	dfuh-tool

# Verify that the tool is supported
ifneq ($(CY_OPEN_TYPE),)
ifeq ($(filter $(CY_OPEN_TYPE),$(CY_OPEN_TYPE_LIST)),)
$(error Unsupported tool type - $(CY_OPEN_TYPE). $(CY_NEWLINE)Supported types are: $(CY_OPEN_TYPE_LIST))
endif
endif

# Extension construction from given file
ifneq ($(CY_OPEN_FILE)),)
CY_OPEN_EXT=$(subst .,,$(suffix $(CY_OPEN_FILE)))
endif


################################################################################
# Definition
################################################################################

##########################
# device-configurator
##########################

CY_OPEN_device_configurator_FILE=$(CY_CONFIG_MODUS_FILE)
CY_OPEN_device_configurator_TOOL=$(CY_CONFIG_MODUS_GUI)
CY_OPEN_device_configurator_TOOL_ARGS=$(CY_CONFIG_LIBFILE)
CY_OPEN_device_configurator_TOOL_FLAGS=$(CY_CONFIG_MODUS_GUI_FLAGS)
CY_OPEN_device_configurator_TOOL_NEWCFG_FLAGS=

##########################
# capsense-configurator
##########################

CY_OPEN_capsense_configurator_FILE=$(wildcard $(call CY_MACRO_DIR,$(CY_CONFIG_MODUS_FILE))/*.cycapsense)
CY_OPEN_capsense_configurator_TOOL=$(CY_CAPSENSE_CONFIGURATOR_DIR)/capsense-configurator
CY_OPEN_capsense_configurator_TOOL_FLAGS=$(CY_CONFIG_LIBFILE) --config 
ifeq ($(CY_CONFIG_MODUS_FILE),)
CY_OPEN_capsense_configurator_TOOL_NEWCFG_FLAGS=$(CY_CONFIG_LIBFILE) --config $(CY_INTERNAL_APPLOC)/design.cycapsense
else
CY_OPEN_capsense_configurator_TOOL_NEWCFG_FLAGS=$(CY_CONFIG_LIBFILE) --config $(call CY_MACRO_DIR,$(CY_CONFIG_MODUS_FILE))/design.cycapsense
endif

##########################
# capsense-tuner
##########################

CY_OPEN_capsense_tuner_FILE=$(wildcard $(call CY_MACRO_DIR,$(CY_CONFIG_MODUS_FILE))/*.cycapsense)
CY_OPEN_capsense_tuner_TOOL=$(CY_CAPSENSE_CONFIGURATOR_DIR)/capsense-tuner
CY_OPEN_capsense_tuner_TOOL_FLAGS=--config 
ifeq ($(CY_CONFIG_MODUS_FILE),)
CY_OPEN_capsense_tuner_TOOL_NEWCFG_FLAGS=--config $(CY_INTERNAL_APPLOC)/design.cycapsense
else
CY_OPEN_capsense_tuner_TOOL_NEWCFG_FLAGS=--config $(call CY_MACRO_DIR,$(CY_CONFIG_MODUS_FILE))/design.cycapsense
endif

##########################
# qspi-configurator
##########################

CY_OPEN_qspi_configurator_FILE=$(wildcard $(call CY_MACRO_DIR,$(CY_CONFIG_MODUS_FILE))/*.cyqspi)
CY_OPEN_qspi_configurator_TOOL=$(CY_QSPI_CONFIGURATOR_DIR)/qspi-configurator
CY_OPEN_qspi_configurator_TOOL_FLAGS=--config 
ifeq ($(CY_CONFIG_MODUS_FILE),)
CY_OPEN_qspi_configurator_TOOL_NEWCFG_FLAGS=--config $(CY_INTERNAL_APPLOC)/design.cyqspi
else
CY_OPEN_qspi_configurator_TOOL_NEWCFG_FLAGS=--config $(call CY_MACRO_DIR,$(CY_CONFIG_MODUS_FILE))/design.cyqspi
endif

##########################
# seglcd-configurator
##########################

CY_OPEN_seglcd_configurator_FILE=$(wildcard $(call CY_MACRO_DIR,$(CY_CONFIG_MODUS_FILE))/*.cyseglcd)
CY_OPEN_seglcd_configurator_TOOL=$(CY_SEGLCD_CONFIGURATOR_DIR)/seglcd-configurator
CY_OPEN_seglcd_configurator_TOOL_FLAGS=$(CY_CONFIG_LIBFILE) --config 
ifeq ($(CY_CONFIG_MODUS_FILE),)
CY_OPEN_seglcd_configurator_TOOL_NEWCFG_FLAGS=$(CY_CONFIG_LIBFILE) --config $(CY_INTERNAL_APPLOC)/design.cyseglcd
else
CY_OPEN_seglcd_configurator_TOOL_NEWCFG_FLAGS=$(CY_CONFIG_LIBFILE) --config $(call CY_MACRO_DIR,$(CY_CONFIG_MODUS_FILE))/design.cyseglcd
endif

##########################
# smartio-configurator
##########################

CY_OPEN_smartio_configurator_FILE=$(CY_CONFIG_MODUS_FILE)
CY_OPEN_smartio_configurator_TOOL=$(CY_SMARTIO_CONFIGURATOR_DIR)/smartio-configurator
CY_OPEN_smartio_configurator_TOOL_FLAGS=$(CY_CONFIG_LIBFILE) 
CY_OPEN_smartio_configurator_TOOL_NEWCFG_FLAGS=$(CY_CONFIG_LIBFILE) 

##########################
# bt-configurator
##########################

CY_OPEN_bt_configurator_FILE=$(CY_CONFIG_CYBT_FILE)
CY_OPEN_bt_configurator_TOOL=$(CY_CONFIG_CYBT_GUI)
CY_OPEN_bt_configurator_TOOL_FLAGS=--config 
CY_OPEN_bt_configurator_TOOL_NEWCFG_FLAGS=--config $(CY_INTERNAL_APPLOC)/design.cybt $(CY_OPEN_bt_configurator_DEVICE)

##########################
# usbdev-configurator
##########################

CY_OPEN_usbdev_configurator_FILE=$(CY_CONFIG_CYUSBDEV_FILE)
CY_OPEN_usbdev_configurator_TOOL=$(CY_CONFIG_CYUSBDEV_GUI)
CY_OPEN_usbdev_configurator_TOOL_FLAGS=--config 
CY_OPEN_usbdev_configurator_TOOL_NEWCFG_FLAGS=--config $(CY_INTERNAL_APPLOC)/design.cyusbdev

##########################
# cype-tool
##########################

CY_OPEN_cype_tool_FILE=
CY_OPEN_cype_tool_TOOL=$(CY_PE_TOOL_DIR)/cype-tool
CY_OPEN_cype_tool_TOOL_FLAGS=
CY_OPEN_cype_tool_TOOL_NEWCFG_FLAGS=

##########################
# dfuh-tool
##########################

CY_OPEN_dfuh_tool_FILE=
CY_OPEN_dfuh_tool_TOOL=$(CY_DFUH_TOOL_DIR)/dfuh-tool
CY_OPEN_dfuh_tool_TOOL_FLAGS=
CY_OPEN_dfuh_tool_TOOL_NEWCFG_FLAGS=


################################################################################
# File type defaults
################################################################################

modus_DEFAULT_TYPE=device-configurator
cycapsense_DEFAULT_TYPE=capsense-configurator
cyqspi_DEFAULT_TYPE=qspi-configurator
cyseglcd_DEFAULT_TYPE=seglcd-configurator
cybt_DEFAULT_TYPE=bt-configurator
cyusbdev_DEFAULT_TYPE=usbdev-configurator
cyacd2_DEFAULT_TYPE=dfuh-tool


################################################################################
# Prepare tool launch
################################################################################

# Only file is given. Use the default type for that file extension
ifneq ($(CY_OPEN_FILE),)
ifeq ($(CY_OPEN_TYPE),)
CY_OPEN_TYPE=$($(CY_OPEN_EXT)_DEFAULT_TYPE)
endif
endif

# Set the tool and its arguments
CY_OPEN_TOOL_FILE=$(CY_OPEN_$(subst -,_,$(CY_OPEN_TYPE))_FILE)
CY_OPEN_TOOL_LAUNCH=$(CY_OPEN_$(subst -,_,$(CY_OPEN_TYPE))_TOOL)
CY_OPEN_TOOL_FLAGS=$(CY_OPEN_$(subst -,_,$(CY_OPEN_TYPE))_TOOL_FLAGS)
CY_OPEN_TOOL_ARGS=$(CY_OPEN_$(subst -,_,$(CY_OPEN_TYPE))_TOOL_ARGS)
CY_OPEN_TOOL_NEWCFG_FLAGS=$(CY_OPEN_$(subst -,_,$(CY_OPEN_TYPE))_TOOL_NEWCFG_FLAGS)

# Use the file if provided
ifneq ($(CY_OPEN_FILE),)
CY_OPEN_TOOL_FILE=$(CY_OPEN_FILE)
endif

ifneq ($(CY_MAKE_IDE),)
CY_OPEN_STDOUT=>& /dev/null
endif


################################################################################
# Tool launch target
################################################################################

open:
ifeq ($(CY_OPEN_FILE),)
ifeq ($(CY_OPEN_TYPE),)
	$(error Neither tool type or file specified to launch a tool)
endif
endif
ifeq ($(CY_OPEN_TOOL_LAUNCH),)
	$(error Unable to find a default tool to launch .$(CY_OPEN_EXT) file extension)
endif
ifeq ($(CY_OPEN_TOOL_FILE),)
	$(info Launching $(notdir $(CY_OPEN_TOOL_LAUNCH)) tool for a new configuration)
	$(CY_NOISE) $(CY_OPEN_TOOL_LAUNCH) $(CY_OPEN_TOOL_ARGS) $(CY_OPEN_TOOL_NEWCFG_FLAGS) $(CY_OPEN_STDOUT) &
else
	$(info $(CY_NEWLINE)Launching $(notdir $(CY_OPEN_TOOL_LAUNCH)) tool on $(CY_OPEN_TOOL_FILE))
	$(CY_NOISE) $(CY_OPEN_TOOL_LAUNCH) $(CY_OPEN_TOOL_ARGS) $(CY_OPEN_TOOL_FLAGS) $(CY_OPEN_TOOL_FILE) $(CY_OPEN_STDOUT) &
endif

#
# Identify the phony targets
#
.PHONY: open
