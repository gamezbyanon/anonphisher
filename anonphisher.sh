#!/bin/bash

# ============================================================
#   Anonphisher - Social Engineering Toolkit Launcher
#   c0d3d By @non G00nz
# ============================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ============================================================
# BANNER
# ============================================================
banner() {
    clear
    echo -e "${RED}"
    echo "  █████╗ ███╗   ██╗ ██████╗ ███╗   ██╗██████╗ ██╗  ██╗██╗███████╗██╗  ██╗███████╗██████╗ "
    echo " ██╔══██╗████╗  ██║██╔═══██╗████╗  ██║██╔══██╗██║  ██║██║██╔════╝██║  ██║██╔════╝██╔══██╗"
    echo " ███████║██╔██╗ ██║██║   ██║██╔██╗ ██║██████╔╝███████║██║███████╗███████║█████╗  ██████╔╝"
    echo " ██╔══██║██║╚██╗██║██║   ██║██║╚██╗██║██╔═══╝ ██╔══██║██║╚════██║██╔══██║██╔══╝  ██╔══██╗"
    echo " ██║  ██║██║ ╚████║╚██████╔╝██║ ╚████║██║     ██║  ██║██║███████║██║  ██║███████╗██║  ██║"
    echo " ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${PURPLE}                  ╔══════════════════════════════════╗${NC}"
    echo -e "${PURPLE}                  ║      c0d3d By @non G00nz         ║${NC}"
    echo -e "${PURPLE}                  ╚══════════════════════════════════╝${NC}"
    echo -e "${YELLOW}         [!] For authorized penetration testing use only [!]${NC}"
    echo ""
}

# ============================================================
# ROOT CHECK
# ============================================================
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[!] This script must be run as root (sudo ./anonphisher.sh)${NC}"
        exit 1
    fi
}

# ============================================================
# DEPENDENCY CHECK
# ============================================================
check_dep() {
    command -v "$1" &>/dev/null
}

# ============================================================
# INSTALL FUNCTIONS
# ============================================================

install_set() {
    echo -e "${CYAN}[*] Installing Social Engineer Toolkit (SET)...${NC}"
    apt-get update -y
    apt-get install -y python3 python3-pip git
    if [[ -d "/opt/social-engineer-toolkit" ]]; then
        echo -e "${YELLOW}[!] SET directory already exists. Pulling latest update...${NC}"
        cd /opt/social-engineer-toolkit && git pull
    else
        git clone https://github.com/trustedsec/social-engineer-toolkit /opt/social-engineer-toolkit
    fi
    cd /opt/social-engineer-toolkit
    pip3 install -r requirements.txt
    python3 setup.py install
    echo -e "${GREEN}[+] SET installed successfully.${NC}"
}

install_gophish() {
    echo -e "${CYAN}[*] Installing Gophish...${NC}"
    apt-get install -y wget unzip

    GOPHISH_VERSION="0.12.1"
    ARCH=$(uname -m)

    if [[ "$ARCH" == "x86_64" ]]; then
        GOPHISH_URL="https://github.com/gophish/gophish/releases/download/v${GOPHISH_VERSION}/gophish-v${GOPHISH_VERSION}-linux-64bit.zip"
    else
        GOPHISH_URL="https://github.com/gophish/gophish/releases/download/v${GOPHISH_VERSION}/gophish-v${GOPHISH_VERSION}-linux-32bit.zip"
    fi

    mkdir -p /opt/gophish
    wget -O /opt/gophish/gophish.zip "$GOPHISH_URL"
    unzip -o /opt/gophish/gophish.zip -d /opt/gophish/
    chmod +x /opt/gophish/gophish
    rm /opt/gophish/gophish.zip
    echo -e "${GREEN}[+] Gophish installed to /opt/gophish/${NC}"
}

install_evilginx() {
    echo -e "${CYAN}[*] Installing Evilginx2...${NC}"
    apt-get install -y golang git make

    if [[ -d "/opt/evilginx2" ]]; then
        echo -e "${YELLOW}[!] Evilginx2 directory exists. Pulling latest update...${NC}"
        cd /opt/evilginx2 && git pull
    else
        git clone https://github.com/kgretzky/evilginx2 /opt/evilginx2
    fi

    cd /opt/evilginx2
    make
    echo -e "${GREEN}[+] Evilginx2 built and installed at /opt/evilginx2/evilginx${NC}"
}

install_burpsuite() {
    echo -e "${CYAN}[*] Installing Burp Suite Community Edition...${NC}"
    apt-get install -y wget curl

    BURP_URL="https://portswigger.net/burp/releases/download?product=community&type=Linux"
    wget -O /tmp/burpsuite_installer.sh "$BURP_URL"
    chmod +x /tmp/burpsuite_installer.sh
    /tmp/burpsuite_installer.sh
    echo -e "${GREEN}[+] Burp Suite installer launched. Follow on-screen prompts.${NC}"
}

# ============================================================
# LAUNCH FUNCTIONS
# ============================================================

launch_set() {
    if [[ -f "/opt/social-engineer-toolkit/setoolkit" ]]; then
        echo -e "${GREEN}[+] Launching SET...${NC}"
        sleep 1
        cd /opt/social-engineer-toolkit && python3 setoolkit
    elif check_dep setoolkit; then
        setoolkit
    else
        echo -e "${RED}[!] SET not found.${NC}"
        read -rp "    Install SET now? [y/n]: " choice
        [[ "$choice" == "y" || "$choice" == "Y" ]] && install_set && launch_set
    fi
}

launch_gophish() {
    if [[ -f "/opt/gophish/gophish" ]]; then
        echo -e "${GREEN}[+] Launching Gophish...${NC}"
        echo -e "${YELLOW}[i] Admin panel will be available at https://127.0.0.1:3333${NC}"
        echo -e "${YELLOW}[i] Default credentials: admin / gophish${NC}"
        sleep 2
        cd /opt/gophish && ./gophish
    else
        echo -e "${RED}[!] Gophish not found.${NC}"
        read -rp "    Install Gophish now? [y/n]: " choice
        [[ "$choice" == "y" || "$choice" == "Y" ]] && install_gophish && launch_gophish
    fi
}

launch_evilginx() {
    if [[ -f "/opt/evilginx2/evilginx" ]]; then
        echo -e "${GREEN}[+] Launching Evilginx2...${NC}"
        sleep 1
        /opt/evilginx2/evilginx
    elif check_dep evilginx2; then
        evilginx2
    else
        echo -e "${RED}[!] Evilginx2 not found.${NC}"
        read -rp "    Install Evilginx2 now? [y/n]: " choice
        [[ "$choice" == "y" || "$choice" == "Y" ]] && install_evilginx && launch_evilginx
    fi
}

launch_burpsuite() {
    if check_dep burpsuite; then
        echo -e "${GREEN}[+] Launching Burp Suite...${NC}"
        sleep 1
        burpsuite &
    elif [[ -f "/usr/local/bin/burpsuite" ]]; then
        /usr/local/bin/burpsuite &
    else
        echo -e "${RED}[!] Burp Suite not found.${NC}"
        read -rp "    Install Burp Suite now? [y/n]: " choice
        [[ "$choice" == "y" || "$choice" == "Y" ]] && install_burpsuite
    fi
}

# ============================================================
# INSTALL ALL
# ============================================================

install_all() {
    echo -e "${CYAN}[*] Installing all tools...${NC}"
    install_set
    install_gophish
    install_evilginx
    install_burpsuite
    echo -e "${GREEN}[+] All tools installed.${NC}"
    sleep 2
}

# ============================================================
# STATUS CHECK
# ============================================================

check_status() {
    echo -e "${CYAN}[*] Checking tool status...${NC}"
    echo ""

    # SET
    if [[ -f "/opt/social-engineer-toolkit/setoolkit" ]] || check_dep setoolkit; then
        echo -e "  SET          : ${GREEN}[INSTALLED]${NC}"
    else
        echo -e "  SET          : ${RED}[NOT FOUND]${NC}"
    fi

    # Gophish
    if [[ -f "/opt/gophish/gophish" ]]; then
        echo -e "  Gophish      : ${GREEN}[INSTALLED]${NC}"
    else
        echo -e "  Gophish      : ${RED}[NOT FOUND]${NC}"
    fi

    # Evilginx2
    if [[ -f "/opt/evilginx2/evilginx" ]] || check_dep evilginx2; then
        echo -e "  Evilginx2    : ${GREEN}[INSTALLED]${NC}"
    else
        echo -e "  Evilginx2    : ${RED}[NOT FOUND]${NC}"
    fi

    # Burp Suite
    if check_dep burpsuite || [[ -f "/usr/local/bin/burpsuite" ]]; then
        echo -e "  Burp Suite   : ${GREEN}[INSTALLED]${NC}"
    else
        echo -e "  Burp Suite   : ${RED}[NOT FOUND]${NC}"
    fi

    echo ""
    read -rp "Press [Enter] to return to menu..." _
}

# ============================================================
# DOWNLOAD MENU
# ============================================================

download_menu() {
    while true; do
        banner
        echo -e "${WHITE}  ╔══════════════════════════════════╗${NC}"
        echo -e "${WHITE}  ║        DOWNLOAD / INSTALL        ║${NC}"
        echo -e "${WHITE}  ╚══════════════════════════════════╝${NC}"
        echo ""
        echo -e "  ${CYAN}[1]${NC} Install SET (Social Engineer Toolkit)"
        echo -e "  ${CYAN}[2]${NC} Install Gophish"
        echo -e "  ${CYAN}[3]${NC} Install Evilginx2"
        echo -e "  ${CYAN}[4]${NC} Install Burp Suite Community"
        echo -e "  ${CYAN}[5]${NC} Install ALL Tools"
        echo -e "  ${CYAN}[6]${NC} Check Tool Status"
        echo -e "  ${RED}[0]${NC} Back to Main Menu"
        echo ""
        read -rp "  Select option: " opt
        case $opt in
            1) install_set ;;
            2) install_gophish ;;
            3) install_evilginx ;;
            4) install_burpsuite ;;
            5) install_all ;;
            6) check_status ;;
            0) break ;;
            *) echo -e "${RED}[!] Invalid option.${NC}" ; sleep 1 ;;
        esac
    done
}

# ============================================================
# MAIN MENU
# ============================================================

main_menu() {
    while true; do
        banner
        echo -e "${WHITE}  ╔══════════════════════════════════╗${NC}"
        echo -e "${WHITE}  ║           MAIN  MENU             ║${NC}"
        echo -e "${WHITE}  ╚══════════════════════════════════╝${NC}"
        echo ""
        echo -e "  ${CYAN}[1]${NC} Launch SET  (Social Engineer Toolkit)"
        echo -e "  ${CYAN}[2]${NC} Launch Gophish"
        echo -e "  ${CYAN}[3]${NC} Launch Evilginx2"
        echo -e "  ${CYAN}[4]${NC} Launch Burp Suite"
        echo -e "  ${CYAN}[5]${NC} Download / Install Tools"
        echo -e "  ${CYAN}[6]${NC} Check Tool Status"
        echo -e "  ${RED}[0]${NC} Exit"
        echo ""
        read -rp "  Select option: " opt
        case $opt in
            1) launch_set ;;
            2) launch_gophish ;;
            3) launch_evilginx ;;
            4) launch_burpsuite ;;
            5) download_menu ;;
            6) check_status ;;
            0)
                echo -e "${RED}[!] Exiting Anonphisher. Stay ethical.${NC}"
                exit 0
                ;;
            *) echo -e "${RED}[!] Invalid option.${NC}" ; sleep 1 ;;
        esac
    done
}

# ============================================================
# ENTRY POINT
# ============================================================
check_root
main_menu

