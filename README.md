# Prerequisites

AKA stuff I couldn't automate. Yet.

## Windows

- Install PowerShell Core: https://github.com/PowerShell/PowerShell/releases
- Enable local script execution:
  ```PowerShell
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned 
  ```
- Run .\install.ps1 in PowerShell Core

## WSL

### SSH Config Sync
- https://superuser.com/questions/1183176/can-i-share-my-ssh-keys-between-wsl-and-windows
