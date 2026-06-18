param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^([01]\d|2[0-3]):[0-5]\d$')]
    [string]$ScheduledTime
)

$cfg = "C:\Program Files (x86)\FortimonitorAgent\Agent.config"

if (-not (Test-Path $cfg)) {
    throw "Could not find $cfg"
}

[xml]$xml = Get-Content $cfg

$service = $xml.agent.service

if (-not $service) {
    throw "Could not find <service> section under <agent> in $cfg"
}

$node = $service.SelectSingleNode("add[@key='ScheduledUpdate']")

if ($node) {
    $node.SetAttribute("value", $ScheduledTime)
} else {
    $node = $xml.CreateElement("add")
    $node.SetAttribute("key", "ScheduledUpdate")
    $node.SetAttribute("value", $ScheduledTime)
    [void]$service.AppendChild($node)
}

Copy-Item $cfg "$cfg.bak-schedule" -Force

$xml.Save($cfg)

Restart-Service FortiMonitorAgent -Force

Write-Host "ScheduledUpdate changed to $ScheduledTime and FortiMonitorAgent service restarted."