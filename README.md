# Sonarqube

## Description
Repository dedicated to sonarqube provisioning and automation related to that point.

## How to run

### Using podman
```
podman build -t sonarqube .
podman volume create sonar-data
podman volume create sonar-logs
podman volume create sonar-extensions
podman volume create sonar-temp
podman run -v sonar-data:/opt/sonarqube/data -v sonar-logs:/opt/sonarqube/logs -v sonar-extensions:/opt/sonarqube/extensions -v sonar-temp:/opt/sonarqube/temp sonarqube:latest
```

### Using OpenShift
```
./deploy-openshift.sh
```

## Known issues
Elasticsearch has one issue with user with UID and GUID 999, so we used a different one, 666. See [this](https://community.sonarsource.com/t/sonarqube-server-not-working-giving-accessdeniedexception/18208) reference in case of any doubts. To see some info and details about sonarqube see [oficial sonarqube dockerhub web page](https://hub.docker.com/_/sonarqube). If you don't know how to use volumes using podman see [Podman - Volumes 1/2](https://blog.while-true-do.io/podman-volumes-1/).

## In case of questions, please get in touch
jpmaida@redhat.com
