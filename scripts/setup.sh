#!/bin/bash

apt-get update
apt -y install iputils-ping

MONGODB1=`ping -c 1 mongo | head -1  | cut -d "(" -f 2 | cut -d ")" -f 1`

echo "Waiting for startup.."
until curl http://${MONGODB1}:27017/serverStatus\?text\=1 2>&1 | grep uptime | head -1; do
  printf '.'
  sleep 1
done

echo curl http://${MONGODB1}:27017/serverStatus\?text\=1 2>&1 | grep uptime | head -1
echo "Started.."


echo SETUP.sh time now: `date +"%T" `
mongo --host ${MONGODB1}:27017 <<EOF
   var cfg = {
        "_id": "es",
        "members": [
            {
                "_id": 0,
                "host": "${MONGODB1}:27017"
            }
        ]
    };
    rs.initiate(cfg);
    rs.reconfig(cfg, {force : true});
    rs.status();
EOF
