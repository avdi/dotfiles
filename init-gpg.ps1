$env:WSL_UTF8=1 # Make `wsl` not emit spurious nulls 🤦
# See https://stackoverflow.com/questions/64104790/powershell-strange-wsl-output-string-encoding

$pinentry_path = "c:\Program Files (x86)\GnuPG\bin\pinentry-basic.exe"
Write-Host "Making sure GPG is installed on Windows..."
if (Test-Path -Path $pinentry_path) {
  Write-Host "GPG found"
} else {
  winget install --accept-source-agreements GnuPG.Gpg4win
}

Write-Host "Making sure gpg is installed in WSL..."
if (wsl -e which gpg -and wsl -e which gpg-agent) {
  Write-Host "WSL GPG found"
} else {
  wsl -e sudo apt install gpg gnupg gpg-agent
}

$wsl_pinentry_path = wsl -e wslpath $pinentry_path

$gpg_conf = @"
default-cache-ttl 34560000
max-cache-ttl 34560000
pinentry-program "$($wsl_pinentry_path)"
"@

$gpg_conf | wsl -e sh -c "cat > ~/.gnupg/gpg-agent.conf"
wsl -e  gpgconf --kill gpg-agent