#!/bin/bash
set -eu

# clustering のために一旦 background で起動
/usr/local/bin/docker-entrypoint.sh rabbitmq-server -detached

# cluster に参加させる
rabbitmqctl stop_app
rabbitmqctl reset
rabbitmqctl join_cluster rabbit@$1

# 以降は元 (Dockerfile) の起動形式にあわせるための処理
rabbitmqctl stop

# ! FIXME: stopped まで少し時間がかかる，もう少し賢くしたい
sleep 5s

/usr/local/bin/docker-entrypoint.sh rabbitmq-server
