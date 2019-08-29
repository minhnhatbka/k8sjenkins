env_version=$1
app_name=$2

cd ..

unzip -qq k8sjenkins/flyway.zip -d k8sjenkins
cp db/$env_version/$app_name/conf/flyway.conf k8sjenkins/flyway/conf/flyway.conf
cp -R db/alpha/demo/sql/ k8sjenkins/flyway/
chmod 755 ./k8sjenkins/flyway/flyway
./k8sjenkins/flyway/flyway repair
./k8sjenkins/flyway/flyway migrate &> flyway.log

if grep -q "Successfully applied" flyway.log
then
        echo "Successfully applied";
elif grep -q "is up to date. No migration necessary." flyway.log
then
	echo "No migration necessary";
else
	cat flyway.log ;
        echo "nok";
	echo "rollback :( ";
	rm  k8sjenkins/flyway/sql/* ;
	cp -R db/alpha/demo/rollback/* k8sjenkins/flyway/sql/ ;
	./k8sjenkins/flyway/flyway repair ;
	./k8sjenkins/flyway/flyway migrate &> rollback_flyway.log ;
	echo "rollback log" ;
	cat rollback_flyway.log	;
        exit 1
fi
