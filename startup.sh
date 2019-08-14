#/bin/bash

# Add Docker Host Info
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
DATE_FORMAT="+%Y-%m-%d %H:%M:%S"

echo "Hello from nhattm2"
echo "Current environment is" $env_name
echo "Current application name is" $app_name

/usr/script/mc config host add minio http://192.168.50.11:31991 myaccesskey mysecretkey
echo "mc done"

app_version=$(cat /image_info/app_version)
git_revision=$(cat /image_info/git_revision)
config_url="http://192.168.50.11:31991/minio"

echo "$(date "${DATE_FORMAT}") | Pulling Configuration"
cd /tmp

/usr/script/mc cp minio/$env_name/alpha_106.zip .

echo "$(date "${DATE_FORMAT}") | Pulled Configuration"
echo "$(date "${DATE_FORMAT}") | Extract Configuration file"
mkdir alpha_106
tar -C alpha_106 -zxvf alpha_106.zip && mv /tmp/alpha_106/* /data/projects/$app_name/config/
echo "$(date "${DATE_FORMAT}") | Extracted Configuration file"
echo "$(date "${DATE_FORMAT}") | Check script file for get sensitive data from vault in folder config."	
echo "$(date "${DATE_FORMAT}") | Start JMX Exporter."
chown -R root:root /data/projects/$app_name/config
echo "$(date "${DATE_FORMAT}") | Start Application."
chmod +x /data/projects/$app_name/$app_name-$app_version.jar
cd /data/projects/$app_name
exec java -jar /data/projects/$app_name/$app_name-$app_version.jar
