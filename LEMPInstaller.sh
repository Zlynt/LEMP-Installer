# This script Will Install LAMP (Linux,Nginx,MySQL,PHP)

#Cores para o Texto
vermelho=`tput setaf 1`
verde=`tput setaf 2`
cyan=`tput setaf 6`
azul=`tput setaf 4`
branco=`tput setaf 7`
reset=`tput sgr0`
fundoBranco=`tput setab 7`
fundoVerde=`tput setab 2`
#Fim das cores para o Texto
#Inicio das Funcoes
reloadNginx(){
	if nginx -t >/dev/null
	then
		service nginx reload >/dev/null
		echo "${cyan}Nginx reloaded!${reset}"
	else
		echo "${vermelho}Setup was not finished${reset}"
		exit
	fi
}
#Fim das Funcoes
echo "${fundoVerde}                                               ${reset}"
echo "${fundoVerde}   ${azul}${fundoBranco}          LAMP Installer V0.0.1          ${fundoVerde}   ${reset}"
echo "${fundoVerde}                                               ${reset}"
echo "${fundoVerde}   ${reset}${cyan} Description: ${branco}Installs LAMP Web Server   ${fundoVerde}   ${reset}"
echo "${fundoVerde}   ${reset}${cyan} Author:      ${branco}ZenJB                      ${fundoVerde}   ${reset}"
echo "${fundoVerde}                                               ${reset}"
echo "${reset}"
if [ "$EUID" -ne 0 ]
then
	echo "${vermelho}[ERROR] ${branco}Please run this script as root"
	echo "${reset}"
	exit
else
	echo "${cyan}Script is running under root user.${reset}"
	echo "${cyan}Cleaning packages list...${reset}"
	apt-get clean
	echo "${cyan}Updating packages list...${reset}"
	if apt-get update >/dev/null
	then
		echo "${cyan}Upgrading all packages...${reset}"
		if apt-get --yes dist-upgrade >/dev/null
		then
			echo "${cyan}Installing Whiptail..."
			apt-get --yes install whiptail
			echo "${cyan}Launching interface...${reset}"
		#Interface
		whiptail --backtitle 'LEMP Installer' --title 'Welcome' --msgbox 'This script will install Nginx,MySQL and PHP on Linux' 10 40
		if (whiptail --backtitle 'LEMP Installer' --title 'Setup' --yesno 'Proceed with the installation?' 10 40)
		then
			echo "${cyan}Installing Nginx...${reset}"
			if apt-get --yes install nginx
			then
				echo "${cyan}Installed!"
			else
				echo  "${vermelho}Cannot install Nginx!"
				exit
			fi
			echo "${cyan}Installing MySQL...${reset}"
			if apt-get --yes install mysql-server
                        then
                                echo "${cyan}Installed!"
                        else
                                echo  "${vermelho}Cannot install MySQL Server!"
                                exit
                        fi
			echo "${cyan}Installing PHP...${reset}"
                        if apt-get --yes install php-fpm php-mysql
                        then
                                echo "${cyan}Installed!"
                        else
                                echo  "${vermelho}Cannot install PHP!"
                                exit
                        fi
			whiptail --backtitle 'LEMP Installer' --title 'Setup' --msgbox 'All packages have been installed. Now we will setup LEMP' 10 40
			whiptail --backtitle 'LEMP Installer' --title 'Nginx' --msgbox 'Lets Setup Nginx!' 10 40
			whiptail --backtitle 'LEMP Installer' --title 'Nginx' --msgbox 'Now set server_tokens off;' 10 40
			nano /etc/nginx/nginx.conf
			reloadNginx
			whiptail --backtitle 'LEMP Installer' --title 'Nginx' --msgbox 'Now set error_page 401 403 404 /404.html; (Must be inside seerver{})' 10 40
			nano /etc/nginx/sites-enabled/default
			reloadNginx
			whiptail --backtitle 'LEMP Installer' --title 'PHP' --msgbox 'Lets Setup PHP!' 10 40
			whiptail --backtitle 'LEMP Installer' --title 'PHP' --msgbox 'Set cgi.fix_pathinfo=0' 10 40
			nano /etc/php/7.0/fpm/php.ini
			whiptail --backtitle 'LEMP Installer' --title 'PHP' --msgbox 'Now add index.php between index and index.html' 10 40
			nano /etc/nginx/sites-available/default
			whiptail --backtitle 'LEMP Installer' --title 'PHP' --msgbox 'Now add location ~ \.php$ {include snippets/fastcgi-php.conf;fastcgi_pass unix:/run/php/php7.0-fpm.sock;}' 10 40
			nano /etc/nginx/sites-available/default
			whiptail --backtitle 'LEMP Installer' --title 'PHP' --msgbox 'Now add location ~ /\.ht {deny all;}' 10 40
			nano /etc/nginx/sites-available/default
			whiptail --backtitle 'LEMP Installer' --title 'Nginx and PHP' --msgbox 'Reloading Nginx and PHP' 10 40
			if nginx -t >/dev/null
                        then
                                service nginx reload >/dev/null
                                echo "${cyan}Nginx reloaded!${reset}"
				systemctl restart php7.0-fpm
				echo "${cyan}PHP Restarted!${reset}"
                        else
                                echo "${vermelho}Setup was not finished${reset}"
                                exit
                        fi
			whiptail --backtitle 'LEMP Installer' --title 'MySQL Server' --msgbox 'Setup a password for root user and answer y to all other questions.' 10 40
			mysql_secure_installation
			whiptail --backtitle 'LEMP Installer' --title 'LEMP' --msgbox 'Installation has finished!' 10 40
			whiptail --backtitle 'LEMP Installer' --title 'Credits' --msgbox 'Script made by ZenJB' 10 40
		else
			echo "${vermelho}Setup was not finished${reset}"
			exit
		fi
		else
			echo "${vermelho}[ERROR] Unable to update packages"
´			exit
		fi
	else
		echo "${vermelho}[ERROR] Unable to update package list"
		exit
	fi
	echo "${reset}"
	exit
fi
