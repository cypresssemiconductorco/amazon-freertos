/***************************************************************************//**
* \file cyhal_modules.h
*
* \brief
* Provides an enum of all HAL modules types that can be used for generating
* custom cy_rslt_t items.
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

/**
* \ingroup group_result
* \{
*/

#pragma once

#include "cy_result.h"

#if defined(__cplusplus)
extern "C" {
#endif

/** @brief Enum to specify module IDs for @ref cy_rslt_t values returned from the HAL. */
enum cyhal_rslt_module_chip
{
    CYHAL_RSLT_MODULE_CHIP_HWMGR = CY_RSLT_MODULE_ABSTRACTION_HAL_BASE, //!< Module identifier for the hardware management module
    CYHAL_RSLT_MODULE_ADC,                                              //!< Module identifier for the ADC module
    CYHAL_RSLT_MODULE_COMP,                                             //!< Module identifier for the comparator module
    CYHAL_RSLT_MODULE_CRC,                                              //!< Module identifier for the crypto CRC module
    CYHAL_RSLT_MODULE_DAC,                                              //!< Module identifier for the DAC module
    CYHAL_RSLT_MODULE_DMA,                                              //!< Module identifier for the DMA module
    CYHAL_RSLT_MODULE_FLASH,                                            //!< Module identifier for the flash module
    CYHAL_RSLT_MODULE_GPIO,                                             //!< Module identifier for the GPIO module
    CYHAL_RSLT_MODULE_I2C,                                              //!< Module identifier for the I2C module
    CYHAL_RSLT_MODULE_I2S,                                              //!< Module identifier for the I2S module
    CYHAL_RSLT_MODULE_INTERCONNECT,                                     //!< Module identifier for the Interconnct module
    CYHAL_RSLT_MODULE_OPAMP,                                            //!< Module identifier for the OpAmp module
    CYHAL_RSLT_MODULE_PDMPCM,                                           //!< Module identifier for the PDM/PCM module
    CYHAL_RSLT_MODULE_PWM,                                              //!< Module identifier for the PWM module
    CYHAL_RSLT_MODULE_QSPI,                                             //!< Module identifier for the QSPI module
    CYHAL_RSLT_MODULE_RTC,                                              //!< Module identifier for the RTC module
    CYHAL_RSLT_MODULE_SDHC,                                             //!< Module identifier for the SDHC module
    CYHAL_RSLT_MODULE_SDIO,                                             //!< Module identifier for the SDIO module
    CYHAL_RSLT_MODULE_SPI,                                              //!< Module identifier for the SPI module
    CYHAL_RSLT_MODULE_SYSTEM,                                           //!< Module identifier for the System module
    CYHAL_RSLT_MODULE_TIMER,                                            //!< Module identifier for the Timer module
    CYHAL_RSLT_MODULE_TRNG,                                             //!< Module identifier for the RNG module
    CYHAL_RSLT_MODULE_UART,                                             //!< Module identifier for the UART module
    CYHAL_RSLT_MODULE_USB,                                              //!< Module identifier for the USB module
    CYHAL_RSLT_MODULE_WDT,                                              //!< Module identifier for the WDT module
};

#if defined(__cplusplus)
}
#endif /* __cplusplus */

/** \} group_hal */
