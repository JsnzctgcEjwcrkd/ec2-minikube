#! /bin/bash -e
date

SCRIPT_DIR=$(cd $(dirname $0); pwd)

## update ubuntu
sudo sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
sudo sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
sudo apt update
sudo apt upgrade -y

## allow root login & set ssh alive interval
new_sshd_config="$SCRIPT_DIR/sshd_config"
current_sshd_config="/etc/ssh/sshd_config"
backup_sshd_config="$current_sshd_config.backup"
sudo cp "$current_sshd_config" "$backup_sshd_config"
sudo cp "$new_sshd_config" "$current_sshd_config"
sudo cp -f /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys
sudo service sshd reload

## minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm -rf minikube-linux-amd64

## kubectl
curl -LO "https://dl.k8s.io/release/$(curl -LS https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

## docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm -f get-docker.sh

## ubuntu desktop
sudo sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf
sudo apt-get install -y ubuntu-desktop

## xrdp
sudo apt-get install -y xrdp
sudo systemctl enable xrdp
cat <<EOF | sudo tee /etc/polkit-1/localauthority/50-local.d/xrdp-color-manager.pkla  
[Netowrkmanager]  
Identity=unix-user:*  
Action=org.freedesktop.color-manager.create-device  
ResultAny=no  
ResultInactive=no  
ResultActive=yes  
EOF

echo ---------------------------------------------------
echo Run the command below to complete the installation.
echo ## add rdp user
echo sudo adduser [username]
echo sudo gpasswd -a [username] sudo
echo ## add USER docker group
echo sudo gpasswd -a [username] docker
echo sudo reboot

echo ## minikube start
echo minikube start
echo minikube addons enable ingress
echo ---------------------------------------------------
echo done.
date
