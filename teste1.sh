#!/bin/bash
# Author: meepmaster (modificado)
# Date: 10-6-2025
# Description: Update & Upgrade com limpeza automatizada

# Parar o script em caso de erro
set -e

# Cores
RED="\033[1;31m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

# Timestamp
TIME_STAMP="Atualizado em $(date +"%d/%m/%Y %H:%M:%S") por $USER"

# Checagem de usuário root
check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo -e "${RED}Por favor, execute este script como root!${NOCOLOR}"
        exit 1
    fi
}

# Checagem de conexão com a internet
check_internet() {
    if ! ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
        echo -e "${RED}Este script precisa de conexão ativa com a internet!${NOCOLOR}"
        exit 1
    fi
}

# Atualização, upgrade e limpeza
update_and_clean() {
    echo -e "\n${GREEN}Iniciando atualização do sistema...${NOCOLOR}"
    dpkg --configure -a
    apt-get install -f -y
    apt-get --fix-broken install -y
    apt update --fix-missing
    apt upgrade -y
    apt full-upgrade -y

    echo -e "\n${GREEN}Atualização concluída.${NOCOLOR}"

    echo -e "\n${GREEN}Iniciando limpeza do sistema...${NOCOLOR}"
    apt-get --purge autoremove -y
    apt-get autoclean -y
    apt-get clean

    echo -e "\n${GREEN}Limpeza finalizada.${NOCOLOR}"
    echo -e "${GREEN}$TIME_STAMP${NOCOLOR}"
    echo -e "${GREEN}Be light, be Yourself...${NOCOLOR}\n"
}

# Execução das funções
check_root
check_internet
update_and_clean
