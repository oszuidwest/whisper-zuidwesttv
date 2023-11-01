# Whisper ZuidWest TV
Quick en dirty prototype van een on demand ondertitel-service. Gebruikt Whisper.cpp als algoritme. SQLite als queue manager.

Gebruik:
- Installeer Debian 12
- Draai dingen in `server.sh`
- Pas paden in `index.php` en `worker.sh` aan
- Schiet een request via `http://78.46.178.176/?source=https://vod.zuidwesttv.nl/be2ed6d4-b3a3-45f1-9a88-698393a7ab86/play_720p.mp4&key=abc123`
- Draai worker.sh om te kijken of het werkt
