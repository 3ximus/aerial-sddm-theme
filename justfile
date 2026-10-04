set shell := ["bash", "-cu"]

# Theme install and release paths
THEME_NAME := "aerial-sddm-theme"
INSTALL_DIR := "/usr/share/sddm/themes/"
TARGET_DIR := INSTALL_DIR + THEME_NAME
PACKAGE_DIR := "build/" + THEME_NAME
ARCHIVE := "build/" + THEME_NAME + ".tar.gz"

# Check required runtime files
check:
    test -f metadata.desktop
    test -f Main.qml
    test -f theme.conf
    test -f components/LoginOverlayFader.qml
    test -f components/PasswordBox.qml
    test -f components/resources/background.jpg

# Run SDDM's greeter preview
test: check
    QML_XHR_ALLOW_FILE_READ=1 ${SDDM_GREETER:-sddm-greeter-qt6} --test-mode --theme .

# Install only files used by the greeter; leave local files and existing contents alone
install: check
    sudo install -d "{{TARGET_DIR}}"
    sudo install -m 644 Main.qml metadata.desktop theme.conf "{{TARGET_DIR}}/"
    sudo cp -a components "{{TARGET_DIR}}/"

# Create a clean release archive without local test configuration or repository metadata
package: check
    rm -rf "{{PACKAGE_DIR}}"
    mkdir -p "{{PACKAGE_DIR}}"
    cp -a Main.qml metadata.desktop theme.conf README.md LICENSE components "{{PACKAGE_DIR}}/"
    tar -czf "{{ARCHIVE}}" -C build "{{THEME_NAME}}"

# Remove the installed theme
uninstall:
    sudo rm -rf "{{TARGET_DIR}}"

# Show available commands
default:
    just --list
