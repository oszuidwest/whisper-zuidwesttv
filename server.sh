# Install needed packages
apt update
apt -qq -y install ffmpeg
apt -qq -y install apache2 libapache2-mod-php php-sqlite3

mkdir /opt/whisper
wget -O /opt/whisper/source.zip https://github.com/ggerganov/whisper.cpp/archive/refs/tags/v1.4.0.zip
unzip source.zip
