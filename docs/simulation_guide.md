## Simulation Guide

This guide explains how to simulate the Adaptive Multi-Junction Traffic Grid Controller using Xilinx Vivado and XSim.

### 1. Requirements

- Xilinx Vivado installed
- Git installed
- Windows PowerShell (for the regression script)

### 2. Clone the Repository

Open PowerShell and run:

```powershell
git clone https://github.com/thri-nath/Adaptive-Multi-Junction-Traffic-Grid-Controller.git
cd Adaptive-Multi-Junction-Traffic-Grid-Controller
```

### 3. Project Structure

```text
Adaptive-Multi-Junction-Traffic-Grid-Controller/
├── rtl/          # Verilog design modules
├── tb_Self/      # Self-checking testbenches
├── Verification/ # Verification reports
├── Regression/   # Regression scripts and results
├── Waveforms/    # Simulation waveform artifacts
├── docs/         # Documentation
└── README.md
```

### 4. Run a Simulation in Vivado

1. Open Vivado and create a new RTL project, or open your existing project.
2. Add all required Verilog design files from the `rtl/` directory under **Design Sources**.
3. Add the desired testbench from `tb_Self/` under **Simulation Sources**.
4. Set the testbench module as the simulation top.
5. Click **Run Simulation → Run Behavioral Simulation**.
6. Inspect the waveform and simulation console for results.

### 5. Run the Regression Tests

Open PowerShell in the repository root and run the regression script:

```powershell
powershell -ExecutionPolicy Bypass -File ".\Regression\run_regression.ps1"
```

If the script requires a project-root argument, use the parameter supported by the script:

```powershell
powershell -ExecutionPolicy Bypass -File ".\Regression\run_regression.ps1" -ProjectRoot (Get-Location).Path
```

Check the script's output and generated reports for each test's PASS or FAIL status.

### 6. Features to Verify

- North-South and East-West signal sequencing at both junctions
- Green-wave coordination between Junction A and Junction B
- Traffic-density-based green-light duration
- Pedestrian request handling and fairness
- Emergency vehicle priority
- Safe reset behavior
- Input synchronization

**Important:** A test passing because Junction B eventually turns green does not, by itself, prove that the green-wave offset is correct. Verify the measured start-cycle difference against the required offset.

### 7. Troubleshooting

- **Module not found:** Ensure all required RTL files are included in the Vivado project.
- **Testbench not found:** Add the testbench under Simulation Sources and set it as the simulation top.
- **Script not recognized:** Run the command from the repository root and verify the script path.
- **Absolute-path errors:** Check that scripts use repository-relative paths or a configurable project-root parameter.
- **Simulation fails:** Review the Vivado Tcl console and generated regression logs.

### 8. Expected Results

A successful test should complete compilation, elaboration, and simulation and report its expected PASS result. A regression is considered successful only when all required tests complete and their checks pass.
