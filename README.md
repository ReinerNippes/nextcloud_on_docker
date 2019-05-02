# Install Nextcloud (Latest) + Database (MariaDB/PostgreSQL/SQLite) + Encryption (Let's Encrypt Certificate/Self-signed) + Extra options on Docker

100% Handsfree & Ready to login

Right now this will run on Ubuntu 16/18, Debian 9, CentOS 7. Maybe on Redhat 7.

The playbook runs onx86_64 and ARM(64) server. It's tested on both architektures on AWS EC2 and Scaleway Server as well on Rasberry 3+ running Debian 9.

Collabora and Talk work only on x86_64 server. OnlyOffice is not yet available.

## Preparation

Clone this repo and change into the directory nextcloud_on_docker.

```bash
git clone https://github.com/ReinerNippes/nextcloud_on_docker

cd nextcloud_on_docker
```

Install [Ansible](https://www.ansible.com/) and some needed tools by running the following command with a user that can sudo or is root. 

```bash
./prepare_system.sh
```

Note that root must have also sudo right otherwise the script will complain. Some hoster use distros where is is not in the sudoers file. In this case you have to add `root ALL=(ALL) NOPASSWD:ALL` to /etc/sudoers.

## Configuration

Now you can configure the whole thing by editing the file `inventory` and some other files.

### Preliminary variables

First of all you must define the server fqdn. If you want to get a Let's Encrypt certificate this must be a valid DNS record pointing to your server, and port 80+443 must be open to the internet. 

If you have a private server or if you use an AWS domain name like `ec2-52-3-229-194.compute-1.amazonaws.com` for example, you'll end up with a self-signed certificate. Which is fine but annoying because you have to accept this certificate manually in your browser. If you don't have a fqdn use the server IP address.

*Important:* You only will be able to access nextcloud through this address. 

```ini
# Your domain name to get a Let's Encrypt certificate
nextcloud_server_fqdn       = nextcloud.example.tld
```

Let's Encrypt wants your email address. Enter it here:

```ini
# Your email address for Let's Encrypt
ssl_cert_email              = nextcloud@example.tld
```

### Nextcloud variables

Where do you want to find your Nextcloud program, config, database and data files in the hosts filesystem.

```ini
# data dir
nextcloud_base_dir          = /opt/nextcloud
```

Define your admin user. Leave the password empty and a random one will be generated and displayed at the end of the playbook run.

```ini
# admin user
nextcloud_admin             = 'admin'
nextcloud_passwd            = ''
```

Your favorite database, name, user and password.
The db password will be generated and stored in {{ nextcloud_base_dir }}/secrets. In case you need it

```ini
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

```ini
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

Coming Soon:
Restic Backup tool. Will be installed if backup_folder is not empty.

```ini
# Install restic backup tool if backup_folder is not empty
# more info about restic: https://restic.readthedocs.io/en/latest/
restic_repo          = '' # e.g. /var/nc-backup

# crontab settings for restic
backup_day           = *
backup_hour          = 4
backup_minute        = 0
```

Online office and Talk support as well.

```ini
# Enable an Online Office Suite [collabora|onlyoffice|none]
# more info about collabora office: https://www.collaboraoffice.com/
# more info about onlyoffice office: https://www.onlyoffice.com

online_office               = none
# online_office             = collabora
# online_office             = onlyoffice

# Install turn server for Nextcloud Talk
talk_install                = false
```

If you want to access your database through an admin web page set this value to true

```ini
# adminer is a webfront end for your database at https://nextcloud_server_fqdn/adminer
# password stored in {{ nextcloud_base_dir }}/secrets
adminer_enabled             = false
```

If you want to install a webgui for docker set this value to true

```ini
# portainer is a webfront end for docker host
portainer_enabled           = true
portainer_passwd            = ''              # leave empty to generate random password
```

If you want to access your traefik dashboard uncomment the traefik_api_user

```ini
# user for traefik dashboard at https://nextcloud_server_fqdn/traefik
# traefik_api_user          = traefik
```

If you want to use rclone to backup your data to cloud storage provider remove the variable `restic_repo` from `ìnventory` and edit the file `group_var/all` instead. See https://rclone.org for more details

```ini
restic_repo:     "rclone:backup-nextcloud:unique-s3-bucket-name/s3-folder-name"
rclone_remote: |
      [backup-nextcloud]
      type = s3
      provider = AWS
      env_auth = false
      access_key_id = AKIxxxxx
      secret_access_key = QMpoxxxx
      region = us-east-1
      acl = private
      server_side_encryption = AES256
      storage_class = STANDARD_IA
```

## Installation

Run the ansible playbook.

```bash
./nextdocker.yml
```

Your nextcloud access credentials will be displayed at the end of the run.

```json
ok: [localhost] => {
    "msg": [
        "Your Nextcloud at https://nextcloud.example.tld is ready.",
        "Login with user: admin and password: fTkLgvPYdmjfalP8XgMsEg7plnoPsTvp ",
        "Other secrets you'll find in the directory /opt/nextcloud/secrets "
    ]
}
....
ok: [localhost] => {
    "msg": [
        "Manage your container at https://nextcloud.example.tld/portainer/ .",
        "Login with user: admin and password: CqDy4SqAXC5kEU0hHGQ5IucdBegwaVXa "
    ]
}
....
ok: [localhost] => {
    "msg": [
        "restic backup is configured. Keep your credentials in a safe place.",
        "RESTIC_REPOSITORY='/var/nc-backup'",
        "RESTIC_PASSWORD='ILIOxgRbmrvmvsUhtI7VtOcIz6II10jq'"
    ]
}

```

If you want to get rid of the containers run the following command:

```bash
ansible-playbook nextdocker.yml -e state=absent
```

Your data won't be deleted. You have to do this manually by

```bash
rm -rf ....
```
