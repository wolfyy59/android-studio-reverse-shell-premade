#!/bin/bash
set -e

# ===========================
# CONFIG
# ===========================
ANDROID_SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
INSTALL_DIR="$HOME/Android/Sdk"
GRADLE_VERSION="8.10.2"
GRADLE_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
JDK21_URL="https://download.java.net/openjdk/jdk21/ri/openjdk-21+35_linux-x64_bin.tar.gz"
JDK_INSTALL_DIR="/usr/lib/jvm/jdk-21"

echo "[*] Updating system..."
sudo apt update && sudo apt upgrade -y

echo "[*] Installing dependencies..."
sudo apt install -y wget unzip curl zip dos2unix

# ===========================
# Install OpenJDK 21 manually
# ===========================
echo "[*] Installing OpenJDK 21..."
wget -q $JDK21_URL -O /tmp/openjdk21.tar.gz
sudo mkdir -p $JDK_INSTALL_DIR
sudo tar -xzf /tmp/openjdk21.tar.gz -C /usr/lib/jvm/
# Set JAVA_HOME
echo "export JAVA_HOME=$JDK_INSTALL_DIR" | sudo tee /etc/profile.d/jdk21.sh
echo "export PATH=\$JAVA_HOME/bin:\$PATH" | sudo tee -a /etc/profile.d/jdk21.sh
source /etc/profile.d/jdk21.sh
java -version

# ===========================
# Install Gradle
# ===========================
echo "[*] Installing Gradle $GRADLE_VERSION..."
wget -q $GRADLE_URL -O /tmp/gradle.zip
sudo mkdir -p /opt/gradle
sudo unzip -qo /tmp/gradle.zip -d /opt/gradle
export PATH=/opt/gradle/gradle-${GRADLE_VERSION}/bin:$PATH

# ===========================
# Install Android SDK
# ===========================
echo "[*] Installing Android SDK commandline tools..."
mkdir -p $INSTALL_DIR/cmdline-tools
wget -q $ANDROID_SDK_URL -O /tmp/cmdline-tools.zip
unzip -qo /tmp/cmdline-tools.zip -d $INSTALL_DIR/cmdline-tools
mv $INSTALL_DIR/cmdline-tools/cmdline-tools $INSTALL_DIR/cmdline-tools/latest

# Fix permissions & line endings
chmod -R +x $INSTALL_DIR/cmdline-tools/latest/bin
dos2unix $INSTALL_DIR/cmdline-tools/latest/bin/* || true

# ===========================
# Set environment variables
# ===========================
{
    echo "export ANDROID_HOME=$INSTALL_DIR"
    echo "export ANDROID_SDK_ROOT=$INSTALL_DIR"
    echo "export PATH=\$PATH:$INSTALL_DIR/cmdline-tools/latest/bin"
    echo "export PATH=\$PATH:$INSTALL_DIR/platform-tools"
    echo "export PATH=\$PATH:/opt/gradle/gradle-${GRADLE_VERSION}/bin"
} | tee -a ~/.bashrc

source ~/.bashrc

# ===========================
# Install SDK packages & accept licenses
# ===========================
echo "[*] Installing SDK packages..."
yes | $INSTALL_DIR/cmdline-tools/latest/bin/sdkmanager --licenses
$INSTALL_DIR/cmdline-tools/latest/bin/sdkmanager "platform-tools" "build-tools;35.0.0" "platforms;android-36"

echo "[✔] Setup complete!"
echo "Open a new terminal or run: source ~/.bashrc"
echo "You can now build Android projects with Gradle + Java 21
echo  build project now ./gradlew assembleDebug

