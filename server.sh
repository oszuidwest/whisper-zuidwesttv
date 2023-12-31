# Install needed packages
apt update
apt -qq -y install ffmpeg
apt -qq -y install apache2 libapache2-mod-php php-sqlite3 unzip build-essential

# Download Whisper
mkdir /opt/whisper
wget -O /opt/whisper/source.zip https://github.com/ggerganov/whisper.cpp/archive/refs/heads/master.zip
cd /opt/whisper/
unzip /opt/whisper/source.zip

# Build Whisper
cd /opt/whisper/whisper.cpp-master/
make
./models/download-ggml-model.sh large
./main -m models/ggml-large.bin -f samples/jfk.wav

# Clean-up webserver
rm /var/www/html/index.html
wget -O /var/www/html/index.php https://raw.githubusercontent.com/oszuidwest/whisper-zuidwesttv/main/index.php
wget -O /var/www/html/worker.sh https://raw.githubusercontent.com/oszuidwest/whisper-zuidwesttv/main/worker.sh
chown -R www-data:www-data /var/www/html
