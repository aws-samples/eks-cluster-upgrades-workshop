#!/bin/sh

echo "====================== Self Managed Add-ons ======================" > /tmp/self-addon-report.txt
kubectl get helmreleases -nflux-system | tee -a /tmp/self-addon-report.txt 
echo "====================== Deprecated API in helm charts  ======================" >> /tmp/self-addon-report.txt 
pluto detect-helm -o wide | tee -a /tmp/self-addon-report.txt