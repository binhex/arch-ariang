#!/usr/bin/dumb-init /bin/bash
# shellcheck shell=bash

set -euo pipefail

# common
install_path="/opt/aria2"

# aria2
aria2_logs_path="/config/aria2/logs"
aria2_config_path="/config/aria2/configs"
aria2_cookies_path="/config/aria2/cookies"
aria2_sessions_path="/config/aria2/sessions"
aria2_downloads_path="/config/aria2/downloads"
aria2_rpc_secret_path="/config/aria2/secrets"
aria2_log_filepath="${aria2_logs_path}/aria2.log"
aria2_config_filepath="${aria2_config_path}/aria2.conf"
aria2_rpc_secret_filepath="${aria2_rpc_secret_path}/rpc-secret"
aria2_cookies_filepath="${aria2_cookies_path}/cookies.txt"

# nginx
nginx_config_path="/config/nginx/configs"
nginx_config_filepath="${nginx_config_path}/nginx.conf"
nginx_pid_filepath="${nginx_config_path}/nginx.pid"

# functions
function generate_rpc_secret() {
	od -An -tx1 -N16 /dev/urandom | tr -d ' \n'
}

function resolve_rpc_secret() {

	# user supplied secret via env var takes precedence
	if [[ -n "${ARIA2_RPC_SECRET:-}" ]]; then
		rpc_secret="${ARIA2_RPC_SECRET}"
		echo "[info] Using RPC secret from 'ARIA2_RPC_SECRET'..."
		return 0
	fi

	# secret generated on a previous start
	if [[ -s "${aria2_rpc_secret_filepath}" ]]; then
		rpc_secret=$(cat "${aria2_rpc_secret_filepath}")
		echo "[info] Using RPC secret from '${aria2_rpc_secret_filepath}'..."
		return 0
	fi

	# secret already configured in aria2.conf, leave rpc_secret empty so the config value is used
	if grep -qE '^[[:space:]]*rpc-secret[[:space:]]*=' "${aria2_config_filepath}"; then
		echo "[info] Using RPC secret configured in '${aria2_config_filepath}'..."
		return 0
	fi

	# no secret configured, generate one and persist it for reuse on restart
	rpc_secret=$(generate_rpc_secret)
	printf '%s' "${rpc_secret}" > "${aria2_rpc_secret_filepath}"
	chmod 600 "${aria2_rpc_secret_filepath}"
	echo "[info] Generated RPC secret and stored it in '${aria2_rpc_secret_filepath}'..."
}

# create paths
mkdir -p "${aria2_logs_path}" "${aria2_config_path}" "${nginx_config_path}" "${aria2_downloads_path}" "${aria2_cookies_path}" "${aria2_sessions_path}" "${aria2_rpc_secret_path}"
chmod 700 "${aria2_rpc_secret_path}"

# default nginx
if [[ ! -f "${nginx_config_filepath}" ]]; then
	echo "[info] No nginx config file found, copying default config file to ${nginx_config_filepath}..."
	cp -f "/home/nobody/nginx/nginx.conf" "${nginx_config_filepath}"
fi

# default aria2
if [[ ! -f "${aria2_config_filepath}" ]]; then
	echo "[info] No aria2 config file found, copying default config file to ${aria2_config_filepath}..."
	cp -f "/home/nobody/aria2/aria2.conf" "${aria2_config_filepath}"
fi

# empty cookies file
if [[ ! -f "${aria2_cookies_filepath}" ]]; then
	echo "[info] No aria2 cookies file found, creating empty file at ${aria2_cookies_filepath}..."
	touch "${aria2_cookies_filepath}"
fi

echo "[info] Starting aria2c..."

# command line options override the values in aria2.conf
aria2_parameters=(
	"--conf-path=${aria2_config_filepath}"
	"--log=${aria2_log_filepath}"
)

# secure the rpc interface, an empty value leaves any secret already set in aria2.conf in place
rpc_secret=''
resolve_rpc_secret

if [[ -n "${rpc_secret}" ]]; then
	aria2_parameters+=("--rpc-secret=${rpc_secret}")
fi

"${install_path}/aria2c" "${aria2_parameters[@]}" &

echo "[info] Starting nginx..."
cd "${install_path}" && nginx -g "pid ${nginx_pid_filepath}; daemon off;" -c "${nginx_config_filepath}"
