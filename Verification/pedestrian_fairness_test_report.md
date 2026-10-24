# Pedestrian Fairness Verification Report

## Module
`shared_pedestrian_arbiter` *(confirm the exact module name used in the testbench)*

## Testbench
`pedestrian_fairness_120_tb` *(based on the simulation design snapshot name)*

## Simulation Environment
- Simulator: Xilinx Vivado XSim
- Verification type: Fairness verification using a testbench
- Test scenario: 120 pedestrian requests
- Simulation runtime command: `run 100us`
- Simulation completion time: 7260 ns

## Test Coverage
- Handling pedestrian requests from Junction A
- Handling pedestrian requests from Junction B
- Fair allocation of grants between both junctions
- Verification of grant counts after 120 requests
- Checking for equal grant distribution
- Automatic PASS/FAIL reporting for the fairness test

## Initial Results
- Simulation completion: PASS
- Junction A grant count: PASS — 60 grants
- Junction B grant count: PASS — 60 grants
- Equal grant distribution: PASS
- 120-request fairness test: PASS

*Compilation and elaboration should be marked PASS only if confirmed in the Vivado logs.*

## Final Result

```text
------------------------------------
 PEDESTRIAN FAIRNESS TEST: 120
------------------------------------
INFO: [USF-XSim-96] XSim completed.
Design snapshot 'pedestrian_fairness_120_tb_behav' loaded.
INFO: [USF-XSim-97] XSim simulation ran for 1000ns
launch_simulation: Time (s): cpu = 00:00:06 ; elapsed = 00:00:17
run 100us

Junction A grants: 60
Junction B grants: 60

PASS: 120-request fairness test

$finish called at time : 7260 ns
```

## Conclusion

The pedestrian fairness test was executed using Xilinx Vivado XSim to evaluate the distribution of pedestrian grants between Junction A and Junction B. The test processed 120 requests and reported 60 grants for Junction A and 60 grants for Junction B.

The equal distribution demonstrates that the arbiter achieved balanced grant allocation in this test scenario. The testbench reported `PASS: 120-request fairness test`, and the simulation terminated successfully at 7260 ns.

The module passed the implemented fairness test scenario and is ready for inclusion in the automated regression suite for the Adaptive Multi-Junction Traffic Grid Controller. This result confirms equal grant counts for the tested sequence; broader fairness guarantees depend on the request patterns and conditions covered by the testbench.
