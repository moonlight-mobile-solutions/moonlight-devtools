<#
.SYNOPSIS
    Configures Git user name and email for specific repository and session
.DESCRIPTION
    Sets local Git user config and environment variables for current session
.PARAMETER Name
    Your full name for Git commits (default: $env:GIT_USER_NAME)
.PARAMETER Email
    Your email for Git commits (default: $env:GIT_USER_EMAIL)
.PARAMETER RepoPath
    Path to Git repository (defaults to current directory)
.EXAMPLE
    .\git_config_repo.ps1 -Name "John Doe" -Email "john@moonlightmobile.dev" -RepoPath "C:\projects\my-repo"
.EXAMPLE
    .\git_config_repo.ps1  # Uses values from environment variables
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$Name = $env:GIT_USER_NAME,
    
    [Parameter(Mandatory=$false)]
    [string]$Email = $env:GIT_USER_EMAIL,
    
    [Parameter(Mandatory=$false)]
    [string]$RepoPath = "."
)

# Verify parameters
if (-not $Name -or -not $Email) {
    Write-Host "Error: Name and Email must be specified either as parameters or in GIT_USER_NAME/GIT_USER_EMAIL environment variables" -ForegroundColor Red
    exit 1
}

# Verify Git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git is not installed. Please install Git first." -ForegroundColor Red
    exit 1
}

# Verify directory is Git repository
if (-not (Test-Path (Join-Path $RepoPath ".git"))) {
    Write-Host "The specified path is not a Git repository" -ForegroundColor Red
    exit 1
}

# Set Git local configurations
Push-Location $RepoPath
git config user.name "$Name"
git config user.email "$Email"
Pop-Location

# Set/update environment variables for current session
$env:GIT_USER_NAME = $Name
$env:GIT_USER_EMAIL = $Email

# Verify configurations
Write-Host "`nGit repository configuration updated successfully:" -ForegroundColor Green
Write-Host "Repository: $(Resolve-Path $RepoPath)"
Write-Host "Name: $(git -C $RepoPath config user.name)"
Write-Host "Email: $(git -C $RepoPath config user.email)"

Write-Host "`nEnvironment variables set for current session:" -ForegroundColor Cyan
Write-Host "GIT_USER_NAME: $env:GIT_USER_NAME"
Write-Host "GIT_USER_EMAIL: $env:GIT_USER_EMAIL"