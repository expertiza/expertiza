## Running expertiza using docker

## Installation

1) Install [docker](https://www.docker.com/get-started) 
2) Install [VSCode](https://code.visualstudio.com/download)
3) Install [RemoteContainers VsCode Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)
4) Check that you have docker and docker-compose
(Mac / Linux)
```
docker -v 
docker-compose -v
```


5) Download the [scrubbed database](https://drive.google.com/u/0/uc?id=1CwM7H0GMeU5rEfCIZyoXeUvzrS1M2i64&export=download)
Add it to the project root directory and rename it to **expertiza.sql**


6) Run expertiza in **attached** mode or **detached** mode in macs **terminal** or **windows PowerShell**

**NOTE!  Do not run with WSL on the first run! (causes volume generation issues)**

**Recommended for windows** Attached (closing terminal closes expertiza):
`docker-compose up`

Detached (closing terminal does not close expertiza):
`docker-compose up -d`

7) You can verify that everything is running by using `docker ps`

**NOTE This may take 5-10 minutes to set up the database and migrate on the first run!!**

You should see mysql (healthy)
and redis (healthy)
and expertiza_web

8) Getting terminal access to your instance of expertiza (running in a container!)
In VSCode click the green icon in the bottom left.

Select 
`Remote Containers: Open Locally` 
or 
`Remote Containers: Reopen Locally`

9) VSCode will install ruby extensions and you can click the plus button on the right to get a new
terminal.

10) Run `bundle exec rails s -b 0.0.0.0`

11) Setup is complete! Please read below to understand how to connect to expertiza, MYSQL and Redis

#### Connecting to expertiza

Go to your browser at http://localhost:3000
You should see expertiza load after 5 - 30 seconds.


#### Connecting to MYSQL
From your local machine connect like you normally would, using these credentials

Host/IP: 127.0.0.1
Port: 3306
Username: root
Password: expertiza

If you are inside the container (vscode terminal that has root@random-numbers-here) use the same credentials but change host/ip to `mysql`.

#### Connecting to Redis
From your local machine connect like you normally would, using these credentials

Host/IP: 127.0.0.1
Port: 6379

If you are inside the container (vscode terminal that has root@random-numbers-here) use the same credentials but change host/ip to `redis`.


## More about docker

Docker containers allow you to run a much more efficient "virtual machine" or "container" than traditional VMs.

**Why use docker?** You can abstract your development, stage, and production environments to a set of repeatable commands. It effectively guarantees that an environment is the same on one host to the next.

**docker-compose vs docker** docker-compose allows you to run multiple docker containers (called services) in an orderly fashion. By default, docker containers are **not** exposed to your local machine, a port needs to be forwarded. docker-compose can handle this as well as setting up the connections between your containers and configuring them.

### Helpful docker commands

`docker-compose up`

Starts the expertiza services (mysql database, redis, and rails) in attached mode (if you close your terminal it will shudown these services)


`docker-compose up -d `

Starts the expertiza services (mysql database, redis, and rails) in detached mode (if you close your terminal it will **not** shudown these services)


`docker-compose down`

Shuts down local docker-compose containers/services


`docker-compose up [service]`

You can start specici services by specifying them in a list ex: `docker-compose up mysql redis`


`docker ps`

Shows running docker containers, forwarded ports and their health status if applicable



## Common Issues

### run: bin/rake db:migrate RAILS_ENV=development

This means migrations were not ran
Do a Ctrl +C or `docker-compose down` depending on if you are using -d or not
delete the .initialized file
`docker-compose up`

### Error response from daemon: error while creating mount source path
Try `docker-compose down`
Then `docker-compose up` once it completes
If that fails, try 
Restarting docker desktop or the docker daemon (linux). Find docker in the tray, hit quit docker desktop then relaunch