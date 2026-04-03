#!/bin/bash

#Generates system report and writes it to report.txt

current_datetime=$(date +"%Y-%m-%d %H:%M:%S")
if [[ -z "$current_datetime" ]]; then
    current_datetime="Unavailable"
fi

current_user=$(whoami)
if [[ -z "$current_user" ]]; then
    current_user="Unavailable"
fi

internal_ip=$(hostname -I | awk '{print $1}')
if [[ -z "$internal_ip" ]]; then
    internal_ip="Unavailable"
fi

hostname=$(hostname)
if [[ -z "$hostname" ]]; then
    current_user="Unavailable"
fi

external_ip=$(curl -s ifconfig.me 2>/dev/null)
if [[ -z "$external_ip" ]]; then
    external_ip="Unavailable"
fi

if [ -f /etc/os-release ]; then
    source /etc/os-release
    distro_info="$PRETTY_NAME"
else
    distro_info="Unavailable"
fi

system_uptime=$(uptime -p)
if [[ -z "$system_uptime" ]]; then
    system_uptime="Unavailable"
fi

disk_used=$(df -BG / | awk 'NR==2 {print $3}')
if [[ -z "$disk_used" ]]; then
    disk_used="Unavailable"
fi

disk_free=$(df -BG / | awk 'NR==2 {print $4}')
if [[ -z "$disk_free" ]]; then
    disk_free="Unavailable"
fi

ram_total=$(free -g | awk '/^Mem:/ {print $2}')
if [[ -z "$ram_total" ]]; then
    ram_total="Unavailable"
fi

ram_free=$(free -g | awk '/^Mem:/ {print $4}')
if [[ -z "$ram_free" ]]; then
    ram_free="Unavailable"
fi

cpu_cores=$(nproc)
if [[ -z "$cpu_cores" ]]; then
    cpu_cores="Unavailable"
fi

cpu_freq=$(lscpu | awk -F: '/CPU MHz/ {print $2}')
if [[ -z "$cpu_freq" ]]; then
    cpu_freq="Unavailable"
fi

report_file="report.txt"

{
    echo "Current date and time: $current_datetime"
    echo "Current user: $current_user"
    echo "Internal IP address: ${internal_ip}"
    echo "Hostname: $hostname"
    echo "External IP address: ${external_ip}"
    echo "Linux distro info: $distro_info"
    echo "System uptime: $system_uptime"
    echo "Disk space: Used: $disk_used, Free: $disk_free"
    echo "RAM: Total: $ram_total, Free: $ram_free"
    echo "CPU: Number of cores: $cpu_cores, Frequency: $cpu_freq"
} > "$report_file"

echo "Report file generated: $report_file"
