env_version=$1
app_name=$2

unzip -qq sonar.zip -d ..

cd ..

sonar/bin/sonar-scanner -Dsonar.projectKey=hello -Dsonar.sources=demo -Dsonar.host.url=http://10.58.244.249:9100 -Dsonar.login=7755d9298fc0967bce54399fd4715e0f31b6808c -Dsonar.projectBaseDir=. -Dsonar.language=java -Dsonar.java.binaries=demo/target/classes &> sonar.log && \
sleep 1 && \
report_link=`grep "More about the report processing at" sonar.log |grep -o "http.*"` && \
sleep 1 && \
curl $report_link &> sonar2.log;


if grep -q '"status":"FAILED"' sonar2.log
then
        cat sonar2.log ;
	exit 1;
else
        cat sonar2.log ;
        echo "sonar done";
fi
