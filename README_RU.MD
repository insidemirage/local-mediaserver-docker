Вот обновлённый README.md — более живой, дружелюбный и визуально приятный:

---

# 🎬 Домашний медиа-сервер на Docker  
**Стримь, качай, делись — всё в одном флаконе!**  

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)](https://docker.com)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/insidemirage/local-mediaserver-docker/graphs/commit-activity)
[![GitHub issues](https://img.shields.io/github/issues/insidemirage/local-mediaserver-docker)](https://github.com/insidemirage/local-mediaserver-docker/issues)

> ✨ **Забудь про подписки и заморочки** — подними свой личный Netflix, фотоальбом и торрент-качалку на любом компе за 5 минут.

---

## 🚀 Одна команда — и всё готово

Скопируй и вставь это в терминал — магия начнётся:

### С curl
```bash
curl -sSL https://raw.githubusercontent.com/insidemirage/local-mediaserver-docker/main/install.sh | bash
```

### С wget
```bash
wget -qO- https://raw.githubusercontent.com/insidemirage/local-mediaserver-docker/main/install.sh | bash
```

**Что произойдёт?**  
Скрипт сам поставит Docker, Docker Compose, Git, скачает всё нужное и запустит сервер. Ты даже кофе не успеешь допить ☕.

---

## 📦 Что входит в комплект?

| Сервис | Зачем нужен | Порт |
|--------|-------------|------|
| **QBittorrent** 🧲 | Качает фильмы и музыку | 8080 |
| **Jellyfin** 🎞️ | Твой личный Netflix для домашней коллекции | 8096 |
| **Piwigo** 📸 | Фотоальбом, как у бабушки, только современный | 8082 |
| **FileBrowser** 📁 | Заходишь по браузеру и ковыряешься в файлах | 8083 |
| **MariaDB** 🐬 | База данных для фоток (тихо делает свою работу) | — |

---

## 🖥️ Как этим пользоваться?

После запуска сервер покажет тебе локальный IP (что-то типа `192.168.1.xxx`).  
Просто открой браузер на любом устройстве в сети и введи:

```
QBittorrent → http://192.168.1.xxx:8080
Jellyfin    → http://192.168.1.xxx:8096
Piwigo      → http://192.168.1.xxx:8082
FileBrowser → http://192.168.1.xxx:8083
```

**Логин везде:** `admin`  
**Пароль:** сгенерится случайный и покажется в терминале (запиши его или сфоткай на телефон, пока не закрыл терминал).

---

## 🔧 Ручной режим (для перфекционистов)

Если хочешь всё сделать своими руками:

```bash
git clone https://github.com/insidemirage/local-mediaserver-docker.git
cd local-mediaserver-docker
chmod +x start_docker.sh
./start_docker.sh
```

---

## 📁 Что упадёт в папку?

```
📂 local-mediaserver-docker/
├── 📀 films/               # Сюда складывай фильмы (Jellyfin их подхватит)
├── 📥 downloads/           # QBittorrent будет качать сюда
├── 🖼️ storage/              # Фотки для Piwigo
├── ⚙️ piwigo/               # Настройки фотоальбома
├── 🗄️ mariadb/data/         # База данных
├── 📂 filebrowser/          # Данные файлового менеджера
├── ⚙️ qbittorrent/config/   # Конфиги торрент-клиента
├── ⚙️ jellyfin/config/      # Конфиги медиа-сервера
├── 🐳 docker-compose.yml     # Описание всех контейнеров
├── 🚀 start_docker.sh        # Запускатор
└── 📦 install.sh             # Установщик (одна команда)
```

---

## 💡 Почему это круто?

✅ **Никаких ежемесячных платежей** — всё твоё и работает на твоём железе.  
✅ **Конфиденциальность** — твои фотки и просмотры не уходят в облака.  
✅ **Простота** — даже если ты впервые слышишь про Docker, скрипт сделает всё сам.  
✅ **Расширяемость** — хочешь добавить Nextcloud или Plex? Легко, докер же!  
✅ **Работает на любом старье** — Pentium, Raspberry Pi, старый ноутбук — всё подойдёт.

---

## ⚠️ Важные мелочи

- 🔒 **Закрепи IP** в роутере (DHCP-резервация), чтобы после перезагрузки адрес не поменялся.
- 🔥 **Открой порты** в файрволе (8080, 8096, 8082, 8083), если хочешь доступ из интернета (но осторожно с безопасностью).
- 👥 **Группа docker** — если Docker только что поставился, выйди из системы и зайди снова, или выполни `newgrp docker`, чтобы не писать sudo.

---

## 🛠️ Полезные команды

```bash
# Посмотреть логи всех контейнеров
docker-compose logs -f

# Остановить всё
docker-compose down

# Перезапустить
docker-compose restart

# Обновиться до последних версий
git pull
docker-compose pull
docker-compose up -d
```

---

## 🆘 Что делать, если…?

**…пишет "permission denied"**  
→ `newgrp docker` или перелогинься.

**…порты уже заняты**  
→ Отредактируй `docker-compose.yml` и поменяй левую часть (например, `8080:8080` на `8085:8080`).

**…не видно с других устройств**  
→ Проверь IP, файрвол и что устройства в одной сети.

**…установка оборвалась**  
→ Бывает, просто запусти `./start_docker.sh` ещё раз.

---

## 📸 Скриншоты (как это выглядит)

*(Тут были бы картинки, но GitHub их не любит, так что поверь на слово — красиво!)*

| Jellyfin | QBittorrent |
|----------|-------------|
| ![Jellyfin](https://jellyfin.org/images/screenshot-slide1.jpg) | ![QBittorrent](https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/Qbittorrent_v4.3.9_screenshot.png/800px-Qbittorrent_v4.3.9_screenshot.png) |

---

## 📝 Лицензия

Проект живёт под лицензией MIT — делай с ним что хочешь, даже продавай (но лучше поделись с другом).

---

## 🤗 Хочешь помочь?

Звёздочка на GitHub, пул-реквест или просто доброе слово — всё приветствуется!  
[Репозиторий на GitHub](https://github.com/insidemirage/local-mediaserver-docker)

---

**Приятного просмотра!** 🍿📽️