#!/bin/bash

NAMESPACE=$1
if [ "$NAMESPACE" == "" ]; then
    NAMESPACE='sonarqube-custom'
fi

oc project $NAMESPACE &>/dev/null
if [ $? -eq 1 ]; then
    echo "You must create a namespace first."
else
    echo "############################################################"
    echo "Importing image"
    echo "############################################################"
    oc -n $NAMESPACE import-image openjdk/openjdk-11-rhel7:1.12-1.1658422675 --from=registry.redhat.io/openjdk/openjdk-11-rhel7:1.12-1.1658422675 --confirm

    echo "############################################################"
    echo "Creating build"
    echo "############################################################"
    oc -n $NAMESPACE new-build . --name=sonarqube --strategy=docker -l "app=sonarqube"

    echo "############################################################"
    echo "Starting build"
    echo "############################################################"
    oc -n $NAMESPACE start-build bc/sonarqube --from-dir=. -w -F

    echo "############################################################"
    echo "Creating database"
    echo "############################################################"
    oc new-app --template=postgresql-persistent -p POSTGRESQL_USER=sonar -p POSTGRESQL_PASSWORD=sonar -p POSTGRESQL_DATABASE=sonarqube -n $NAMESPACE

    echo "############################################################"
    echo "Creating app"
    echo "############################################################"
    oc new-app --name=sonarqube --image-stream=sonarqube -l "app=sonarqube" -n $NAMESPACE
    oc -n $NAMESPACE set env deployment sonarqube SONAR_VERSION=7.9.1 SONARQUBE_JDBC_USERNAME=sonar SONARQUBE_JDBC_PASSWORD=sonar SONARQUBE_JDBC_URL="jdbc:postgresql://postgresql.$NAMESPACE.svc.cluster.local/sonarqube" SONAR_LOG_LEVEL=INFO
    oc -n $NAMESPACE create route edge --service=sonarqube --port=9000 --insecure-policy=Allow
fi
