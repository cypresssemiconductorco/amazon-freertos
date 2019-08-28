/**************************************************************************//**
 * @file     startup_psoc6_03_cm0plus.S
 * @brief    CMSIS Core Device Startup File for
 *           ARMCM0plus Device Series
 * @version  V5.00
 * @date     02. March 2016
 ******************************************************************************/
/*
 * Copyright (c) 2009-2016 ARM Limited. All rights reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the License); you may
 * not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an AS IS BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

    /* Address of the NMI handler */
    #define CY_NMI_HANLDER_ADDR         0x0000000D

    /* The CPU VTOR register */
    #define CY_CPU_VTOR_ADDR            0xE000ED08

    .syntax    unified

    .section __STACK, __stack
    .align    3
#ifdef __STACK_SIZE
    .equ    Stack_Size, __STACK_SIZE
#else
    .equ    Stack_Size, 0x00001000
#endif
    .globl    __StackTop
    .globl    __StackLimit

__StackLimit:
    .space    Stack_Size
    .equ __StackTop, . - Stack_Size

    .section __HEAP, __heap
    .align    3
#ifdef __HEAP_SIZE
    .equ    Heap_Size, __HEAP_SIZE
#else
    .equ    Heap_Size, 0x00000400
#endif
    .globl    __HeapBase
    .globl    __HeapLimit
__HeapBase:
    .if    Heap_Size
    .space    Heap_Size
    .endif

    .section __VECT, ___Vectors
    .align 2
    .globl    ___Vectors
___Vectors:
    .long    __StackTop            /* Top of Stack */
    .long    Reset_Handler+1       /* Reset Handler. Added +1, clang doesn't make lsb to 1 for thumb */
    .long    CY_NMI_HANLDER_ADDR   /* NMI Handler */
    .long    HardFault_Handler     /* Hard Fault Handler */
    .long    0                     /* Reserved */
    .long    0                     /* Reserved */
    .long    0                     /* Reserved */
    .long    0                     /* Reserved */
    .long    0                     /* Reserved */
    .long    0                     /* Reserved */
    .long    0                     /* Reserved */
    .long    SVC_Handler           /* SVCall Handler */
    .long    0                     /* Reserved */
    .long    0                     /* Reserved */
    .long    PendSV_Handler        /* PendSV Handler */
    .long    SysTick_Handler       /* SysTick Handler */

     /* External interrupts                             Description */
    .long    NvicMux0_IRQHandler                     /* CPU User Interrupt #0 */
    .long    NvicMux1_IRQHandler                     /* CPU User Interrupt #1 */
    .long    NvicMux2_IRQHandler                     /* CPU User Interrupt #2 */
    .long    NvicMux3_IRQHandler                     /* CPU User Interrupt #3 */
    .long    NvicMux4_IRQHandler                     /* CPU User Interrupt #4 */
    .long    NvicMux5_IRQHandler                     /* CPU User Interrupt #5 */
    .long    NvicMux6_IRQHandler                     /* CPU User Interrupt #6 */
    .long    NvicMux7_IRQHandler                     /* CPU User Interrupt #7 */
    .long    Internal0_IRQHandler                    /* Internal SW Interrupt #0 */
    .long    Internal1_IRQHandler                    /* Internal SW Interrupt #1 */
    .long    Internal2_IRQHandler                    /* Internal SW Interrupt #2 */
    .long    Internal3_IRQHandler                    /* Internal SW Interrupt #3 */
    .long    Internal4_IRQHandler                    /* Internal SW Interrupt #4 */
    .long    Internal5_IRQHandler                    /* Internal SW Interrupt #5 */
    .long    Internal6_IRQHandler                    /* Internal SW Interrupt #6 */
    .long    Internal7_IRQHandler                    /* Internal SW Interrupt #7 */

    .equ    __VectorsSize, . - ___Vectors

    .section __RAMVECTORS, ___ramVectors
    .align 2
    .globl ___ramVectors

___ramVectors:
    .space  __VectorsSize

    /* Only .text, otherwise the linker is smart enough to treat .thumb_func as 2 byte aligned and the
    * Reset handler vector + 1 in the vector table ends up at +2 and boot fails. Clang/LLVM issue.
    */
    .text
    /* Reset handler */
    .globl Reset_Handler

Reset_Handler:
    bl Cy_OnResetUser
    cpsid i

/*  Single section scheme.
 *
 *  The ranges of copy from/to are specified by following symbols
 *    __etext: LMA of start of the section to copy from. Usually end of text
 *    __data_start__: VMA of start of the section to copy to
 *    __data_end__: VMA of end of the section to copy to
 *
 *  All addresses must be aligned to 4 bytes boundary.
 */
    .equ    __copy_table_start__, ___Vectors
    .equ    __data_start__, ___ramVectors
    .equ    __data_end__, __data_start__ + __VectorsSize
    ldr    r1, =__copy_table_start__
    ldr    r2, =__data_start__
    ldr    r3, =__data_end__
.L_loop_copy_table:
    subs   r4, r3, r2
    ble    .L_loop_copy_table_done
    ldr    r0, [r1,r4]
    str    r0, [r2,r4]
    subs   r3, #4
    bgt    .L_loop_copy_table
.L_loop_copy_table_done:
    ldr    r1, =segment$end$__TEXT + 3
    ldr    r2, =section$start$__DATA$__data
    ldr    r3, =section$end$__DATA$__data
    movs   r4, #3
    mvns   r4,r4
    ands    r1, r1, r4
.L_loop_copy_data:
    subs   r4, r3, r2
    ble    .L_loop_copy_data_done
    ldr    r0, [r1,r4]
    str    r0, [r2,r4]
    subs   r3, #4
    bgt    .L_loop_copy_data
.L_loop_copy_data_done:
    ldr    r2, =section$start$__DATA$__bss
    ldr    r3, =section$end$__DATA$__bss
.L_loop_bss:
    subs   r1, r3, r2
    ble    .L_loop_bss_done
    movs   r0, #0
    str    r0, [r2,r1]
    subs   r3, #4
    bgt    .L_loop_bss
.L_loop_bss_done:
    ldr    r2, =section$start$__DATA$__zerofill
    ldr    r3, =section$end$__DATA$__zerofill
.L_loop_zerofill:
    subs   r1, r3, r2
    ble    .L_loop_zerofill_done
    movs   r0, #0
    str    r0, [r2,r1]
    subs   r3, #4
    bgt    .L_loop_zerofill
.L_loop_zerofill_done:

    /* Update Vector Table Offset Register. */
    ldr r0, =___ramVectors
    ldr r1, =CY_CPU_VTOR_ADDR
    str r0, [r1]
    dsb 0xF

    bl _HeapInit
#ifndef __NO_SYSTEM_INIT
    bl    _SystemInit
#endif

    bl    _main

    /* Should never get here */
    b   .

    .pool

    .text
    .thumb
    .thumb_func
    .align 2

    /* Device startup customization */
    .weak_definition   Cy_OnResetUser
    .global Cy_OnResetUser, Cy_OnResetUser
Cy_OnResetUser:
    bx lr

    .align    1
    .thumb_func
    .weak_definition    Default_Handler

Default_Handler:
    b    .
    .weak_definition    Cy_SysLib_FaultHandler

Cy_SysLib_FaultHandler:
    b    .

    .text
    .thumb_func
    .align 2
Fault_Handler:
    /* Storing LR content for Creator call stack trace */
    push {LR}
    movs r0, #4
    mov r1, LR
    tst r0, r1
    beq .L_MSP
    mrs r0, PSP
    b .L_API_call
.L_MSP:
    mrs r0, MSP
.L_API_call:
    /* Compensation of stack pointer address due to pushing 4 bytes of LR */
    adds r0, r0, #4
    bl Cy_SysLib_FaultHandler
    b   .

.macro    def_fault_Handler    fault_handler_name
    .weak_definition    \fault_handler_name
    .set    \fault_handler_name, Fault_Handler
    .endm

/*    Macro to define default handlers. Default handler
 *    will be weak symbol and just dead loops. They can be
 *    overwritten by other handlers */
    .macro    def_irq_handler    handler_name
    .weak_definition    \handler_name
    .set    \handler_name, Default_Handler
    .endm

    def_irq_handler    NMI_Handler

    def_fault_Handler  HardFault_Handler

    def_irq_handler    SVC_Handler
    def_irq_handler    PendSV_Handler
    def_irq_handler    SysTick_Handler

    def_irq_handler  NvicMux0_IRQHandler                     /* CPU User Interrupt #0 */
    def_irq_handler  NvicMux1_IRQHandler                     /* CPU User Interrupt #1 */
    def_irq_handler  NvicMux2_IRQHandler                     /* CPU User Interrupt #2 */
    def_irq_handler  NvicMux3_IRQHandler                     /* CPU User Interrupt #3 */
    def_irq_handler  NvicMux4_IRQHandler                     /* CPU User Interrupt #4 */
    def_irq_handler  NvicMux5_IRQHandler                     /* CPU User Interrupt #5 */
    def_irq_handler  NvicMux6_IRQHandler                     /* CPU User Interrupt #6 */
    def_irq_handler  NvicMux7_IRQHandler                     /* CPU User Interrupt #7 */
    def_irq_handler  Internal0_IRQHandler                    /* Internal SW Interrupt #0 */
    def_irq_handler  Internal1_IRQHandler                    /* Internal SW Interrupt #1 */
    def_irq_handler  Internal2_IRQHandler                    /* Internal SW Interrupt #2 */
    def_irq_handler  Internal3_IRQHandler                    /* Internal SW Interrupt #3 */
    def_irq_handler  Internal4_IRQHandler                    /* Internal SW Interrupt #4 */
    def_irq_handler  Internal5_IRQHandler                    /* Internal SW Interrupt #5 */
    def_irq_handler  Internal6_IRQHandler                    /* Internal SW Interrupt #6 */
    def_irq_handler  Internal7_IRQHandler                    /* Internal SW Interrupt #7 */

    .end


/* [] END OF FILE */
