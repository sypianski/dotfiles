#!/bin/bash
# Tmux status bar: RAM and CPU info

# RAM: used/total in GB
read -r total used free shared buff_cache available <<< $(free -m | awk '/^Mem:/ {print $2, $3, $4, $5, $6, $7}')
ram_used_gb=$(awk "BEGIN {printf \"%.1f\", $used/1024}")
ram_total_gb=$(awk "BEGIN {printf \"%.1f\", $total/1024}")

# CPU: average usage (1-idle from top)
cpu=$(top -bn1 | awk '/^%Cpu/ {printf "%.0f", 100 - $8}')

echo "${ram_used_gb}/${ram_total_gb}G ${cpu}%"
