# Green-Wave Density Verification Report

## Module
`traffic_system_top`

## Testbench
`green_wave_density_tb`

## Simulation Environment
- Simulator: Xilinx Vivado XSim
- Verification type: Self-checking testbench
- Test scenario: Traffic-density-based green duration and green-wave coordination
- Density input width: 3 bits
- Simulation runtime command: `run 7us`
- Simulation completion time: 3371 ns

## Test Coverage
- Verification of North-South green duration under different traffic-density conditions
- Testing five combinations of Junction A and Junction B traffic densities
- Verification that green duration adapts to the traffic-density input
- Comparison of expected and measured green duration
- Verification of green-wave coordination by observing Junction B's North-South green phase
- Checking green duration against the testbench's allowed tolerance
- Automatic PASS/FAIL reporting and error counting

## Initial Results

| Test | A NS Density | B NS Density | Expected Green Duration | Measured Duration | Result |
|---|---:|---:|---:|---:|---|
| 1 | 0 | 0 | 10 cycles | 12 cycles | PASS |
| 2 | 1 | 2 | 14 cycles | 16 cycles | PASS |
| 3 | 2 | 1 | 18 cycles | 20 cycles | PASS |
| 4 | 4 | 3 | 26 cycles | 28 cycles | PASS |
| 5 | 7 | 5 | 30 cycles | 32 cycles | PASS |

- Density duration checks passed: 5/5
- Total errors: 0
- Junction B North-South green observed in all five tests: PASS
- Overall test result: PASS

## Final Result

```text
========================================
 GREEN-WAVE DENSITY SELF-CHECKING TEST
========================================

Density test 1
A NS density = 0
B NS density = 0
Expected A green duration = 10 cycles
Measured A NS green = 12 cycles
PASS: A green duration is within tolerance
INFO: Junction B NS green observed

Density test 2
A NS density = 1
B NS density = 2
Expected A green duration = 14 cycles
Measured A NS green = 16 cycles
PASS: A green duration is within tolerance
INFO: Junction B NS green observed

Density test 3
A NS density = 2
B NS density = 1
Expected A green duration = 18 cycles
Measured A NS green = 20 cycles
PASS: A green duration is within tolerance
INFO: Junction B NS green observed

Density test 4
A NS density = 4
B NS density = 3
Expected A green duration = 26 cycles
Measured A NS green = 28 cycles
PASS: A green duration is within tolerance
INFO: Junction B NS green observed

Density test 5
A NS density = 7
B NS density = 5
Expected A green duration = 30 cycles
Measured A NS green = 32 cycles
PASS: A green duration is within tolerance
INFO: Junction B NS green observed

========================================
Density duration checks passed: 5/5
Total errors: 0
GREEN-WAVE DENSITY TEST: PASS
========================================

$finish called at time : 3371 ns
```

## Conclusion

The `traffic_system_top` module was tested using the `green_wave_density_tb` self-checking testbench in Xilinx Vivado XSim. Five traffic-density combinations were evaluated to verify adaptive North-South green durations at Junction A and observe green-wave progression at Junction B.

The expected green durations ranged from 10 to 30 cycles, while the measured durations ranged from 12 to 32 cycles. All five measurements passed the testbench's tolerance checks, and Junction B's North-South green phase was observed in every test.

The simulation reported **5 out of 5 density-duration checks passed, with zero errors**. The overall result was `GREEN-WAVE DENSITY TEST: PASS`, and the simulation completed at 3371 ns.

The tested density-adaptation scenarios passed and are ready for inclusion in the automated regression suite for the Adaptive Multi-Junction Traffic Grid Controller.

*Verification note:* The reported results establish that the measured durations satisfy the testbench's tolerance. Green-wave timing accuracy, including the required offset between Junction A and Junction B, should be verified separately against the project's specified coordination window if it is not already checked by this testbench.
