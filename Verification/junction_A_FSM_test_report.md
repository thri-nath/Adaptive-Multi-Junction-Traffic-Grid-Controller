# Junction FSM Verification Report

## Module
`junction_fsm`

## Testbench
`junction_fsm_tb_Self`

## Simulation Environment
- Simulator: Xilinx Vivado XSim
- Verification type: Self-checking testbench
- Clock period: 20 ns
- Simulation completion time: 2240 ns
- Green extension parameter: 2
- Minimum green time: 5 cycles
- Maximum green time: 10 cycles
- Yellow time: 2 cycles
- All-red time: 2 cycles
- Pedestrian time: 3 cycles
- Synchronization timeout: 8 cycles
- Operating mode: Master (`IS_MASTER = 1`)

## Test Coverage
- Initial reset behavior
- Traffic-light output initialization
- North-South green and yellow sequencing
- East-West green and yellow sequencing
- All-red intervals between traffic directions
- Traffic-density-based green timing
- Maximum green-time clamping
- Complete traffic-light cycle
- Green-wave output pulse
- Master-mode synchronization behavior
- Pedestrian request and grant handling
- Pedestrian walk output
- Pedestrian completion and traffic resumption
- Emergency activation and state transition
- Emergency-state traffic-light outputs
- Pedestrian output clearing during emergency
- Emergency release and recovery
- Reset during operation
- Simultaneous green-light safety check
- Unknown traffic-light output monitoring

## Verification Results

- Initial reset and all-red state: PASS
- Traffic-light output initialization: PASS
- NS green operation: PASS
- NS green-time clamping: PASS
- NS yellow transition: PASS
- All-red transition before EW green: PASS
- EW green operation: PASS
- EW density-based green timing: PASS
- EW yellow transition: PASS
- All-red transition before NS green: PASS
- Complete traffic-light cycle: PASS
- Green-wave output pulse: PASS
- Master-mode synchronization behavior: PASS
- Pedestrian request and grant: PASS
- Pedestrian walk output: PASS
- Pedestrian completion: PASS
- Traffic resumption after pedestrian service: PASS
- Emergency transition to yellow: PASS
- Emergency-state entry: PASS
- All-red outputs during emergency: PASS
- Pedestrian walk cleared during emergency: PASS
- Recovery after emergency release: PASS
- Reset during operation: PASS
- Traffic-light safety monitoring: PASS

## Final Result

```text
============================================
 JUNCTION FSM SELF-CHECKING REGRESSION
============================================

TEST 1: Reset
PASS: Reset selects initial all-red state
PASS: Reset sets both lights to red
PASS: Reset clears pedestrian outputs
PASS: Reset clears green-wave output

TEST 2: Traffic sequencing and density
PASS: FSM enters NS green
PASS: NS green, EW red
PASS: NS green target is clamped to MAX_GREEN
PASS: NS green transitions to NS yellow
PASS: NS yellow, EW remains red
PASS: All-red between NS and EW
PASS: Both directions red during transition
PASS: FSM enters EW green
PASS: EW green, NS red
PASS: EW green target reflects traffic density
PASS: EW green transitions to EW yellow
PASS: EW yellow, NS remains red
PASS: All-red before returning to NS
PASS: Both directions red before NS resumes
PASS: FSM completes a full traffic cycle
PASS: Green-wave output pulse observed in master mode
PASS: Master does not wait for slave synchronization

TEST 3: Pedestrian service
PASS: Reset selects initial all-red state
PASS: Reset sets both lights to red
PASS: Reset clears pedestrian outputs
PASS: Reset clears green-wave output
PASS: Reach all-red before pedestrian decision
PASS: Granted pedestrian request enters PED state
PASS: Both vehicle directions red during pedestrian phase
PASS: Requested pedestrian crossing receives walk
PASS: Traffic resumes after pedestrian service

TEST 4: Emergency handling
PASS: Emergency causes NS green to turn yellow
PASS: FSM enters emergency state
PASS: Emergency state holds both directions red
PASS: Emergency state clears pedestrian walk
PASS: FSM returns to all-red after emergency

TEST 5: Reset during operation
PASS: Reach NS green before operational reset
PASS: Reset selects initial all-red state
PASS: Reset sets both lights to red
PASS: Reset clears pedestrian outputs
PASS: Reset clears green-wave output
PASS: Pedestrian output remains clear after reset

============================================
REGRESSION SUMMARY
Checks performed: 41
Errors detected : 0
RESULT: ALL CHECKS PASSED
============================================
$finish called at time : 2240 ns
```

## Test Summary

- Total checks performed: 41
- Failed checks: 0
- Reported errors: 0

**Overall Result: PASS**

## Conclusion

The `junction_fsm` module was verified using a self-checking testbench in Xilinx Vivado XSim with a 20 ns clock period. Verification covered reset behavior, normal traffic-light sequencing, all-red transitions, traffic-density-based green timing, maximum green-time clamping, pedestrian request handling, green-wave output, emergency handling, and recovery after reset and emergency release. The simulation completed at 2240 ns with 41 checks performed and zero reported errors. All implemented checks passed.

The results support the functional behavior of the module under the tested master-mode scenarios. Slave-mode synchronization, exhaustive traffic-density combinations, and additional emergency and pedestrian corner cases remain candidates for further verification before full system integration.
