#!/usr/bin/env bash
set -euo pipefail

script_name="${0##*/}"

bold="$(tput bold)"
normal="$(tput sgr0)"

config_dir="/etc/nginx/sites-available"
symlink_dir="/etc/nginx/sites-enabled"

default_template="/etc/nginx/snippets/server.conf.template"


help() {
    echo "${bold}Usage:${normal} ${script_name} <config_name> <domain> <backend>"
    echo
    echo "${bold}Arguments:${normal}"
    echo "  config_name   Name of the Nginx config"
    echo "  domain        Domain name"
    echo "  backend       HTTP backend host"
    echo
    echo "${bold}Options:${normal}"
    echo "  -h, --help    Show this help message"
    echo
    echo "${bold}Example:${normal}"
    echo "   ${script_name} git git.mysite.org 127.0.0.1:8000"
}


confirm_overwrite() {
    local file_kind="$1"
    local file_path="$2"

    echo "${file_kind} '${file_path}' already exists."
    echo -n "${bold}Do you want to overwrite it?${normal} [y/N] "
    read -r answer

    if [[ "$answer" != [yY] ]]; then
        exit 130
    fi
}


parse_args() {
    if [[ $# -eq 1 && ("$1" == "-h" || "$1" == "--help") ]]; then
        help
        exit 0
    fi

    if [[ $# -ne 3 ]]; then
        help >&2
        exit 2
    fi

    config_name="$1"
    domain="$2"
    backend="$3"

    if [[ "$config_name" == *_* ]]; then
        echo "${bold}Error:${normal} config_name must not contain underscores: '$config_name'" >&2
        exit 2
    fi
}


generate_config() {
    local config_name="$1"
    local domain="$2"
    local backend="$3"

    local config_path="${config_dir}/${config_name}.conf"
    local upstream_name="${config_name//./_}"

    mkdir -p "$(dirname "$config_path")"

    if [[ -e "$config_path" || -L "$config_path" ]]; then
        confirm_overwrite "Nginx config" "$config_path"
        echo
    fi

    export UPSTREAM_NAME="$upstream_name"
    export DOMAIN="$domain"
    export BACKEND="$backend"

    if [[ -f "$custom_template" ]]; then
        envsubst '${UPSTREAM_NAME} ${DOMAIN} ${BACKEND}' < "$custom_template" > "$config_path"

        echo "${bold}Nginx config '${config_path}' was generated using the custom template:${normal}"
        echo "${custom_template}"
        echo
        echo "${bold}If you do not want custom settings, please remove or rename the custom template and run:${normal}"
        echo "${script_name} $*"
        echo
        echo "${bold}The default template will then be used:${normal}"
        echo "${default_template}"
    else
        envsubst '${UPSTREAM_NAME} ${DOMAIN} ${BACKEND}' < "$default_template" > "$config_path"

        echo "${bold}Nginx config '${config_path}' was generated using the default template:${normal}"
        echo "${default_template}"
        echo
        echo "${bold}If you want to use your own config, please create:${normal}"
        echo "${custom_template}"
        echo
        echo "${bold}And run:${normal}"
        echo "${script_name} $*"
    fi
}


create_symlink() {
    local config_name="$1"

    local source="${config_dir}/${config_name}.conf"
    local link="${symlink_dir}/${config_name}.conf"

    if [[ -e "$link" || -L "$link" ]]; then
        echo
        confirm_overwrite "Symbolic link" "$link"
    fi

    mkdir -p "$(dirname "$link")"

    ln -sf "$source" "$link"
}


main() {
    parse_args "$@"

    custom_template="${config_dir}/${config_name}.conf.template"

    generate_config "$config_name" "$domain" "$backend"
    create_symlink "$config_name"
}


main "$@"
