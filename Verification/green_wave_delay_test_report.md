# Green Wave Delay Verification Report

## Module
`green_wave_delay`

## Testbench
`green_wave_delay_tb`

## Simulation Environment
- Simulator: Xilinx Vivado XSim
- Verification type: Self-checking testbench
- Clock period: 20 ns
- Parameter: `HOLD_CYCLES = 8`

## Test Coverage
- Initial reset behavior
- Normal green-wave delay operation
- Output assertion after the configured delay
- Clearing the output after completion
- Clearing during an active delay
- Cancellation of a pending output pulse
- Restarting the delay after clearing
- Automatic PASS/FAIL reporting

## Initial Results
- Compilation: PASS*
- Elaboration: PASS*
- Initial reset: PASS
- Normal delay: PASS
- Clear output: PASS
- Clear during active delay: PASS
- Cancellation of pending output: PASS
- Restart after clear: PASS

## Final Result

```text
-----------------------------------
 GREEN WAVE DELAY TESTBENCH
-----------------------------------
PASS: Reset
TEST 2: Normal delay
PASS: Output detected at cycle 9
TEST 3: Clear output
PASS: Clear resets output
TEST 4: Clear during delay
PASS: Clear cancels pending output
TEST 5: Restart after clear
PASS: Output detected at cycle 9
-----------------------------------
ALL TESTS PASSED
-----------------------------------
$finish called at time : 791 ns
```

## Conclusion

The `green_wave_delay` module was verified using a self-checking testbench in Xilinx Vivado XSim with a 20 ns clock period and `HOLD_CYCLES` set to 8. The testbench checked reset behavior, normal delay operation, output clearing, cancellation of an active delay, and restarting after clearing. All reported checks passed, with no failures. The output was detected at cycle 9 for both normal operation and restart testing. The module passed the implemented test scenarios and is ready for further integration testing with the traffic controller system.

*Compilation and elaboration should be marked PASS only if confirmed in the Vivado logs.*
