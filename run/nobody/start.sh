#!/usr/bin/dumb-init /bin/bash

# common
install_path="/opt/aria2"

# aria2
aria2_logs_path="/config/aria2/logs"
aria2_config_path="/config/aria2/configs"
aria2_cookies_path="/config/aria2/cookies"
aria2_sessions_path="/config/aria2/sessions"
aria2_downloads_path="/config/aria2/downloads"
aria2_log_filepath="${aria2_logs_path}/aria2.log"
aria2_config_filepath="${aria2_config_path}/aria2.conf"
aria2_cookies_filepath="${aria2_cookies_path}/cookies.txt"

# nginx
nginx_config_path="/config/nginx/configs"
nginx_config_filepath="${nginx_config_path}/nginx.conf"
nginx_pid_filepath="${nginx_config_path}/nginx.pid"

# create paths
mkdir -p "${aria2_logs_path}" "${aria2_config_path}" "${nginx_config_path}" "${aria2_downloads_path}" "${aria2_cookies_path}" "${aria2_sessions_path}"

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
"${install_path}/aria2c" --conf-path="${aria2_config_filepath}" --dir="${aria2_downloads_path}" --log-level=notice --log="${aria2_log_filepath}" &

echo "[info] Starting nginx..."
cd "${install_path}" && nginx -g "pid ${nginx_pid_filepath}; daemon off;" -c "${nginx_config_filepath}"
