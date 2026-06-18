$cfg = "C:\Program Files (x86)\FortimonitorAgent\Agent.config"

if (Test-Path $cfg) {
    [xml]$xml = Get-Content $cfg

    $service = $xml.agent.service
    if (-not $service) {
        throw "Could not find <service> section in $cfg"
    }

    function Set-AgentSetting($key, $value) {
        $node = $service.add | Where-Object { $_.key -eq $key }
        if ($node) {
            $node.value = $value
        } else {
            $newNode = $xml.CreateElement("add")
            $newNode.SetAttribute("key", $key)
            $newNode.SetAttribute("value", $value)
            [void]$service.AppendChild($newNode)
        }
    }

    Set-AgentSetting "AutoUpdate" "true"
    Set-AgentSetting "ScheduledUpdate" "11:00"

    Copy-Item $cfg "$cfg.bak" -Force
    $xml.Save($cfg)

    Restart-Service FortiMonitorAgent -Force
}