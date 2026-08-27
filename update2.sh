#!/bin/bash

# ==============================================================================
# SCRIPT: system_update_upgrade_clean.sh
# DESCRICAO: Atualiza, upgrade e limpa pacotes do sistema (Debian/Ubuntu).
# AUTOR   : [Seu Nome]
# DATA    : $(date +'%d/%m/%Y')
# ==============================================================================

# Configurações Globais
export LC_ALL=en_US.UTF-8 # Evita erros de codificação de idioma
set -e                     # O script sai se um comando falhar (com cuidado)

# Variáveis de Cores
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'               # Sem cores

# Variável de Log/Timestamp
SCRIPT_NAME=$(basename "$0")
TIMESTAMP=$(date "+%d/%m/%Y %H:%M:%S")
USER_NAME=$(whoami)

# ==============================================================================
# FUNÇÕES AUXILIARES
# ==============================================================================

log_info() {
    echo -e "${GREEN}>> $1${NC}"
}

log_warn() {
    echo -e "${YELLOW}!! $1${NC}"
}

log_error() {
    echo -e "${RED}✗ $1${NC}" >&2 # Escreve no STDERR (melhor para logs)
    exit 1
}

# Checa se tem permissão de root
check_root() {
    if [[ $(id -u) -ne 0 ]]; then
        log_error "Este script precisa ser executado com permissões de ROOT. Use 'sudo'."
        echo "Ex: sudo $SCRIPT_NAME"
        exit 1
    fi
}

# Checa conexão com a internet
check_connection() {
    log_info "Verificando conexão com a internet..."
    if ! ping -c 2 -W 3 google.com > /dev/null 2>&1; then
        log_error "Sem acesso à internet. Certifique-se de que seu sistema está online."
    fi
}

# Função para confirmar ação (segurança)
confirm_action() {
    read -p "$(log_warn "Isso irá atualizar e alterar pacotes do sistema. Deseja continuar? [y/N] ") CONFIRM
    [[ "$CONFIRM" =~ ^[Yy]$ ]] || exit 1
}

# ==============================================================================
# LÓGICA PRINCIPAL
# ==============================================================================

main() {
    # Mensação de cabeçalho
    echo -e "${GREEN}"
    echo "#####################################"
    echo "###   SYSTEM UPDATE & UPGRADE      ###"
    echo "###       Autor: $(whoami)         ###"
    echo "###       Data: $TIMESTAMP          ###"
    echo "#####################################"
    echo -e "${NC}"

    # Passo 1: Verificações Preliminares
    check_root
    check_connection
    
    if [[ $(id -u) -ne 0 ]]; then 
        log_warn "Aviso de segurança: A atualização será feita com sudo."
        # Como o script já verificou root acima, se passar aqui está como root.
    fi

    confirm_action

    echo ""
    log_info "INICIANDO ATUALIZAÇÃO E UPGRADE..."
    echo "----------------------------------------"

    # 1. Atualizar listas de pacotes
    apt update -y
    
    # 2. Fixar dependências quebradas (se houver) antes do upgrade completo
    dpkg --configure -a
    apt install -f -y

    # 3. Upgrade / Full Upgrade
    log_info "Aplicando atualizações..."
    apt full-upgrade -y
    
    # 4. Limpeza Automática e Manual
    apt-get autoremove --purge -y
    apt-get autoclean -y
    apt-get clean
    apt-get dist-upgrade -y

    log_info "Limpeza finalizada."

    echo ""
    log_info "AÇÃO CONCLUÍDA COM SUCESSO!"
    echo -e "${GREEN}Atualizado em: $TIMESTAMP por $USER${NC}"
    
    # Mensagem de encerramento
    sleep 1
    echo ""
    echo -e "${GREEN}Be light, be Yourself...${NC}"
}

# Executa a função principal
main "$@"
