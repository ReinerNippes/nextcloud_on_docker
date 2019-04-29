Install Nextcloud (Latest) + Database (MariaDB/PostgreSQL/SQLite) + Encryption (Let's Encrypt Certificate/Self-signed) on Docker
================================================
100% Handsfree & Ready to login

Right now this will run on Ubuntu 16/18, Debian 9, CentOS 7. Maybe on Redhat 7. 
The script is prepared for Raspbian and CoreOS. But this is still under development (pre-alpha).

Preparation
-----

Clone this repo and change into the directory nextcloud_on_docker.
```
git clone https://github.com/ReinerNippes/nextcloud_on_docker

cd nextcloud_on_docker
```

Install [Ansible](https://www.ansible.com/) and some needed tools by running the following command with a user that can sudo or is root.
```
./prepare_system.sh
```

Configuration
----
Now you can configure the whole thing by editing the file `inventory` and some other files.

### Preliminary variables

First of all you must define the server fqdn. If you want to get a Let's Encrypt certificate this must be a valid DNS record pointing to your server, and port 80+443 must be open to the internet. If you have a private server or if you use an AWS domain name like `ec2-52-3-229-194.compute-1.amazonaws.com` for example, you'll end up with a self-signed certificate. Which is fine but annoying because you have to accept this certificate manually in your browser. If you don't have a fqdn use the server IP address.
```
# Your domain name to get a Let's Encrypt certificate
nextcloud_server_fqdn       = nextcloud.example.tld
```

Let's Encrypt wants your email address. Enter it here:
```
# Your email address for Let's Encrypt
ssl_cert_email              = nextcloud@example.tld
```

Choose a DNS resolver.
(e.g. your fritz.box ; default is ccc 213.73.91.35 (germany) - 216.87.84.211 OpenNIC (usa))
```
# Your DNS resolver (nginx reverse ip lookup)
nginx_resolver              = '213.73.91.35 216.87.84.211 valid=30s'
```

### Nextcloud variables

Where do you want to find your Nextcloud program, config, database and data files in the hosts filesystem.
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

Your favorite database, name, user and password. 
The db password will be generated and stored in {{ nextcloud_base_dir }}/secrets. In case you need it
```
# database settings (choose one)
nextcloud_db_type           = 'pgsql'         # (PostgreSQL)
# nextcloud_db_type         = 'mysql'         # (MariaDB)
# nextcloud_db_type         = 'sqlite'        # (SQLite)

# options for mariadb or postgres
nextcloud_db_host           = 'localhost'
nextcloud_db_name           = 'nextcloud'
nextcloud_db_user           = 'nextcloud'
nextcloud_db_passwd         = ''              # leave empty to generate random password
nextcloud_db_prefix         = 'oc_'
```
### Optional variables

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
talk_install         = true
```

If you want to access your database through an admin web page set this value to true
```
# adminer is a webfront end for your database at https://nextcloud_server_fqdn/adminer/
adminer_enabled      = false
```

If you want to install a webgui for docker set this value to true
```
# portainer is a webfront end for docker host at https://nextcloud_server_fqdn/portainer/
portainer_enabled    = true
portainer_passwd     = ''              # leave empty to generate random password
```

If you want to access your traefik dashboard uncomment the traefik_api_user
```
# user for traefik dashboard at https://nextcloud_server_fqdn/traefik/
# traefik_api_user      = traefik
```

Installation
-----
Run the ansible playbook.
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

Your data won't be deleted. You have to do this manually by 
```
rm -rf ....
```
