# This file has been created using https://github.com/lindycoder/prepopulated-mysql-container-example/blob/master/Dockerfile and modified to needs
FROM mariadb:latest as builder

# That file does the DB initialization but also runs mysql daemon, by removing the last line it will only init
RUN ["sed", "-i", "s/exec \"$@\"/echo \"not running $@\"/", "/usr/local/bin/docker-entrypoint.sh"]

# needed for intialization
ENV MYSQL_ROOT_PASSWORD=mariadb_root
ENV MYSQL_DATABASE=db_profile

COPY db_profile.sql /docker-entrypoint-initdb.d/

# Need to change the datadir to something else than /var/lib/mysql because the parent docker file defines it as a volume.
# https://docs.docker.com/engine/reference/builder/#volume :
#       Changing the volume from within the Dockerfile: If any build steps change the data within the volume after
#       it has been declared, those changes will be discarded.
RUN ["/usr/local/bin/docker-entrypoint.sh", "mysqld", "--datadir", "/initialized-db", "--aria-log-dir-path", "/initialized-db"]

FROM mariadb:latest

COPY --from=builder /initialized-db /var/lib/mysql
