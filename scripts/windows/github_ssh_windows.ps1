<#
.SYNOPSIS
    Configura automaticamente chave SSH para GitHub no Windows
.DESCRIPTION
    Script para gerar e configurar chave SSH para GitHub sem interação do usuário
.PARAMETER githubEmail
    E-mail associado à conta do GitHub
.EXAMPLE
    .\github_ssh_windows.ps1 -githubEmail "seu-email@moonlightmobile.dev"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$githubEmail
)

# Configurações
$sshKeyPath = "$env:USERPROFILE\.ssh\id_ed25519_github"
$sshKeyType = "ed25519" 

# Verificar/Instalar OpenSSH
if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando OpenSSH Client..."
    try {
        Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0 -ErrorAction Stop
    } catch {
        Write-Host "Falha ao instalar OpenSSH. Por favor instale manualmente." -ForegroundColor Red
        exit 1
    }
}

# Criar diretório .ssh
if (-not (Test-Path "$env:USERPROFILE\.ssh")) {
    New-Item -ItemType Directory -Path "$env:USERPROFILE\.ssh" -Force | Out-Null
}

# Gerar chave SSH
Write-Host "Gerando chave SSH para $githubEmail..."
ssh-keygen -t $sshKeyType -f $sshKeyPath -N '""' -C $githubEmail

# Configurar ssh-agent
Write-Host "Configurando ssh-agent..."
Start-Service ssh-agent
ssh-add $sshKeyPath

# Configurar arquivo SSH config
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

# Mostrar resultados
Write-Host "`n✅ Configuração concluída para $githubEmail!" -ForegroundColor Green
Write-Host "📋 Chave pública para adicionar ao GitHub:`n" -ForegroundColor Cyan
Get-Content "$sshKeyPath.pub"