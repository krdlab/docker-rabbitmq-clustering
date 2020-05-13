# docker-rabbitmq-clustering

## network partition を発生させる例

```sh
pumba netem --tc-image gaiadocker/iproute2 --duration 120s loss --percent 100 docker-rabbitmq-clustering_rabbit2_1 docker-rabbitmq-clustering_rabbit3_1
```

しばらくすると log に

```
rabbit1_1  | 2019-12-19 06:47:13.118 [error] <0.1176.0> ** Node rabbit@rabbit2 not responding **
rabbit1_1  | ** Removing (timedout) connection **
rabbit1_1  | 2019-12-19 06:47:13.118 [info] <0.524.0> rabbit on node rabbit@rabbit2 down
rabbit1_1  | 2019-12-19 06:47:13.121 [error] <0.16287.0> ** Node rabbit@rabbit3 not responding **
rabbit1_1  | ** Removing (timedout) connection **
rabbit1_1  | 2019-12-19 06:47:13.121 [warning] <0.777.0> Management delegate query returned errors:
rabbit1_1  | [{<43379.549.0>,{exit,{nodedown,rabbit@rabbit2},[]}},{<43381.547.0>,{exit,{nodedown,rabbit@rabbit3},[]}}]
rabbit1_1  | 2019-12-19 06:47:13.137 [info] <0.524.0> Node rabbit@rabbit2 is down, deleting its listeners
rabbit1_1  | 2019-12-19 06:47:13.139 [info] <0.524.0> node rabbit@rabbit2 down: net_tick_timeout
rabbit1_1  | 2019-12-19 06:47:13.139 [info] <0.524.0> rabbit on node rabbit@rabbit3 down
rabbit1_1  | 2019-12-19 06:47:13.146 [info] <0.524.0> Node rabbit@rabbit3 is down, deleting its listeners
rabbit1_1  | 2019-12-19 06:47:13.148 [info] <0.524.0> node rabbit@rabbit3 down: net_tick_timeout
rabbit1_1  | 2019-12-19 06:47:19.341 [warning] <0.778.0> Management delegate query returned errors:
rabbit1_1  | [{<43379.549.0>,{exit,{nodedown,rabbit@rabbit2},[]}},{<43381.547.0>,{exit,{nodedown,rabbit@rabbit3},[]}}]
```

ダウン判定が出力される，このときメッセージを適当に rabbit1 へ publish する．

```
rabbit1_1  | 2019-12-19 06:47:57.390 [info] <0.524.0> node rabbit@rabbit2 up
rabbit1_1  | 2019-12-19 06:47:57.395 [error] <0.310.0> Mnesia(rabbit@rabbit1): ** ERROR ** mnesia_event got {inconsistent_database, running_partitioned_network, rabbit@rabbit2}
rabbit1_1  | 2019-12-19 06:47:57.801 [info] <0.524.0> node rabbit@rabbit3 up
rabbit1_1  | 2019-12-19 06:47:57.804 [error] <0.310.0> Mnesia(rabbit@rabbit1): ** ERROR ** mnesia_event got {inconsistent_database, running_partitioned_network, rabbit@rabbit3}
```

120s が経過して loss がなくなると，inconsistent になる．

## PerfTest

`docker-compose up -d` で作成された network に対して PerfTest を実行する．

```sh
docker run -it --rm --network docker-rabbitmq-clustering_default \
    pivotalrabbitmq/perf-test:latest \
    --uris amqp://rabbit1,amqp://rabbit2,amqp://rabbit3
```
