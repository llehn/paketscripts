if (-not (Test-Path ".git")) { 
    throw "Not a git repository, .git folder not found"
}

Write-Output "Initializing repository for binary files"

function Download-File {
param (
  [string]$url,
  [string]$file
 )
  Write-Output "Downloading $url to $file"
  $downloader = Get-Downloader $url
  
  $downloader.DownloadFile($url, $file)
}

Download-File 