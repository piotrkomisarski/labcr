$data = [Console]::In.ReadToEnd() | ConvertFrom-Json -ErrorAction SilentlyContinue

if ($data) {
    $model = $data.model.display_name
    $cwd = $data.workspace.current_dir
    $style = $data.output_style.name
    $usage = $data.context_window.current_usage

    if ($usage) {
        $current = $usage.input_tokens + $usage.cache_creation_input_tokens + $usage.cache_read_input_tokens
        $size = $data.context_window.context_window_size
        $pct = [math]::Floor($current * 100 / $size)
        Write-Host -NoNewline "$model | $cwd | Style: $style | Context: $pct%"
    } else {
        Write-Host -NoNewline "$model | $cwd | Style: $style"
    }
}
