#!/bin/sh

echo "====================== Kubent Deprecated APIs report ======================" > /tmp/kubent-report.txt
/usr/local/bin/kubent | tee -a /tmp/kubent-report.txt