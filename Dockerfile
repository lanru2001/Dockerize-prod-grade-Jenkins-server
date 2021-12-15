# Define your base image as jenkins/jenkins:lts and remember to restart the container to start all the plugins from plugin manager cli
FROM jenkins/jenkins:lts
MAINTAINER azeez.olanrewaju@sysnetgs.com
USER root

RUN apt-get update && \
    apt-get -y install apt-transport-https \
      ca-certificates \
      wget \
      vim \
      zip \
      unzip \
      curl \
      software-properties-common && \
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
    add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
      $(lsb_release -cs) \
      stable" && \
   apt-get update && \
   apt-get -y install docker-ce

#Plugin installation manager CLI
RUN jenkins-plugin-cli --plugins pipeline-model-definition github-branch-source:1.8

# install jenkins plugins
COPY ./jenkins-plugins /usr/share/jenkins/plugins
RUN while read i ; \
                do /usr/local/bin/install-plugins.sh $i ; \
        done < /usr/share/jenkins/plugins

# Install "software-properties-common" (for the "add-apt-repository")
RUN apt-get update -y  && apt-get install -y \
    software-properties-common

# Install OpenJDK-8
RUN apt-get update && \
    apt-get clean


# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /opt/java/openjdk/bin/java
RUN export JAVA_HOME
RUN echo  java -version

#Set Oracle Java8 as the default Java
#RUN update-java-alternatives -s java-8-oracle
RUN echo "export JAVA_HOME=/opt/java/openjdk/bin/java" >> ~/.bashrc   

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Install gradle 
#ENV GRADLE_VERSION=7.0

#RUN wget https://services.gradle.org/distributions/gradle-${VERSION}-bin.zip -P /tmp
#RUN unzip -d /opt/gradle /tmp/gradle-${VERSION}-bin.zip
#RUN ln -s /opt/gradle/gradle-${VERSION} /opt/gradle/latest

#Update and upgrade all packages to latest 
RUN apt-get update -y && apt-get upgrade -y 

#Update the username and password
#ENV JENKINS_USER admin
#ENV JENKINS_PASS ThisIs@StrongP@ssword

#id_rsa.pub file will be saved at /root/.ssh/
#RUN ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''

# allows to skip Jenkins setup wizard
#ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Jenkins runs all grovy files from init.groovy.d dir
# use this for creating default admin user
#COPY default-user.groovy /usr/share/jenkins/ref/init.groovy.d/

VOLUME /var/jenkins_home
EXPOSE 8080 50000
