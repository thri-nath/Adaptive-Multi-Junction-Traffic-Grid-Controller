# Generic Timer Verification Report

## Module
`generic_timer`

## Testbench
`generic_timer_tb_Self`

## Simulation Environment
- Simulator: Xilinx Vivado XSim
- Verification type: Self-checking testbench
- Clock period: 20 ns

## Test Coverage
- Reset behavior
- Start signal during reset
- Timer completion for multiple target values
- Completion signal behavior
- Counter wraparound for target zero
- Reset during active counting
- Restart during counting
- Holding start high
- Changing target during counting
- Maximum 8-bit target value

## Initial Results
- Compilation: PASS
- Elaboration: PASS
- Initial reset: PASS
- Start ignored during reset: PASS
- Target 1: PASS
- Target 9: PASS
- Target 25: PASS

## Final Result
```
====================================
GENERIC TIMER SELF-CHECKING TEST
====================================
PASS: Initial reset | expected=0 actual=0
PASS: Start ignored during reset | expected=0 actual=0
PASS: done is low after start | expected=0 actual=0
PASS: Target 1 | expected=1 actual=1
PASS: done clears after completion | expected=0 actual=0
PASS: done is low after start | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: Target 9 | expected=1 actual=1
PASS: done clears after completion | expected=0 actual=0
PASS: done is low after start | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: Target 25 | expected=1 actual=1
PASS: done clears after completion | expected=0 actual=0
PASS: done is low after start | expected=0 actual=0
ASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: Target 32 | expected=1 actual=1
PASS: done clears after completion | expected=0 actual=0
PASS: done is low after start | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: Target 10 | expected=1 actual=1
PASS: done clears after completion | expected=0 actual=0
PASS: done is low after start | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: Target 8 | expected=1 actual=1
PASS: done clears after completion | expected=0 actual=0
PASS: done is low after start | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: Target 3 | expected=1 actual=1
PASS: done clears after completion | expected=0 actual=0
PASS: done is low after start | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: Maximum target 255 | expected=1 actual=1
PASS: done clears after completion | expected=0 actual=0
PASS: done is low after start | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: done remains low before target | expected=0 actual=0
PASS: Target 0 counter wraparound | expected=1 actual=1
PASS: done clears after completion | expected=0 actual=0
PASS: Reset clears done | expected=0 actual=0
PASS: Reset test started | expected=0 actual=0
PASS: Timer still counting | expected=0 actual=0
PASS: Reset cancels active timer | expected=0 actual=0
PASS: Timer stays idle after reset | expected=0 actual=0
PASS: Reset clears done | expected=0 actual=0
PASS: Held start keeps done low | expected=0 actual=0
PASS: Held start restarts counter | expected=0 actual=0
PASS: Held start timer completes after release | expected=1 actual=1
PASS: Reset clears done | expected=0 actual=0
PASS: Active timer before restart | expected=0 actual=0
PASS: Restart clears done | expected=0 actual=0
PASS: Restarted timer still counting | expected=0 actual=0
PASS: Restart with target 3 completes | expected=1 actual=1
PASS: Reset clears done | expected=0 actual=0
PASS: Changed target not reached yet | expected=0 actual=0
PASS: Changed target completes at 4 | expected=1 actual=1

```

TEST SUMMARY
====================================
PASS: 636
FAIL: 0
====================================
OVERALL RESULT: PASS
$finish called at time : 13411 ns 


## Conclusion

The generic timer module was verified using a self-checking testbench in Xilinx Vivado XSim with a 20 ns clock period. The testbench covered reset behavior, timer completion for different target values, counter wraparound, restart behavior, and changes to the target during counting. A total of 636 checks passed with 0 failures. The simulation completed successfully, and the recorded results indicate that the module passed the tested scenarios. The generic timer is ready for integration testing with the other traffic controller modules.


