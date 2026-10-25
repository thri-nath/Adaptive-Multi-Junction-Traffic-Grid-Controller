
# Adaptive Multi-Junction Traffic Grid Controller

## About the Project

The **Adaptive Multi-Junction Traffic Grid Controller** is a Verilog HDL project designed to control and coordinate traffic signals at multiple junctions. It combines normal traffic-light sequencing with traffic-density adaptation, green-wave coordination, pedestrian request handling, and emergency vehicle priority.

The design is developed and simulated using **Xilinx Vivado** and **XSim**. Self-checking Verilog testbenches are used to verify expected behavior, while simulation waveforms help inspect signal transitions and timing.

## Project Objectives

- Control traffic signals at two 4-way junctions: Junction A and Junction B.
- Use traffic sensor inputs and density values to adapt signal timing.
- Coordinate traffic signals using a green-wave delay mechanism.
- Handle pedestrian requests and competing pedestrian demands.
- Give priority to emergency conditions.
- Synchronize external inputs and manage reset behavior.
- Verify the design using self-checking testbenches.

## System Architecture

The system is divided into smaller Verilog modules. Each module handles a specific function, making the design easier to test, debug, and maintain.

| Module | Purpose |
|---|---|
| `junction_fsm` | Controls traffic-light states and sequencing at a junction. |
| `traffic_system_top` | Connects the modules to form the complete traffic-control system. |
| `green_wave_delay` | Provides delay logic for coordinating signal timing between junctions. |
| `shared_pedestrian_arbiter` | Manages competing pedestrian requests. |
| `emergency_controller` | Handles emergency traffic conditions. |
| `input_sync` | Synchronizes external inputs to the design clock domain. |
| `reset_sync` | Handles reset synchronization. |
| `generic_timer` | Provides timing support for the controller. |

## Traffic-Light Encoding

The current `junction_fsm` implementation uses the following encoding:

| Signal | Encoding |
|---|---|
| Red | `3'b001` |
| Yellow | `3'b010` |
| Green | `3'b100` |

These encodings should be checked against the RTL if the implementation changes.

## Repository Structure

```text
Adaptive-Multi-Junction-Traffic-Grid-Controller/
├── Regression/
├── Verification/
├── Waveforms/
├── docs/
├── rtl/
├── tb_Self/
└── README.md
```

### Folder Descriptions

#### `rtl/` — RTL Source Code

Contains the Verilog HDL modules that implement the traffic controller, including junction control, green-wave coordination, pedestrian arbitration, emergency handling, synchronization, and timing logic.

#### `tb_Self/` — Self-Checking Testbenches

Contains Verilog testbenches that automatically check expected outputs and behavior for individual modules and the integrated system.

#### `Verification/` — Verification Evidence

Organizes verification reports and supporting evidence for tested requirements, such as reset operation, emergency handling, pedestrian arbitration, and green-wave behavior.

#### `Regression/` — Regression Testing

Organizes regression-related files and test summaries used to check multiple testbenches after RTL changes.

#### `Waveforms/` — Simulation Waveforms

Stores waveform files or screenshots used to inspect traffic-light transitions, reset behavior, emergency operation, and timing relationships.

#### `docs/` — Documentation

Contains supporting project documents, such as architecture diagrams, progress reports, verification documentation, and the technical report.

#### `README.md` — Project Overview

Provides the project introduction, objectives, architecture, repository structure, verification status, and simulation instructions.

> Folder descriptions are based on the current repository layout. Check the contents of each folder for the latest files and artifacts.

## Verification

The project uses self-checking Verilog testbenches in Xilinx Vivado XSim. The tests check expected behavior instead of relying only on visual waveform inspection.

Verification scenarios include:

- Normal traffic-light sequencing.
- Reset behavior and reset during operation.
- Green-wave delay operation.
- Traffic-density-dependent signal timing.
- Pedestrian request handling and arbitration.
- Emergency activation and recovery.
- Timer operation, clearing, cancellation, and restart.
- Integrated top-level system behavior.

### Latest Recorded Regression Results

The latest regression run recorded during development reported the following:

| Metric | Result |
|---|---:|
| Testbenches executed | 13 |
| Passed | 13 |
| Failed | 0 |
| Needs review | 0 |

The top-level self-checking testbench also reported **37 checks with 0 errors** in a separate run.

These results apply only to the scenarios covered by the tests. Passing testbenches does not automatically prove that every project requirement has been satisfied.

**Green-wave timing:** The required start-time offset between Junction A and Junction B must be checked against the specification and measured simulation timestamps before full timing compliance is claimed.

Re-run regression after RTL changes and update this section using the latest actual results.

## Tools Used

- Verilog HDL
- Xilinx Vivado
- XSim simulator
- Git and GitHub
- Draw.io for architecture diagrams

## How to Run a Simulation

1. Open Xilinx Vivado.
2. Open the existing project or create a simulation project.
3. Add the required Verilog source files from `rtl/`.
4. Add the appropriate self-checking testbench from `tb_Self/`.
5. Set the selected testbench as the simulation top module.
6. Ensure that all required dependent RTL modules are included.
7. Run **Behavioral Simulation** using XSim.
8. Check the simulation transcript for `PASS`, `FAIL`, and error messages.
9. Open the waveform viewer when you need to inspect signal transitions or timing.

The required testbench and module dependencies depend on the scenario being tested.

## Regression Testing

The `Regression/` folder is used to organize regression-related files and results.

After running a regression:

1. Confirm that all expected testbenches were executed.
2. Review the summary for passed, failed, and review-required tests.
3. Investigate any failures or timing mismatches.
4. Save useful logs, summaries, and waveforms in the appropriate folders.
5. Update the verification results in this README only after checking the latest output.

If a regression script is available, follow its instructions and run it from the appropriate project directory.

## Project Status

The main RTL modules and top-level design have been developed, and self-checking verification has been performed for multiple individual modules and integrated scenarios.

The latest recorded regression run passed all 13 listed tests, with zero failures and zero tests requiring review.

Further work focuses on checking specification compliance, expanding corner-case coverage, organizing verification evidence, and repeating regression after design changes. The green-wave timing requirement should be verified explicitly against the required offset and measured simulation results.

## Future Work

- Expand corner-case and boundary-condition testing.
- Improve traffic-density and emergency-scenario coverage.
- Verify the green-wave offset quantitatively against the specification.
- Keep regression runs reproducible.
- Organize logs, reports, and representative waveforms.
- Update documentation whenever the design or verification results change.


## Simulation Guide

For detailed instructions on setting up Vivado, adding RTL modules and testbenches, running XSim simulations, inspecting waveforms, and troubleshooting common errors, see the [Simulation Guide](docs/simulation_guide.md).


## GitHub Repository

Source code, testbenches, verification evidence, waveforms, and documentation are available here:

[Adaptive Multi-Junction Traffic Grid Controller](https://github.com/thri-nath/Adaptive-Multi-Junction-Traffic-Grid-Controller)
