
param(
   [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),
    [string]$RtlDir = "ATC.srcs\sources_1\new",
    [string]$TbDir = "ATC.srcs\sim_2\new",
    [string]$ResultsDir = "regression_results"
)

$ErrorActionPreference = "Stop"

# ==================================================
# PATHS
# ==================================================
$rtlPath = Join-Path $ProjectRoot $RtlDir
$tbPath = Join-Path $ProjectRoot $TbDir
$outPath = Join-Path $ProjectRoot $ResultsDir
$buildPath = Join-Path $outPath "build"

# ==================================================
# EXPECTED TESTBENCH FILES
# ==================================================
$expectedTests = @(
    "emergency_all_phases_tb.v",
    "emergency_controller_tb_Self.v",
    "generic_timer_tb_Self.v",
    "green_wave_delay_tb_Self.v",
    "green_wave_density_tb.v",
    "input_sync_tb_Self.v",
    "junction_fsm_tb_Self.v",
    "junctionb_FSM_tb_Self.v",
    "pedestrian_fairness_120_tb.v",
    "reset_during_operation_tb.v",
    "reset_sync_tb_Self.v",
    "shared_pedestrian_arbiter_tb_Self.v",
    "traffic_system_top_tb_Self.v"
)

# ==================================================
# CHECK VIVADO TOOLS AND DIRECTORIES
# ==================================================
foreach ($tool in @("xvlog", "xelab", "xsim")) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        throw "$tool not found. Add the Vivado bin directory to PATH."
    }
}

if (-not (Test-Path $rtlPath)) {
    throw "RTL directory not found: $rtlPath"
}

if (-not (Test-Path $tbPath)) {
    throw "Testbench directory not found: $tbPath"
}

# ==================================================
# DISCOVER SOURCE FILES
# ==================================================
$rtlFiles = @(
    Get-ChildItem $rtlPath -Recurse -File |
        Where-Object { $_.Extension -in @(".v", ".sv") }
)

$allTbFiles = @(
    Get-ChildItem $tbPath -Recurse -File |
        Where-Object { $_.Extension -in @(".v", ".sv") }
)

if ($rtlFiles.Count -eq 0) {
    throw "No RTL Verilog files found."
}

if ($allTbFiles.Count -eq 0) {
    throw "No testbench Verilog files found."
}

$tbFiles = @()

foreach ($name in $expectedTests) {
    $foundFiles = @(
        $allTbFiles | Where-Object { $_.Name -eq $name }
    )

    if ($foundFiles.Count -eq 1) {
        $tbFiles += $foundFiles[0]
    }
    elseif ($foundFiles.Count -eq 0) {
        Write-Warning "Testbench missing: $name"
    }
    else {
        Write-Warning "Duplicate testbench filename: $name"
    }
}

# ==================================================
# PREPARE RESULTS
# ==================================================
New-Item -ItemType Directory -Force -Path $outPath |
    Out-Null

New-Item -ItemType Directory -Force -Path $buildPath |
    Out-Null

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$summaryPath = Join-Path $outPath "summary_$timestamp.csv"
$results = @()

# ==================================================
# RUN REGRESSION
# ==================================================
foreach ($tb in $tbFiles) {

    $testName = [IO.Path]::GetFileNameWithoutExtension($tb.Name)
    $testBuild = Join-Path $buildPath $testName
    $log = Join-Path $outPath "$testName.log"
    $snapshot = "sim_$testName"

    Write-Host "`n========================================"
    Write-Host "TEST: $($tb.Name)"
    Write-Host "========================================"

    $status = "FAIL"
    $details = ""
    $top = ""

    # Detect testbench top module.
    $source = Get-Content -LiteralPath $tb.FullName -Raw

    $moduleMatches = [regex]::Matches(
        $source,
        '(?m)^\s*module\s+(?:automatic\s+|static\s+)?([A-Za-z_]\w*)'
    )

    if ($moduleMatches.Count -ne 1) {
        $details = "Expected one module declaration; found $($moduleMatches.Count)."

        $results += [PSCustomObject]@{
            Test       = $tb.Name
            TopModule  = ""
            Status     = "FAIL"
            Details    = $details
            Log        = $log
        }

        Write-Host "RESULT: FAIL - $details"
        continue
    }

    $top = $moduleMatches[0].Groups[1].Value

    if (Test-Path $testBuild) {
        Remove-Item $testBuild -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $testBuild |
        Out-Null

    @(
        "Testbench: $($tb.Name)"
        "Top module: $top"
        "Started: $(Get-Date)"
        ""
    ) | Set-Content -LiteralPath $log

    Push-Location $testBuild

    try {
        # ------------------------------------------
        # COMPILE
        # ------------------------------------------
        Write-Host "Compiling..."

        $sources = @(
            $rtlFiles | ForEach-Object { $_.FullName }
        ) + @($tb.FullName)

        $compileOutput = & xvlog -sv $sources 2>&1
        $compileCode = $LASTEXITCODE

        $compileText = ($compileOutput | Out-String)
        $compileText | Out-File -LiteralPath $log -Append -Encoding utf8

        if ($compileCode -ne 0) {
            throw "Compilation failed (exit code $compileCode)."
        }

        # ------------------------------------------
        # ELABORATE
        # ------------------------------------------
        Write-Host "Elaborating $top..."

        $elabOutput = & xelab $top -s $snapshot 2>&1
        $elabCode = $LASTEXITCODE

        $elabText = ($elabOutput | Out-String)
        $elabText | Out-File -LiteralPath $log -Append -Encoding utf8

        if ($elabCode -ne 0) {
            throw "Elaboration failed (exit code $elabCode)."
        }

# ------------------------------------------
# SIMULATE UNTIL TESTBENCH FINISHES
# ------------------------------------------
Write-Host "Simulating until testbench finishes..."

$simOutput = & xsim $snapshot -runall 2>&1
$simCode = $LASTEXITCODE

$simText = ($simOutput | Out-String)
$simText | Out-File -LiteralPath $log -Append -Encoding utf8

if ($simCode -ne 0) {
    throw "Simulation failed (exit code $simCode)."
}


        # ------------------------------------------
        # CHECK TESTBENCH RESULTS
        # ------------------------------------------
        # Check the simulator output and the complete log.
        # This supports markers emitted during simulation
        # as well as markers written to the log.


$allOutput = [System.IO.File]::ReadAllText($log)
$combinedOutput = $allOutput + "`n" + $simText

# Recognize explicit final PASS/FAIL markers.
$hasFinalPass = [regex]::IsMatch(
    $combinedOutput,
    '(?im)^\s*(?:REGRESSION RESULT|OVERALL RESULT|GREEN-WAVE DENSITY TEST)\s*:\s*PASS\s*$'
) -or [regex]::IsMatch(
    $combinedOutput,
    '(?im)^\s*ALL TESTS PASSED\s*$'
)

$hasFinalFail = [regex]::IsMatch(
    $combinedOutput,
    '(?im)^\s*(?:REGRESSION RESULT|OVERALL RESULT|GREEN-WAVE DENSITY TEST)\s*:\s*FAIL\s*$'
) -or [regex]::IsMatch(
    $combinedOutput,
    '(?im)^\s*TESTS FAILED\s*$'
)


# Check numeric failure/error summaries safely.
$failureCountMatches = [regex]::Matches(
    $combinedOutput,
    '(?im)^\s*(?:TOTAL FAIL|FAIL)\s*:\s*(\d+)\s*$'
)

$errorCountMatches = [regex]::Matches(
    $combinedOutput,
    '(?im)^\s*(?:TOTAL ERRORS|Total errors|ERRORS)\s*:\s*(\d+)\s*$'
)

$hasNonZeroFailures = $false
foreach ($match in $failureCountMatches) {
    if ([int]$match.Groups[1].Value -gt 0) {
        $hasNonZeroFailures = $true
    }
}

$hasNonZeroErrors = $false
foreach ($match in $errorCountMatches) {
    if ([int]$match.Groups[1].Value -gt 0) {
        $hasNonZeroErrors = $true
    }
}




$hasFatal = [regex]::IsMatch(
    $combinedOutput,
    '(?im)^\s*\$fatal\b|FATAL:'
)

if ($hasFinalFail -or $hasNonZeroFailures -or
    $hasNonZeroErrors -or $hasFatal) {
    throw "Testbench reported a failure, fatal error, or nonzero error count."
}
elseif ($hasFinalPass) {
    $status = "PASS"
    $details = "Compile, elaboration and simulation completed; recognized explicit PASS result."
}
elseif ([regex]::IsMatch($combinedOutput, '(?im)^\s*PASS\s*:')) {
    $status = "REVIEW"
    $details = "Individual checks passed, but no recognized final PASS result was found."
}
else {
    $status = "INCONCLUSIVE"
    $details = "No recognized final PASS/FAIL result was found."
}
}
    catch {
        $status = "FAIL"
        $details = $_.Exception.Message

        Add-Content -LiteralPath $log `
            "`nREGRESSION SCRIPT ERROR: $details"
    }
    finally {
        Pop-Location
    }

    $results += [PSCustomObject]@{
        Test       = $tb.Name
        TopModule  = $top
        Status     = $status
        Details    = $details
        Log        = $log
    }

    Write-Host "RESULT: $status - $details"
}

# ==================================================
# REPORT MISSING TESTS
# ==================================================
foreach ($name in $expectedTests) {
    $foundCount = @(
        $tbFiles | Where-Object { $_.Name -eq $name }
    ).Count

    if ($foundCount -eq 0) {
        $results += [PSCustomObject]@{
            Test       = $name
            TopModule  = ""
            Status     = "FAIL"
            Details    = "Expected testbench file missing."
            Log        = ""
        }
    }
}

# ==================================================
# SAVE SUMMARY
# ==================================================
$results | Export-Csv -LiteralPath $summaryPath -NoTypeInformation

$passed = @(
    $results | Where-Object { $_.Status -eq "PASS" }
).Count

$failed = @(
    $results | Where-Object { $_.Status -eq "FAIL" }
).Count

$review = @(
    $results | Where-Object {
        $_.Status -in @("REVIEW", "INCONCLUSIVE")
    }
).Count

Write-Host "`n========================================"
Write-Host "         REGRESSION SUMMARY"
Write-Host "========================================"

$results |
    Format-Table Test, TopModule, Status, Details -AutoSize

Write-Host "Total tests : $($results.Count)"
Write-Host "Passed      : $passed"
Write-Host "Failed      : $failed"
Write-Host "Needs review: $review"
Write-Host "Summary CSV : $summaryPath"
Write-Host "Logs folder : $outPath"

if ($failed -gt 0 -or $review -gt 0) {
    exit 1
}

exit 0
