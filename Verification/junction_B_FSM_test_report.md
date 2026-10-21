# Junction B FSM Verification Report

## Module
`junction_fsm`

## Testbench
`junctionb_FSM_tb_Self`

## Simulation Environment
- Simulator: Xilinx Vivado XSim
- Verification type: Self-checking regression testbench
- FSM configuration: Slave mode (`IS_MASTER = 0`)

## Test Coverage
- Initial reset behavior
- All-red state and vehicle signal outputs
- Pedestrian output clearing
- Green-wave synchronization wait
- Green-wave trigger and slave release
- Normal traffic sequencing from NS to EW
- Yellow transitions and all-red safety intervals
- Traffic-density-based green timing
- Maximum green-time clamping
- Synchronization recovery
- Pedestrian request servicing
- Pedestrian walk signal and completion pulse
- Emergency activation and release
- Density calculation
- Reset during operation
- Correct operation after reset

## Initial Results
- Reset and initial all-red state: PASS
- Green-wave synchronization: PASS
- Traffic sequencing and density handling: PASS
- Synchronization recovery: PASS
- Pedestrian service: PASS
- Emergency handling: PASS
- Density calculation: PASS
- Reset during operation: PASS
- Operation after reset: PASS

## Final Result

```text
============================================
 JUNCTION B FSM SELF-CHECKING REGRESSION
============================================

TEST 1: Reset
PASS: Reset selects initial all-red state
PASS: Reset sets both directions red
PASS: Reset clears pedestrian outputs
PASS: Reset clears green-wave output

TEST 2: Green-wave synchronization
PASS: Slave enters synchronization wait
PASS: Both directions red while waiting for synchronization
PASS: Green-wave trigger releases slave
PASS: NS green after synchronization trigger
PASS: Green-wave output pulse observed

TEST 3: Traffic sequencing and density
PASS: NS green transitions to yellow
PASS: NS yellow output is correct
PASS: All-red before EW green
PASS: All-red transition is safe
PASS: FSM enters EW green
PASS: EW green output is correct
PASS: EW maximum density is clamped to MAX_GREEN
PASS: EW green transitions to yellow
PASS: EW yellow output is correct
PASS: All-red before NS decision
PASS: Both directions red before synchronization

TEST 4: Synchronization recovery
PASS: Slave waits for next green-wave trigger
PASS: Slave returns to NS green

TEST 5: Pedestrian service
PASS: Reach EW green before pedestrian service
PASS: EW transitions to yellow
PASS: Reach all-red pedestrian decision
PASS: Granted request enters pedestrian state
PASS: Both vehicle directions red during pedestrian phase
PASS: Requested pedestrian crossing receives walk
PASS: Pedestrian completion pulse observed

TEST 6: Emergency handling
PASS: Traffic resumes after pedestrian phase
PASS: Emergency causes NS green to turn yellow
PASS: FSM enters emergency state
PASS: Emergency state holds both directions red
PASS: Emergency state clears pedestrian walk
PASS: Emergency release returns to all-red

TEST 7: Density calculation
PASS: Slave enters synchronization wait
PASS: NS green begins after trigger
PASS: NS density 2 selects green target 7

TEST 8: Reset during operation
PASS: Reset selects initial all-red state
PASS: Reset sets both directions red
PASS: Reset clears pedestrian outputs
PASS: Reset clears green-wave output
PASS: Pedestrian outputs cleared after operational reset

TEST 9: Operation after reset
PASS: Slave returns to synchronization wait
PASS: NS green resumes after reset
PASS: Post-reset density target clamps at MAX_GREEN

============================================
REGRESSION SUMMARY
Checks performed: 46
Errors detected : 0
RESULT: ALL CHECKS PASSED
============================================

$finish called at time : 2340 ns
```

## Test Summary

| Metric | Result |
|---|---:|
| Checks performed | 46 |
| Errors detected | 0 |
| Passed checks | 46 |
| Failed checks | 0 |
| Overall result | PASS |

## Conclusion

The `junctionb_fsm` module was verified in slave mode (`IS_MASTER = 0`) using a self-checking regression testbench in Xilinx Vivado XSim. Verification covered reset behavior, green-wave synchronization, traffic-light sequencing, density-based timing, pedestrian servicing, emergency handling, synchronization recovery, and reset during operation. A total of 46 checks were performed, with zero errors detected. The simulation completed successfully at 2340 ns, and all tested scenarios passed. These results support the module's functional behavior for the tested cases and provide a basis for integration and system-level regression testing.
