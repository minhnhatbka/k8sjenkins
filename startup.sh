#!/bin/bash

# Add Docker Host Info
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
DATE_FORMAT="+%Y-%m-%d %H:%M:%S"

echo "Current environment is" $env_name
echo "Current application name is" $app_name
echo "Current country code is" $country_code
echo "Current java xmx is" $java_xmx
echo "Current java xms is" $java_xms

app_version=$(cat /image_info/app_version)
git_revision=$(cat /image_info/git_revision)
config_url="http://192.168.50.11:31991/minio"

echo "$(date "${DATE_FORMAT}") | Pulling Configuration"
cd /tmp
response_http=$(wget --server-response ${config_url}/${app_name}-${app_version}.zip 2>&1 | awk '/^  HTTP/{print $2}')
echo "$(date "${DATE_FORMAT}") | Http status when pulling configuration is ${response_http}"
if [[ ${response_http} != 200 ]]; then
	echo "$(date "${DATE_FORMAT}") | Failed : Cannot pull configure"
	sleep 2s
	exit 1
else
	echo "$(date "${DATE_FORMAT}") | Pulled Configuration"
	echo "$(date "${DATE_FORMAT}") | Extract Configuration file"
	tar -zxvf $app_name-$app_version.zip && mv /tmp/$app_name-$app_version/* /data/projects/$app_name/config/
	echo "$(date "${DATE_FORMAT}") | Extracted Configuration file"
	echo "$(date "${DATE_FORMAT}") | Check script file for get sensitive data from vault in folder config."	

	echo "$(date "${DATE_FORMAT}") | Start JMX Exporter."

	chown -R root:root /data/projects/$app_name/config

	echo "$(date "${DATE_FORMAT}") | Start Application."
	chmod +x /data/projects/$app_name/$app_name-$app_version.jar
	cd /data/projects/$app_name
	exec java -jar /data/projects/$app_name/$app_name-$app_version.jar
fi
