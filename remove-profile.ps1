# Directly retrieve Default Profile WMI instances
$DefaultUserProfile = Get-WmiObject -Class Win32_UserProfile -Filter "LocalPath='C:\Users\Default'"

if ($DefaultUserProfile) {
    # Filter profiles w/ WMI
    Get-WmiObject -Class Win32_UserProfile |
        Where-Object {
            # $_ is an automatic variable in PowerShell that represents the current object being processed within a pipeline or script block.
            -not $_.Special -and
            $_.LocalPath -ne 'C:\Users\Default' -and
            [datetime]::Parse($_.ConvertToDateTime($_.LastUseTime)) -lt (Get-Date).AddDays(-30)
        } |
        ForEach-Object {
            try {
                $_ | Remove-WmiObject -ErrorAction Stop
                Remove-Item $_.LocalPath -Recurse -Force -ErrorAction Stop
                Write-Host "Profile removed: $($_.LocalPath)"
            } catch {
                Write-Warning "Failed to remove profile $($_.LocalPath): $($_.Exception.Message)"
            }
        }
    Write-Host "User profiles other than Default Profile processed successfully."
} else {
    Write-Warning "Default Profile not found. Aborting operation."
}
