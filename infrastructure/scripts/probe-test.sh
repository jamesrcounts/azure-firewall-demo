#!/usr/bin/env bash
while :
do
sleep 5
curl https://firewall.jamesrcounts.com --resolve firewall.jamesrcounts.com:443:52.154.203.99
date
done