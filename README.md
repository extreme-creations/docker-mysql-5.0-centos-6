
# Docker MySQL 5.0 (CentOS 6)
A dockerfile to build a container based on MySQL 5.0 (CentOS 6.9) for legacy applications.

Much of this is borrowed from the [official MySQL docker images](https://github.com/docker-library/mysql/).

All the dependencies including MySQL client and server libraries are included in this repo in case they are later removed from remote servers.

## Environment Variables
On first run the container will configure MySQL based on the following environment variables:

### `MYSQL_ROOT_PASSWORD`

This variable is mandatory and specifies the password that will be set for the MySQL `root` superuser account. In the above example, it was set to `my-secret-pw`.

### `MYSQL_DATABASE`

This variable is optional and allows you to specify the name of a database to be created on image startup. If a user/password was supplied (see below) then that user will be granted superuser access ([corresponding to `GRANT ALL`](http://dev.mysql.com/doc/en/adding-users.html)) to this database.

### `MYSQL_USER`, `MYSQL_PASSWORD`

These variables are optional, used in conjunction to create a new user and to set that user's password. This user will be granted superuser permissions (see above) for the database specified by the `MYSQL_DATABASE` variable. Both variables are required for a user to be created.

Do note that there is no need to use this mechanism to create the root superuser, that user gets created by default with the password specified by the `MYSQL_ROOT_PASSWORD` variable.

## Scripts / Data Import
On first run, any files found in `/docker-entrypoint-initdb.d` with extensions `.sh`, `.sql` and `.sql.gz` will be executed.

Files will be executed in alphabetical order. You can easily populate your `mysql` services by [mounting a SQL dump into that directory](https://docs.docker.com/engine/tutorials/dockervolumes/#mount-a-host-file-as-a-data-volume) and provide [custom images](https://docs.docker.com/reference/builder/) with contributed data. SQL files will be imported by default to the database specified by the `MYSQL_DATABASE` variable.

## Example Build Command

`docker build -t mysql5.0-centos .`

## Example Docker Compose File

The following example docker compose file demonstrates how you can use the environment variables to setup a MySQL container based on this image.

    version: "2.2"
    services:
      mysql:
          image: mysql5.0-centos
          environment:
            - MYSQL_ROOT_HOST=%
            - MYSQL_ROOT_PASSWORD=YOUR_ROOT_PW_HERE
            - MYSQL_DATABASE=YOUR_DB_HERE
            - MYSQL_USER=YOUR_DB_USER_HERE
            - MYSQL_PASSWORD=YOUR_DB_PW_HERE
            - MYSQL_ALLOW_EMPTY_PASSWORD=no
          ports:
            - "3306:3306"
          command: mysqld
          volumes:
            - mysqldata:/var/lib/mysql
            - ./db/initial:/docker-entrypoint-initdb.d
          tmpfs:
            - /tmp:exec,mode=777
    volumes:
      mysqldata:

By placing a database dump such as my-database.sql in `/db/initial` a database and corresponding user and password will be created for you based on the details provided in the environment variables.
