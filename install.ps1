if ( $PSVersionTable -and ( $PSVersionTable.PSVersion.Major -gt 5 ) ) {
    Write-Host "Acceptable version of PowerShell found!"
}
else {
    Write-Error -ErrorAction Stop "Pleae run me in a newer version of PowerShell: https://github.com/PowerShell/PowerShell/releases"
}

if ( -not $IsWindows) {
    Write-Error "This doesn't appear to be Windows" -ErrorAction Stop
}

if ( -not (Test-Path $profile -Verbose) ) {
    New-Item -ItemType File -Force $profile -Verbose
}

$old_profile_contents = Get-Content -Path $profile -Verbose
$omit = $false
$old_profile_contents | Where-Object {
    switch -regex ($_) {
        'BEGIN_AVDI_DOTFILES' { $omit = $true; $false }
        'END_AVDI_DOTFILES' { $omit = $false; $false }
        Default { -not $omit }
    }
} | Set-Content -Path $profile -Verbose
Add-Content -Verbose -Path $profile -Value @'

# BEGIN_AVDI_DOTFILES
if ( Test-Path $env:USERPROFILE\dotfiles ) {
    . $env:USERPROFILE\dotfiles\profile.ps1
} else {
    Write-Host "Missing $env:USERPROFILE\dotfiles. Run: git clone https://github.com/avdi/dotfiles.git"
}
# END_AVDI_DOTFILES
'@

Write-Host "Checking for Ruby 2..."
try {
    $ruby_version = (ruby --version)
}
catch {
    Write-Error "Failed to find a Ruby executable!" -ErrorAction Stop
}

$success = $ruby_version -match '^ruby (?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)'
Write-Host $Matches[0]
$ruby_major = [int]$Matches.major
$ruby_minor = [int]$Matches.minor

if ($ruby_major -lt 2) {
    Write-Error "Please install Ruby 2" -ErrorAction Stop
}

Write-Host "Checking for Rake..."
try {
    $rake_version = (rake --version)
}
catch {
    Write-Host "Rake not found. Attempting to install it..."
    gem install rake
    $rake_version = (rake --version)
}

$success = $rake_version -match 'rake, version (?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)'
Write-Host $Matches[0]
$rake_major = [int]$Matches.major
$rake_minor = [int]$Matches.minor

# On Windows, Rake looks for ~/Rake, not ~/.rake
$tasks_dir = Join-Path $env:USERPROFILE Rake

Write-Host "Checking for rake tasks ($tasks_dir)"
if (Test-Path -PathType Container $tasks_dir -Verbose) {
    Write-Host "$tasks_dir exits"
}
else {
    Write-Host "$tasks_dir does not exist"
    $dotfiles_tasks_dir = Join-Path (Get-Item $PSScriptRoot) .rake
    New-Item -ItemType SymbolicLink -Path $tasks_dir -Target $dotfiles_tasks_dir -Verbose
}

Write-Host "Setting up Windows Terminal..."
$winterm_settings_path = Join-Path $env:LOCALAPPDATA Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
Copy-Item -Verbose $winterm_settings_path "$winterm_settings_path.pre_dotfiles"
New-Item -Verbose -Force -ItemType SymbolicLink -Path $winterm_settings_path -Target (Join-Path (Get-Item $PSScriptRoot) .\WindowsTerminal\settings.json)

$volatile_dir = (Join-Path $env:USERPROFILE ($env:DROPBOX ?? "Dropbox") config volatile)
if (Test-Path -PathType Container $volatile_dir -Verbose) {
    Write-Host "Setting up SSH config..."
    $ssh_config_dir = (Join-Path $env:USERPROFILE .ssh)
    New-Item -Verbose -Force -ItemType Directory -Path $ssh_config_dir
    New-Item -Verbose -Force -ItemType HardLink -Path (Join-Path $ssh_config_dir config) -Target (Join-Path $volatile_dir .ssh config)
    
    Write-Host "Setting up WP-CLI config..."
    New-Item -Verbose -Force -ItemType SymbolicLink -Path (Join-Path $env:USERPROFILE .wp-cli) -Target (Join-Path $volatile_dir .wp-cli)    

    Write-Host "Setting up convenience link to $volatile_dir ..."
    New-Item -Verbose -Force -ItemType SymbolicLink -Path (Join-Path $PSScriptRoot volatile) -Value $volatile_dir
}
else {
    Write-Error "Directory $volatile_dir not found"
}
