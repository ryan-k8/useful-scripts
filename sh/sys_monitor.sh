#!/bin/zsh

USER_EMAIL="$1"
CPU_THRESHOLD="$2"
BATTERY_THRESHOLD="$3"
UPTIME_THRESHOLD="$4"
INTERVAL="$5"

send_email() {
    echo -e "$1" | mail -s "System Alert: Threshold Exceeded" "$USER_EMAIL"
}

get_cpu_usage() {
    # iostat | awk 'NR==4 {print 100 - $6}' | cut -d'.' -f1
    # top -l 1 | grep "CPU usage:" | awk '{print $3}' | cut -d% -f1
    top -l 1 | grep "CPU usage:" | awk '{print int($3)}' | cut -d% -f1
}

get_battery_level() {
    pmset -g batt | grep -Eo "\d+%" | cut -d% -f1
}

get_uptime() {
    uptime | awk -F'( |,|:)+' '{ if ($6 == "day" || $6 == "days") { print ($5 * 1440) + ($7 * 60) + $8 } else { print ($5 * 60) + $6 }}'
}

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

while true; do
    CPU_USAGE=$(get_cpu_usage)
    BATTERY_LEVEL=$(get_battery_level)
    UPTIME=$(get_uptime)

    # Check CPU usage
    if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
        echo -e "${RED}CPU usage is high: $CPU_USAGE%${RESET}"
        send_email "CPU usage has exceeded the threshold. Current usage: $CPU_USAGE%"
        exit 0
    else
        echo -e "${GREEN}CPU usage is within limits: $CPU_USAGE%${RESET}"
    fi

    # Check battery level
    if [ "$BATTERY_LEVEL" -lt "$BATTERY_THRESHOLD" ]; then
        echo -e "${YELLOW}Battery level is low: $BATTERY_LEVEL%${RESET}"
        send_email "Battery level is below the threshold. Current level: $BATTERY_LEVEL%"
        exit 0
    else
        echo -e "${GREEN}Battery level is within limits: $BATTERY_LEVEL%${RESET}"
    fi

    # Check uptime
    if [ "$UPTIME" -gt "$UPTIME_THRESHOLD" ]; then
        echo -e "${RED}System uptime is high: $UPTIME minutes${RESET}"
        send_email "System uptime has exceeded the threshold. Current uptime: $UPTIME minutes"
        exit 0
    else
        echo -e "${GREEN}System uptime is within limits: $UPTIME minutes${RESET}"
    fi

    # Wait for the specified interval before checking again
    sleep "$INTERVAL"
done
