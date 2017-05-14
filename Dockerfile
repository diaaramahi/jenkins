FROM debian
MAINTAINER Diaa Ramahi <diaa.ramahi@gmail.com>

################# Install Need ###################
RUN apt-get update && \
      apt-get -y install sudo

#RUN apt-get install -y sudo
RUN apt-get install wget -y
RUN sudo apt-get install apache2 -y
RUN sudo apt-get install python python-pip -y
RUN sudo pip install awscli
RUN sudo apt-get update -y
RUN sudo apt-get install jq -y

##################################################

############## Install Jenkins ###################
RUN wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
RUN sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
RUN sudo apt-get update -y
RUN sudo apt-get install jenkins -y
RUN sudo apt-get install default-jre -y
RUN sudo apt-get install default-jdk -y
RUN chown -R jenkins:jenkins /var/lib/jenkins
##################################################


##################################################
#RUN sudo add-apt-repository ppa:git-core/ppa
RUN sudo apt-get update -y
RUN sudo apt-get install git-core -y
##################################################

######### Install Elastic file system ############
RUN sudo apt-get install nfs-common -y
# EFS_URL - URL of the elastic file system
RUN sudo mkdir /lamsa-efs

ADD jenkins /etc/sysconfig/jenkins
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
USER jenkins

CMD sudo apt-get update -y && \
sudo apt-get upgrade jenkins -y && \
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${EFS_URL}:/ lamsa-efs && \
mount --bind --verbose /lamsa-efs/debian/jenkins_home /var/lib/jenkins && \
mount --bind --verbose /lamsa-efs/debian/cache/jenkins /var/cache/jenkins && \
sudo service apache2 start && sudo service jenkins start && tail -f /var/log/apache2/error.log
##################################################

EXPOSE 8080 80 50000