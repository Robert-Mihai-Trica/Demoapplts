# Folosim imaginea oficială de Jenkins
FROM jenkins/jenkins:lts

# Instalăm Docker
USER root
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce-cli

# Instalăm Minikube
RUN curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
    chmod +x minikube && \
    mv minikube /usr/local/bin/

# Permiterea utilizatorului Jenkins să folosească Docker
RUN usermod -aG docker jenkins

# Configurăm Jenkins să ruleze pe portul 8383
ENV JENKINS_OPTS --httpPort=8383

# Expunem portul 8383
EXPOSE 8383

# Schimbăm înapoi utilizatorul Jenkins
USER jenkins

# Comandă de pornire Jenkins
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]
