#!/bin/bash

# Configuração automática de chave SSH para GitHub - macOS
# Uso: ./script.sh seu-email@moonlightmobile.dev

if [ -z "$1" ]; then
    echo "Erro: E-mail do GitHub não fornecido."
    echo "Uso: $0 seu-email@moonlightmobile.dev"
    exit 1
fi

GITHUB_EMAIL="$1"
SSH_KEY_PATH="$HOME/.ssh/id_ed25519_github"
SSH_KEY_TYPE="ed25519"

# Criar diretório .ssh
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Gerar chave SSH
echo "Gerando nova chave SSH para $GITHUB_EMAIL..."
ssh-keygen -t $SSH_KEY_TYPE -f "$SSH_KEY_PATH" -N "" -C "$GITHUB_EMAIL"

# Configurar ssh-agent
eval "$(ssh-agent -s)"

# Configurar arquivo config
SSH_CONFIG="$HOME/.ssh/config"
if ! grep -q "github.com" "$SSH_CONFIG" 2>/dev/null; then
    cat >> "$SSH_CONFIG" <<EOL
Host github.com
    HostName github.com
    User git
    IdentityFile $SSH_KEY_PATH
    IdentitiesOnly yes
EOL
    chmod 600 "$SSH_CONFIG"
fi

# Adicionar chave ao ssh-agent e keychain
ssh-add --apple-use-keychain "$SSH_KEY_PATH"

# Resultado
echo -e "\n✅ Configuração concluída para $GITHUB_EMAIL!"
echo "📋 Chave pública para adicionar ao GitHub:"
cat "${SSH_KEY_PATH}.pub"