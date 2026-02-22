# 🚀 Proxmox Telegram Monitor

Lightweight monitoring script written in Bash for Proxmox nodes.
Sends real-time alerts and full system reports via Telegram Bot API.

Designed for homelab environments, small infrastructures, and DevOps-oriented monitoring setups.

![GitHub stars](https://img.shields.io/github/stars/elc4br4/proxmox-telegram-monitor?style=social)
---

## 📊 Features

* ✅ CPU usage monitoring
* ✅ RAM usage monitoring
* ✅ Disk usage per mount point
* ✅ CPU temperature check
* ✅ System load monitoring
* ✅ Alert cooldown system (prevents spam)
* ✅ Manual full system report mode
* ✅ Minimal dependencies
* ✅ Cron-ready
* ✅ Absolute binary paths (cron-safe)

---

## 🛠 Tech Stack

* Bash
* Linux system tools (`top`, `awk`, `df`, `free`)
* Telegram Bot API
* curl

---

## 📦 Project Structure

```
proxmox-telegram-monitor/
│
├── monitor.sh
├── README.md
└── LICENSE
```

---

## ⚙️ Configuration

Edit the following variables inside `monitor.sh`:

```bash
BOT_TOKEN="your-bot-token"
CHAT_ID="your-chat-id"

CPU_LIMIT=90
RAM_LIMIT=85
TEMP_LIMIT=80
DISK_LIMIT=85
LOAD_LIMIT=4
COOLDOWN=600
```

### Thresholds

| Metric   | Default |
| -------- | ------- |
| CPU      | 90%     |
| RAM      | 85%     |
| Temp     | 80°C    |
| Disk     | 85%     |
| Load     | 4       |
| Cooldown | 600s    |

---

## 🤖 Telegram Bot Setup

1. Open Telegram.
2. Create a new bot using **@BotFather**.
3. Copy the generated bot token.
4. Get your Chat ID.
5. Replace the values inside the script.

---

## ▶️ Usage

### Alert Mode (for cron)

```bash
./monitor.sh alert
```

Checks metrics and sends alerts only if thresholds are exceeded.

---

### Report Mode

```bash
./monitor.sh report
```

Sends a full system report regardless of thresholds.

---

## ⏱ Cron Configuration Example

Run alert check every 2 minutes:

```bash
*/2 * * * * /path/to/monitor.sh alert
```

Daily report at 09:00:

```bash
0 9 * * * /path/to/monitor.sh report
```
---

## 📜 License

MIT License

---

## 👨‍💻 Author

elc4br4

