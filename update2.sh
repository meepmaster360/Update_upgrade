#!/usr/bin/env bash
#
# update-system.sh
# Atualiza e limpa sistemas Debian/Ubuntu/Linux Mint.
#

set -Eeuo pipefail
IFS=$'\n\t'

readonly RED='\033[1;31m'
readonly GREEN='\033[1;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

readonly SCRIPT_NAME="${0##*/}"
readonly TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S %Z')"
readonly LOG_FILE="/var/log/${SCRIPT_NAME%.sh}.log"

cleanup_done=0

info() {
    printf '\n%b[INFO]%b %s\n' "$GREEN" "$NC" "$*"
}

warn() {
    printf '\n%b[AVISO]%b %s\n' "$YELLOW" "$NC" "$*" >&2
}

error() {
    printf '\n%b[ERRO]%b %s\n' "$RED" "$NC" "$*" >&2
}

die() {
    error "$*"
    exit 1
}

on_error() {
    local exit_code=$?
    local line_no=$1

    error "O script falhou na linha ${line_no} (código ${exit_code})."
    error "Consulte o registo: ${LOG_FILE}"
    exit "$exit_code"
}

trap 'on_error $LINENO' ERR

require_root() {
    [[ $EUID -eq 0 ]] || die "Execute o script como root: sudo ./${SCRIPT_NAME}"
}

require_apt() {
    command -v apt-get >/dev/null 2>&1 || \
        die "Este script requer APT (Debian, Ubuntu, Linux Mint ou derivado)."
}

check_connection() {
    info "A verificar ligação à Internet..."

    # Evita depender de ICMP/ping, frequentemente bloqueado por redes/firewalls.
    if ! getent hosts deb.debian.org >/dev/null 2>&1 &&
       ! getent hosts archive.ubuntu.com >/dev/null 2>&1; then
        die "Não foi possível resolver um repositório APT. Verifique a ligação e o DNS."
    fi
}

configure_dpkg() {
    info "A configurar pacotes pendentes..."
    dpkg --configure -a
}

repair_dependencies() {
    info "A corrigir dependências eventualmente quebradas..."
    apt-get --fix-broken install -y
}

update_packages() {
    info "A atualizar índices de pacotes..."
    apt-get update

    info "A atualizar o sistema..."
    apt-get full-upgrade -y
}

clean_system() {
    info "A remover dependências não utilizadas e respetivas configurações..."
    apt-get autoremove --purge -y

    info "A limpar a cache de pacotes..."
    apt-get clean
}

show_reboot_status() {
    if [[ -f /var/run/reboot-required ]]; then
        warn "É necessário reiniciar o sistema."
        [[ -f /var/run/reboot-required.pkgs ]] && {
            printf '%bPacotes que pedem reinício:%b\n' "$YELLOW" "$NC"
            cat /var/run/reboot-required.pkgs
        }
    else
        info "Não foi indicado qualquer reinício obrigatório."
    fi
}

main() {
    require_root
    require_apt
    check_connection

    printf '%b========================================%b\n' "$GREEN" "$NC"
    printf '%b Atualização iniciada: %s %b\n' "$GREEN" "$TIMESTAMP" "$NC"
    printf '%b========================================%b\n' "$GREEN" "$NC"

    configure_dpkg
    repair_dependencies
    update_packages
    clean_system
    show_reboot_status

    printf '\n%b========================================%b\n' "$GREEN" "$NC"
    printf '%b Atualização concluída com sucesso. %b\n' "$GREEN" "$NC"
    printf '%b Registo guardado em: %s %b\n' "$GREEN" "$LOG_FILE" "$NC"
    printf '%b========================================%b\n' "$GREEN" "$NC"
}

main "$@" 2>&1 | tee -a "$LOG_FILE"
