Install Latest Nextclod + Mariadb/Postgres/Sqlite + A+ Certificate or Selfsigned - 100% Handsfree on Docker -> Ready to login
================================================

Usage
-----

Clone this repo and change into the directory nextcloud_on_docker.

```
git clone https://github.com/ReinerNippes/nextcloud_on_docker

cd nextcloud_on_docker
```  

Install ansible and some needed tools by runing with a user that can sudo or is root.

```
./prepare_system.sh
```

Right now this will run on Ubuntu 16/18, Debian 9, CentOS 7. Maybe on Redhat 7. 
The script is prepared for Raspbian and CoreOS. But this is still under development. Pre-Alpha.

Now you can configure the whole thing by editing the file `inventory` and some other files.

First of all you must define the server fqdn. If you want to get a Letsencrypt certificate this must be a valid DNS record pointing to your server and port 80+443 must be open to the internet.
If you have a private server or you use for example an AWS domain name like `ec2-52-3-229-194.compute-1.amazonaws.com` you'll end up with a selfsigned certificate.Which is fine but anoying because you have to accept this certificate manuall in your browser.
If you don't have a fqdn use the server IP address.

```
# Your domain name to get a letsencrypt certificate
nextcloud_server_fqdn       = nextcloud.example.org
```

Letsencrypt wants your email address. Enter it here:
```
# Your email adresse for letsencrypt
ssl_cert_email = nextcloud@example.org
```

Where to you want to find your nextcloud program, config, database and data files in the hosts filesystem. 
```
# data dir
nextcloud_base_dir          = /opt/nextcloud
```

Define your admin user. Leave the password empty and a random one will be generated and displayed at the end of the playbook run.
```

# admin user
nextcloud_admin             = 'admin'
nextcloud_passwd            = ''
```

Your favourite database, name, user and password. 
The db password will be generated and stored in {{ nextcloud_base_dir }}/secrets. In case you need it
```
# database settings (choose one)
# nextcloud_db_type           = 'mysql'        # (MariaDB)
# nextcloud_db_type           = 'pgsql'        # (PostgreSQL)

nextcloud_db_type           = 'sqlite'        # (SQLite)

# options for mariadb or postgres
nextcloud_db_host           = 'localhost'
nextcloud_db_name           = 'nextcloud'
nextcloud_db_user           = 'nextcloud'
nextcloud_db_prefix         = 'oc_'
```
If you want to setup the nextcloud mail system put your mail server config here.
```
# Nextcloud mail setup
nextcloud_configure_mail    = false
nextcloud_mail_from         =
nextcloud_mail_smtpmode     = smtp
nextcloud_mail_smtpauthtype = LOGIN
nextcloud_mail_domain       =
nextcloud_mail_smtpname     =
nextcloud_mail_smtpsecure   = tls
nextcloud_mail_smtpauth     = 1
nextcloud_mail_smtphost     =
nextcloud_mail_smtpport     = 587
nextcloud_mail_smtpname     =
nextcloud_mail_smtppwd      =
```

Backup will come soon.
```
# Install restic backup tool if backup_folder is not empty
# more info about restic: https://restic.readthedocs.io/en/latest/
backup_folder        = '' # e.g. /var/nc-backup
# crontab settings restic for restic
backup_day           = *
backup_hour          = 4
backup_minute        = 0
```

Online office and Talk support as well.
```
# Enable an Online Office Suite [collabora|onlyoffice|none]
# more info about collabora office: https://www.collaboraoffice.com/
# more info about onlyoffice office: https://www.onlyoffice.com

online_office     = none
# online_office     = collabora
# online_office     = onlyoffice

# Install turn server for Nextcloud Talk
# talk_install         = true
```

If you want to access your databaes through an admin web page set this value to true
```
# adminer is a webfront end for your database at https://nextcloud_server_fqdn/adminer
adminer_enabled      = falsee
```

If you want to access your traeifk dashboard uncomment the traefik_api_user
```
# user for traefik dashboard at https://nextcloud_server_fqdn/traefik
# traefik_api_user      = traefik
```

Run the ansible playbook book.

```
ansible-playbook nextdocker.yml
```

Your nextcloud access credentials will be displayed at the end of the run.

```
ok: [localhost] => {
    "msg": [
        "Your Nextcloud at https://nextcloud.example.org is ready.",
        "Login with user: admin and password: fTkLgvPYdmjfalP8XgMsEg7plnoPsTvp ",
        "Other secrets you'll find in the directory /opt/nextcloud/secrets "
    ]
}
```

If you want to get rid of the container run
```
ansible-playbook nextdocker.yml -e state=absent
```

Your data won't be deleted. You have to do this manually by rm -rf ....
