#!/bin/bash
#
# Author  Anrip <mail@anrip.com>
# Website http://www.anrip.com/post/1811
#
 
if [ ! `which docker` ]; then
    wget -qO- https://get.docker.com/ | sh
fi
 
docker pull sameersbn/redis:latest
docker pull sameersbn/mysql:latest
docker pull sameersbn/gitlab:latest
docker pull sameersbn/redmine:latest
 
docker run --name app-redis -d \
    --publish 127.8.9.1:6379:6379 \
    --volume /srv/docker/app-redis:/var/lib/redis \
    sameersbn/redis
 
docker run --name app-mysql -d \
    --env 'MYSQL_CHARSET=utf8' \
    --env 'MYSQL_COLLATION=utf8_general_ci' \
    --env 'DB_REMOTE_ROOT_NAME=root' \
    --env 'DB_REMOTE_ROOT_PASS=password' \
    --publish 127.8.9.1:3306:3306 \
    --volume /srv/docker/app-mysql:/var/lib/mysql \
    sameersbn/mysql
 
MYSQL_CHARSET="DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci"
cat > /srv/docker/app-mysql/init.sql <<EOF
    CREATE USER 'gitlab'@'%.%.%.%' IDENTIFIED BY 'password';
    CREATE DATABASE IF NOT EXISTS gitlabhq_production ${MYSQL_CHARSET};
    GRANT ALL PRIVILEGES ON \`gitlabhq_production\`.* TO 'gitlab'@'%.%.%.%';
    CREATE USER 'redmine'@'%.%.%.%' IDENTIFIED BY 'password';
    CREATE DATABASE IF NOT EXISTS redmine_production ${MYSQL_CHARSET};
    GRANT ALL PRIVILEGES ON \`redmine_production\`.* TO 'redmine'@'%.%.%.%';
EOF
 
sleep 30
docker exec -it app-mysql mysql "-e source /var/lib/mysql/init.sql"
rm -rf /srv/docker/app-mysql/init.sql
 
docker run --name app-gitlab -d \
    --link app-mysql:mysql \
    --link app-redis:redisio \
    --env 'GITLAB_SSH_PORT=22' \
    --env 'GITLAB_PORT=80' \
    --env 'GITLAB_HOST=team.vmlu.com' \
    --env 'GITLAB_RELATIVE_URL_ROOT=/gitlab' \
    --env 'GITLAB_EMAIL=team@anrip.com' \
    --env 'GITLAB_EMAIL_DISPLAY_NAME=Vmlu Team' \
    --env 'GITLAB_SECRETS_DB_KEY_BASE=long-and-random-alpha-numeric-string' \
    --env 'GITLAB_USERNAME_CHANGE=false' \
    --env 'UNICORN_TIMEOUT=120' \
    --env 'SMTP_DOMAIN=anrip.com' \
    --env 'SMTP_HOST=smtp.exmail.qq.com' \
    --env 'SMTP_PORT=587' \
    --env 'SMTP_USER=team@anrip.com' \
    --env 'SMTP_PASS=password' \
    --env 'DB_HOST=mysql' \
    --env 'DB_USER=gitlab' \
    --env 'DB_PASS=password' \
    --publish 127.8.9.3:22:22 \
    --publish 127.8.9.3:80:80 \
    --volume /srv/docker/app-gitlab:/home/git/data \
    sameersbn/gitlab
 
docker run --name app-redmine -d \
    --link app-mysql:mysql \
    --env 'REDMINE_PORT=80' \
    --env 'REDMINE_RELATIVE_URL_ROOT=/redmine' \
    --env 'SMTP_DOMAIN=anrip.com' \
    --env 'SMTP_HOST=smtp.exmail.qq.com' \
    --env 'SMTP_PORT=587' \
    --env 'SMTP_USER=team@anrip.com' \
    --env 'SMTP_PASS=password' \
    --env 'DB_HOST=mysql' \
    --env 'DB_USER=redmine' \
    --env 'DB_PASS=password' \
    --publish 127.8.9.2:80:80 \
    --volume /srv/docker/app-redmine:/home/redmine/data \
    sameersbn/redmine
 
#sudo aptitude install -y rinetd
#sudo echo "12.34.56.78 22 127.8.9.3 22" >>/etc/rinetd.conf
