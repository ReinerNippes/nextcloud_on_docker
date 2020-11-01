# Setup routes to other containers
## Intro
After setting up *nextcloud_on_docker* on your server you might want to route traffic to other containers or web-apps you might have on your server.  
You can easily achieve this by using the **Traefik2** container ansible created. [Docs here](https://doc.traefik.io/traefik/v2.0/)  
Using this method, *Traefik2* will take care of automatic request and management of SSL-Certificates.

In the example below we will use the **[whoami](https://doc.traefik.io/traefik/v2.0/user-guides/docker-compose/basic-example/)** container. If you setup everything just right, when accessing `subdomain.fqdn.com` you will get information regarding IP, container name, etc. from the *whoami* container

 1. Create `docker-compose.yml` file with the sample content below. 
>
    version: '3'
        networks:
            traefik:
                external: true
        services:
            whoami:
                #A container that exposes an API to show its IP address
                image: traefik/whoami
                networks:
                   #your container needs to be on the same network as traefik
                   - traefik
                labels:
                  #enable traefik for this container
                  - traefik.enable=true
                  #create a middleware for whoami to redirect traffic to https
                  - traefik.http.middlewares.whoami-https.redirectscheme.scheme=https
                  #create a router called whoami-http to listen on the entrypoint for http/80. 
                  #web is defined in traefik.yaml.j2
                  - traefik.http.routers.whoami-http.entrypoints=web
                  #set the domainname for the site on router whoami-http. It listens on http/80
                  - traefik.http.routers.whoami-http.rule=Host(`subdomain.fqdn.com`)
                  #route traffic from whoami-http to whoami-https middleware
                  - traefik.http.routers.whoami-http.middlewares=whoami-https@docker
                  #setup the entrypoint for https/443. Create a router called whoami.
                  - traefik.http.routers.whoami.entrypoints=web-secure
                  #define the domainname for this route. It listens on https/443
                  - traefik.http.routers.whoami.rule=Host(`subdomain.fqdn.com`)
                  #use tls
                  - traefik.http.routers.whoami.tls=true
                  #use this if you have setup LetsEncrypt
                  - traefik.http.routers.whoami.tls.certresolver=certificatesResolverDefault
                  #use this if you have another certificate issuer. It should match the initial ansible setup in inventory, used to spin up nextcloud-docker
                  #- traefik.http.routers.whoami.tls.certresolver=dnsChallenge
                  #inform traefik about the network it should listen on- useful if you have more than one networks for your container
                  - traefik.docker.network=traefik

 2. Change `subdomain.fqdn.com` to your own subdomain
 3. To use it with multiple hosted containers you need to replace *whoami* in **all** the labels above with another meaningful name. e.g.
>traefik.http.middlewares.whoami-https.redirectscheme.scheme=https

becomes
>traefik.http.middlewares.yourwebappname-https.redirectscheme.scheme=https

You cannot have more than one container with the same rule name.

## Sample config
Check out the sample [docker-compose-whoami.yml](docker-compose-whoami.yml) for traefik/whoami

## Credits
Credit goes to [Chris Wiegman](https://chriswiegman.com/2019/10/serving-your-docker-apps-with-https-and-traefik-2/).

