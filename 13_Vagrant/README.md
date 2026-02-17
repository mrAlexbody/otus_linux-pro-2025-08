# Домашнее задание 13
## Расширенная настройка дисков и сетей

### Цель:
- научиться добавлять диски и настраивать сетевые соединения;


### Описание/Пошаговая инструкция выполнения домашнего задания:
### 🎯Задание

**1. Подготовка окружения:**

- Убедитесть, что установле VirtualBox и Vagrant.
- Создайте директорию для проекта.
- Создать базовую виртуальную машину:
- Использовать можно любой образ.
- Настроите память ВМ: 1024 МБ.

**Добавление дисков:**
-Добавьте пару виртуальных диска размером 1 ГБ каждый.

**Настройка сети:**
- Настройте проброс 80 порта с гостевой системы на порт 8080 хостовой системы.

### **Провижининг:**

**Напишите провижининг, который:**

- Форматирует добавленные диски в файловую систему ext4.
- Создает точки монтирования /mnt/disk1 и /mnt/disk2.
- Монтирует диски в указанные директории.
- Добавляет записи в /etc/fstab для автоматического монтирования при загрузке.

_P.S.: Вы можете использовать пример, продемонстрированный на занятии_

---
## Установка Vagrant
Установка Vagrant & Ansible производилась в WSL2 Windows11. В Windows11 было установлено:

+ VirtualBox 

![img.png](img.png)

+ Vagrant
```shell
amyskin@otus-vagrant:~$ vagrant --version
Vagrant 2.4.9
```

+ WSL2 
```shell
В PowerShell
C:\Windows\System32>wsl --install
...
C:\Windows\System32>wsl --list --online
Ниже указан список допустимых дистрибутивов, которые можно установить.
Установить с помощью "wsl.exe --install <Distro>".

NAME                            FRIENDLY NAME
AlmaLinux-8                     AlmaLinux OS 8
AlmaLinux-9                     AlmaLinux OS 9
AlmaLinux-Kitten-10             AlmaLinux OS Kitten 10
AlmaLinux-10                    AlmaLinux OS 10
Debian                          Debian GNU/Linux
FedoraLinux-43                  Fedora Linux 43
FedoraLinux-42                  Fedora Linux 42
SUSE-Linux-Enterprise-15-SP7    SUSE Linux Enterprise 15 SP7
SUSE-Linux-Enterprise-16.0      SUSE Linux Enterprise 16.0
Ubuntu                          Ubuntu
Ubuntu-24.04                    Ubuntu 24.04 LTS
archlinux                       Arch Linux
eLxr                            eLxr 12.12.0.0 GNU/Linux
kali-linux                      Kali Linux Rolling
openSUSE-Tumbleweed             openSUSE Tumbleweed
openSUSE-Leap-16.0              openSUSE Leap 16.0
Ubuntu-20.04                    Ubuntu 20.04 LTS
Ubuntu-22.04                    Ubuntu 22.04 LTS
OracleLinux_7_9                 Oracle Linux 7.9
OracleLinux_8_10                Oracle Linux 8.10
OracleLinux_9_5                 Oracle Linux 9.5
openSUSE-Leap-15.6              openSUSE Leap 15.6
SUSE-Linux-Enterprise-15-SP6    SUSE Linux Enterprise 15 SP6

C:\Windows\System32>wsl --install -d Ubuntu-24.04
wsl: Использование устаревшей регистрации распространения. Вместо этого рассмотрите возможность использования дистрибутива на основе tar.
Скачивание: Ubuntu 24.04 LTS
Скачано: Ubuntu 24.04 LTS.
Дистрибутив успешно установлен. Его можно запустить с помощью "wsl.exe -d Ubuntu 24.04 LTS"
Запуск Ubuntu 24.04 LTS...
Installing, this may take a few minutes...
Please create a default UNIX user account. The username does not need to match your Windows username.
For more information visit: https://aka.ms/wslusers
Enter new UNIX username: alexander
New password:
Retype new password:
passwd: password updated successfully
Installation successful!
wsl: Failed to start the systemd user session for 'alexander'. See journalctl for more details.
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

Welcome to Ubuntu 24.04.1 LTS (GNU/Linux 6.6.87.2-microsoft-standard-WSL2)
...
amyskin@otus-vagrant:~$
amyskin@otus-vagrant:~/Vagrant/vagrant_provisioning$ uname -r
6.6.87.2-microsoft-standard-WSL2
amyskin@otus-vagrant:~/Vagrant/vagrant_provisioning$ date
Mon Feb 16 22:48:41 MSK 2026
amyskin@otus-vagrant:~/Vagrant/vagrant_provisioning$ cat /etc/os-release
PRETTY_NAME="Ubuntu 24.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.3 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=noble
LOGO=ubuntu-logo
```
Сам конфиг WSL2 ~/.wslconfig:
```shell
[wsl2]
processors=16
memory=8GB
swap=1073741824
networkingMode=Mirrored
[network]
hostname = selinux
generateHosts = false
[experimental]
```
## Основные установки в Linux Ubuntu 24.04 WSL2
### Добавление в apt
```shell
amyskin@otus-vagrant:~$ sudo apt install curl wget
amyskin@otus-vagrant:~$ wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
amyskin@otus-vagrant:~$ echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
aamyskin@otus-vagrant:~$ sudo apt update 
```
### Установка Vagrant
```shell
amyskin@otus-vagrant:~$ sudo apt-get install vagrant
Get:1 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Hit:2 http://archive.ubuntu.com/ubuntu noble InRelease
Get:3 https://apt.releases.hashicorp.com noble InRelease [12.9 kB]
Get:4 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Get:5 https://apt.releases.hashicorp.com noble/main amd64 Packages [216 kB]
Get:6 http://archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
Get:7 http://security.ubuntu.com/ubuntu noble-security/main amd64 Packages [1404 kB]
Get:8 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages [1694 kB]
Get:9 http://archive.ubuntu.com/ubuntu noble-updates/main Translation-en [313 kB]
Get:10 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Components [175 kB]
....
Fetched 13.9 MB in 2s (5905 kB/s)
Reading package lists... Done
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
vagrant is already the newest version (2.4.9-1).
0 upgraded, 0 newly installed, 0 to remove and 68 not upgraded.
alexander@otus-selinux:~$ vagrant --version
Vagrant 2.4.9

amyskin@otus-vagrant:~$ echo "export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"" >> ~/.bash
.bash_history  .bash_logout   .bashrc
aamyskin@otus-vagrant:~$ echo "export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"" >> ~/.bashrc
```
Для правильной работы Vagrant в среде WSL2 и корректно подключаться к виртуальным машинам, которые будут созданныв  VirtualBox на хост-системе Windows.
Нужно установить plugin virtualbox_WSL2
```shell
amyskin@otus-vagrant:~$ vagrant plugin install virtualbox_WSL2
Installing the 'virtualbox_WSL2' plugin. This can take a few minutes...
Fetching rake-13.3.1.gem
Fetching virtualbox_WSL2-0.1.3.gem
Installed the plugin 'virtualbox_WSL2 (0.1.3)'!
```
После для работы SSH внутри WSL2 нужно добавить пару строк в файл Vagrant (вот теперь, Vagrant будет находить SSH в WSL2) :
```shell
  config.ssh.host = "127.0.0.1"
  config.ssh.port = 2200
```
и это:
```shell
amyskin@otus-vagrant:~$ cat ~/.bashrc
...
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1
export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
```
Ключевые моменты для успешной работы (чтобы понять, на это ушёл день):
+ Версии должны совпадать: Версия Vagrant, установленная в WSL, должна совпадать с версией, установленной в Windows. 
+ Запускать _vagrant up_ из пути, доступного Windows. Это важно для работы общих папок (synced folders).
### Установка Ansible в WSL2 
```shell
amyskin@otus-vagrant:~$ sudo apt install software-properties-common
amyskin@otus-vagrant:~$ sudo add-apt-repository --yes --update ppa:ansible/ansible
amyskin@otus-vagrant:~$ sudo apt install ansible 
[sudo] password for amyskin:
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
software-properties-common is already the newest version (0.99.49.3).
software-properties-common set to manually installed.
0 upgraded, 0 newly installed, 0 to remove and 36 not upgraded.
Repository: 'Types: deb
URIs: https://ppa.launchpadcontent.net/ansible/ansible/ubuntu/
Suites: noble
Components: main
'
Description:
Ansible is a radically simple IT automation platform that makes your applications and systems easier to deploy. 
Avoid writing scripts or custom code to deploy and update your applications— automate in a language that approaches plain English, using SSH, with no agents to install on remote systems.

http://ansible.com/

If you face any issues while installing Ansible PPA, file an issue here:
https://github.com/ansible-community/ppa/issues
More info: https://launchpad.net/~ansible/+archive/ubuntu/ansible
Adding repository.
Get:1 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Hit:2 http://archive.ubuntu.com/ubuntu noble InRelease
Get:3 https://apt.releases.hashicorp.com noble InRelease [12.9 kB]
Get:4 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Get:5 https://ppa.launchpadcontent.net/ansible/ansible/ubuntu noble InRelease [17.8 kB]
Get:6 http://security.ubuntu.com/ubuntu noble-security/main amd64 Packages [1408 kB]
Hit:7 http://archive.ubuntu.com/ubuntu noble-backports InRelease
Get:8 https://ppa.launchpadcontent.net/ansible/ansible/ubuntu noble/main amd64 Packages [772 B]
Get:9 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages [1697 kB]
Get:10 https://ppa.launchpadcontent.net/ansible/ansible/ubuntu noble/main Translation-en [472 B]
Get:11 http://security.ubuntu.com/ubuntu noble-security/main amd64 c-n-f Metadata [9756 B]
Get:12 http://security.ubuntu.com/ubuntu noble-security/universe amd64 Packages [924 kB]
Get:13 http://security.ubuntu.com/ubuntu noble-security/universe amd64 c-n-f Metadata [19.7 kB]
Get:14 http://archive.ubuntu.com/ubuntu noble-updates/main Translation-en [314 kB]
Get:15 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 Packages [1515 kB]
Get:16 http://archive.ubuntu.com/ubuntu noble-updates/universe Translation-en [308 kB]
Fetched 6480 kB in 2s (4003 kB/s)
Reading package lists... Done
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following packages will be upgraded:
  ansible
1 upgraded, 0 newly installed, 0 to remove and 37 not upgraded.
Need to get 19.4 MB of archives.
After this operation, 71.9 MB disk space will be freed.
Get:1 https://ppa.launchpadcontent.net/ansible/ansible/ubuntu noble/main amd64 ansible all 12.3.0-1ppa~noble [19.4 MB]
Fetched 19.4 MB in 2s (8349 kB/s)
(Reading database ... 79571 files and directories currently installed.)
Preparing to unpack .../ansible_12.3.0-1ppa~noble_all.deb ...
Unpacking ansible (12.3.0-1ppa~noble) over (9.2.0+dfsg-0ubuntu5) ...
Setting up ansible (12.3.0-1ppa~noble) ...
Processing triggers for man-db (2.12.0-4build2) ...

amyskin@otus-vagrant:~$ ansible --version
ansible [core 2.16.3]
  config file = None
  configured module search path = ['/home/alexander/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/alexander/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.12.3 (main, Jan  8 2026, 11:30:50) [GCC 13.3.0] (/usr/bin/python3)
  jinja version = 3.1.2
  libyaml = True
```
## Получение и запуск стенда
Стандартный vagrantfile:
```shell
amyskin@otus-vagrant:~/Vagrant/vagrant_provisioning$ cat ./vagrantfile
Vagrant.configure("2") do |config|
  config.vm.box = "generic/rocky9" # Или centos/stream8, generic/alma9
  config.vm.box_check_update = false

  config.vm.network "forwarded_port", guest: 80, host: 8080

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = 1
  end

  config.vm.provision "shell", inline: <<-SHELL
    dnf update -y
    dnf install -y @development-tools rpmdevtools rpmlint createrepo_c nginx
    systemctl enable --now nginx
  SHELL
end

```
Доработал файл следующим образом:
```shell
amyskin@otus-vagrant:~/Vagrant/vagrant_provisioning$ cat ./Vagrantfile
Vagrant.configure("2") do |config|

  # Нужно для WSL2
  config.ssh.host = "127.0.0.1"

  # Выбор ОС Linux
  config.vm.box = "generic/rocky9"
  config.vm.box_check_update = false

  # Проброс порта 80 гостевой системы на 8080 хоста
  config.vm.network "forwarded_port", guest: 80, host: 8080

  # Назначение внутренней сети в VirtualBox
  config.vm.network "private_network", type: "dhcp", virtualbox__intnet: "mynet"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = 1

    # Добавление дополнительных дисков
    disk1_path = File.join(Dir.pwd, "disk1.vdi")
    disk2_path = File.join(Dir.pwd, "disk2.vdi")

    # Создание дисков
    unless File.exist?(disk1_path)
      vb.customize ['createhd', '--filename', disk1_path, '--size', 1024]
    end
    unless File.exist?(disk2_path)
      vb.customize ['createhd', '--filename', disk2_path, '--size', 1024]
    end

    # Подключаем диски к SATA-контроллеру
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', disk1_path]
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', disk2_path]
  end

  # Единый провижининг
  config.vm.provision "shell", inline: <<-SHELL
    set -e  # Прерывать выполнение при ошибке

    # Установка плагинов для управления репозиториями
    dnf install -y dnf-plugins-core

    # Включение репы CRB
    dnf config-manager --set-enabled crb

    # Обновление системы и установка пакетов
    dnf update -y
    dnf groupinstall -y "Development Tools"
    dnf install -y rpmdevtools rpmlint createrepo_c nginx

    # Запуск Nginx
    systemctl enable --now nginx

    # Работа с дисками
    DISKS=("/dev/sdb" "/dev/sdc")
    MOUNTS=("/mnt/disk1" "/mnt/disk2")

    for i in 0 1; do
      DISK=${DISKS[$i]}
      MOUNT=${MOUNTS[$i]}

      # Проверка наличия диска
      if [ ! -b "$DISK" ]; then
        echo "Диск $DISK не найден, пропускаем."
        continue
      fi

      # Форматирование в ext4
      if ! blkid "$DISK"; then
        echo "Форматирую $DISK в ext4"
        mkfs.ext4 -F "$DISK"
      else
        echo "Файловая система на $DISK уже существует"
      fi

      # Создание точки монтирования
      mkdir -p "$MOUNT"

      # Монтирование
      if ! mountpoint -q "$MOUNT"; then
        mount "$DISK" "$MOUNT"
        echo "Смонтирован $DISK в $MOUNT"
      else
        echo "$MOUNT уже смонтирован"
      fi

      # Добавление записи в /etc/fstab
      UUID=$(blkid -s UUID -o value "$DISK")
      if ! grep -q "$UUID" /etc/fstab; then
        echo "UUID=$UUID $MOUNT ext4 defaults 0 2" >> /etc/fstab
        echo "Запись в fstab для $MOUNT добавлена"
      else
        echo "Запись в fstab для $MOUNT уже существует"
      fi
    done
  SHELL
end
```
Сам запуск установки:
```shell
amyskin@otus-vagrant:~/Vagrant/vagrant_provisioning$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Clearing any previously set forwarded ports...
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
    default: Adapter 2: intnet
==> default: Forwarding ports...
    default: 80 (guest) => 8080 (host) (adapter 1)
    default: 22 (guest) => 2222 (host) (adapter 1)
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
    default:
    default: Vagrant insecure key detected. Vagrant will automatically replace
    default: this with a newly generated keypair for better security.
    default:
    default: Inserting generated public key within guest...
    default: Removing insecure key from the guest if it's present...
    default: Key inserted! Disconnecting and reconnecting using new SSH key...
==> default: Machine booted and ready!
==> default: Checking for guest additions in VM...
    default: The guest additions on this VM do not match the installed version of
    default: VirtualBox! In most cases this is fine, but in rare cases it can
    default: prevent things such as shared folders from working properly. If you see
    default: shared folder errors, please make sure the guest additions within the
    default: virtual machine match the version of VirtualBox you have installed on
    default: your host and reload your VM.
    default:
    default: Guest Additions Version: 6.1.48
    default: VirtualBox Version: 7.0
==> default: Configuring and enabling network interfaces...
==> default: Running provisioner: shell...
    default: Running: inline script
    default: Extra Packages for Enterprise Linux 9 - x86_64  2.7 MB/s |  20 MB     00:07
    default: Extra Packages for Enterprise Linux 9 - x86_64  2.7 MB/s |  20 MB     00:07
    default: Extra Packages for Enterprise Linux 9 openh264  1.3 kB/s | 2.5 kB     00:01
    default: Rocky Linux 9 - BaseOS                          6.1 MB/s |  13 MB     00:02
    default: Rocky Linux 9 - AppStream                        12 MB/s |  15 MB     00:01
    default: Rocky Linux 9 - Extras                           32 kB/s |  17 kB     00:00
    default: Package dnf-plugins-core-4.3.0-11.el9_3.noarch is already installed.
    default: Dependencies resolved.
    default: ================================================================================
    default:  Package                      Arch       Version               Repository  Size
    default: ================================================================================
    default: Upgrading:
    default:  dnf-plugins-core             noarch     4.3.0-24.el9_7        baseos      35 k
    default:  python3-dnf-plugins-core     noarch     4.3.0-24.el9_7        baseos     245 k
    default:  yum-utils                    noarch     4.3.0-24.el9_7        baseos      34 k
    default:
    default: Transaction Summary
    default: ================================================================================
    default: Upgrade  3 Packages
    default:
    default: Total download size: 315 k
    default: Downloading Packages:
    default: (1/3): dnf-plugins-core-4.3.0-24.el9_7.noarch.r  66 kB/s |  35 kB     00:00
    default: (2/3): yum-utils-4.3.0-24.el9_7.noarch.rpm       63 kB/s |  34 kB     00:00
    default: (3/3): python3-dnf-plugins-core-4.3.0-24.el9_7. 348 kB/s | 245 kB     00:00
    default: --------------------------------------------------------------------------------
    default: Total                                           308 kB/s | 315 kB     00:01
...
  default: Installed:
    default:   createrepo_c-0.20.1-4.el9.x86_64
    default:   createrepo_c-libs-0.20.1-4.el9.x86_64
    default:   desktop-file-utils-0.26-6.el9.x86_64
    default:   enchant-1:1.6.0-30.el9.x86_64
    default:   hunspell-1.7.0-11.el9.x86_64
    default:   hunspell-en-0.20140811.1-20.el9.noarch
    default:   hunspell-en-GB-0.20140811.1-20.el9.noarch
    default:   hunspell-en-US-0.20140811.1-20.el9.noarch
    default:   hunspell-filesystem-1.7.0-11.el9.x86_64
    default:   nginx-2:1.20.1-24.el9.x86_64
    default:   nginx-core-2:1.20.1-24.el9.x86_64
    default:   nginx-filesystem-2:1.20.1-24.el9.noarch
    default:   python3-argcomplete-1.12.0-5.el9.0.1.noarch
    default:   python3-chardet-4.0.0-5.el9.noarch
    default:   python3-enchant-3.2.0-5.el9.noarch
    default:   python3-file-magic-5.39-16.el9.noarch
    default:   python3-idna-2.10-7.el9_4.1.noarch
    default:   python3-pysocks-1.7.1-12.el9.0.1.noarch
    default:   python3-requests-2.25.1-10.el9_6.noarch
    default:   python3-urllib3-1.26.5-6.el9_7.1.noarch
    default:   rocky-logos-httpd-90.16-1.el9.noarch
    default:   rpmdevtools-9.5-1.el9.noarch
    default:   rpmlint-1.11-19.el9.noarch
    default:
    default: Complete!
    default: Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
    default: Форматирую /dev/sdb в ext4
    default: mke2fs 1.46.5 (30-Dec-2021)
    default: Creating filesystem with 262144 4k blocks and 65536 inodes
    default: Filesystem UUID: 70b95f1f-e70b-40ec-92aa-db18f7a138cf
    default: Superblock backups stored on blocks:
    default:    32768, 98304, 163840, 229376
    default:
    default: Allocating group tables: done
    default: Writing inode tables: done
    default: Creating journal (8192 blocks): done
    default: Writing superblocks and filesystem accounting information: done
    default:
    default: Смонтирован /dev/sdb в /mnt/disk1
    default: Запись в fstab для /mnt/disk1 добавлена
    default: Форматирую /dev/sdc в ext4
    default: mke2fs 1.46.5 (30-Dec-2021)
    default: Creating filesystem with 262144 4k blocks and 65536 inodes
    default: Filesystem UUID: 703dcb7a-7790-429f-ab39-8085fe5b9616
    default: Superblock backups stored on blocks:
    default:    32768, 98304, 163840, 229376
    default:
    default: Allocating group tables: done
    default: Writing inode tables: done
    default: Creating journal (8192 blocks): done
    default: Writing superblocks and filesystem accounting information: done
    default:
    default: Смонтирован /dev/sdc в /mnt/disk2
    default: Запись в fstab для /mnt/disk2 добавлена
```
Чтобы заработал прброс портов в WSL2 на Windows11, нужно сделать это: 
> В командной строке WSL2 узнаём ip:
```shell
hostname -I | awk '{print $1}'
```
> Так как WSL 2 не пробрасывает порты на внешние интерфейсы Windows автоматически для сторонних приложений типа VirtualBox то нужно выполните команду:
```shell
PS C:\Users\Alexander> netsh interface portproxy add v4tov4 listenport=8080 listenaddress=0.0.0.0 connectport=8080 connectaddress=192.168.77.5
```
и
``` shell
PS C:\Users\Alexander> New-NetFirewallRule -DisplayName "Vagrant-WSL2-Forwarding" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow


Name                          : {221d226b-c14a-47fa-9c2f-a75fa0f3377c}
DisplayName                   : Vagrant-WSL2-Forwarding
Description                   :
DisplayGroup                  :
Group                         :
Enabled                       : True
Profile                       : Any
Platform                      : {}
Direction                     : Inbound
Action                        : Allow
EdgeTraversalPolicy           : Block
LooseSourceMapping            : False
LocalOnlyMapping              : False
Owner                         :
PrimaryStatus                 : OK
Status                        : Правило было успешно проанализировано из хранилища. (65536)
EnforcementStatus             : NotApplicable
PolicyStoreSource             : PersistentStore
PolicyStoreSourceType         : Local
RemoteDynamicKeywordAddresses : {}
PolicyAppId                   :
PackageFamilyName             :

```
Проверка:
```shell
amyskin@otus-vagrant:~/Vagrant/vagrant_provisioning$ vagrant ssh
[vagrant@rocky9 ~]$ netstat -putnl
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      -
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -
tcp6       0      0 :::80                   :::*                    LISTEN      -
tcp6       0      0 :::22                   :::*                    LISTEN      -
udp        0      0 127.0.0.1:323           0.0.0.0:*                           -
udp6       0      0 ::1:323                 :::*                                -
[vagrant@rocky9 ~]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: disabled)
     Active: active (running) since Tue 2026-02-17 08:43:34 UTC; 1h 34min ago
    Process: 80986 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 80987 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 80988 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 80989 (nginx)
      Tasks: 2 (limit: 5824)
     Memory: 2.2M (peak: 2.2M)
        CPU: 33ms
     CGroup: /system.slice/nginx.service
             ├─80989 "nginx: master process /usr/sbin/nginx"
             └─80990 "nginx: worker process"
[vagrant@rocky9 ~]$ cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Wed Jan 10 19:32:38 2024
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
/dev/mapper/rl_rocky9-root /                       xfs     defaults        0 0
UUID=f3f9428d-ec07-43e3-a3b5-e2bc2ecb683d /boot                   xfs     defaults        0 0
/dev/mapper/rl_rocky9-swap none                    swap    defaults        0 0
#VAGRANT-BEGIN
# The contents below are automatically generated by Vagrant. Do not modify.
#VAGRANT-END
UUID=70b95f1f-e70b-40ec-92aa-db18f7a138cf /mnt/disk1 ext4 defaults 0 2
UUID=703dcb7a-7790-429f-ab39-8085fe5b9616 /mnt/disk2 ext4 defaults 0 2
[vagrant@rocky9 ~]$ df -hT
Filesystem                 Type      Size  Used Avail Use% Mounted on
devtmpfs                   devtmpfs  4.0M     0  4.0M   0% /dev
tmpfs                      tmpfs     475M     0  475M   0% /dev/shm
tmpfs                      tmpfs     190M  9.4M  181M   5% /run
/dev/mapper/rl_rocky9-root xfs        70G  3.8G   67G   6% /
/dev/sda1                  xfs       960M  318M  643M  34% /boot
/dev/sdb                   ext4      974M   24K  907M   1% /mnt/disk1
/dev/sdc                   ext4      974M   24K  907M   1% /mnt/disk2
tmpfs                      tmpfs      95M  4.0K   95M   1% /run/user/1000
[vagrant@rocky9 ~]$ lsblk
NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                  8:0    0  128G  0 disk
├─sda1               8:1    0    1G  0 part /boot
└─sda2               8:2    0  127G  0 part
  ├─rl_rocky9-root 253:0    0   70G  0 lvm  /
  └─rl_rocky9-swap 253:1    0    2G  0 lvm  [SWAP]
sdb                  8:16   0    1G  0 disk /mnt/disk1
sdc                  8:32   0    1G  0 disk /mnt/disk2
[vagrant@rocky9 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:cb:b3:b6 brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute eth0
       valid_lft 80133sec preferred_lft 80133sec
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ee:42:7d brd ff:ff:ff:ff:ff:ff
```
