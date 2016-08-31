if (-not (Test-Path ".git")) { 
    throw "Not a git repository, .git folder not found"
}

Write-Output "Initializing repository for binary files"

$null > "paket.dependencies"
$null > "paket.lock"
"1.0" | Out-File "version" -encoding ASCII

New-Item -ItemType directory -Path ".paket"

function Get-Downloader {
param (
  [string]$url
 )

  $downloader = new-object System.Net.WebClient

  $defaultCreds = [System.Net.CredentialCache]::DefaultCredentials
  if ($defaultCreds -ne $null) {
    $downloader.Credentials = $defaultCreds
  }

  # check if a proxy is required
  $explicitProxy = $env:chocolateyProxyLocation
  $explicitProxyUser = $env:chocolateyProxyUser
  $explicitProxyPassword = $env:chocolateyProxyPassword
  if ($explicitProxy -ne $null) {
    # explicit proxy
    $proxy = New-Object System.Net.WebProxy($explicitProxy, $true)
    if ($explicitProxyPassword -ne $null) {
      $passwd = ConvertTo-SecureString $explicitProxyPassword -AsPlainText -Force
      $proxy.Credentials = New-Object System.Management.Automation.PSCredential ($explicitProxyUser, $passwd)
    }

    Write-Debug "Using explicit proxy server '$explicitProxy'."
    $downloader.Proxy = $proxy

  } elseif (!$downloader.Proxy.IsBypassed($url))
  {
    # system proxy (pass through)
    $creds = $defaultCreds
    if ($creds -eq $null) {
      Write-Debug "Default credentials were null. Attempting backup method"
      $cred = get-credential
      $creds = $cred.GetNetworkCredential();
    }
    
    $proxyaddress = $downloader.Proxy.GetProxy($url).Authority
    Write-Debug "Using system proxy server '$proxyaddress'."
    $proxy = New-Object System.Net.WebProxy($proxyaddress)
    $proxy.Credentials = $creds
    $downloader.Proxy = $proxy
  }  
  
  return $downloader
}

function Download-File {
param (
  [string]$url,
  [string]$file
 )
  Write-Output "Downloading $url to $file"
  $downloader = Get-Downloader $url
  
  $downloader.DownloadFile($url, $file)
}

Download-File "https://github.com/fsprojects/Paket/releases/download/3.17.2/paket.bootstrapper.exe" ".paket\paket.bootstrapper.exe"

Download-File "https://raw.githubusercontent.com/llehn/paketscripts/master/paket.template" "paket.template"

Download-File "https://raw.githubusercontent.com/llehn/paketscripts/master/readme.md" "readme.md"

Write-Output "Open paket.template and readme.md and replace CAPITAL TEXT with real content."
Write-Output "Then commit and push the repo."
Write-Output "Done."