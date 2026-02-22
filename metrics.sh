#!/bin/bash

# ================= CONFIG =================

BOT_TOKEN="<your-bot-token>"
CHAT_ID="<your-chat-id>"

STATE_DIR="/var/tmp/proxmox-metrics"
COOLDOWN=600

CPU_LIMIT=90
RAM_LIMIT=85
TEMP_LIMIT=80
DISK_LIMIT=85
LOAD_LIMIT=4

mkdir -p "$STATE_DIR"

MODE="$1"   # alert | report

# ================= FUNCIONES =================

send_telegram() {
  local KEY="$1"
  local MSG="$2"
  local FORCE="$3"
  local NOW=$(/usr/bin/date +%s)
  local STATE_FILE="$STATE_DIR/$KEY"

  if [[ "$FORCE" != "force" && -f "$STATE_FILE" ]]; then
    LAST=$(/usr/bin/cat "$STATE_FILE")
    if (( NOW - LAST < COOLDOWN )); then
      return
    fi
  fi

  echo "$NOW" > "$STATE_FILE"

  /usr/bin/curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    --data-urlencode "text=$MSG" > /dev/null
}

# ================= MÉTRICAS =================

# HOSTNAME
HOSTNAME=$(/usr/bin/hostname)

# CPU 
CPU=$(/usr/bin/top -bn1 | /usr/bin/awk -F',' '/Cpu/ {
    for(i=1;i<=NF;i++) if($i ~ /id/) {gsub(" id","",$i); gsub("%","",$i); print 100-$i}
}')
CPU_INT=${CPU%.*}
CPU_INT=${CPU_INT:-0}

# RAM
RAM=$(/usr/bin/free | /usr/bin/awk '/Mem/ {print $3/$2 * 100}')
RAM_INT=${RAM%.*}
RAM_INT=${RAM_INT:-0}

# TEMP
TEMP_RAW=$(/usr/bin/cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | /usr/bin/head -n1)
[ -n "$TEMP_RAW" ] && TEMP=$((TEMP_RAW / 1000)) || TEMP="N/A"

# LOAD
LOAD=$(/usr/bin/awk '{print $1}' /proc/loadavg)
LOAD_INT=${LOAD%.*}
LOAD_INT=${LOAD_INT:-0}

# DISK
DISK_INFO=$(/usr/bin/df -P -h | /usr/bin/awk 'NR>1 {print $6 ": " $5}')

# ================= ALERTAS =================

if [[ "$MODE" == "alert" ]]; then

  echo "DEBUG: CPU=$CPU_INT RAM=$RAM_INT TEMP=$TEMP LOAD=$LOAD_INT"

  (( CPU_INT > CPU_LIMIT )) && \
    send_telegram "cpu" "🔥 CPU ALTA
📍 Nodo: $HOSTNAME
⚡ ${CPU_INT}%" ""

  (( RAM_INT > RAM_LIMIT )) && \
    send_telegram "ram" "🧠 RAM ALTA
📍 Nodo: $HOSTNAME
💾 ${RAM_INT}%" ""

  [[ "$TEMP" != "N/A" && "$TEMP" -gt "$TEMP_LIMIT" ]] && \
    send_telegram "temp" "🌡️ TEMP CPU
📍 Nodo: $HOSTNAME
🔥 ${TEMP}°C" ""

  while read -r LINE; do
    USE=${LINE##* }
    USE_INT=${USE%%%}
    USE_INT=${USE_INT:-0}
    MOUNT=${LINE%%:*}

    (( USE_INT > DISK_LIMIT )) && \
      send_telegram "disk_$MOUNT" "💽 DISCO LLENO
📍 Nodo: $HOSTNAME
📁 $MOUNT
⚠️ ${USE_INT}%" ""
  done <<< "$DISK_INFO"

  (( LOAD_INT > LOAD_LIMIT )) && \
    send_telegram "load" "📊 LOAD ALTO
📍 Nodo: $HOSTNAME
⚠️ $LOAD" ""

fi

# ================= REPORTE =================

if [[ "$MODE" == "report" ]]; then

  MSG="📊 REPORTE PROXMOX 📈
📍 Nodo: $HOSTNAME

🧠 CPU: ${CPU_INT}%
💾 RAM: ${RAM_INT}%
🌡️ Temp: ${TEMP}°C
📊 Load: $LOAD

💽 Disco:
$DISK_INFO
"

  send_telegram "report" "$MSG" "force"
fi
