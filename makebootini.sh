#!/bin/sh
if [ -f "/internal/boot.ini" ]
then
    break
else
    cp /system/etc/boot.ini.template /internal/boot.ini
fi
