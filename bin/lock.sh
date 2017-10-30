#!/bin/bash

i3lock -i /home/mpatelcz/Pictures/Golebie.png

sleep 180; pgrep i3lock && xset dpms force off
