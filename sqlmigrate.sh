env_version=$1
app_name=$2

cd ..

unzip k8sjenkins/flyway.zip -d k8sjenkins
cp db/$env_version/$app_name/conf/flyway.conf k8sjenkins/flyway/conf/flyway.conf
cp -R db/alpha/demo/sql/ k8sjenkins/flyway/
chmod 755 ./k8sjenkins/flyway/flyway
./k8sjenkins/flyway/flyway migrate &> flyway.log

if grep -q Successfully flyway.log
then
        echo "ok";
else
        echo "nok";
        exit 1
fi
