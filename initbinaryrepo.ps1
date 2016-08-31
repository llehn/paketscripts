if (-not (Test-Path ".git")) { 
    throw "Not a git repository, .git folder not found"
}

Write-Output "Initializing repository for binary files"

$null > "paket.dependencies"
$null > "paket.lock"
echo "1.0" > "version"

New-Item -ItemType directory -Path ".paket"

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

Write-Output "Done, open paket.template and readme.md and replace CAPITAL TEXT with real content"