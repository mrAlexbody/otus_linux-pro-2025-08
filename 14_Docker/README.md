# Домашнее задание 14
## Docker

### Цель:
- освоить базовые принципы работы с Docker, научиться создавать, настраивать и управлять контейнерами;


### Описание/Пошаговая инструкция выполнения домашнего задания:

#### 🎯 Задание

- Установите Docker на хост машину https://docs.docker.com/engine/install/ubuntu/
- Установите Docker Compose - как плагин, или как отдельное приложение
- Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx)
- Определите разницу между контейнером и образом
- Вывод опишите в домашнем задании.
- Ответьте на вопрос: Можно ли в контейнере собрать ядро?
---

### Установка Docker и Docker Compose
> Обновление пакетов и установка зависимостей
```shell
root@otus-docker:~# apt update
Hit:1 http://security.ubuntu.com/ubuntu noble-security InRelease
Hit:2 http://archive.ubuntu.com/ubuntu noble InRelease
Hit:3 http://archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:4 https://ppa.launchpadcontent.net/ansible/ansible/ubuntu noble InRelease
Hit:5 http://archive.ubuntu.com/ubuntu noble-backports InRelease
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
61 packages can be upgraded. Run 'apt list --upgradable' to see them.
root@otus-docker:~# apt upgrade
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Calculating upgrade... Done
The following packages were automatically installed and are no longer required:
  ieee-data libnftables1 libnftnl11 libwayland-server0 nftables python3-argcomplete python3-dnspython python3-libcloud python3-lockfile
  python3-netaddr python3-passlib python3-selinux python3-simplejson wireguard-tools
Use 'apt autoremove' to remove them.
The following NEW packages will be installed:
  python3-nacl python3-paramiko sshpass
The following packages will be upgraded:
  ansible ansible-core apparmor base-files bsdextrautils bsdutils cloud-init dhcpcd-base eject fdisk gcc-14-base landscape-client landscape-common
....
Processing triggers for mailcap (3.70+nmu1ubuntu1) ...
Processing triggers for libc-bin (2.39-0ubuntu8.7) ...
```
> Добавление официального GPG-ключа Docker
```shell
root@otus-docker:~# install -m 0755 -d /etc/apt/keyrings
root@otus-docker:~# curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
root@otus-docker:~# chmod a+r /etc/apt/keyrings/docker.asc
```
> Добавление репозитория Docker
```shell
root@otus-docker:~# echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
root@otus-docker:~# cat /etc/apt/sources.list.d/docker.list
deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu noble stable
root@otus-docker:~# apt update
Hit:1 http://archive.ubuntu.com/ubuntu noble InRelease
Get:2 https://download.docker.com/linux/ubuntu noble InRelease [48.5 kB]
Hit:3 https://ppa.launchpadcontent.net/ansible/ansible/ubuntu noble InRelease
Hit:4 http://archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:5 http://archive.ubuntu.com/ubuntu noble-backports InRelease
Get:6 https://download.docker.com/linux/ubuntu noble/stable amd64 Packages [46.6 kB]
Hit:7 http://security.ubuntu.com/ubuntu noble-security InRelease
Fetched 95.0 kB in 1s (152 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
All packages are up to date.
```
> Установка Docker Engine и сопутствующих пакетов
```shell
root@otus-docker:~# apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following packages were automatically installed and are no longer required:
  ieee-data libwayland-server0 python3-argcomplete python3-dnspython python3-libcloud python3-lockfile python3-netaddr python3-passlib python3-selinux
  python3-simplejson wireguard-tools
Use 'apt autoremove' to remove them.
The following additional packages will be installed:
  docker-ce-rootless-extras iptables libip4tc2 libip6tc2 libnetfilter-conntrack3 libnfnetlink0 libslirp0 pigz slirp4netns
Suggested packages:
  cgroupfs-mount | cgroup-lite docker-model-plugin firewalld
The following NEW packages will be installed:
  containerd.io docker-buildx-plugin docker-ce docker-ce-cli docker-ce-rootless-extras docker-compose-plugin iptables libip4tc2 libip6tc2
  libnetfilter-conntrack3 libnfnetlink0 libslirp0 pigz slirp4netns
0 upgraded, 14 newly installed, 0 to remove and 0 not upgraded.
Need to get 97.5 MB of archives.
After this operation, 395 MB of additional disk space will be used.
Do you want to continue? [Y/n] y
Do you want to continue? [Y/n] y
Get:1 http://archive.ubuntu.com/ubuntu noble/main amd64 libip4tc2 amd64 1.8.10-3ubuntu2 [23.3 kB]
Get:2 https://download.docker.com/linux/ubuntu noble/stable amd64 containerd.io amd64 2.2.1-1~ubuntu.24.04~noble [23.4 MB]
Get:3 http://archive.ubuntu.com/ubuntu noble/main amd64 libip6tc2 amd64 1.8.10-3ubuntu2 [23.7 kB]
Get:4 http://archive.ubuntu.com/ubuntu noble/main amd64 libnfnetlink0 amd64 1.0.2-2build1 [14.8 kB]
Get:5 http://archive.ubuntu.com/ubuntu noble/main amd64 libnetfilter-conntrack3 amd64 1.0.9-6build1 [45.2 kB]
Get:6 http://archive.ubuntu.com/ubuntu noble/main amd64 iptables amd64 1.8.10-3ubuntu2 [381 kB]
Get:7 http://archive.ubuntu.com/ubuntu noble/universe amd64 pigz amd64 2.8-1 [65.6 kB]
Get:8 http://archive.ubuntu.com/ubuntu noble/main amd64 libslirp0 amd64 4.7.0-1ubuntu3 [63.8 kB]
Get:9 http://archive.ubuntu.com/ubuntu noble/universe amd64 slirp4netns amd64 1.2.1-1build2 [34.9 kB]
Get:10 https://download.docker.com/linux/ubuntu noble/stable amd64 docker-ce-cli amd64 5:29.3.0-1~ubuntu.24.04~noble [16.4 MB]
Get:11 https://download.docker.com/linux/ubuntu noble/stable amd64 docker-ce amd64 5:29.3.0-1~ubuntu.24.04~noble [22.6 MB]
Get:12 https://download.docker.com/linux/ubuntu noble/stable amd64 docker-buildx-plugin amd64 0.31.1-1~ubuntu.24.04~noble [20.3 MB]
Get:13 https://download.docker.com/linux/ubuntu noble/stable amd64 docker-ce-rootless-extras amd64 5:29.3.0-1~ubuntu.24.04~noble [6390 kB]
Get:14 https://download.docker.com/linux/ubuntu noble/stable amd64 docker-compose-plugin amd64 5.1.0-1~ubuntu.24.04~noble [7847 kB]
Fetched 97.5 MB in 3s (37.9 MB/s)
Selecting previously unselected package containerd.io.
(Reading database ... 83572 files and directories currently installed.)
Preparing to unpack .../00-containerd.io_2.2.1-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking containerd.io (2.2.1-1~ubuntu.24.04~noble) ...
....
Setting up docker-ce (5:29.3.0-1~ubuntu.24.04~noble) ...
Created symlink /etc/systemd/system/multi-user.target.wants/docker.service → /usr/lib/systemd/system/docker.service.
Created symlink /etc/systemd/system/sockets.target.wants/docker.socket → /usr/lib/systemd/system/docker.socket.
Processing triggers for man-db (2.12.0-4build2) ...
Processing triggers for libc-bin (2.39-0ubuntu8.7) ...
```
> Проверка установки
```shell
root@otus-docker:~# docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
17eec7bbc9d7: Pull complete
ea52d2000f90: Download complete
Digest: sha256:ef54e839ef541993b4e87f25e752f7cf4238fa55f017957c2eb44077083d7a6a
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

root@otus-docker:~# docker
docker                         dockerd                        dockerd-rootless.sh
docker-proxy                   dockerd-rootless-setuptool.sh

root@otus-docker:~# docker ps -a
CONTAINER ID   IMAGE         COMMAND    CREATED          STATUS                      PORTS     NAMES
38b514974e79   hello-world   "/hello"   13 seconds ago   Exited (0) 13 seconds ago             epic_merkle
```
```shell
root@otus-docker:~# docker compose version
Docker Compose version v5.1.0
```
> Docker Compose установлен версии 5.1.0
> Создал директорию для выполнения задания, так удобней 
```shell
root@otus-docker:~# mkdir my-nginx && cd my-nginx
```
> Создал файл `index.html` с произвольным содержимым
```shell
root@otus-docker:~/my-nginx# cat ./index.html
<!DOCTYPE html>
<html>
<head>
<title>Кастомный Nginx</title>
</head>
<body>
<h1>Привет от Nginx в Docker на Alpine!</h1>
<p>Это кастомная страница.</p>
</body>
</html>
```
> Создал 'Dockerfile' для установки 
```shell
root@otus-docker:~/my-nginx# cat ./Dockerfile
# Установка базового образа nginx на alpine
FROM nginx:alpine
# Копирование кастомной страницы в диркторию для nginx
COPY index.html /usr/share/nginx/html/index.html
```
> Выполнил команду сборки с указанием тега образа
```shell
root@otus-docker:~/my-nginx# docker build -t my-nginx:alpine .
[+] Building 5.0s (7/7) FINISHED                                                                                                         docker:default
 => [internal] load build definition from Dockerfile                                                                                               0.0s
 => => transferring dockerfile: 271B                                                                                                               0.0s
 => [internal] load metadata for docker.io/library/nginx:alpine                                                                                    1.6s
 => [internal] load .dockerignore                                                                                                                  0.0s
 => => transferring context: 2B                                                                                                                    0.0s
 => [internal] load build context                                                                                                                  0.1s
 => => transferring context: 247B                                                                                                                  0.0s
 => [1/2] FROM docker.io/library/nginx:alpine@sha256:1d13701a5f9f3fb01aaa88cef2344d65b6b5bf6b7d9fa4cf0dca557a8d7702ba                              2.6s
 => => resolve docker.io/library/nginx:alpine@sha256:1d13701a5f9f3fb01aaa88cef2344d65b6b5bf6b7d9fa4cf0dca557a8d7702ba                              0.0s
 => => sha256:5e7756927bef33a266e1221356d5da8553139cb80bc5b1b3827010811d9ea268 20.24MB / 20.24MB                                                   0.8s
 => => sha256:6d397a54a185dd0b6638d1a3934b81daef7a140741e12697377d6279066f7ca7 1.40kB / 1.40kB                                                     0.5s
 => => sha256:955a8478f9aceb66cbf2f579fa3c24e1af278d1fa3ffd3043d6260e21d2f7416 1.21kB / 1.21kB                                                     0.7s
 => => sha256:399d0898a94e0084f81499a3e3c29824357118c7ce551648ea1dbab813884661 404B / 404B                                                         0.6s
 => => sha256:6b7b6c7061b76cdb8601e18722d12ae3232f0ddcfa1d2983754abcc6ce0a8a83 954B / 954B                                                         0.3s
 => => sha256:3e2c181db1b0985ce357c7aaf48ac615f30f392cd15d5c5ba34c4faa1f4f39a2 626B / 626B                                                         0.3s
 => => sha256:bca5d04786e112d958f100a66f8257b2aeefc14b64d81e405c3c44acff2fb000 1.86MB / 1.86MB                                                     0.4s
 => => sha256:589002ba0eaed121a1dbf42f6648f29e5be55d5c8a6ee0f8eaa0285cc21ac153 3.86MB / 3.86MB                                                     0.6s
 => => extracting sha256:589002ba0eaed121a1dbf42f6648f29e5be55d5c8a6ee0f8eaa0285cc21ac153                                                          0.1s
 => => extracting sha256:bca5d04786e112d958f100a66f8257b2aeefc14b64d81e405c3c44acff2fb000                                                          0.2s
 => => extracting sha256:3e2c181db1b0985ce357c7aaf48ac615f30f392cd15d5c5ba34c4faa1f4f39a2                                                          0.0s
 => => extracting sha256:6b7b6c7061b76cdb8601e18722d12ae3232f0ddcfa1d2983754abcc6ce0a8a83                                                          0.0s
 => => extracting sha256:399d0898a94e0084f81499a3e3c29824357118c7ce551648ea1dbab813884661                                                          0.0s
 => => extracting sha256:955a8478f9aceb66cbf2f579fa3c24e1af278d1fa3ffd3043d6260e21d2f7416                                                          0.0s
 => => extracting sha256:6d397a54a185dd0b6638d1a3934b81daef7a140741e12697377d6279066f7ca7                                                          0.0s
 => => extracting sha256:5e7756927bef33a266e1221356d5da8553139cb80bc5b1b3827010811d9ea268                                                          0.5s
 => [2/2] COPY index.html /usr/share/nginx/html/index.html                                                                                         0.1s
 => exporting to image                                                                                                                             0.3s
 => => exporting layers                                                                                                                            0.1s
 => => exporting manifest sha256:120155d068e100c2278ca25748143a1fc2e784006c92a338f5125f7d3cc1fdea                                                  0.0s
 => => exporting config sha256:5fea5939af76f3e150c94d66890965c0336035eec9ef74ba5fe12d6ccb89c338                                                    0.0s
 => => exporting attestation manifest sha256:139040964f9fb37b7730e3c8d2797d4caa45587ab0b7ca9518de8e8935f7af50                                      0.0s
 => => exporting manifest list sha256:19b711ca3058e000c6a8d0efd88ebfb65a626d3ce203cc7e443f6346104216b6                                             0.0s
 => => naming to docker.io/library/my-nginx:alpine                                                                                                 0.0s
 => => unpacking to docker.io/library/my-nginx:alpine                                                                                              0.0s
```
> Проверка сборки
```shell
root@otus-docker:~/my-nginx# docker images
                                                                                                                                    i Info →   U  In Use
IMAGE                ID             DISK USAGE   CONTENT SIZE   EXTRA
hello-world:latest   ef54e839ef54       25.9kB         9.52kB    U
my-nginx:alpine      19b711ca3058       92.5MB           26MB
root@otus-docker:~/my-nginx# docker ps -a
CONTAINER ID   IMAGE         COMMAND    CREATED          STATUS                      PORTS     NAMES
38b514974e79   hello-world   "/hello"   20 minutes ago   Exited (0) 20 minutes ago             epic_merkle
root@otus-docker:~/my-nginx# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
> Запустил контейнер, пробросив порт 80 контейнера на порт 8080 хоста
```shell
root@otus-docker:~/my-nginx# docker run -d -p 8080:80 --name my-nginx-container my-nginx:alpine
70779e6ca4c27b7f2a411402d3a8cf1b03c2934cd1c25784a664a5ab554c3ef1
root@otus-docker:~/my-nginx# docker ps
CONTAINER ID   IMAGE             COMMAND                  CREATED         STATUS         PORTS                                     NAMES
70779e6ca4c2   my-nginx:alpine   "/docker-entrypoint.…"   3 seconds ago   Up 2 seconds   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   my-nginx-container

```
> Проверил, что всё работает
```shell
root@otus-docker:~/my-nginx# curl localhost:8080
<!DOCTYPE html>
<html>
<head>
<title>Кастомный Nginx</title>
</head>
<body>
<h1>Привет от Nginx в Docker на Alpine!</h1>
<p>Это кастомная страница.</p>
</body>
</html>
```
```shell
root@otus-docker:~/my-nginx# docker ps
CONTAINER ID   IMAGE             COMMAND                  CREATED         STATUS         PORTS                                     NAMES
70779e6ca4c2   my-nginx:alpine   "/docker-entrypoint.…"   5 minutes ago   Up 5 minutes   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   my-nginx-container

root@otus-docker:~/my-nginx# docker exec -it 70779e6ca4c2 sh
/ # ls -la
total 80
drwxr-xr-x    1 root     root          4096 Mar  5 18:35 .
drwxr-xr-x    1 root     root          4096 Mar  5 18:35 ..
-rwxr-xr-x    1 root     root             0 Mar  5 18:35 .dockerenv
drwxr-xr-x    2 root     root          4096 Jan 27 21:19 bin
drwxr-xr-x    5 root     root           340 Mar  5 18:35 dev
drwxr-xr-x    1 root     root          4096 Feb  4 23:53 docker-entrypoint.d
-rwxr-xr-x    1 root     root          1620 Feb  4 23:53 docker-entrypoint.sh
drwxr-xr-x    1 root     root          4096 Mar  5 18:35 etc
drwxr-xr-x    2 root     root          4096 Jan 27 21:19 home
drwxr-xr-x    1 root     root          4096 Jan 27 21:19 lib
drwxr-xr-x    5 root     root          4096 Jan 27 21:19 media
drwxr-xr-x    2 root     root          4096 Jan 27 21:19 mnt
drwxr-xr-x    2 root     root          4096 Jan 27 21:19 opt
dr-xr-xr-x  274 root     root             0 Mar  5 18:35 proc
drwx------    1 root     root          4096 Mar  5 18:38 root
drwxr-xr-x    1 root     root          4096 Mar  5 18:35 run
drwxr-xr-x    2 root     root          4096 Jan 27 21:19 sbin
drwxr-xr-x    2 root     root          4096 Jan 27 21:19 srv
dr-xr-xr-x   13 root     root             0 Mar  5 18:35 sys
drwxrwxrwt    2 root     root          4096 Jan 27 21:19 tmp
drwxr-xr-x    1 root     root          4096 Jan 27 21:19 usr
drwxr-xr-x    1 root     root          4096 Jan 27 21:19 var
/ # uname -a
Linux 70779e6ca4c2 6.6.87.2-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC Thu Jun  5 18:30:46 UTC 2025 x86_64 Linux
/ # ps aux
PID   USER     TIME  COMMAND
    1 root      0:00 nginx: master process nginx -g daemon off;
   30 nginx     0:00 nginx: worker process
   31 nginx     0:00 nginx: worker process
   32 nginx     0:00 nginx: worker process
   33 nginx     0:00 nginx: worker process
   34 nginx     0:00 nginx: worker process
   35 nginx     0:00 nginx: worker process
   36 nginx     0:00 nginx: worker process
   37 nginx     0:00 nginx: worker process
   38 nginx     0:00 nginx: worker process
   39 nginx     0:00 nginx: worker process
   40 nginx     0:00 nginx: worker process
   41 nginx     0:00 nginx: worker process
   48 root      0:00 sh
   56 root      0:00 ps aux
/ # cat /usr/share/nginx/html/
50x.html    index.html
/ # cat /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head>
<title>Кастомный Nginx</title>
</head>
<body>
<h1>Привет от Nginx в Docker на Alpine!</h1>
<p>Это кастомная страница.</p>
</body>
</html>
/ # exit
```
### Разница между образом и контейнером
> **Образ (image)** — это неизменяемый шаблон, содержащий файловую систему, настройки окружения, команды для запуска приложения и другие метаданные. Образ является «слепком» состояния, который можно использовать для создания множества контейнеров. Образы обычно строятся на основе других образов (слоёв) и хранятся в реестре (например, Docker Hub).

> **Контейнер (container)** — это запущенный экземпляр образа. Он представляет собой изолированную среду выполнения, включающую файловую систему образа, плюс свой собственный слой для записи. Контейнер имеет состояние (запущен/остановлен), сетевые интерфейсы, может изменять свою файловую систему (но изменения не сохраняются в исходном образе). Можно создавать, запускать, останавливать, удалять контейнеры.

### Можно ли в контейнере собрать ядро?
> Можно, но зачем ? Всё равно запустить не получиться. Контейнер использует ядро хоста, а не своё собственное.

The END!!!