
# =========================
# CONFIGURATION SECTION
# =========================

$CsvPath = "C:\Users\Creed\Downloads\TestData.csv"

# Customize these field names to match your CSV headers:
# IP   -> e.g. SourceIP, ClientIP
# Date -> e.g. Timestamp, EventDate
# Leave .Group, .Name, and .Count unchanged (they come from Group-Object)

$IPColumn   = "IP"
$DateColumn = "Date"


# =========================
# LOAD DATA
# =========================

$Data = Import-Csv $CsvPath


# =========================
# DISPLAY AVAILABLE IPS
# Write-Host "`nAvailable IP Addresses (First Seen Date):`n" -ForegroundColor Cyan

# Build grouped IP summary
$Grouped = $Data |
    Group-Object $IPColumn |
    ForEach-Object {

        $FirstSeen = $_.Group |
            Sort-Object { [datetime]$_.($DateColumn) } |
            Select-Object -First 1

        [PSCustomObject]@{
            IP        = $_.Name
            FirstSeen = $FirstSeen.$DateColumn
        }
    } |
    Sort-Object { [datetime]$_.FirstSeen }

# Output table
$Grouped | Format-Table -AutoSize

# Space-separated IP list underneath
Write-Host "`nIP List (space-separated):`n" -ForegroundColor Cyan

$Grouped.IP -join " " | Write-Host

Write-Host ""


# =========================
# USER INPUT
# =========================

$SearchIP = Read-Host "Enter IP address to search for"
$SearchDate = Read-Host "Enter date to filter by (optional - press Enter to skip)"


# =========================
# FILTER DATA
# =========================

if ([string]::IsNullOrWhiteSpace($SearchDate)) {

    $Results = $Data | Where-Object {
        $_.$IPColumn -eq $SearchIP
    }

}
else {

    $Results = $Data | Where-Object {
        $_.$IPColumn -eq $SearchIP -and $_.$DateColumn -eq $SearchDate
    }
}


# =========================
# OUTPUT RESULTS
# =========================

if ($Results) {

    $Results |
        Sort-Object { [datetime]$_.($DateColumn) } |
        Format-Table -AutoSize

}
else {
    Write-Host "No matching records found."
}
