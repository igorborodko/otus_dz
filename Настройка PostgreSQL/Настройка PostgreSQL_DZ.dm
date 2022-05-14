
#Настройка PostgreSQL

#создайте виртуальную машину c Ubuntu 20.04 LTS (bionic) в GCE типа e2-medium в default VPC в любом регионе и зоне, например us-central1-a или ЯО

#поставьте на нее PostgreSQL 14 через sudo apt

#проверьте что кластер запущен через sudo -u postgres pg_lsclusters

#зайдите из под пользователя postgres в psql и сделайте произвольную таблицу с произвольным содержимым postgres=# create table test(c1 text); postgres=# insert into test values('1'); \q

#остановите postgres например через sudo -u postgres pg_ctlcluster 14 main stop

#создайте новый standard persistent диск GKE через Compute Engine -> Disks в том же регионе и зоне что GCE инстанс размером например 10GB - или аналог в другом облаке/виртуализации

#добавьте свеже-созданный диск к виртуальной машине - надо зайти в режим ее редактирования и дальше выбрать пункт attach existing disk

#проинициализируйте диск согласно инструкции и подмонтировать файловую систему, только не забывайте менять имя диска на актуальное, в вашем случае это скорее всего будет /dev/sdb - https://www.digitalocean.com/community/tutorials/how-to-partition-and-format-storage-devices-in-linux

#перезагрузите инстанс и убедитесь, что диск остается примонтированным (если не так смотрим в сторону fstab)

#сделайте пользователя postgres владельцем /mnt/data - chown -R postgres:postgres /mnt/data/

#перенесите содержимое /var/lib/postgres/14 в /mnt/data - mv /var/lib/postgresql/14 /mnt/data

#попытайтесь запустить кластер - sudo -u postgres pg_ctlcluster 14 main start

#напишите получилось или нет и почему
----------------------------------------
Кластер не запустился потому как дирректорию перенесли на /dev/sdb /mnt/data

Ошибка:
root@superserver:/mnt/data# sudo -u postgres pg_ctlcluster 14 main start
Error: /var/lib/postgresql/14/main is not accessible or does not exist

----------------------------------------

#задание: найти конфигурационный параметр в файлах раположенных в /etc/postgresql/14/main который надо поменять и поменяйте его

#напишите что и почему поменяли
----------------------------------------

Сделал замену(закомментил) в postgresql.conf

root@superserver:/etc/postgresql/14/main# nano postgresql.conf

#data_directory = '/var/lib/postgresql/14/main'         # use data in another directory
data_directory = '/mnt/data/14/main'

----------------------------------------
#попытайтесь запустить кластер - sudo -u postgres pg_ctlcluster 14 main start

#напишите получилось или нет и почему
----------------------------------------
Не получилось:
Возникла ошибка:
Warning: the cluster will not be running as a systemd service. Consider using systemctl:

Заупстилс помощью systemctl

root@superserver:/etc/postgresql/14/main# sudo systemctl start postgresql

Проверил статус

root@superserver:/etc/postgresql/14/main# sudo systemctl status postgresql
● postgresql.service - PostgreSQL RDBMS
     Loaded: loaded (/lib/systemd/system/postgresql.service; enabled; vendor preset: enabled)
     Active: active (exited) since Sat 2022-05-14 20:24:46 UTC; 1h 30min ago
   Main PID: 23017 (code=exited, status=0/SUCCESS)
      Tasks: 0 (limit: 4646)
     Memory: 0B
     CGroup: /system.slice/postgresql.service

May 14 20:24:46 superserver systemd[1]: Starting PostgreSQL RDBMS...
May 14 20:24:46 superserver systemd[1]: Finished PostgreSQL RDBMS.
root@superserver:/etc/postgresql/14/main# sudo -u postgres psql
psql (14.3 (Ubuntu 14.3-1.pgdg20.04+1))
Type "help" for help.

Проверил дирректорию
postgres=# SHOW data_directory;
  data_directory
-------------------
 /mnt/data/14/main
(1 row)


#зайдите через через psql и проверьте содержимое ранее созданной таблицы

Проверил базу - на месте

postgres=# select * from persons;
 id | first_name | second_name
----+------------+-------------
  1 | ivan       | ivanov
  2 | petr       | petrov
(2 rows)

#задание со звездочкой *: не удаляя существующий GCE инстанс/ЯО сделайте новый, поставьте на его PostgreSQL, удалите файлы с данными из /var/lib/postgres, перемонтируйте внешний диск который сделали ранее от первой виртуальной машины ко второй и запустите PostgreSQL на второй машине так чтобы он работал с данными на внешнем диске, расскажите как вы это сделали и что в итоге получилось.
Не выполнено.
