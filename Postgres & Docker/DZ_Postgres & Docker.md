# otus_dz

• сделать каталог /var/lib/postgres

done

• развернуть контейнер с PostgreSQL 14 смонтировав в него /var/lib/postgres
• развернуть контейнер с клиентом postgres

выставил порт 5430 - 5432 был занят

Пробовал переписать ваш файл:
Сначала выдавал ошибку в строке:
**image: bitnami/redis:6.2.7**

Избавился от табулатуры, далее ошибка была

**ERROR: In file './docker-compose.yaml', service must be a mapping, not a NoneType.**

рповерял docker-compose config

Пытался избавиться от каких-то отдельных параметров, подозревая что где то ошибка, в итоге компос файл сократился до одного постгреса и ошибка оставалась.

Переписал отдельно докер компос, сохранить базу после удаления контейнера не удалось:

docker-compose - во вложении.
-------------------------------------------------------------------------------


CONTAINER ID   IMAGE                COMMAND                  CREATED          STATUS          PORTS                                       NAMES
73c83f3324e8   postgres:14.2        "docker-entrypoint.s…"   30 minutes ago   Up 30 minutes   0.0.0.0:5430->5432/tcp, :::5430->5432/tcp   docker




• подключится из контейнера с клиентом к контейнеру с сервером и сделать таблицу с парой строк

docker exec -it 73c83f3324e8 bash

psql -h localhost -p 5430 -U postgres -W

postgres=# 
create table persons(id serial, first_name text, second_name text); insert into persons(first_name, second_name) values('ivan', 'ivanov'); insert into persons(first_name, second_name) values('petr', 'petrov'); commit;
CREATE TABLE
INSERT 0 1
INSERT 0 1
WARNING:  there is no transaction in progress
COMMIT

postgres=# 
select * from persons;
 id | first_name | second_name
----+------------+-------------
  1 | ivan       | ivanov
  2 | petr       | petrov
(2 rows)


• подключится к контейнеру с сервером с ноутбука/компьютера извне инстансов GCP/ЯО/Аналоги

Подключался к DB с помощью DBeaver


