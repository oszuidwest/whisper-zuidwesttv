# Install needed packages
apt update
apt -qq -y install ffmpeg
apt -qq -y install apache2 libapache2-mod-php php-sqlite3 unzip build-essential

# Download Whisper
mkdir /opt/whisper
wget -O /opt/whisper/source.zip https://github.com/ggerganov/whisper.cpp/archive/refs/tags/v1.4.0.zip
cd /opt/whisper/
unzip /opt/whisper/source.zip

# Build Whisper
cd /opt/whisper/whisper.cpp-1.4.0/
make
./models/download-ggml-model.sh large
./main -m models/ggml-large.bin -f samples/jfk.wav
