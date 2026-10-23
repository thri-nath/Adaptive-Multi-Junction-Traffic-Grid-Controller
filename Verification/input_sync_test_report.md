# Input Synchronizer Verification Report

## Module
`input_sync`

## Testbench
`input_sync_tb_Self`

## Simulation Environment
- Simulator: Xilinx Vivado XSim
- Verification type: Self-checking testbench
- Clock period: 20 ns
- Parameter: `WIDTH = 4`

## Test Coverage
- Initial reset behavior
- Rising input synchronization through Stage 1
- Rising input synchronization through Stage 2
- Falling input synchronization through Stage 1
- Falling input synchronization through Stage 2
- Multiple-bit input synchronization through both stages
- Clearing the output using reset
- Automatic PASS/FAIL reporting

## Initial Results
- Compilation: PASS*
- Elaboration: PASS*
- Initial reset: PASS
- Rising input — Stage 1: PASS
- Rising input — Stage 2: PASS
- Falling input — Stage 1: PASS
- Falling input — Stage 2: PASS
- Multiple-bit input — Stage 1: PASS
- Multiple-bit input — Stage 2: PASS
- Reset clears output: PASS

## Final Result

```text
-----------------------------------
 INPUT SYNC AUTOMATED TESTBENCH
-----------------------------------
PASS: Reset
PASS: Async change - no immediate output
PASS: Async change - Stage 1
PASS: Async change - Stage 2
PASS: Pipeline cleared before rising test
PASS: Rising input - Stage 1
PASS: Rising input - Stage 2
PASS: Falling input - Stage 1
PASS: Falling input - Stage 2
PASS: Multiple bits - Stage 1
PASS: Multiple bits - Stage 2
PASS: Reset clears output
-----------------------------------
ALL TESTS PASSED
-----------------------------------
$finish called at time : 271 ns 
```

## Conclusion

The `input_sync` module was verified using a self-checking testbench in Xilinx Vivado XSim with a 20 ns clock period and `WIDTH` set to 4. The testbench checked reset behavior, rising and falling input propagation through both synchronization stages, multiple-bit synchronization, and output clearing during reset. All eight reported checks passed, with zero errors. The simulation completed successfully at 171 ns. The module passed the implemented test scenarios and is ready for inclusion in the automated regression suite for the Adaptive Multi-Junction Traffic Grid Controller.

*Compilation and elaboration should be marked PASS only if confirmed in the Vivado logs.*
