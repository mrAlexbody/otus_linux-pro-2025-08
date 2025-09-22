Домашнее задание 01
=
## "Обновление ядра системы"

###Цель:
+ научиться обновлять ядро в ОС Linux;


###Описание/Пошаговая инструкция выполнения домашнего задания:
###🎯Задание
+ Запустите ВМ c Ubuntu.
+ Обновите ядро ОС на новейшую стабильную версию из mainline-репозитория.
+ Оформите отчет в README-файле в GitHub-репозитории.

###⭐️Задание со звездочкой:
+ Собрать ядро самостоятельно из исходных кодов.
---
### Обноление ядра Linux из исходных кодов
Запускаем ВМ Ubuntu 24.04 LTS с версией ядра 6.8.0-79-generic
````shell
 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Ср 10 сен 2025 20:12:14 UTC

  System load:  0.51               Processes:             201
  Usage of /:   11.3% of 57.20GB   Users logged in:       0
  Memory usage: 52%                IPv4 address for eth0: 192.168.77.12
  Swap usage:   0%

root@linux:~# uname -r
6.8.0-79-generic
````
Установил нужные пакеты для сборки ядра
````shell
root@linux:~# apt-get install wget curl make build-essential libncurses-dev flex bison libssl-dev libelf-dev
````
Скачал на сервер исходники "ванильное ядро" версии 6.16.6
````shell
root@linux:~# wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.16.6.tar.xz
--2025-09-10 20:13:02--  https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.16.6.tar.xz
Resolving cdn.kernel.org (cdn.kernel.org)... 151.101.1.176, 151.101.65.176, 151.101.129.176, ...
Connecting to cdn.kernel.org (cdn.kernel.org)|151.101.1.176|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 152654392 (146M) [application/x-xz]
Saving to: ‘linux-6.16.6.tar.xz.1’
linux-6.16.6.tar.xz.1                100%[======================================================================>] 145,58M  22,0MB/s    in 6,4s
2025-09-10 20:13:09 (22,8 MB/s) - ‘linux-6.16.6.tar.xz.1’ saved [152654392/152654392]

root@linux:~# tar xf ./linux-6.16.6.tar.xz

root@linux:~# ls
linux-6.16.6  linux-6.16.6.tar.xz  linux-6.16.6.tar.xz.1
````
Переместим исходники в правильное место
```shell
root@linux:~# mv ./linux-6.16.6 /usr/src/
root@linux:~# ls /usr/src/
linux-6.16.6  linux-headers-6.8.0-79  linux-headers-6.8.0-79-generic
```
Скопируем конфигурцию сборки ядра из текужей версии
```shell
root@linux:~# cd /usr/src/linux-6.16.6/
root@linux:/usr/src/linux-6.16.6# ls
arch   certs    CREDITS  Documentation  fs       init      ipc     Kconfig  lib       MAINTAINERS  mm   README  samples  security  tools  virt
block  COPYING  crypto   drivers        include  io_uring  Kbuild  kernel   LICENSES  Makefile     net  rust    scripts  sound     usr
root@linux:/usr/src/linux-6.16.6# cp /boot/config-$(uname -r) .config
```
Запускаем команду, которая берет существующий файл конфигурации (.config) и адаптирует его к новой версии исходного кода, где
автоматически присваивает значения по умолчанию всем новым параметрам, появившимся в этой новой версии
```shell
root@linux:/usr/src/linux-6.16.6# make olddefconfig
  HOSTCC  scripts/basic/fixdep
  HOSTCC  scripts/kconfig/conf.o
  HOSTCC  scripts/kconfig/confdata.o
  HOSTCC  scripts/kconfig/expr.o
  LEX     scripts/kconfig/lexer.lex.c
  YACC    scripts/kconfig/parser.tab.[ch]
  HOSTCC  scripts/kconfig/lexer.lex.o
  HOSTCC  scripts/kconfig/menu.o
  HOSTCC  scripts/kconfig/parser.tab.o
  HOSTCC  scripts/kconfig/preprocess.o
  HOSTCC  scripts/kconfig/symbol.o
  HOSTCC  scripts/kconfig/util.o
  HOSTLD  scripts/kconfig/conf
.config:964:warning: symbol value '0' invalid for BASE_SMALL
.config:7321:warning: symbol value 'm' invalid for FB_BACKLIGHT
.config:10819:warning: symbol value 'm' invalid for ANDROID_BINDER_IPC
.config:10820:warning: symbol value 'm' invalid for ANDROID_BINDERFS
.config:11811:warning: symbol value 'm' invalid for CRYPTO_ARCH_HAVE_LIB_CHACHA
.config:11814:warning: symbol value 'm' invalid for CRYPTO_ARCH_HAVE_LIB_CURVE25519
.config:11819:warning: symbol value 'm' invalid for CRYPTO_ARCH_HAVE_LIB_POLY1305
#
# configuration written to .config
#
... и т.д.
```
Запустил параллельной сборку ядра
```shell
root@linux:/usr/src/linux-6.16.6# make -j$(nproc)
  WRAP    arch/x86/include/generated/uapi/asm/bpf_perf_event.h
  WRAP    arch/x86/include/generated/uapi/asm/errno.h
  WRAP    arch/x86/include/generated/uapi/asm/fcntl.h
  WRAP    arch/x86/include/generated/uapi/asm/ioctl.h
  WRAP    arch/x86/include/generated/uapi/asm/ioctls.h
  WRAP    arch/x86/include/generated/uapi/asm/ipcbuf.h
  WRAP    arch/x86/include/generated/uapi/asm/param.h
  WRAP    arch/x86/include/generated/uapi/asm/poll.h
  UPD     include/generated/uapi/linux/version.h
  WRAP    arch/x86/include/generated/uapi/asm/resource.h
  WRAP    arch/x86/include/generated/uapi/asm/socket.h
  WRAP    arch/x86/include/generated/uapi/asm/sockios.h
  WRAP    arch/x86/include/generated/uapi/asm/termbits.h
  WRAP    arch/x86/include/generated/uapi/asm/termios.h
  WRAP    arch/x86/include/generated/uapi/asm/types.h
  SYSHDR  arch/x86/include/generated/uapi/asm/unistd_32.h
  SYSHDR  arch/x86/include/generated/uapi/asm/unistd_64.h
  SYSHDR  arch/x86/include/generated/uapi/asm/unistd_x32.h
  SYSTBL  arch/x86/include/generated/asm/syscalls_32.h
  SYSHDR  arch/x86/include/generated/asm/unistd_32_ia32.h
  WRAP    arch/x86/include/generated/asm/early_ioremap.h
  UPD     include/generated/compile.h
  WRAP    arch/x86/include/generated/asm/fprobe.h
  SYSHDR  arch/x86/include/generated/asm/unistd_64_x32.h
  HOSTCC  arch/x86/tools/relocs_32.o
  WRAP    arch/x86/include/generated/asm/mcs_spinlock.h
  WRAP    arch/x86/include/generated/asm/mmzone.h
  WRAP    arch/x86/include/generated/asm/irq_regs.h
  WRAP    arch/x86/include/generated/asm/kmap_size.h
  WRAP    arch/x86/include/generated/asm/local64.h
  UPD     include/config/kernel.release
  WRAP    arch/x86/include/generated/asm/mmiowb.h
  UPD     arch/x86/include/generated/asm/cpufeaturemasks.h
  DESCEND objtool
  WRAP    arch/x86/include/generated/asm/module.lds.h
  WRAP    arch/x86/include/generated/asm/rwonce.h
  SYSTBL  arch/x86/include/generated/asm/syscalls_64.h
  HOSTCC  arch/x86/tools/relocs_64.o
  HOSTCC  arch/x86/tools/relocs_common.o
  HYPERCALLS arch/x86/include/generated/asm/xen-hypercalls.h
  UPD     include/generated/utsrelease.h
  HOSTCC  scripts/kallsyms
  HOSTCC  scripts/sorttable
  HOSTCC  scripts/asn1_compiler
  HOSTCC  scripts/genksyms/genksyms.o
  YACC    scripts/genksyms/parse.tab.[ch]
  HOSTCC  scripts/sign-file
  HOSTCC  scripts/selinux/mdp/mdp
  LEX     scripts/genksyms/lex.lex.c
  HOSTCC  scripts/insert-sys-cert
  HOSTCC  scripts/genksyms/parse.tab.o
  HOSTCC  scripts/genksyms/lex.lex.o
  INSTALL /usr/src/linux-6.16.6/tools/objtool/libsubcmd/include/subcmd/exec-cmd.h
  INSTALL /usr/src/linux-6.16.6/tools/objtool/libsubcmd/include/subcmd/help.h
  INSTALL /usr/src/linux-6.16.6/tools/objtool/libsubcmd/include/subcmd/pager.h
  INSTALL /usr/src/linux-6.16.6/tools/objtool/libsubcmd/include/subcmd/parse-options.h
  INSTALL /usr/src/linux-6.16.6/tools/objtool/libsubcmd/include/subcmd/run-command.h
  INSTALL libsubcmd_headers
  HOSTLD  arch/x86/tools/relocs
  .... и т.д.
```
Ошибка сборки
```shell
...
  CC [M]  fs/bcachefs/varint.o
  CC [M]  fs/xfs/xfs_notify_failure.o
  CC [M]  fs/bcachefs/xattr.o
  LD [M]  fs/xfs/xfs.o
  LD [M]  fs/bcachefs/bcachefs.o
make[1]: *** [/usr/src/linux-6.16.6/Makefile:2003: .] Error 2
make: *** [Makefile:248: __sub-make] Error 2
... и т.д.
```
Поиск ошибки 
```shell
root@linux:/usr/src/linux-6.16.6# df -h
Filesystem                         Size  Used Avail Use% Mounted on
tmpfs                              392M  1,1M  391M   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv   58G  8,4G   47G  16% /
tmpfs                              2,0G     0  2,0G   0% /dev/shm
tmpfs                              5,0M     0  5,0M   0% /run/lock
/dev/sda2                          1,8G  100M  1,6G   7% /boot
tmpfs                              392M   12K  392M   1% /run/user/1000

root@linux:/usr/src/linux-6.16.6# dmesg -T | tail -20
[Ср сен 10 20:04:54 2025] input: TPPS/2 IBM TrackPoint as /devices/platform/i8042/serio1/input/input3
[Ср сен 10 20:04:54 2025] input: AT Translated Set 2 keyboard as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A03:00/device:07/VMBUS:01/d34b2567-b9b6-42b9-8                                                                                                                                                                    778-0a4ec0b955bf/serio2/input/input5
[Ср сен 10 20:04:54 2025] systemd[1]: Started systemd-journald.service - Journal Service.
[Ср сен 10 20:04:55 2025] systemd-journald[416]: Received client request to flush runtime journal.
[Ср сен 10 20:04:55 2025] systemd-journald[416]: /var/log/journal/0e820715110a45f2b52ade688f519640/system.journal: Journal file uses a different seq                                                                                                                                                                    uence number ID, rotating.
[Ср сен 10 20:04:55 2025] systemd-journald[416]: Rotating system journal.
[Ср сен 10 20:04:55 2025] kauditd_printk_skb: 110 callbacks suppressed
[Ср сен 10 20:04:55 2025] audit: type=1400 audit(1757534695.311:121): apparmor="STATUS" operation="profile_replace" info="same as current profile, s                                                                                                                                                                    kipping" profile="unconfined" name="rsyslogd" pid=861 comm="apparmor_parser"
[Ср сен 10 20:04:55 2025] NET: Registered PF_QIPCRTR protocol family
[Ср сен 10 20:04:55 2025] loop0: detected capacity change from 0 to 8
[Ср сен 10 20:04:55 2025] audit: type=1400 audit(1757534695.462:122): apparmor="STATUS" operation="profile_replace" profile="unconfined" name="/usr/                                                                                                                                                                    lib/snapd/snap-confine" pid=971 comm="apparmor_parser"
[Ср сен 10 20:04:55 2025] audit: type=1400 audit(1757534695.478:123): apparmor="STATUS" operation="profile_replace" profile="unconfined" name="/usr/                                                                                                                                                                    lib/snapd/snap-confine//mount-namespace-capture-helper" pid=971 comm="apparmor_parser"
[Ср сен 10 20:05:40 2025] hv_balloon: Max. dynamic memory size: 1048576 MB
[Ср сен 10 20:08:06 2025] TCP: eth0: Driver has suspect GRO implementation, TCP performance may be compromised.
[Ср сен 10 20:08:06 2025] systemd-journald[416]: /var/log/journal/0e820715110a45f2b52ade688f519640/user-1000.journal: Journal file uses a different                                                                                                                                                                     sequence number ID, rotating.
[Ср сен 10 20:08:49 2025] hv_balloon: Balloon request will be partially fulfilled. Balloon floor reached.
[Ср сен 10 20:13:49 2025] hv_balloon: Balloon request will be partially fulfilled. Balloon floor reached.
[Ср сен 10 20:13:49 2025] hv_balloon: Balloon request will be partially fulfilled. Balloon floor reached.
[Ср сен 10 20:13:49 2025] hv_balloon: Balloon request will be partially fulfilled. Balloon floor reached.
[Ср сен 10 20:13:49 2025] hv_balloon: Balloon request will be partially fulfilled. Balloon floor reached.
root@linux:/usr/src/linux-6.16.6# dmesg -T | tail -200
[Ср сен 10 20:04:50 2025] sd 2:0:0:0: Attached scsi generic sg1 type 0
[Ср сен 10 20:04:50 2025] hid-hyperv 0006:045E:0621.0001: input: VIRTUAL HID v0.01 Mouse [Microsoft Vmbus HID-compliant Mouse] on
[Ср сен 10 20:04:50 2025] sd 2:0:0:0: [sda] 125829120 512-byte logical blocks: (64.4 GB/60.0 GiB)
[Ср сен 10 20:04:50 2025] sd 2:0:0:0: [sda] Write Protect is off
[Ср сен 10 20:04:50 2025] sd 2:0:0:0: [sda] Mode Sense: 0f 00 00 00
[Ср сен 10 20:04:50 2025] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[Ср сен 10 20:04:50 2025]  sda: sda1 sda2 sda3
[Ср сен 10 20:04:50 2025] sd 2:0:0:0: [sda] Attached SCSI disk
[Ср сен 10 20:04:51 2025] raid6: avx2x4   gen() 34835 MB/s
[Ср сен 10 20:04:51 2025] raid6: avx2x2   gen() 33449 MB/s
[Ср сен 10 20:04:51 2025] raid6: avx2x1   gen() 23456 MB/s
[Ср сен 10 20:04:51 2025] raid6: using algorithm avx2x4 gen() 34835 MB/s
[Ср сен 10 20:04:51 2025] raid6: .... xor() 6878 MB/s, rmw enabled
[Ср сен 10 20:04:51 2025] raid6: using avx2x2 recovery algorithm
[Ср сен 10 20:04:51 2025] xor: automatically using best checksumming function   avx
[Ср сен 10 20:04:51 2025] async_tx: api initialized (async)
[Ср сен 10 20:04:51 2025] psmouse serio1: trackpoint: failed to get extended button data, assuming 3 buttons
[Ср сен 10 20:04:51 2025] Btrfs loaded, zoned=yes, fsverity=yes
[Ср сен 10 20:04:51 2025] I/O error, dev fd0, sector 0 op 0x0:(READ) flags 0x0 phys_seg 1 prio class 0
[Ср сен 10 20:04:51 2025] floppy: error 10 while reading block 0
[Ср сен 10 20:04:51 2025] EXT4-fs (dm-0): mounted filesystem 79885dde-1c3a-4402-8c04-67471bab8984 ro with ordered data mode. Quota mode: none.
[Ср сен 10 20:04:51 2025] systemd[1]: Inserted module 'autofs4'
[Ср сен 10 20:04:51 2025] systemd[1]: systemd 255.4-1ubuntu8.10 running in system mode (+PAM +AUDIT +SELINUX +APPARMOR +IMA +SMACK +SECCOMP +GCRYPT                                                                                                                                                                     -GNUTLS +OPENSSL +ACL +BLKID +CURL +ELFUTILS +FIDO2 +IDN2 -IDN +IPTC +KMOD +LIBCRYPTSETUP +LIBFDISK +PCRE2 -PWQUALITY +P11KIT +QRENCODE +TPM2 +BZIP2                                                                                                                                                                     +LZ4 +XZ +ZLIB +ZSTD -BPF_FRAMEWORK -XKBCOMMON +UTMP +SYSVINIT default-hierarchy=unified)
[Ср сен 10 20:04:51 2025] systemd[1]: Detected virtualization microsoft.
[Ср сен 10 20:04:51 2025] systemd[1]: Detected architecture x86-64.
---
root@linux:/usr/src/linux-6.16.6# free --mega
               total        used        free      shared  buff/cache   available
Mem:             649         489         135           3         295         160
Swap:           2038          49        1989
```
Виртуалки не хватило памяти, накинул до 8 ГБ и запустил всё заново через очистку (cleanup) собранных файлов.

```shell
root@linux:/usr/src/linux-6.16.6# make clean
  CLEAN   arch/x86/entry/vdso
  CLEAN   arch/x86/kernel/cpu
  CLEAN   arch/x86/kernel
  CLEAN   arch/x86/kvm
  CLEAN   arch/x86/purgatory
  CLEAN   arch/x86/realmode/rm
  CLEAN   arch/x86/tools
  CLEAN   arch/x86/lib/crypto
  CLEAN   arch/x86/lib
  CLEAN   crypto/asymmetric_keys
  CLEAN   drivers/accessibility/speakup
  CLEAN   drivers/firmware/efi/libstub
  CLEAN   drivers/gpu/drm/radeon
  CLEAN   drivers/gpu/drm/xe
  CLEAN   drivers/net/wan
  CLEAN   drivers/scsi/aic7xxx
  CLEAN   drivers/scsi
  CLEAN   drivers/tty/vt
  CLEAN   fs/unicode
  CLEAN   init
  CLEAN   kernel/debug/kdb
  CLEAN   kernel
  CLEAN   lib/raid6
  CLEAN   lib/test_fortify
  CLEAN   lib
  CLEAN   net/wireless
  CLEAN   security/apparmor
  CLEAN   security/selinux
  CLEAN   security/tomoyo
  CLEAN   usr
  CLEAN   .
```
Запуск сборки ядра
```shell
root@linux:/usr/src/linux-6.16.6# make -j$(nproc)
...
 HOSTCC  scripts/kconfig/mconf.o
  HOSTCC  scripts/kconfig/lxdialog/checklist.o
  HOSTCC  scripts/kconfig/lxdialog/inputbox.o
  HOSTCC  scripts/kconfig/lxdialog/menubox.o
  HOSTCC  scripts/kconfig/lxdialog/textbox.o
  HOSTCC  scripts/kconfig/lxdialog/util.o
  HOSTCC  scripts/kconfig/lxdialog/yesno.o
  HOSTCC  scripts/kconfig/mnconf-common.o
  HOSTCC  scripts/kconfig/confdata.o
  HOSTCC  scripts/kconfig/expr.o
  LEX     scripts/kconfig/lexer.lex.c
  YACC    scripts/kconfig/parser.tab.[ch]
  HOSTCC  scripts/kconfig/lexer.lex.o
  HOSTCC  scripts/kconfig/menu.o
  HOSTCC  scripts/kconfig/parser.tab.o
  HOSTCC  scripts/kconfig/preprocess.o
  HOSTCC  scripts/kconfig/symbol.o
  HOSTCC  scripts/kconfig/util.o
  HOSTLD  scripts/kconfig/mconf
... и т.д.
````
Теперь устанавливаем собранное ядро в систему, с обновлением конфигурации загрузчика и созданием initramfs
```shell
root@linux:/usr/src/linux-6.16.6# make install
  INSTALL /boot
run-parts: executing /etc/kernel/postinst.d/initramfs-tools 6.16.6 /boot/vmlinuz-6.16.6
update-initramfs: Generating /boot/initrd.img-6.16.6
run-parts: executing /etc/kernel/postinst.d/unattended-upgrades 6.16.6 /boot/vmlinuz-6.16.6
run-parts: executing /etc/kernel/postinst.d/update-notifier 6.16.6 /boot/vmlinuz-6.16.6
run-parts: executing /etc/kernel/postinst.d/xx-update-initrd-links 6.16.6 /boot/vmlinuz-6.16.6
I: /boot/initrd.img is now a symlink to initrd.img-6.16.6
run-parts: executing /etc/kernel/postinst.d/zz-update-grub 6.16.6 /boot/vmlinuz-6.16.6
Sourcing file `/etc/default/grub'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.16.6
Found initrd image: /boot/initrd.img-6.16.6
Found linux image: /boot/vmlinuz-6.8.0-79-generic
Found initrd image: /boot/initrd.img-6.8.0-79-generic
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
Adding boot menu entry for UEFI Firmware Settings ...
done
...и т.д.
```
Перезагрузил ВМ  и проверил версию ядра
```shell
root@linux:/usr/src/linux-6.16.6# uname -r
6.8.0-79-generic

root@linux:/usr/src/linux-6.16.6# update-grub
Sourcing file `/etc/default/grub'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.16.6
Found initrd image: /boot/initrd.img-6.16.6
Found linux image: /boot/vmlinuz-6.8.0-79-generic
Found initrd image: /boot/initrd.img-6.8.0-79-generic
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
Adding boot menu entry for UEFI Firmware Settings ...
done
```
```shell
root@linux:/usr/src/linux-6.16.6# ls -la /boot/vmlinuz-* /boot/initrd.img-*
-rw-r--r-- 1 root root 597241367 сен 11 06:56 /boot/initrd.img-6.16.6
-rw-r--r-- 1 root root  72478863 сен 10 20:03 /boot/initrd.img-6.8.0-79-generic
-rw-r--r-- 1 root root  13918720 сен 11 06:56 /boot/vmlinuz-6.16.6
-rw------- 1 root root  15014280 авг 12 10:35 /boot/vmlinuz-6.8.0-79-generic

````
```shell
root@linux:/usr/src/linux-6.16.6# reboot
Broadcast message from root@linux on pts/3 (Thu 2025-09-11 07:22:48 UTC):
The system will reboot now!

Broadcast message from root@linux on pts/3 (Thu 2025-09-11 07:22:48 UTC):

The system will reboot now!
````
После перезагрузки проверяем
```shell
root@linux:~# uname -r
6.16.6
```
```shell
root@linux:~# grep -A 10 -B 2 "6.16.6" /boot/grub/grub.cfg
          search --no-floppy --fs-uuid --set=root bad47e9c-3ab0-471b-8ab0-83d353c77c2b
        fi
        linux   /vmlinuz-6.16.6 root=/dev/mapper/ubuntu--vg-ubuntu--lv ro
        initrd  /initrd.img-6.16.6
}
submenu 'Advanced options for Ubuntu' $menuentry_id_option 'gnulinux-advanced-79885dde-1c3a-4402-8c04-67471bab8984' {
        menuentry 'Ubuntu, with Linux 6.16.6' --class ubuntu --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-6.16.6-advanced-79885dde-1c3a-4402-8c04-67471bab8984' {
                recordfail
                load_video
                gfxmode $linux_gfx_mode
                insmod gzio
                if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi
                insmod part_gpt
                insmod ext2
                set root='hd0,gpt2'
                if [ x$feature_platform_search_hint = xy ]; then
                  search --no-floppy --fs-uuid --set=root --hint-bios=hd0,gpt2 --hint-efi=hd0,gpt2 --hint-baremetal=ahci0,gpt2  bad47e9c-3ab0-471b-8ab0-83d353c77c2b
--
                  search --no-floppy --fs-uuid --set=root bad47e9c-3ab0-471b-8ab0-83d353c77c2b
                fi
                echo    'Loading Linux 6.16.6 ...'
                linux   /vmlinuz-6.16.6 root=/dev/mapper/ubuntu--vg-ubuntu--lv ro
                echo    'Loading initial ramdisk ...'
                initrd  /initrd.img-6.16.6
        }
        menuentry 'Ubuntu, with Linux 6.16.6 (recovery mode)' --class ubuntu --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-6.16.6-recovery-79885dde-1c3a-4402-8c04-67471bab8984' {
                recordfail
                load_video
                insmod gzio
                if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi
                insmod part_gpt
                insmod ext2
                set root='hd0,gpt2'
                if [ x$feature_platform_search_hint = xy ]; then
                  search --no-floppy --fs-uuid --set=root --hint-bios=hd0,gpt2 --hint-efi=hd0,gpt2 --hint-baremetal=ahci0,gpt2  bad47e9c-3ab0-471b-8ab0-83d353c77c2b
                else
                  search --no-floppy --fs-uuid --set=root bad47e9c-3ab0-471b-8ab0-83d353c77c2b
                fi
                echo    'Loading Linux 6.16.6 ...'
                linux   /vmlinuz-6.16.6 root=/dev/mapper/ubuntu--vg-ubuntu--lv ro recovery nomodeset dis_ucode_ldr
                echo    'Loading initial ramdisk ...'
                initrd  /initrd.img-6.16.6
        }
        menuentry 'Ubuntu, with Linux 6.8.0-79-generic' --class ubuntu --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-6.8.0-79-generic-advanced-79885dde-1c3a-4402-8c04-67471bab8984' {
                recordfail
                load_video
                gfxmode $linux_gfx_mode
                insmod gzio
                if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi
                insmod part_gpt
                insmod ext2
                set root='hd0,gpt2'
```
Всё ок, ВМ обновлена на новое ядро!!!
