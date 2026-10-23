# Adaptive Multi-Junction Traffic Grid Controller

## About the Project

This project is about designing a traffic signal controller for multiple junctions using Verilog HDL. The main idea is to control traffic signals based on traffic conditions and coordinate signals between junctions.

Along with normal traffic control, the design includes features such as pedestrian request handling, emergency vehicle support, and green-wave coordination. I am developing and testing the modules using Xilinx Vivado and its XSim simulator.

## Project Objectives

- Control traffic lights at multiple junctions.
- Use traffic sensor inputs and traffic density values for signal control.
- Coordinate signals between junctions using green-wave delay.
- Handle pedestrian requests and manage shared pedestrian access.
- Give priority to emergency conditions.
- Verify the design using self-checking testbenches.

## Design Overview

The design is divided into smaller Verilog modules. Each module handles a particular function, which makes testing and debugging easier.

The main components are:

| Module | Purpose |
|---|---|
| `junction_fsm` | Controls the traffic light states at a junction. |
| `traffic_system_top` | Connects the main modules to form the complete system. |
| `green_wave_delay` | Adds a delay for coordinating traffic signals between junctions. |
| `shared_pedestrian_arbiter` | Manages competing pedestrian requests. |
| `emergency_controller` | Handles emergency traffic conditions. |
| `input_sync` | Synchronizes external input signals. |
| `reset_sync` | Handles reset synchronization. |
| Timer module | Provides timing support for the traffic controller. |

## Traffic Light States

The traffic light outputs use the following encoding in the current `junction_fsm` implementation:

| Signal | Encoding |
|---|---|
| Red | `3'b001` |
| Yellow | `3'b010` |
| Green | `3'b100` |

## Verification

I am verifying the design using self-checking Verilog testbenches in Xilinx Vivado XSim. The testbenches check the expected outputs for different input conditions instead of relying only on visual waveform inspection.

The verification work includes:

- Reset behavior.
- Normal traffic signal operation.
- Green-wave coordination between junctions.
- Pedestrian request handling.
- Simultaneous pedestrian requests and arbitration.
- Emergency activation and recovery.
- Changes in traffic density.
- Reset during operation.
- Delay operation, clearing, cancellation, and restart.

### Current Verification Results

The top-level self-checking testbench completed **37 checks with 0 errors** across the tested scenarios.

The `green_wave_delay` testbench also passed its tested cases, including normal delay operation, output clearing, cancellation of a pending delay, and restarting after clearing.

These results apply to the scenarios covered by the current testbenches. Further testing and automated regression are planned as the project develops.

## Tools Used

- Verilog HDL
- Xilinx Vivado
- XSim simulator
- Git and GitHub
- Draw.io for the architecture diagram



## How to Run the Simulation

1. Open Xilinx Vivado.
2. Create or open a simulation project.
3. Add the required Verilog files from the `rtl` folder.
4. Add the required self-checking testbench from `tb_Self`.
5. Set the testbench as the simulation top module.
6. Run Behavioral Simulation using XSim.
7. Check the simulation transcript for PASS messages and errors.
8. Open the waveform to inspect the signal transitions when needed.

Make sure all module dependencies are added before running the simulation.

## Project Status

The main RTL modules and the top-level design have been developed, and self-checking verification has been completed for several individual modules and the integrated system.

The current focus is on improving verification coverage, keeping the test reports and waveforms organized, and working towards automated regression testing so that the existing tests can be rerun whenever the RTL changes.

## Future Work

- Add more corner-case tests.
- Improve coverage of traffic and emergency scenarios.
- Automate the execution of testbenches.
- Run regression tests after RTL changes.
- Continue documenting simulation results and fixing any issues found.

## GitHub Repository

Source code, testbenches, reports, and other project files are available here:

[Adaptive Multi-Junction Traffic Grid Controller](https://github.com/thri-nath/Adaptive-Multi-Junction-Traffic-Grid-Controller)

