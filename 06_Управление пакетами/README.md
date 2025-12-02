# Домашнее задание 06
## Сборка RPM-пакета и создание репозитория

### Цель:
+ Научиться собирать RPM-пакеты.
+ Создавать собственный RPM-репозиторий.


### Описание/Пошаговая инструкция выполнения домашнего задания:

#### 🎯 Что нужно сделать?

+ создать свой RPM (можно взять свое приложение, либо собрать к примеру Apache с определенными опциями);
+ cоздать свой репозиторий и разместить там ранее собранный RPM;
+ реализовать это все либо в Vagrant, либо развернуть у себя через Nginx и дать ссылку на репозиторий.

---
> Установка пакетов
```shell
[root@cv5526017 ~]# yum install -y wget rpmdevtools rpm-build createrepo yum-utils cmake gcc git nano
Last metadata expiration check: 1:22:07 ago on Tue 02 Dec 2025 02:53:38 PM MSK.
Package wget-1.24.5-5.el10.x86_64 is already installed.
Package git-2.47.3-1.el10_0.x86_64 is already installed.
Package nano-8.1-3.el10.x86_64 is already installed.
Dependencies resolved.
=========================================================================================================================================
 Package                                  Architecture          Version                                   Repository                Size
=========================================================================================================================================
Installing:
 cmake                                    x86_64                3.30.5-3.el10_0                           appstream                 12 M
 createrepo_c                             x86_64                1.1.2-4.el10                              appstream                 77 k
 gcc                                      x86_64                14.3.1-2.1.el10.alma.1                    appstream                 38 M
 rpm-build                                x86_64                4.19.1.1-20.el10.alma.1                   appstream                 66 k
 rpmdevtools                              noarch                9.6-9.el10                                appstream                 88 k
 yum-utils                                noarch                4.7.0-9.el10                              baseos                    39 k
Installing dependencies:
 annobin-docs                             noarch                12.99-1.el10                              appstream                 88 k
 annobin-plugin-gcc                       x86_64                12.99-1.el10                              appstream                995 k
 bzip2                                    x86_64                1.0.8-25.el10                             baseos                    53 k
 cmake-data                               noarch                3.30.5-3.el10_0                           appstream                1.8 M
 cmake-filesystem                         x86_64                3.30.5-3.el10_0                           appstream                 15 k
 cmake-rpm-macros                         noarch                3.30.5-3.el10_0                           appstream                 15 k
 cpp                                      x86_64                14.3.1-2.1.el10.alma.1                    appstream                 13 M
 createrepo_c-libs                        x86_64                1.1.2-4.el10                              appstream                106 k
 debugedit                                x86_64                5.1-8.el10                                appstream                 79 k
 dwz                                      x86_64                0.16-1.el10                               appstream                139 k
 efi-srpm-macros                          noarch                6-6.el10.alma.1                           appstream                 23 k
 elfutils                                 x86_64                0.193-1.el10                              baseos                   566 k
 emacs-filesystem                         noarch                1:29.4-12.el10                            appstream                9.1 k
 fonts-srpm-macros                        noarch                1:2.0.5-18.el10                           appstream                 26 k
 forge-srpm-macros                        noarch                0.4.0-6.el10                              appstream                 20 k
 gcc-plugin-annobin                       x86_64                14.3.1-2.1.el10.alma.1                    appstream                 67 k
 gdb-minimal                              x86_64                16.3-2.el10                               appstream                4.3 M
 glibc-devel                              x86_64                2.39-58.el10_1.2.alma.1                   appstream                483 k
 go-srpm-macros                           noarch                3.6.0-4.el10                              appstream                 27 k
 kernel-headers                           x86_64                6.12.0-124.8.1.el10_1                     appstream                3.0 M
 kernel-srpm-macros                       noarch                1.0-25.el10                               appstream                9.7 k
 libmpc                                   x86_64                1.3.1-7.el10                              appstream                 71 k
 libpkgconf                               x86_64                2.1.0-3.el10                              baseos                    38 k
 libxcrypt-devel                          x86_64                4.4.36-10.el10                            appstream                 33 k
 lua-srpm-macros                          noarch                1-15.el10                                 appstream                8.7 k
 make                                     x86_64                1:4.4.1-9.el10                            baseos                   589 k
 ocaml-srpm-macros                        noarch                10-4.el10                                 appstream                9.0 k
 openblas-srpm-macros                     noarch                2-19.el10                                 appstream                7.6 k
 package-notes-srpm-macros                noarch                0.5-13.el10                               appstream                9.1 k
 perl-srpm-macros                         noarch                1-57.el10                                 appstream                8.4 k
 pkgconf                                  x86_64                2.1.0-3.el10                              baseos                    43 k
 pkgconf-m4                               noarch                2.1.0-3.el10                              baseos                    14 k
 pkgconf-pkg-config                       x86_64                2.1.0-3.el10                              baseos                   9.7 k
 pyproject-srpm-macros                    noarch                1.16.2-1.el10                             appstream                 14 k
 python-srpm-macros                       noarch                3.12-10.el10                              appstream                 23 k
 python3-argcomplete                      noarch                3.2.2-4.el10                              appstream                 88 k
 python3-rpmautospec-core                 noarch                0.1.5-2.el10_0                            epel                      15 k
 qt6-srpm-macros                          noarch                6.9.1-1.el10                              appstream                9.5 k
 redhat-rpm-config                        noarch                293-1.el10.alma.1                         appstream                 70 k
 rust-toolset-srpm-macros                 noarch                1.88.0-1.el10.alma.1                      appstream                 12 k
 systemd-rpm-macros                       noarch                257-13.el10.alma.1                        baseos                    27 k
 unzip                                    x86_64                6.0-69.el10                               baseos                   188 k
 zip                                      x86_64                3.0-45.el10                               baseos                   268 k
 zstd                                     x86_64                1.5.5-9.el10                              baseos                   464 k
Installing weak dependencies:
 python3-rpmautospec                      noarch                0.8.1-11.el10_1                           epel                     151 k

Transaction Summary
=========================================================================================================================================
Install  51 Packages

Total download size: 77 M
Installed size: 223 M
Downloading Packages:
(1/51): annobin-docs-12.99-1.el10.noarch.rpm                                                             3.4 MB/s |  88 kB     00:00
(2/51): annobin-plugin-gcc-12.99-1.el10.x86_64.rpm                                                       3.8 MB/s | 995 kB     00:00
(3/51): cmake-filesystem-3.30.5-3.el10_0.x86_64.rpm                                                      2.5 MB/s |  15 kB     00:00
(4/51): cmake-rpm-macros-3.30.5-3.el10_0.noarch.rpm                                                      1.3 MB/s |  15 kB     00:00
(5/51): cmake-data-3.30.5-3.el10_0.noarch.rpm                                                            6.6 MB/s | 1.8 MB     00:00
(6/51): createrepo_c-1.1.2-4.el10.x86_64.rpm                                                             2.7 MB/s |  77 kB     00:00
(7/51): createrepo_c-libs-1.1.2-4.el10.x86_64.rpm                                                        2.5 MB/s | 106 kB     00:00
(8/51): debugedit-5.1-8.el10.x86_64.rpm                                                                  669 kB/s |  79 kB     00:00
(9/51): dwz-0.16-1.el10.x86_64.rpm                                                                       8.4 MB/s | 139 kB     00:00
(10/51): efi-srpm-macros-6-6.el10.alma.1.noarch.rpm                                                      3.6 MB/s |  23 kB     00:00
(11/51): emacs-filesystem-29.4-12.el10.noarch.rpm                                                        1.8 MB/s | 9.1 kB     00:00
(12/51): fonts-srpm-macros-2.0.5-18.el10.noarch.rpm                                                      4.5 MB/s |  26 kB     00:00
(13/51): forge-srpm-macros-0.4.0-6.el10.noarch.rpm                                                       3.8 MB/s |  20 kB     00:00
(14/51): cmake-3.30.5-3.el10_0.x86_64.rpm                                                                 13 MB/s |  12 MB     00:00
(15/51): gcc-plugin-annobin-14.3.1-2.1.el10.alma.1.x86_64.rpm                                            6.1 MB/s |  67 kB     00:00
(16/51): gdb-minimal-16.3-2.el10.x86_64.rpm                                                               17 MB/s | 4.3 MB     00:00
(17/51): cpp-14.3.1-2.1.el10.alma.1.x86_64.rpm                                                            12 MB/s |  13 MB     00:01
(18/51): glibc-devel-2.39-58.el10_1.2.alma.1.x86_64.rpm                                                  4.7 MB/s | 483 kB     00:00
(19/51): go-srpm-macros-3.6.0-4.el10.noarch.rpm                                                          2.8 MB/s |  27 kB     00:00
(20/51): kernel-srpm-macros-1.0-25.el10.noarch.rpm                                                       1.1 MB/s | 9.7 kB     00:00
(21/51): libmpc-1.3.1-7.el10.x86_64.rpm                                                                  5.0 MB/s |  71 kB     00:00
(22/51): libxcrypt-devel-4.4.36-10.el10.x86_64.rpm                                                       3.6 MB/s |  33 kB     00:00
(23/51): lua-srpm-macros-1-15.el10.noarch.rpm                                                            939 kB/s | 8.7 kB     00:00
(24/51): ocaml-srpm-macros-10-4.el10.noarch.rpm                                                          943 kB/s | 9.0 kB     00:00
(25/51): openblas-srpm-macros-2-19.el10.noarch.rpm                                                       1.2 MB/s | 7.6 kB     00:00
(26/51): package-notes-srpm-macros-0.5-13.el10.noarch.rpm                                                858 kB/s | 9.1 kB     00:00
(27/51): perl-srpm-macros-1-57.el10.noarch.rpm                                                           1.1 MB/s | 8.4 kB     00:00
(28/51): pyproject-srpm-macros-1.16.2-1.el10.noarch.rpm                                                  1.3 MB/s |  14 kB     00:00
(29/51): python-srpm-macros-3.12-10.el10.noarch.rpm                                                      1.8 MB/s |  23 kB     00:00
(30/51): kernel-headers-6.12.0-124.8.1.el10_1.x86_64.rpm                                                  19 MB/s | 3.0 MB     00:00
(31/51): python3-argcomplete-3.2.2-4.el10.noarch.rpm                                                     1.5 MB/s |  88 kB     00:00
(32/51): qt6-srpm-macros-6.9.1-1.el10.noarch.rpm                                                         1.7 MB/s | 9.5 kB     00:00
(33/51): redhat-rpm-config-293-1.el10.alma.1.noarch.rpm                                                  6.2 MB/s |  70 kB     00:00
(34/51): rpm-build-4.19.1.1-20.el10.alma.1.x86_64.rpm                                                    7.3 MB/s |  66 kB     00:00
(35/51): rust-toolset-srpm-macros-1.88.0-1.el10.alma.1.noarch.rpm                                        145 kB/s |  12 kB     00:00
(36/51): rpmdevtools-9.6-9.el10.noarch.rpm                                                               991 kB/s |  88 kB     00:00
(37/51): bzip2-1.0.8-25.el10.x86_64.rpm                                                                  8.4 MB/s |  53 kB     00:00
(38/51): libpkgconf-2.1.0-3.el10.x86_64.rpm                                                              2.1 MB/s |  38 kB     00:00
(39/51): elfutils-0.193-1.el10.x86_64.rpm                                                                 16 MB/s | 566 kB     00:00
(40/51): pkgconf-2.1.0-3.el10.x86_64.rpm                                                                 3.5 MB/s |  43 kB     00:00
(41/51): make-4.4.1-9.el10.x86_64.rpm                                                                     16 MB/s | 589 kB     00:00
(42/51): pkgconf-m4-2.1.0-3.el10.noarch.rpm                                                              1.3 MB/s |  14 kB     00:00
(43/51): pkgconf-pkg-config-2.1.0-3.el10.x86_64.rpm                                                      1.9 MB/s | 9.7 kB     00:00
(44/51): gcc-14.3.1-2.1.el10.alma.1.x86_64.rpm                                                            28 MB/s |  38 MB     00:01
(45/51): systemd-rpm-macros-257-13.el10.alma.1.noarch.rpm                                                108 kB/s |  27 kB     00:00
(46/51): unzip-6.0-69.el10.x86_64.rpm                                                                    749 kB/s | 188 kB     00:00
(47/51): yum-utils-4.7.0-9.el10.noarch.rpm                                                               3.4 MB/s |  39 kB     00:00
(48/51): zip-3.0-45.el10.x86_64.rpm                                                                       16 MB/s | 268 kB     00:00
(49/51): zstd-1.5.5-9.el10.x86_64.rpm                                                                     24 MB/s | 464 kB     00:00
(50/51): python3-rpmautospec-0.8.1-11.el10_1.noarch.rpm                                                  2.9 MB/s | 151 kB     00:00
(51/51): python3-rpmautospec-core-0.1.5-2.el10_0.noarch.rpm                                              132 kB/s |  15 kB     00:00
-----------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                     21 MB/s |  77 MB     00:03
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                 1/1
  Installing       : unzip-6.0-69.el10.x86_64                                                                                       1/51
  Installing       : make-1:4.4.1-9.el10.x86_64                                                                                     2/51
  Installing       : elfutils-0.193-1.el10.x86_64                                                                                   3/51
  Installing       : libmpc-1.3.1-7.el10.x86_64                                                                                     4/51
  Installing       : gdb-minimal-16.3-2.el10.x86_64                                                                                 5/51
  Installing       : emacs-filesystem-1:29.4-12.el10.noarch                                                                         6/51
  Installing       : dwz-0.16-1.el10.x86_64                                                                                         7/51
  Installing       : cmake-rpm-macros-3.30.5-3.el10_0.noarch                                                                        8/51
  Installing       : cmake-filesystem-3.30.5-3.el10_0.x86_64                                                                        9/51
  Installing       : cmake-data-3.30.5-3.el10_0.noarch                                                                             10/51
  Installing       : cmake-3.30.5-3.el10_0.x86_64                                                                                  11/51
  Installing       : debugedit-5.1-8.el10.x86_64                                                                                   12/51
  Installing       : cpp-14.3.1-2.1.el10.alma.1.x86_64                                                                             13/51
  Installing       : zip-3.0-45.el10.x86_64                                                                                        14/51
  Installing       : python3-rpmautospec-core-0.1.5-2.el10_0.noarch                                                                15/51
  Installing       : python3-rpmautospec-0.8.1-11.el10_1.noarch                                                                    16/51
  Installing       : zstd-1.5.5-9.el10.x86_64                                                                                      17/51
  Installing       : pkgconf-m4-2.1.0-3.el10.noarch                                                                                18/51
  Installing       : libpkgconf-2.1.0-3.el10.x86_64                                                                                19/51
  Installing       : pkgconf-2.1.0-3.el10.x86_64                                                                                   20/51
  Installing       : pkgconf-pkg-config-2.1.0-3.el10.x86_64                                                                        21/51
  Installing       : bzip2-1.0.8-25.el10.x86_64                                                                                    22/51
  Installing       : rust-toolset-srpm-macros-1.88.0-1.el10.alma.1.noarch                                                          23/51
  Installing       : qt6-srpm-macros-6.9.1-1.el10.noarch                                                                           24/51
  Installing       : python3-argcomplete-3.2.2-4.el10.noarch                                                                       25/51
  Installing       : perl-srpm-macros-1-57.el10.noarch                                                                             26/51
  Installing       : package-notes-srpm-macros-0.5-13.el10.noarch                                                                  27/51
  Installing       : openblas-srpm-macros-2-19.el10.noarch                                                                         28/51
  Installing       : ocaml-srpm-macros-10-4.el10.noarch                                                                            29/51
  Installing       : lua-srpm-macros-1-15.el10.noarch                                                                              30/51
  Installing       : kernel-srpm-macros-1.0-25.el10.noarch                                                                         31/51
  Installing       : kernel-headers-6.12.0-124.8.1.el10_1.x86_64                                                                   32/51
  Installing       : libxcrypt-devel-4.4.36-10.el10.x86_64                                                                         33/51
  Installing       : glibc-devel-2.39-58.el10_1.2.alma.1.x86_64                                                                    34/51
  Installing       : gcc-14.3.1-2.1.el10.alma.1.x86_64                                                                             35/51
  Installing       : gcc-plugin-annobin-14.3.1-2.1.el10.alma.1.x86_64                                                              36/51
  Installing       : efi-srpm-macros-6-6.el10.alma.1.noarch                                                                        37/51
  Installing       : createrepo_c-libs-1.1.2-4.el10.x86_64                                                                         38/51
  Installing       : annobin-docs-12.99-1.el10.noarch                                                                              39/51
  Installing       : annobin-plugin-gcc-12.99-1.el10.x86_64                                                                        40/51
  Installing       : fonts-srpm-macros-1:2.0.5-18.el10.noarch                                                                      41/51
  Installing       : forge-srpm-macros-0.4.0-6.el10.noarch                                                                         42/51
  Installing       : go-srpm-macros-3.6.0-4.el10.noarch                                                                            43/51
  Installing       : python-srpm-macros-3.12-10.el10.noarch                                                                        44/51
  Installing       : pyproject-srpm-macros-1.16.2-1.el10.noarch                                                                    45/51
  Installing       : redhat-rpm-config-293-1.el10.alma.1.noarch                                                                    46/51
  Running scriptlet: redhat-rpm-config-293-1.el10.alma.1.noarch                                                                    46/51
  Installing       : rpm-build-4.19.1.1-20.el10.alma.1.x86_64                                                                      47/51
  Installing       : rpmdevtools-9.6-9.el10.noarch                                                                                 48/51
  Installing       : createrepo_c-1.1.2-4.el10.x86_64                                                                              49/51
  Installing       : yum-utils-4.7.0-9.el10.noarch                                                                                 50/51
  Installing       : systemd-rpm-macros-257-13.el10.alma.1.noarch                                                                  51/51
  Running scriptlet: systemd-rpm-macros-257-13.el10.alma.1.noarch                                                                  51/51

Installed:
  annobin-docs-12.99-1.el10.noarch                                  annobin-plugin-gcc-12.99-1.el10.x86_64
  bzip2-1.0.8-25.el10.x86_64                                        cmake-3.30.5-3.el10_0.x86_64
  cmake-data-3.30.5-3.el10_0.noarch                                 cmake-filesystem-3.30.5-3.el10_0.x86_64
  cmake-rpm-macros-3.30.5-3.el10_0.noarch                           cpp-14.3.1-2.1.el10.alma.1.x86_64
  createrepo_c-1.1.2-4.el10.x86_64                                  createrepo_c-libs-1.1.2-4.el10.x86_64
  debugedit-5.1-8.el10.x86_64                                       dwz-0.16-1.el10.x86_64
  efi-srpm-macros-6-6.el10.alma.1.noarch                            elfutils-0.193-1.el10.x86_64
  emacs-filesystem-1:29.4-12.el10.noarch                            fonts-srpm-macros-1:2.0.5-18.el10.noarch
  forge-srpm-macros-0.4.0-6.el10.noarch                             gcc-14.3.1-2.1.el10.alma.1.x86_64
  gcc-plugin-annobin-14.3.1-2.1.el10.alma.1.x86_64                  gdb-minimal-16.3-2.el10.x86_64
  glibc-devel-2.39-58.el10_1.2.alma.1.x86_64                        go-srpm-macros-3.6.0-4.el10.noarch
  kernel-headers-6.12.0-124.8.1.el10_1.x86_64                       kernel-srpm-macros-1.0-25.el10.noarch
  libmpc-1.3.1-7.el10.x86_64                                        libpkgconf-2.1.0-3.el10.x86_64
  libxcrypt-devel-4.4.36-10.el10.x86_64                             lua-srpm-macros-1-15.el10.noarch
  make-1:4.4.1-9.el10.x86_64                                        ocaml-srpm-macros-10-4.el10.noarch
  openblas-srpm-macros-2-19.el10.noarch                             package-notes-srpm-macros-0.5-13.el10.noarch
  perl-srpm-macros-1-57.el10.noarch                                 pkgconf-2.1.0-3.el10.x86_64
  pkgconf-m4-2.1.0-3.el10.noarch                                    pkgconf-pkg-config-2.1.0-3.el10.x86_64
  pyproject-srpm-macros-1.16.2-1.el10.noarch                        python-srpm-macros-3.12-10.el10.noarch
  python3-argcomplete-3.2.2-4.el10.noarch                           python3-rpmautospec-0.8.1-11.el10_1.noarch
  python3-rpmautospec-core-0.1.5-2.el10_0.noarch                    qt6-srpm-macros-6.9.1-1.el10.noarch
  redhat-rpm-config-293-1.el10.alma.1.noarch                        rpm-build-4.19.1.1-20.el10.alma.1.x86_64
  rpmdevtools-9.6-9.el10.noarch                                     rust-toolset-srpm-macros-1.88.0-1.el10.alma.1.noarch
  systemd-rpm-macros-257-13.el10.alma.1.noarch                      unzip-6.0-69.el10.x86_64
  yum-utils-4.7.0-9.el10.noarch                                     zip-3.0-45.el10.x86_64
  zstd-1.5.5-9.el10.x86_64

Complete!
```
> Далее будет сборка пакета NGINX c модулем ngx_broli. Это нужный модуль для поддержки сжатия HTTP-ответов. 
> Загрузка SRPM пакет NGINX (просто, скачаем исходники):
```shell
[root@cv5526017 ~]# mkdir rpm && cd rpm
[root@cv5526017 rpm]# yumdownloader --source nginx
enabling appstream-source repository
enabling baseos-source repository
enabling crb-source repository
enabling extras-source repository
enabling epel-source repository
AlmaLinux 10 - AppStream - Source                                                                        416 kB/s | 483 kB     00:01
AlmaLinux 10 - BaseOS - Source                                                                           143 kB/s | 157 kB     00:01
AlmaLinux 10 - CRB - Source                                                                               92 kB/s |  87 kB     00:00
AlmaLinux 10 - Extras - Source                                                                           3.2 kB/s | 2.7 kB     00:00
Extra Packages for Enterprise Linux 10 - x86_64 - Source                                                 2.3 MB/s | 3.6 MB     00:01
nginx-1.26.3-1.el10.src.rpm                                                                              3.9 MB/s | 1.3 MB     00:00

[root@cv5526017 rpm]# tree
.
└── nginx-1.26.3-1.el10.src.rpm

1 directory, 1 file
[root@cv5526017 rpm]# ll
total 1352
-rw-r--r-- 1 root root 1377239 Dec  2 16:24 nginx-1.26.3-1.el10.src.rpm

[root@cv5526017 rpm]# rpm -Uvh nginx*.src.rpm
Updating / installing...
   1:nginx-2:1.26.3-1.el10            ################################# [100%]
[root@cv5526017 rpm]# yum-builddep nginx
enabling appstream-source repository
enabling baseos-source repository
enabling crb-source repository
enabling extras-source repository
enabling epel-source repository
Last metadata expiration check: 0:02:30 ago on Tue 02 Dec 2025 04:24:36 PM MSK.
Package make-1:4.4.1-9.el10.x86_64 is already installed.
Package gcc-14.3.1-2.1.el10.alma.1.x86_64 is already installed.
Package systemd-257-13.el10.alma.1.x86_64 is already installed.
Package systemd-rpm-macros-257-13.el10.alma.1.noarch is already installed.
Package gnupg2-2.4.5-2.el10.x86_64 is already installed.
Dependencies resolved.
=========================================================================================================================================
 Package                                    Architecture          Version                                 Repository                Size
=========================================================================================================================================
Installing:
 gd-devel                                   x86_64                2.3.3-20.el10_0                         appstream                 40 k
 libxslt-devel                              x86_64                1.1.39-8.el10_0                         appstream                124 k
...

  perl-macros-4:5.40.2-512.2.el10_0.noarch                           perl-version-8:0.99.32-4.el10.x86_64
  pixman-0.43.4-2.el10.x86_64                                        pixman-devel-0.43.4-2.el10.x86_64
  python3-packaging-24.2-2.el10.noarch                               sysprof-capture-devel-47.2-1.el10.x86_64
  systemtap-sdt-devel-5.3-3b.el10.x86_64                             systemtap-sdt-dtrace-5.3-3b.el10.x86_64
  xml-common-0.6.3-65.el10.noarch                                    xorg-x11-proto-devel-2024.1-3.el10.noarch
  xz-devel-1:5.6.2-4.el10_0.x86_64                                   zlib-ng-compat-devel-2.2.3-2.el10.x86_64

Complete!
[root@cv5526017 rpm]#
```
> Далее скачал исходники модуля ngx_broli для nginx: 
```shell
[root@cv5526017 rpm]# cd ~
[root@cv5526017 ~]# git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli
Cloning into 'ngx_brotli'...
remote: Enumerating objects: 237, done.
remote: Counting objects: 100% (37/37), done.
remote: Compressing objects: 100% (16/16), done.
remote: Total 237 (delta 24), reused 21 (delta 21), pack-reused 200 (from 1)
Receiving objects: 100% (237/237), 79.51 KiB | 1.39 MiB/s, done.
Resolving deltas: 100% (114/114), done.
Submodule 'deps/brotli' (https://github.com/google/brotli.git) registered for path 'deps/brotli'
Cloning into '/root/ngx_brotli/deps/brotli'...
remote: Enumerating objects: 8937, done.
remote: Counting objects: 100% (471/471), done.
remote: Compressing objects: 100% (286/286), done.
remote: Total 8937 (delta 290), reused 193 (delta 185), pack-reused 8466 (from 4)
Receiving objects: 100% (8937/8937), 45.92 MiB | 14.65 MiB/s, done.
Resolving deltas: 100% (5687/5687), done.
Submodule path 'deps/brotli': checked out 'ed738e842d2fbdf2d6459e39267a633c4a9b2f5d'

```
> Зашёл в директорию 
````shell
[root@cv5526017 ~]# cd ~/ngx_brotli/deps/brotli/
[root@cv5526017 brotli]# ll
total 128
-rw-r--r-- 1 root root  3057 Dec  2 16:30 BUILD.bazel
drwxr-xr-x 8 root root  4096 Dec  2 16:30 c
-rw-r--r-- 1 root root  5677 Dec  2 16:30 CHANGELOG.md
-rw-r--r-- 1 root root 12897 Dec  2 16:30 CMakeLists.txt
-rw-r--r-- 1 root root  1378 Dec  2 16:30 compiler_config_setting.bzl
-rw-r--r-- 1 root root  1633 Dec  2 16:30 CONTRIBUTING.md
drwxr-xr-x 3 root root  4096 Dec  2 16:30 csharp
drwxr-xr-x 2 root root  4096 Dec  2 16:30 docs
drwxr-xr-x 2 root root  4096 Dec  2 16:30 fetch-spec
drwxr-xr-x 3 root root  4096 Dec  2 16:30 go
drwxr-xr-x 3 root root  4096 Dec  2 16:30 java
drwxr-xr-x 2 root root  4096 Dec  2 16:30 js
-rw-r--r-- 1 root root  1084 Dec  2 16:30 LICENSE
-rw-r--r-- 1 root root   409 Dec  2 16:30 MANIFEST.in
-rw-r--r-- 1 root root    81 Dec  2 16:30 pyproject.toml
drwxr-xr-x 3 root root  4096 Dec  2 16:30 python
-rw-r--r-- 1 root root   652 Dec  2 16:30 README
-rw-r--r-- 1 root root  4099 Dec  2 16:30 README.md
drwxr-xr-x 3 root root  4096 Dec  2 16:30 research
drwxr-xr-x 3 root root  4096 Dec  2 16:30 scripts
-rw-r--r-- 1 root root   314 Dec  2 16:30 SECURITY.md
-rw-r--r-- 1 root root    53 Dec  2 16:30 setup.cfg
-rw-r--r-- 1 root root  9155 Dec  2 16:30 setup.py
drwxr-xr-x 3 root root  4096 Dec  2 16:30 tests
-rw-r--r-- 1 root root   418 Dec  2 16:30 WORKSPACE.bazel

````
> Сборка модуля
```shell
root@cv5526017 brotli]#
[root@cv5526017 brotli]# mkdir out && cd out
[root@cv5526017 out]# cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed ..
-- The C compiler identification is GNU 14.3.1
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /usr/bin/cc - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Build type is 'Release'
-- Performing Test BROTLI_EMSCRIPTEN
-- Performing Test BROTLI_EMSCRIPTEN - Failed
-- Compiler is not EMSCRIPTEN
-- Looking for log2
-- Looking for log2 - not found
-- Looking for log2
-- Looking for log2 - found
-- Configuring done (1.3s)
-- Generating done (0.0s)
CMake Warning:
  Manually-specified variables were not used by the project:

    CMAKE_CXX_FLAGS

-- Build files have been written to: /root/ngx_brotli/deps/brotli/out
[root@cv5526017 out]# cmake --build . --config Release -j 2 --target brotlienc
[  3%] Building C object CMakeFiles/brotlicommon.dir/c/common/context.c.o
[  6%] Building C object CMakeFiles/brotlicommon.dir/c/common/constants.c.o
[ 10%] Building C object CMakeFiles/brotlicommon.dir/c/common/platform.c.o
[ 13%] Building C object CMakeFiles/brotlicommon.dir/c/common/dictionary.c.o
[ 17%] Building C object CMakeFiles/brotlicommon.dir/c/common/shared_dictionary.c.o
[ 20%] Building C object CMakeFiles/brotlicommon.dir/c/common/transform.c.o
[ 24%] Linking C static library libbrotlicommon.a
[ 24%] Built target brotlicommon
[ 27%] Building C object CMakeFiles/brotlienc.dir/c/enc/backward_references.c.o
[ 31%] Building C object CMakeFiles/brotlienc.dir/c/enc/backward_references_hq.c.o
[ 34%] Building C object CMakeFiles/brotlienc.dir/c/enc/bit_cost.c.o
[ 37%] Building C object CMakeFiles/brotlienc.dir/c/enc/block_splitter.c.o
[ 41%] Building C object CMakeFiles/brotlienc.dir/c/enc/brotli_bit_stream.c.o
[ 44%] Building C object CMakeFiles/brotlienc.dir/c/enc/cluster.c.o
[ 48%] Building C object CMakeFiles/brotlienc.dir/c/enc/command.c.o
[ 51%] Building C object CMakeFiles/brotlienc.dir/c/enc/compound_dictionary.c.o
[ 55%] Building C object CMakeFiles/brotlienc.dir/c/enc/compress_fragment.c.o
[ 58%] Building C object CMakeFiles/brotlienc.dir/c/enc/compress_fragment_two_pass.c.o
[ 62%] Building C object CMakeFiles/brotlienc.dir/c/enc/dictionary_hash.c.o
[ 65%] Building C object CMakeFiles/brotlienc.dir/c/enc/encode.c.o
[ 68%] Building C object CMakeFiles/brotlienc.dir/c/enc/encoder_dict.c.o
[ 72%] Building C object CMakeFiles/brotlienc.dir/c/enc/entropy_encode.c.o
[ 75%] Building C object CMakeFiles/brotlienc.dir/c/enc/fast_log.c.o
[ 79%] Building C object CMakeFiles/brotlienc.dir/c/enc/histogram.c.o
[ 82%] Building C object CMakeFiles/brotlienc.dir/c/enc/literal_cost.c.o
[ 86%] Building C object CMakeFiles/brotlienc.dir/c/enc/memory.c.o
[ 89%] Building C object CMakeFiles/brotlienc.dir/c/enc/metablock.c.o
[ 93%] Building C object CMakeFiles/brotlienc.dir/c/enc/static_dict.c.o
[ 96%] Building C object CMakeFiles/brotlienc.dir/c/enc/utf8_util.c.o
[100%] Linking C static library libbrotlienc.a
[100%] Built target brotlienc
```
> Долгий поиск, где указать модуль =)
````shell
[root@cv5526017 ~]# cd ~/rpmbuild/SPECS/
[root@cv5526017 SPECS]# ll
total 48
-rw-r--r-- 1 root root 46949 Feb  6  2025 nginx.spec
[root@cv5526017 SPECS]# cat ./nginx.spec
````
```shell
.... кусок SPEC конфигурации
%build
# nginx does not utilize a standard configure script.  It has its own
# and the standard configure options cause the nginx configure script
# to error out.  This is is also the reason for the DESTDIR environment
# variable.
export DESTDIR=%{buildroot}
# So the perl module finds its symbols:
nginx_ldopts="$RPM_LD_FLAGS -Wl,-E -O2"
if ! ./configure \
    --prefix=%{_datadir}/nginx \
    --sbin-path=%{_sbindir}/nginx \
    --modules-path=%{nginx_moduledir} \
    --conf-path=%{_sysconfdir}/nginx/nginx.conf \
    --error-log-path=%{_localstatedir}/log/nginx/error.log \
    --http-log-path=%{_localstatedir}/log/nginx/access.log \
    --http-client-body-temp-path=%{_localstatedir}/lib/nginx/tmp/client_body \
    --http-proxy-temp-path=%{_localstatedir}/lib/nginx/tmp/proxy \
    --http-fastcgi-temp-path=%{_localstatedir}/lib/nginx/tmp/fastcgi \
    --http-uwsgi-temp-path=%{_localstatedir}/lib/nginx/tmp/uwsgi \
    --http-scgi-temp-path=%{_localstatedir}/lib/nginx/tmp/scgi \
    --pid-path=/run/nginx.pid \
    --lock-path=/run/lock/subsys/nginx \
    --user=%{nginx_user} \
    --group=%{nginx_user} \
    --with-compat \
    --with-debug \
    --add-module=/root/ngx_brotli \
%if 0%{?with_aio}
    --with-file-aio \
%endif
%if 0%{?with_gperftools}
    --with-google_perftools_module \
%endif
...
```
> Сама сборка пакета
```shell
[root@cv5526017 SPECS]# cd ~/rpmbuild/SPECS/
[root@cv5526017 SPECS]# rpmbuild -ba nginx.spec -D 'debug_package %{nil}'
setting SOURCE_DATE_EPOCH=1738800000
Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.rlXZbK
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cat /root/rpmbuild/SOURCES/maxim.key /root/rpmbuild/SOURCES/arut.key /root/rpmbuild/SOURCES/pluknet.key /root/rpmbuild/SOURCES/sb.key /root/rpmbuild/SOURCES/thresh.key
+ /usr/lib/rpm/redhat/gpgverify --keyring=/root/rpmbuild/BUILD/nginx.gpg --signature=/root/rpmbuild/SOURCES/nginx-1.26.3.tar.gz.asc --data=/root/rpmbuild/SOURCES/nginx-1.26.3.tar.gz
gpgv: Signature made Wed Feb  5 14:23:53 2025 MSK
gpgv:                using RSA key D6786CE303D9A9022998DC6CC8464D549AF75C0A
gpgv:                issuer "s.kandaurov@f5.com"
gpgv: Good signature from "Sergey Kandaurov <s.kandaurov@f5.com>"
gpgv:                 aka "Sergey Kandaurov <pluknet@nginx.com>"
+ cd /root/rpmbuild/BUILD
+ rm -rf nginx-1.26.3
+ /usr/lib/rpm/rpmuncompress -x /root/rpmbuild/SOURCES/nginx-1.26.3.tar.gz
+ STATUS=0
+ '[' 0 -ne 0 ']'
+ cd nginx-1.26.3
+ rm -rf /root/rpmbuild/BUILD/nginx-1.26.3-SPECPARTS
+ /usr/bin/mkdir -p /root/rpmbuild/BUILD/nginx-1.26.3-SPECPARTS
+ /usr/bin/chmod -Rf a+rX,u+w,g-w,o-w .
+ /usr/lib/rpm/rpmuncompress /root/rpmbuild/SOURCES/0001-remove-Werror-in-upstream-build-scripts.patch
+ /usr/bin/patch -p1 -s --fuzz=0 --no-backup-if-mismatch -f
+ /usr/lib/rpm/rpmuncompress /root/rpmbuild/SOURCES/0002-fix-PIDFile-handling.patch
+ /usr/bin/patch -p1 -s --fuzz=0 --no-backup-if-mismatch -f
+ /usr/lib/rpm/rpmuncompress /root/rpmbuild/SOURCES/0003-Add-SSL-passphrase-dialog.patch
+ /usr/bin/patch -p1 -s --fuzz=0 --no-backup-if-mismatch -f
+ /usr/lib/rpm/rpmuncompress /root/rpmbuild/SOURCES/0004-Disable-ENGINE-support.patch
+ /usr/bin/patch -p1 -s --fuzz=0 --no-backup-if-mismatch -f
+ /usr/lib/rpm/rpmuncompress /root/rpmbuild/SOURCES/0005-Compile-perl-module-with-O2.patch
+ /usr/bin/patch -p1 -s --fuzz=0 --no-backup-if-mismatch -f
+ cp /root/rpmbuild/SOURCES/README.dynamic /root/rpmbuild/SOURCES/UPGRADE-NOTES-1.6-to-1.10 /root/rpmbuild/SOURCES/nginx.service /root/rpmbuild/SOURCES/nginx.conf /root/rpmbuild/SOURCES/nginx@.service /root/rpmbuild/SOURCES/instance.conf .
+ sed -e '/^error_log /s|error\.log|@INSTANCE@_error.log|' -e '/^pid /s|nginx\.pid|nginx-@INSTANCE@.pid|' -e '/^ *access_log/s|access\.log|@INSTANCE@_access.log|' nginx.conf
+ touch -r /root/rpmbuild/SOURCES/nginx.conf instance.conf
+ cp -a ../nginx-1.26.3 ../nginx-1.26.3-1.el10-src
+ mv ../nginx-1.26.3-1.el10-src .
+ RPM_EC=0
++ jobs -p
+ exit 0
... можно выпить чайку !!!
... ждём
Requires(post): /bin/sh
Requires: libc.so.6()(64bit) libc.so.6(GLIBC_2.14)(64bit) libc.so.6(GLIBC_2.2.5)(64bit) libc.so.6(GLIBC_2.3.4)(64bit) libc.so.6(GLIBC_2.33)(64bit) libc.so.6(GLIBC_2.4)(64bit) libc.so.6(GLIBC_ABI_DT_RELR)(64bit) rtld(GNU_HASH)
Processing files: nginx-mod-devel-1.26.3-1.el10.x86_64
Provides: nginx-mod-devel = 2:1.26.3-1.el10 nginx-mod-devel(x86-64) = 2:1.26.3-1.el10 perl(nginx) rpm_macro(_nginx_abiversion) rpm_macro(_nginx_buildsrcdir) rpm_macro(_nginx_modbuilddir) rpm_macro(_nginx_modsrcdir) rpm_macro(_nginx_srcdir) rpm_macro(nginx_modbuild) rpm_macro(nginx_modconfdir) rpm_macro(nginx_modconfigure) rpm_macro(nginx_moddir) rpm_macro(nginx_modrequires)
Requires(rpmlib): rpmlib(CompressedFileNames) <= 3.0.4-1 rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1
Requires: /usr/bin/perl /usr/bin/sh perl(:VERSION) >= 5.6.0 perl(:VERSION) >= 5.6.1 perl(Exporter) perl(XSLoader) perl(constant) perl(strict) perl(warnings)
Checking for unpackaged file(s): /usr/lib/rpm/check-files /root/rpmbuild/BUILDROOT/nginx-1.26.3-1.el10.x86_64
Wrote: /root/rpmbuild/SRPMS/nginx-1.26.3-1.el10.src.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-mod-devel-1.26.3-1.el10.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-core-1.26.3-1.el10.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-mod-stream-1.26.3-1.el10.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-mod-mail-1.26.3-1.el10.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-1.26.3-1.el10.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-mod-http-perl-1.26.3-1.el10.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-mod-http-xslt-filter-1.26.3-1.el10.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-mod-http-image-filter-1.26.3-1.el10.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/noarch/nginx-filesystem-1.26.3-1.el10.noarch.rpm
Wrote: /root/rpmbuild/RPMS/noarch/nginx-all-modules-1.26.3-1.el10.noarch.rpm
Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.jDJI7m
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd nginx-1.26.3
+ /usr/bin/rm -rf /root/rpmbuild/BUILDROOT/nginx-1.26.3-1.el10.x86_64
+ RPM_EC=0
++ jobs -p
+ exit 0
Executing(rmbuild): /bin/sh -e /var/tmp/rpm-tmp.FHU6Ei
+ umask 022
+ cd /root/rpmbuild/BUILD
+ rm -rf /root/rpmbuild/BUILD/nginx-1.26.3-SPECPARTS
+ rm -rf nginx-1.26.3 nginx-1.26.3.gemspec
+ RPM_EC=0
++ jobs -p
+ exit 0
[root@cv5526017 SPECS]#

```
> Проверил, есть-ли пакеты 
```shell
[root@cv5526017 SPECS]# ll ~/rpmbuild/RPMS/x86_64/
total 2264
-rw-r--r-- 1 root root   33198 Dec  2 16:48 nginx-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root 1147867 Dec  2 16:48 nginx-core-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root  897091 Dec  2 16:48 nginx-mod-devel-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root   21616 Dec  2 16:48 nginx-mod-http-image-filter-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root   33621 Dec  2 16:48 nginx-mod-http-perl-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root   20467 Dec  2 16:48 nginx-mod-http-xslt-filter-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root   55367 Dec  2 16:48 nginx-mod-mail-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root   88893 Dec  2 16:48 nginx-mod-stream-1.26.3-1.el10.x86_64.rpm

```
> Скопировал  пакеты в общий каталог
```shell
[root@cv5526017 SPECS]# cp ~/rpmbuild/RPMS/noarch/* ~/rpmbuild/RPMS/x86_64/
[root@cv5526017 SPECS]# cd ~/rpmbuild/RPMS/x86_64
[root@cv5526017 x86_64]# ls -la
total 2296
drwxr-xr-x 2 root root    4096 Dec  2 17:04 .
drwxr-xr-x 4 root root    4096 Dec  2 16:48 ..
-rw-r--r-- 1 root root   33198 Dec  2 16:48 nginx-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root    9613 Dec  2 17:04 nginx-all-modules-1.26.3-1.el10.noarch.rpm
-rw-r--r-- 1 root root 1147867 Dec  2 16:48 nginx-core-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root   11359 Dec  2 17:04 nginx-filesystem-1.26.3-1.el10.noarch.rpm
-rw-r--r-- 1 root root  897091 Dec  2 16:48 nginx-mod-devel-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root   21616 Dec  2 16:48 nginx-mod-http-image-filter-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root   33621 Dec  2 16:48 nginx-mod-http-perl-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root   20467 Dec  2 16:48 nginx-mod-http-xslt-filter-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root   55367 Dec  2 16:48 nginx-mod-mail-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root   88893 Dec  2 16:48 nginx-mod-stream-1.26.3-1.el10.x86_64.rpm

```
> Установил пакеты
```shell
[root@cv5526017 x86_64]# yum localinstall *.rpm
Last metadata expiration check: 2:12:24 ago on Tue 02 Dec 2025 02:53:38 PM MSK.
Dependencies resolved.
=========================================================================================================================================
 Package                                     Architecture           Version                           Repository                    Size
=========================================================================================================================================
Installing:
 nginx                                       x86_64                 2:1.26.3-1.el10                   @commandline                  32 k
 nginx-all-modules                           noarch                 2:1.26.3-1.el10                   @commandline                 9.4 k
 nginx-core                                  x86_64                 2:1.26.3-1.el10                   @commandline                 1.1 M
 nginx-filesystem                            noarch                 2:1.26.3-1.el10                   @commandline                  11 k
 nginx-mod-devel                             x86_64                 2:1.26.3-1.el10                   @commandline                 876 k
 nginx-mod-http-image-filter                 x86_64                 2:1.26.3-1.el10                   @commandline                  21 k
 nginx-mod-http-perl                         x86_64                 2:1.26.3-1.el10                   @commandline                  33 k
 nginx-mod-http-xslt-filter                  x86_64                 2:1.26.3-1.el10                   @commandline                  20 k
 nginx-mod-mail                              x86_64                 2:1.26.3-1.el10                   @commandline                  54 k
 nginx-mod-stream                            x86_64                 2:1.26.3-1.el10                   @commandline                  87 k
Installing dependencies:
 almalinux-logos-httpd                       noarch                 100.3-3.el10_0                    appstream                     18 k

Transaction Summary
=========================================================================================================================================
Install  11 Packages

Total size: 2.2 M
Total download size: 18 k
Installed size: 11 M
Is this ok [y/N]: y
Downloading Packages:
almalinux-logos-httpd-100.3-3.el10_0.noarch.rpm                                                          348 kB/s |  18 kB     00:00
-----------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                     25 kB/s |  18 kB     00:00
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                 1/1
  Running scriptlet: nginx-filesystem-2:1.26.3-1.el10.noarch                                                                        1/11
  Installing       : nginx-filesystem-2:1.26.3-1.el10.noarch                                                                        1/11
  Installing       : nginx-core-2:1.26.3-1.el10.x86_64                                                                              2/11
  Installing       : almalinux-logos-httpd-100.3-3.el10_0.noarch                                                                    3/11
  Installing       : nginx-2:1.26.3-1.el10.x86_64                                                                                   4/11
  Running scriptlet: nginx-2:1.26.3-1.el10.x86_64                                                                                   4/11
  Installing       : nginx-mod-http-image-filter-2:1.26.3-1.el10.x86_64                                                             5/11
  Running scriptlet: nginx-mod-http-image-filter-2:1.26.3-1.el10.x86_64                                                             5/11
  Installing       : nginx-mod-http-perl-2:1.26.3-1.el10.x86_64                                                                     6/11
  Running scriptlet: nginx-mod-http-perl-2:1.26.3-1.el10.x86_64                                                                     6/11
  Installing       : nginx-mod-http-xslt-filter-2:1.26.3-1.el10.x86_64                                                              7/11
  Running scriptlet: nginx-mod-http-xslt-filter-2:1.26.3-1.el10.x86_64                                                              7/11
  Installing       : nginx-mod-mail-2:1.26.3-1.el10.x86_64                                                                          8/11
  Running scriptlet: nginx-mod-mail-2:1.26.3-1.el10.x86_64                                                                          8/11
  Installing       : nginx-mod-stream-2:1.26.3-1.el10.x86_64                                                                        9/11
  Running scriptlet: nginx-mod-stream-2:1.26.3-1.el10.x86_64                                                                        9/11
  Installing       : nginx-all-modules-2:1.26.3-1.el10.noarch                                                                      10/11
  Installing       : nginx-mod-devel-2:1.26.3-1.el10.x86_64                                                                        11/11
  Running scriptlet: nginx-mod-devel-2:1.26.3-1.el10.x86_64                                                                        11/11

Installed:
  almalinux-logos-httpd-100.3-3.el10_0.noarch                             nginx-2:1.26.3-1.el10.x86_64
  nginx-all-modules-2:1.26.3-1.el10.noarch                                nginx-core-2:1.26.3-1.el10.x86_64
  nginx-filesystem-2:1.26.3-1.el10.noarch                                 nginx-mod-devel-2:1.26.3-1.el10.x86_64
  nginx-mod-http-image-filter-2:1.26.3-1.el10.x86_64                      nginx-mod-http-perl-2:1.26.3-1.el10.x86_64
  nginx-mod-http-xslt-filter-2:1.26.3-1.el10.x86_64                       nginx-mod-mail-2:1.26.3-1.el10.x86_64
  nginx-mod-stream-2:1.26.3-1.el10.x86_64

Complete!

```
> Проверка
```shell
[root@cv5526017 x86_64]# systemctl restart nginx
[root@cv5526017 x86_64]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: active (running) since Tue 2025-12-02 17:06:53 MSK; 10s ago
 Invocation: ee6a4dd523054c049a9385d3c582bae9
    Process: 31136 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 31138 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 31140 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 31141 (nginx)
      Tasks: 2 (limit: 5916)
     Memory: 6.3M (peak: 6.5M)
        CPU: 109ms
     CGroup: /system.slice/nginx.service
             ├─31141 "nginx: master process /usr/sbin/nginx"
             └─31142 "nginx: worker process"

Dec 02 17:06:53 cv5526017.novalocal systemd[1]: Starting nginx.service - The nginx HTTP and reverse proxy server...
Dec 02 17:06:53 cv5526017.novalocal nginx[31138]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Dec 02 17:06:53 cv5526017.novalocal nginx[31138]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Dec 02 17:06:53 cv5526017.novalocal systemd[1]: Started nginx.service - The nginx HTTP and reverse proxy server.

```
> Можно проверить заходом на тестовую страницу https://repo.rawl32.ru/ или 
```shell
[root@cv5526017 x86_64]# curl http://repo.rawl32.ru
<html>
<head><title>301 Moved Permanently</title></head>
<body>
<center><h1>301 Moved Permanently</h1></center>
<hr><center>nginx/1.26.3</center>
</body>
</html>


[root@cv5526017 x86_64]# curl https://repo.rawl32.ru
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
        <head>
                <title>Test Page for the HTTP Server on AlmaLinux</title>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
                <style type="text/css">
                        /*<![CDATA[*/
                        body {
                                background-color: #fff;
                                color: #000;
                                font-size: 1.1em;
                                font-family: "Red Hat Text", Helvetica, Tahoma, sans-serif;
                                margin: 0;
                                padding: 0;
                border-bottom: 30px solid #082336;
                                min-height: 100vh;
                                box-sizing: border-box;
...
```
> Теперь можно сделать репозитарий и разместить там пакеты 
```shell
[root@cv5526017 x86_64]# mkdir /usr/share/nginx/html/repo
[root@cv5526017 x86_64]# cp ~/rpmbuild/RPMS/x86_64/*.rpm /usr/share/nginx/html/repo/
[root@cv5526017 x86_64]# ls -la  /usr/share/nginx/html/repo/
total 2296
drwxr-xr-x 2 root root    4096 Dec  2 17:16 .
drwxr-xr-x 4 root root    4096 Dec  2 17:16 ..
-rw-r--r-- 1 root root   33198 Dec  2 17:16 nginx-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root    9613 Dec  2 17:16 nginx-all-modules-1.26.3-1.el10.noarch.rpm
-rw-r--r-- 1 root root 1147867 Dec  2 17:16 nginx-core-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root   11359 Dec  2 17:16 nginx-filesystem-1.26.3-1.el10.noarch.rpm
-rw-r--r-- 1 root root  897091 Dec  2 17:16 nginx-mod-devel-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root   21616 Dec  2 17:16 nginx-mod-http-image-filter-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root   33621 Dec  2 17:16 nginx-mod-http-perl-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root   20467 Dec  2 17:16 nginx-mod-http-xslt-filter-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root   55367 Dec  2 17:16 nginx-mod-mail-1.26.3-1.el10.x86_64.rpm
-rw-r--r-- 1 root root   88893 Dec  2 17:16 nginx-mod-stream-1.26.3-1.el10.x86_64.rpm

```
> Инициализировал репозиторий 
```shell
[root@cv5526017 x86_64]# createrepo /usr/share/nginx/
html/    modules/
[root@cv5526017 x86_64]# createrepo /usr/share/nginx/html/repo/
Directory walk started
Directory walk done - 10 packages
Temporary output repo path: /usr/share/nginx/html/repo/.repodata/
Pool started (with 5 workers)
Pool finished


[root@cv5526017 repodata]# ls -la /usr/share/nginx/html/repo/repodata/
total 28
drwxr-xr-x 2 root root 4096 Dec  2 17:19 .
drwxr-xr-x 3 root root 4096 Dec  2 17:19 ..
-rw-r--r-- 1 root root 1259 Dec  2 17:19 842a304c6b8e9fe0b0d6476ad4d45f6b6a98e99ada70772f424ff1da645826e1-other.xml.zst
-rw-r--r-- 1 root root 2766 Dec  2 17:19 a3a1828b5fdc901dabf111cbcbe06b726063e8d15c67ba7f9fa446434f501381-primary.xml.zst
-rw-r--r-- 1 root root 4416 Dec  2 17:19 c00af2b4bf5888f6fe4169ec53010688207bd517009c2b6dc385876ea0b7593b-filelists.xml.zst
-rw-r--r-- 1 root root 1557 Dec  2 17:19 repomd.xml

```
> Настройки самого nginx
```shell
[root@cv5526017 repodata]# cat /etc/nginx/conf.d/repo_rawl32_ru.conf
server {
    server_name repo.rawl32.ru;

    location / {
        root /usr/share/nginx/html/repo;
        index index.html index.htm;
        autoindex on;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/repo.rawl32.ru/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/repo.rawl32.ru/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
server {
    if ($host = repo.rawl32.ru) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    server_name repo.rawl32.ru;
    return 404; # managed by Certbot


}

```
> Проверка и запуск
```shell
[root@cv5526017 repodata]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
[root@cv5526017 repodata]# nginx -s reload
```
Заходим сюда: https://repo.rawl32.ru/

> Можно и так проверить
```shell
[root@cv5526017 repodata]# curl -a https://repo.rawl32.ru
<html>
<head><title>Index of /</title></head>
<body>
<h1>Index of /</h1><hr><pre><a href="../">../</a>
<a href="repodata/">repodata/</a>                                          02-Dec-2025 14:19                   -
<a href="nginx-1.26.3-1.el10.x86_64.rpm">nginx-1.26.3-1.el10.x86_64.rpm</a>                     02-Dec-2025 14:16               33198
<a href="nginx-all-modules-1.26.3-1.el10.noarch.rpm">nginx-all-modules-1.26.3-1.el10.noarch.rpm</a>         02-Dec-2025 14:16                9613
<a href="nginx-core-1.26.3-1.el10.x86_64.rpm">nginx-core-1.26.3-1.el10.x86_64.rpm</a>                02-Dec-2025 14:16             1147867
<a href="nginx-filesystem-1.26.3-1.el10.noarch.rpm">nginx-filesystem-1.26.3-1.el10.noarch.rpm</a>          02-Dec-2025 14:16               11359
<a href="nginx-mod-devel-1.26.3-1.el10.x86_64.rpm">nginx-mod-devel-1.26.3-1.el10.x86_64.rpm</a>           02-Dec-2025 14:16              897091
<a href="nginx-mod-http-image-filter-1.26.3-1.el10.x86_64.rpm">nginx-mod-http-image-filter-1.26.3-1.el10.x86_6..&gt;</a> 02-Dec-2025 14:16               21616
<a href="nginx-mod-http-perl-1.26.3-1.el10.x86_64.rpm">nginx-mod-http-perl-1.26.3-1.el10.x86_64.rpm</a>       02-Dec-2025 14:16               33621
<a href="nginx-mod-http-xslt-filter-1.26.3-1.el10.x86_64.rpm">nginx-mod-http-xslt-filter-1.26.3-1.el10.x86_64..&gt;</a> 02-Dec-2025 14:16               20467
<a href="nginx-mod-mail-1.26.3-1.el10.x86_64.rpm">nginx-mod-mail-1.26.3-1.el10.x86_64.rpm</a>            02-Dec-2025 14:16               55367
<a href="nginx-mod-stream-1.26.3-1.el10.x86_64.rpm">nginx-mod-stream-1.26.3-1.el10.x86_64.rpm</a>          02-Dec-2025 14:16               88893
</pre><hr></body>
</html>

```
> Далее тест репозитария и его подключения к системе
```shell
[root@cv5526017 repodata]# cat /etc/yum.repos.d/otus.repo
[otus]
name=otus-linux
baseurl=https://repo.rawl32.ru
gpgcheck=0
enabled=1
[root@cv5526017 repodata]# yum repolist enabled | grep otus
otus                 otus-linux
[root@cv5526017 repodata]# cd /usr/share/nginx/html/repo/
[root@cv5526017 repo]# wget https://repo.percona.com/yum/percona-release-latest.noarch.rpm
--2025-12-02 17:39:38--  https://repo.percona.com/yum/percona-release-latest.noarch.rpm
Resolving repo.percona.com (repo.percona.com)... 49.12.125.205, 2a01:4f8:242:5792::2
Connecting to repo.percona.com (repo.percona.com)|49.12.125.205|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 28532 (28K) [application/x-redhat-package-manager]
Saving to: ‘percona-release-latest.noarch.rpm’

percona-release-latest.noarch.rpm  100%[=============================================================>]  27.86K  --.-KB/s    in 0s

2025-12-02 17:39:39 (68.5 MB/s) - ‘percona-release-latest.noarch.rpm’ saved [28532/28532]

[root@cv5526017 repo]# createrepo /usr/share/nginx/html/repo/
Directory walk started
Directory walk done - 11 packages
Temporary output repo path: /usr/share/nginx/html/repo/.repodata/
Pool started (with 5 workers)
Pool finished
[root@cv5526017 repo]# yum makecache
AlmaLinux 10 - AppStream                                                                                 5.4 kB/s | 3.8 kB     00:00
AlmaLinux 10 - BaseOS                                                                                    6.0 kB/s | 3.8 kB     00:00
AlmaLinux 10 - CRB                                                                                       5.9 kB/s | 3.8 kB     00:00
AlmaLinux 10 - Extras                                                                                    7.6 kB/s | 3.3 kB     00:00
Extra Packages for Enterprise Linux 10 - x86_64                                                           46 kB/s |  37 kB     00:00
otus-linux                                                                                                32 kB/s | 3.0 kB     00:00
Metadata cache created.
[root@cv5526017 repo]# yum list | grep otus
percona-release.noarch                                                                   1.0-32                                      otus
```
> Проверка установки
```shell
[root@cv5526017 repo]# yum list | grep otus
percona-release.noarch                                                                   1.0-32                                      otus
[root@cv5526017 repo]# yum install -y percona-release.noarch
Last metadata expiration check: 0:02:21 ago on Tue 02 Dec 2025 05:40:07 PM MSK.
Dependencies resolved.
=========================================================================================================================================
 Package                                Architecture                  Version                          Repository                   Size
=========================================================================================================================================
Installing:
 percona-release                        noarch                        1.0-32                           otus                         28 k

Transaction Summary
=========================================================================================================================================
Install  1 Package

Total download size: 28 k
Installed size: 50 k
Downloading Packages:
percona-release-latest.noarch.rpm                                                                        631 kB/s |  28 kB     00:00
-----------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                    547 kB/s |  28 kB     00:00
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                 1/1
  Installing       : percona-release-1.0-32.noarch                                                                                   1/1
  Running scriptlet: percona-release-1.0-32.noarch                                                                                   1/1
* Enabling the Percona Release repository
<*> All done!
* Enabling the Percona Telemetry repository
<*> All done!
Specified repository is not supported for current operating system!
The percona-release package now contains a percona-release script that can enable additional repositories for our newer products.

Note: currently there are no repositories that contain Percona products or distributions enabled. We recommend you to enable Percona Distribution repositories instead of individual product repositories, because with the Distribution you will get not only the database itself but also a set of other componets that will help you work with your database.

For example, to enable the Percona Distribution for MySQL 8.0 repository use:

  percona-release setup pdps8.0

Note: To avoid conflicts with older product versions, the percona-release setup command may disable our original repository for some products.

For more information, please visit:
  https://docs.percona.com/percona-software-repositories/percona-release.html



Installed:
  percona-release-1.0-32.noarch

Complete!

```
The end! 