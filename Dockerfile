FROM openjdk:8-jdk-alpine
MAINTAINER nhattm2 "nhattm2@viettel.com.vn"

RUN mkdir -p /image_info
RUN echo "#app_version#" > /image_info/app_version && echo "#git_revision#" > /image_info/git_revision

RUN mkdir -p /data/logs/#app_name# && mkdir -p /data/projects/#app_name#/config
RUN useradd appservice -d /data/projects/#app_name# -s /sbin/nologin
RUN chmod 775 /data/logs /data/projects
RUN chown -R appservice:appservice /data/projects

#install Spring Boot artifact
COPY ./target/#app_name#-#app_version#.jar /data/projects/#app_name#

RUN mkdir -p /usr/script
COPY ./startup.sh /usr/script
RUN chmod 755 /usr/script/startup.sh

CMD ["/usr/script/startup.sh"]

