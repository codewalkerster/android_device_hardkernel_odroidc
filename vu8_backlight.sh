#!/bin/sh

echo 97 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio97/direction
