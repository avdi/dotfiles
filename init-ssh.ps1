$env:WSL_UTF8=1 # Make `wsl` not emit spurious nulls 🤦
# See https://stackoverflow.com/questions/64104790/powershell-strange-wsl-output-string-encoding

Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command 'Set-Service -Name `"ssh-agent`" -StartupType Automatic'"` -Verb runAs
Start-Service ssh-agent
