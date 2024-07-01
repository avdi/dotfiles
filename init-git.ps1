$env:WSL_UTF8=1 # Make `wsl` not emit spurious nulls 🤦
# See https://stackoverflow.com/questions/64104790/powershell-strange-wsl-output-string-encoding
$cred_man_path = "C:\Program Files\Git\mingw64\bin\git-credential-manager.exe"

Write-Host "Making sure Git is installed on Windows..."

if (Test-Path -Path $cred_man_path) {
  Write-Host "Git is installed"
} else {
  winget install --accept-source-agreements Git.Git
}

Write-Host "Configuring Git"
C:\Program` Files\Git\cmd\git.exe config --global user.email "avdi@avdi.codes"
C:\Program` Files\Git\cmd\git.exe config --global user.name "Avdi Grimm"


$wsl_status = (wsl --status)
if ($? -and (($wsl_status -join "`n") -match "Default Version")) {
  $wsl_cred_man_path = wsl -e wslpath $cred_man_path
  wsl -e git config --global credential.helper $wsl_cred_man_path
} else {
    Write-Error "$wsl_status"
    Write-Error "WSL is not configured." -ErrorAction Stop
}

Write-Host "Configuring Git (WSL)"
wsl -e git config --global user.email "avdi@avdi.codes"
wsl -e git config --global user.name "Avdi Grimm"
