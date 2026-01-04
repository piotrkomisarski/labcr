# Claude Code Status Line - PowerShell with ANSI colors
# Receives JSON input via stdin

$ErrorActionPreference = 'SilentlyContinue'

# Read JSON input from stdin
$input_json = [Console]::In.ReadToEnd()
$data = $input_json | ConvertFrom-Json

# ANSI color codes (using [char]27 for PowerShell 5.1 compatibility)
$esc = [char]27
$orange = "$esc[38;5;208m"
$cyan = "$esc[36m"
$green = "$esc[32m"
$yellow = "$esc[33m"
$red = "$esc[31m"
$reset = "$esc[0m"

# Extract data
$model_name = $data.model.display_name
$current_dir = Split-Path -Leaf $data.workspace.current_dir

# Calculate context percentage
$context_pct = 0
if ($null -ne $data.context_window.current_usage) {
    $current_tokens = $data.context_window.current_usage.input_tokens +
                      $data.context_window.current_usage.cache_creation_input_tokens +
                      $data.context_window.current_usage.cache_read_input_tokens
    $total_tokens = $data.context_window.context_window_size
    if ($total_tokens -gt 0) {
        $context_pct = [math]::Floor(($current_tokens * 100) / $total_tokens)
    }
}

# Get git branch name
$git_branch = ""
try {
    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    if ($branch) {
        $git_branch = "${green}$branch${reset}"
    }
} catch {}

# Get git status (modified and new files count)
$git_status = ""
try {
    $git_output = git status --porcelain 2>$null
    if ($git_output) {
        $modified = @($git_output | Where-Object { $_ -match '^\s*M' }).Count
        $new_files = @($git_output | Where-Object { $_ -match '^\?\?' }).Count
        $deleted = @($git_output | Where-Object { $_ -match '^\s*D' }).Count

        $parts = @()
        if ($modified -gt 0) { $parts += "${yellow}~$modified${reset}" }
        if ($new_files -gt 0) { $parts += "${green}+$new_files${reset}" }
        if ($deleted -gt 0) { $parts += "${red}-$deleted${reset}" }

        if ($parts.Count -gt 0) {
            $git_status = " [" + ($parts -join " ") + "]"
        }
    }
} catch {}

# Build status line
$branch_part = if ($git_branch) { " | $git_branch |" } else { "" }
$status = "${cyan}${current_dir}${reset} | ${orange}${model_name}${reset} | ${context_pct}%${branch_part}${git_status}"

Write-Host $status
