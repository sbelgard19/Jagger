FROM ubuntu:18.04 
LABEL maintainer="belgard.scott@gmail.com"
RUN  apt-get -y update && apt-get -y install nginx

COPY files/default /etc/nginx/sites-available/default
COPY files/index.html /usr/share/nginx/html/index.html

COPY files/images/Jagger.jpg /usr/share/nginx/html/images/Jagger.jpg

EXPOSE 80
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]