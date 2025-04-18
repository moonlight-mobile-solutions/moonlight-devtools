<#
.SYNOPSIS
    Configura chave SSH para GitHub no Windows sem sobrescrever existentes.
.DESCRIPTION
    Gera chave SSH apenas se não existir, nunca sobrescreve automaticamente.
.PARAMETER githubEmail
    E-mail associado à conta do GitHub.
.EXAMPLE
    .\github_ssh_windows.ps1 -githubEmail "seu-email@exemplo.com"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$githubEmail
)

# Configurações
$sshKeyPath = "$env:USERPROFILE\.ssh\id_ed25519_github"
$sshKeyType = "ed25519"

# Verificar se chave já existe
if (Test-Path "$sshKeyPath*") {
    Write-Host "Chave SSH já existe em $sshKeyPath" -ForegroundColor Yellow
    Write-Host "Script abortado para evitar sobrescrita." -ForegroundColor Red
    Write-Host "Chave pública existente:"
    Get-Content "$sshKeyPath.pub"
    exit 1
}

# Verificar/Instalar OpenSSH
if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando OpenSSH Client..."
    try {
        Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0 -ErrorAction Stop
        Write-Host "OpenSSH instalado com sucesso"
    }
    catch {
        Write-Host "Falha ao instalar OpenSSH. Por favor instale manualmente." -ForegroundColor Red
        exit 1
    }
}

# Criar diretório .ssh se não existir
if (-not (Test-Path "$env:USERPROFILE\.ssh")) {
    New-Item -ItemType Directory -Path "$env:USERPROFILE\.ssh" -Force | Out-Null
}

# Gerar nova chave SSH
Write-Host "Gerando nova chave SSH para $githubEmail..."
ssh-keygen -t $sshKeyType -f $sshKeyPath -C $githubEmail -N '""'

# Configurar ssh-agent
Write-Host "Configurando ssh-agent..."
Start-Service ssh-agent -ErrorAction SilentlyContinue
ssh-add $sshKeyPath

# Configurar arquivo SSH
$sshConfig = "$env:USERPROFILE\.ssh\config"
if (-not (Test-Path $sshConfig) -or -not (Select-String -Path $sshConfig -Pattern "github.com" -Quiet)) {
    Add-Content -Path $sshConfig -Value @"
Host github.com
    HostName github.com
    User git
    IdentityFile $sshKeyPath
    IdentitiesOnly yes
"@
}

# Resultado final
Write-Host "`nConfiguração concluída para $githubEmail!" -ForegroundColor Green
Write-Host "Chave pública para adicionar ao GitHub:`n" -ForegroundColor Cyan
Get-Content "$sshKeyPath.pub"
Write-Host "`nAdicione esta chave pública no GitHub: https://github.com/settings/ssh/new"