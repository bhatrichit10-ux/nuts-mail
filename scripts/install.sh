#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "Run as root"
  exit 1
fi
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RESET="\033[0m"


echo -e "${GREEN}███╗░░██╗██╗░░░██╗████████╗░██████╗ ${RESET}"
echo -e "${GREEN}████╗░██║██║░░░██║╚══██╔══╝██╔════╝ ${RESET}"
echo -e "${GREEN}██╔██╗██║██║░░░██║░░░██║░░░╚█████╗░ ${RESET}"
echo -e "${GREEN}██║╚████║██║░░░██║░░░██║░░░░╚═══██╗ ${RESET}"
echo -e "${GREEN}██║░╚███║╚██████╔╝░░░██║░░░██████╔╝ ${RESET}"
echo -e "${GREEN}╚═╝░░╚══╝░╚═════╝░░░░╚═╝░░░╚═════╝░ ${RESET}"
sleep 1

echo -e "${YELLOW} Installing Updates...${RESET}"
DEBIAN_FRONTEND=noninteractive apt update -y >/dev/null 2>&1
echo -e "${YELLOW} Installing Dependencies...${RESET}"
DEBIAN_FRONTEND=noninteractive apt install -y curl mailutils swaks>/dev/null 2>&1
echo -e "${GREEN}[✓] Installed postfix, mailutils, swaks${RESET}"

echo -e "${YELLOW}[*] Configuring Postfix...${RESET}"
POSTFIX_MAIN="/etc/postfix/main.cf"
cp $POSTFIX_MAIN ${POSTFIX_MAIN}.bak

postconf -e "inet_interfaces = all"
postconf -e "inet_protocols = ipv4"
postconf -e "mynetworks = 127.0.0.0/8, 10.60.0.0/16"
postconf -e "myhostname = $(hostname)"
postconf -e "mydestination = \$myhostname, localhost, localhost.localdomain"
postconf -e "relay_domains ="
postconf -e "smtpd_recipient_restrictions = permit_mynetworks, reject_unauth_destination"
postconf -e "home_mailbox = Maildir/"

echo -e "${GREEN}[✓] Postfix configured${RESET}"

echo -e "${YELLOW}[*] Setting up mailbox...${RESET}"
mkdir -p /root/Maildir
maildirmake /root/Maildir 2>/dev/null || true
echo -e "${GREEN}[✓] Maildir ready${RESET}"


echo -e "${YELLOW}[*] Restarting Postfix...${RESET}"
systemctl restart postfix
echo -e "${GREEN}[✓] Postfix restarted${RESET}"

echo -e "${YELLOW}[*] Checking SMTP (port 25)...${RESET}"
if ss -tulnp | grep -q ":25"; then
    echo -e "${GREEN}[✓] Postfix is listening on port 25${RESET}"
else
    echo -e "${RED}[!] Warning: Postfix not listening${RESET}"
fi

echo ""
echo -e "${BLUE}[*] Do you want to add a container mapping?${RESET}"
echo -e "${BLUE}[*] Try adding mine, My container IP is 10.60.0.177 ${RESET}"
echo -e "${BLUE}[*] And my names richit ${RESET}"
read -p "Enter IP of the other container (or press Enter to skip): " OTHER_IP

if [ ! -z "$OTHER_IP" ]; then
    read -p "Enter hostname (e.g. richit.local): " OTHER_HOST
    echo "$OTHER_IP $OTHER_HOST" >> /etc/hosts
    echo -e "${GREEN}[✓] Added $OTHER_HOST → $OTHER_IP${RESET}"
    echo -e "${YELLOW}[*] !!! Try pinging $OTHER_HOST !!! ${RESET}"
fi


echo -e "██████╗░░█████╗░███╗░░██╗███████╗"
echo -e "██╔══██╗██╔══██╗████╗░██║██╔════╝"
echo -e "██║░░██║██║░░██║██╔██╗██║█████╗░░"
echo -e "██║░░██║██║░░██║██║╚████║██╔══╝░░"
echo -e "██████╔╝╚█████╔╝██║░╚███║███████╗"
echo -e "╚═════╝░░╚════╝░╚═╝░░╚══╝╚══════╝"

echo -e "${GREEN}Installation complete!${RESET}"
echo -e "${YELLOW} Now, you are ready to mail other hackclubbers!!! ${RESET}"