#!/usr/bin/env bash

#Variables loaded via YAML in the vagrantfile are passed as:
# $1 = hostname
# $2 = ip
# $2 = dbHost
# $4 = dbName
# $5 = dbUser
# $6 = dbPass
# $7 = dbRootPass

# Ensures if the specified file is present and the md5 checksum is equal
ensureFilePresentMd5 () {
    source=$1
    target=$2
    if [ "$3" != "" ]; then description=" $3"; else description=" $source"; fi
 
    md5source=`md5sum ${source} | awk '{ print $1 }'`
    if [ -f "$target" ]; then md5target=`md5sum $target | awk '{ print $1 }'`; else md5target=""; fi

    if [ "$md5source" != "$md5target" ];
    then
        echo "Provisioning $description file to $target..."
        cp $source $target
        echo "...done"
        return 1
    else
        return 0
    fi
}

provision() {
  #Apache
  apt-get update
  apt-get install -y apache2
  rm -rf /var/www
  ln -fs /vagrant /var/www
  sudo a2enmod rewrite
  # Apache conf overrides
  ensureFilePresentMd5 /vagrant/projectProvision/apache2.conf /etc/apache2/apache2.conf "custom httpd settings"
  ensureFilePresentMd5 /vagrant/projectProvision/envvars /etc/apache2/envvars "custom httpd settings"
  ensureFilePresentMd5 /vagrant/projectProvision/000-default.conf /etc/apache2/sites-available/000-default.conf "custom vhost settings"

  #MySQL
  apt-get install debconf-utils -y
  #One of these pairs worked. All three pairs are not needed. Figure out which one works and remove the others
  debconf-set-selections <<< "mysql-server-5.5 mysql-server-5.5/root_password password $7"
  debconf-set-selections <<< "mysql-server-5.5 mysql-server-5.5/root_password_again password $7"
  debconf-set-selections <<< "mysql-server mysql-server/root_password password $7"
  debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $7"
  debconf-set-selections <<< "mysql-server mysql-server-5.5/root_password password $7"
  debconf-set-selections <<< "mysql-server mysql-server-5.5/root_password_again password $7"
  sudo apt-get install -y mysql-server-5.5 libapache2-mod-auth-mysql
  # MySQL conf overrides
  ensureFilePresentMd5 /vagrant/projectProvision/my.cnf /etc/mysql/my.cnf "custom mysql settings"
  #restart Apache/PHP
  echo "Restarting MySQL..."; sudo service mysql restart; echo "...done";
  #create the project's db
  mysql -u root -p$7 -h $3 -Bse "CREATE DATABASE $4;"
  echo "Database $4 Created";
  #grant access, Commands differ if there is a password or not. 
  if [ "$6" = "" ]
    then
      mysql -u root -p$7 -h $3 -Bse "GRANT ALL ON $4.* to $5@'%';"
      echo "Database: User $5 granted access to db and a password was not set"; 
      #import the db. 
      if [ -f /vagrant/mysqlImport.sql ]
        then
          #import the db. 
          mysql -u $5 $4 < /vagrant/mysqlImport.sql
          echo "Database imported - sql user password not used";
        else
          echo "A SQL Import script was not found - no data imported.";
      fi
    else
      mysql -u root -p$7 -h $3 -Bse "GRANT ALL ON $4.* to $5@'%' IDENTIFIED BY '$6';"
      echo "Database: User $5 granted access to db and a password was set";
      if [ -f /vagrant/mysqlImport.sql ]
        then
          #import the db. 
          mysql -u $5 -p$6 $4 < /vagrant/mysqlImport.sql
          echo "Database imported - sql user password was used";
        else
          echo "A SQL Import script was not found - no data imported.";
      fi
  fi

  #PHP
  apt-get install -y php5 libapache2-mod-php5 php5-mcrypt
  apt-get install -y php5-curl
  apt-get install -y php5-gd
  apt-get install -y php5-mysql
  apt-get install -y php5-xmlrpc
  apt-get install -y php5-tidy
  #apt-get install php5-sqlite
  apt-get install -y php5-mcrypt
  apt-get install -y php5-xdebug
  apt-get install -y php5-xhprof
  apt-get install -y php5-json

  # PHP conf overrides
  ensureFilePresentMd5 /vagrant/projectProvision/php.ini /etc/php5/apache2/php.ini "custom php settings"

  #restart Apache/PHP
  echo "Restarting Apache/PHP..."; sudo service apache2 restart; echo "...done";

  #GIT
  sudo apt-get install -y git

  #Drush
  sudo apt-get install -y php-pear
  sudo pear channel-discover pear.drush.org
  sudo pear install drush/drush
  sudo drush version

  #Fixes Permissions Issue
  sudo chmod 0755 /var/www/html/
  sudo chmod 0755 /vagrant/html/
}

provision $1 $2 $3 $4 $5 $6 $7