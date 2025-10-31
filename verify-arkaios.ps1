# Arkaios Proxy Verification Script
# - Checks /v1/models
# - Calls /v1/chat/completions with retries/backoff
# - Prints diagnostics from /debug/ping

param(
  [string]$BaseUrl = "http://localhost:4000",
  [string]$ApiKey = "sk_arkaios_proxy_8y28hsy72hs82js9",
  [string]$Model = "arkaios",
  [int]$MaxRetries = 6
)

$ErrorActionPreference = "Stop"

function Write-Log {
  param([string]$Message)
  $ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
  Write-Host "[$ts] $Message"
  try {
    $logPath = Join-Path "$PSScriptRoot" "arkaios-service-proxy\logs\arkaios-smoke.log"
    $dir = Split-Path $logPath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    Add-Content -Path $logPath -Value "[$ts] $Message"
  } catch {}
}

function Invoke-WithRetry {
  param(
    [scriptblock]$Action,
    [int]$MaxAttempts = 5,
    [int]$InitialDelayMs = 1000
  )
  $attempt = 0
  $delay = $InitialDelayMs
  while ($true) {
    $attempt++
    try {
      return & $Action
    } catch {
      $msg = $_.Exception.Message
      # Backoff on typical transient errors
      if ($attempt -ge $MaxAttempts) { throw }
      Write-Log "Attempt $attempt failed: $msg. Retrying in $delay ms..."
      Start-Sleep -Milliseconds $delay
      $delay = [Math]::Min($delay * 2, 15000)
    }
  }
}

function Get-Models {
  $h = @{ Authorization = "Bearer $ApiKey" }
  $url = "$BaseUrl/v1/models"
  Write-Log "GET $url"
  $resp = Invoke-WithRetry -MaxAttempts 3 -InitialDelayMs 1000 -Action {
    Invoke-RestMethod -Method GET -Uri $url -Headers $h
  }
  return $resp
}

function Chat-Completion {
  param([string]$Prompt)
  $h = @{ Authorization = "Bearer $ApiKey"; "Content-Type" = "application/json" }
  $url = "$BaseUrl/v1/chat/completions"
  $body = @{ model = $Model; messages = @(@{ role = "user"; content = $Prompt }) } | ConvertTo-Json -Depth 6
  Write-Log "POST $url (prompt: '$Prompt')"
  $resp = Invoke-WithRetry -MaxAttempts $MaxRetries -InitialDelayMs 1200 -Action {
    Invoke-RestMethod -Method POST -Uri $url -Headers $h -Body $body
  }
  return $resp
}

function Debug-Ping {
  $url = "$BaseUrl/debug/ping"
  Write-Log "GET $url"
  try { return Invoke-RestMethod -Method GET -Uri $url } catch { return @{ error = $_.Exception.Message } }
}

# ---- Run ----
Write-Log "Starting Arkaios proxy verification at BaseUrl=$BaseUrl Model=$Model"

try {
  $models = Get-Models
  $ids = @()
  foreach ($m in $models.data) { $ids += $m.id }
  if ($ids -notcontains $Model) {
    Write-Log "Model '$Model' NOT found in /v1/models: $($ids -join ', ')"
  } else {
    Write-Log "Model '$Model' found in /v1/models."
  }

  $chat = Chat-Completion -Prompt "Ping de verificacion"
  # Try to extract text in various OpenAI-like shapes
  $text = $null
  try {
    if ($chat.choices) {
      foreach ($c in $chat.choices) {
        if ($c.message -and $c.message.content) { $text = $c.message.content; break }
        elseif ($c.text) { $text = $c.text; break }
      }
    }
  } catch {}
  if (-not $text) { $text = ($chat | ConvertTo-Json -Depth 6) }
  Write-Log "Chat OK. Response: $text"

  $diag = Debug-Ping
  $diagJson = ($diag | ConvertTo-Json -Depth 6)
  Write-Log "Debug ping: $diagJson"

  Write-Log "Verification complete."
} catch {
  Write-Log "Verification FAILED: $($_.Exception.Message)"
  exit 1
}