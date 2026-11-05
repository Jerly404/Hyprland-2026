#!/usr/bin/env bash
# Script simple: devuelve solo icono y temperatura
curl -s "wttr.in?format=%c%t" | sed 's/+//g'
