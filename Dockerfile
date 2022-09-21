FROM registry.redhat.io/ubi8/openjdk-11

ENV SONAR_VERSION=9.6.1.59531 \
    SONARQUBE_HOME=/opt/sonarqube \
    SONARQUBE_JDBC_USERNAME=sonar \
    SONARQUBE_JDBC_PASSWORD=sonar \
    SONARQUBE_JDBC_URL=

USER root
EXPOSE 9000
ADD root /

RUN set -x \

	# pub   2048R/D26468DE 2015-05-25
	#       Key fingerprint = F118 2E81 C792 9289 21DB  CAB4 CFCA 4A29 D264 68DE
	# uid                  sonarsource_deployer (Sonarsource Deployer) <infra@sonarsource.com>
	# sub   2048R/06855C1D 2015-05-25
    && for server in $(shuf -e ha.pool.sks-keyservers.net \
                            hkp://p80.pool.sks-keyservers.net:80 \
                            keyserver.ubuntu.com \
                            hkp://keyserver.ubuntu.com:80 \
                            pgp.mit.edu) ; do \
        gpg --batch --keyserver "$server" --recv-keys F1182E81C792928921DBCAB4CFCA4A29D26468DE && break || : ; \
    done \
    && cd /opt \
    && curl -o sonarqube.zip -fSL https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip \
    && microdnf install unzip \
    && unzip -q sonarqube.zip \
    && mv sonarqube-$SONAR_VERSION sonarqube \
    && rm sonarqube.zip* \
    && rm -rf $SONARQUBE_HOME/bin/*

# elasticsearch has issue with user 999
RUN useradd -r -u 666 sonarqube
COPY run.sh $SONARQUBE_HOME/bin/
RUN /usr/bin/fix-permissions $SONARQUBE_HOME \
    && chmod 775 $SONARQUBE_HOME/bin/run.sh

USER sonarqube

WORKDIR $SONARQUBE_HOME

VOLUME "$SONARQUBE_HOME/data"
VOLUME "$SONARQUBE_HOME/logs"
VOLUME "$SONARQUBE_HOME/extensions"
VOLUME "$SONARQUBE_HOME/temp"

ENTRYPOINT ["./bin/run.sh"]
