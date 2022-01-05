#!/usr/bin/env bash
while :
do
sleep 5
curl -sSL -o /dev/null -D - https://firewall.jamesrcounts.com
# curl https://firewall.jamesrcounts.com --resolve firewall.jamesrcounts.com:443:52.185.64.147
date
done