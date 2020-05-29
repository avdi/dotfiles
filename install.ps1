if ( -not (Test-Path $profile -Verbose) ) {
    New-Item -ItemType File -Force $profile -Verbose
}

$dotfiles_profile = Join-Path $PSScriptRoot profile.ps1
$old_profile_contents = Get-Content -Path $profile -Verbose
$omit = $false
$old_profile_contents | Where-Object {
    switch -regex ($_) {
        'BEGIN_AVDI_DOTFILES' { $omit = $true; $false }
        'END_AVDI_DOTFILES' { $omit = $false; $false }
        Default { -not $omit }
    }
} | Set-Content -Path $profile -Verbose
Add-Content -Verbose -Path $profile -Value @"

# BEGIN_AVDI_DOTFILES
. $dotfiles_profile
# END_AVDI_DOTFILES
"@



if ( -not $IsWindows) {
    Write-Error "This doesn't appear to be Windows" -ErrorAction Stop
}

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