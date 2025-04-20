<#
.SYNOPSIS
    Configura ambiente e clona múltiplos repositórios
.DESCRIPTION
    Cria diretório development, configura Git e clona os repositórios da Moonlight
.PARAMETER Name
    Nome para configuração do Git
.PARAMETER Email
    Email para configuração do Git
.PARAMETER FlutterVersion
    Versão do Flutter (padrão: 3.29.3)
.EXAMPLE
    .\env_config_windows.ps1 -Name "Seu Nome" -Email "seu-nome@moonlightmobile.dev" -FlutterVersion "3.29.3"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$Name = $env:GIT_USER_NAME,
    
    [Parameter(Mandatory=$false)]
    [string]$Email = $env:GIT_USER_EMAIL

    [Parameter(Mandatory=$false)]
    [string]$FlutterVersion = "3.29.3"
)

# Lista de repositórios para clonar
$repos = @(
    "git@github.com:moonlight-mobile-solutions/ad-training.git",
    "git@github.com:moonlight-mobile-solutions/design-system-package.git",
    "git@github.com:moonlight-mobile-solutions/moonlight-pay.git",
    "git@github.com:moonlight-mobile-solutions/moonlight-core.git",
    "git@github.com:moonlight-mobile-solutions/auth-platform.git"
)

# Verificar parâmetros
if (-not $Name -or -not $Email) {
    Write-Host "Erro: Nome e Email devem ser informados" -ForegroundColor Red
    exit 1
}

# URL base para downloads
$baseUrl = "https://storage.googleapis.com/flutter_infra_release/releases"

# Determinar URL de download
$flutterUrl = "$baseUrl/releases/windows/flutter_windows_$FlutterVersion-stable.zip"


# Criar diretório development
$devDir = "$env:USERPROFILE\development"
if (-not (Test-Path $devDir)) {
    New-Item -ItemType Directory -Path $devDir | Out-Null
    Write-Host "Diretório development criado: $devDir" -ForegroundColor Green
}

# Baixar Flutter
$flutterDir = "$devDir\flutter"
if (-not (Test-Path "$flutterDir\bin\flutter.bat")) {
    Write-Host "Baixando Flutter $FlutterVersion..."
    $tempFile = "$env:TEMP\flutter_$FlutterVersion.zip"
    Invoke-WebRequest -Uri $flutterUrl -OutFile $tempFile
    
    Write-Host "Instalando Flutter..."
    Expand-Archive -Path $tempFile -DestinationPath $devDir -Force
    Remove-Item $tempFile
}

# Configurar ambiente
$env:PATH += ";$flutterDir\bin"
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$flutterDir\bin", "User")
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$flutterDir\bin\cache\dart-sdk\bin", "User")
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$env:USERPROFILE\.pub-cache\bin", "User")
[Environment]::SetEnvironmentVariable("FLUTTER_ROOT", $flutterDir, "User")

# Salva variáveis de ambiente
$env:GIT_USER_NAME = $Name
$env:GIT_USER_EMAIL = $Email

# Clonar repositórios
foreach ($repo in $repos) {
    $repoName = ($repo -split '/')[-1] -replace '\.git$', ''
    $repoPath = "$devDir\$repoName"
    
    if (-not (Test-Path $repoPath)) {
        Write-Host "Clonando $repoName..." -ForegroundColor Cyan
        git clone $repo $repoPath
        # Configurar Git
        Write-Host "Configurando Git para o repo $repoPath..." -ForegroundColor Cyan
        git config -C $repoPath user.name "$Name"
        git config -C $repoPath user.email "$Email"
    } else {
        Write-Host "Repositório $repoName já existe em $repoPath" -ForegroundColor Yellow
    }
}

# Resumo
Write-Host "`nConfiguração concluída!" -ForegroundColor Green
Write-Host "Flutter $FlutterVersion instalado em: $flutterDir"
Write-Host "Git configurado para: $Name <$Email>"
Write-Host "Repositórios clonados em: $devDir"
Write-Host "Próximos passos:"
Write-Host "1. Baixe a última versão do Android Studio: https://developer.android.com/studio"
Write-Host "2. Instale o Android Studio e configure o SDK Android"
Write-Host "Execute 'flutter doctor' para verificar a instalação"
