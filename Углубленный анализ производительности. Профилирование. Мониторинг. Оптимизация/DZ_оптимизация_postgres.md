

--Подключился к базе, залил 2 млн записей:
sudo su postgres 
cd $HOME && wget --quiet https://edu.postgrespro.ru/demo_small.zip && unzip demo_small.zip && psql < demo_small.sql
exit

--Тестирую pg_top.
sudo -u postgres pg_top

--Ошибка:
last pid: 64507; load avg: 0.00, 0.00, 0.00; up 3+22:36:12 11:20:46
0 processes:
CPU states: 0.0% user, 0.0% nice, 0.2% system, 99.7% idle, 0.1% iowait
Memory: 947M used, 2985M free, 0K shared, 44M buffers, 641M cached
Swap: 0K used, 0K free, 0K cached, 0K in, 0K out

connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: No such file or directory
Is the server running locally and accepting connections on that socket?

--Проверил нетстат:

root@superserver:~# netstat -an | grep 5432
tcp 0 0 127.0.0.1:5432 0.0.0.0:* LISTEN
tcp6 0 0 ::1:5432 :::* LISTEN
unix 2 [ ACC ] STREAM LISTENING 97769 /var/run/postgresql/.s.PGSQL.5432

--Проверил nmap

root@superserver:~# nmap -sS -O 127.0.0.1
Starting Nmap 7.80 ( https://nmap.org ) at 2022-05-17 11:27 UTC
Nmap scan report for localhost (127.0.0.1)
Host is up (0.000027s latency).
Not shown: 998 closed ports
PORT STATE SERVICE
22/tcp open ssh
5432/tcp open postgresql
Device type: general purpose
Running: Linux 2.6.X
OS CPE: cpe:/o:linux:linux_kernel:2.6.32
OS details: Linux 2.6.32
Network Distance: 0 hops

OS detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 1.58 seconds

--Выяснили, порт 5433
sudo -u postgres pg_top -p 5433

--Вывод:
last pid: 78341;  load avg:  0.85,  0.78,  0.53;       up 4+22:48:44                                                                                                                                 11:33:18
7 processes: 5 other background task(s), 2 active
CPU states: 46.1% user,  0.0% nice,  4.0% system, 21.9% idle, 28.0% iowait
Memory: 2013M used, 1919M free, 0K shared, 2988K buffers, 1701M cached
Swap: 0K used, 0K free, 0K cached, 0K in, 0K out

    PID USERNAME    SIZE   RES STATE   XTIME  QTIME  %CPU LOCKS COMMAND
  78342 postgres    214M   16M active   0:00   0:00   0.0     8 postgres: 14/main: postgres postgres [local] idle
  78215 postgres    302M  187M active   0:10   0:10  98.7     1 postgres: 14/main: postgres postgres [local] INSERT
  77128             213M 9552K          0:00   0:00   0.0     0 postgres: 14/main: autovacuum launcher
  77125             213M  105M          0:00   0:00   0.0     0 postgres: 14/main: checkpointer
  77130 postgres    213M 6784K          0:00   0:00   0.0     0 postgres: 14/main: logical replication launcher
  77127             213M 8180K          0:00   0:00   0.0     0 postgres: 14/main: walwriter
  77126             213M  135M          0:00   0:00   0.0     0 postgres: 14/main: background writer

--Вывел процесс 78215

Current query for procpid 78215:

INSERT INTO test SELECT s.id FROM generate_series(1,1000000000) AS s(id);

-- 2 окно параллейно с запуском pgtop
sudo -u postgres psql
CREATE TABLE test(i int);
INSERT INTO test SELECT s.id FROM generate_series(1,1000000000) AS s(id);

--Инсерт завершился ошибкой
ERROR:  could not extend file "base/13728/16507.7": No space left on device
HINT:  Check free disk space.

