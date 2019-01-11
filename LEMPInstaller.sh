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
	echo "${cyan}Cleaning package list.${reset}"
	if ! apt-get clean >/dev/null
	then
		echo "${vermelho}[ERROR] ${branco}Cannot clean correctly!${reset}"
		exit 1
	fi
	echo "${cyan}Updating package list.${reset}"
	if ! apt-get update >/dev/null
	then
		echo "${vermelho}[ERROR] ${branco}Cannot update correctly!${reset}"
		exit 1
	fi
	echo "${cyan}Upgrading all packages...${reset}"
	if ! apt-get --yes dist-upgrade >/dev/null
	then
		echo "${vermelho}[ERROR] ${branco}Cannot Upgrade correctly!${reset}"
		exit 1
	fi
	echo "${cyan}Installing Whiptail package.${reset}"
	if apt-get --yes install whiptail > /dev/null
	then
		echo "${cyan}Done!${reset}"
	else
		echo "${vermelho}Cannot install WhipTail!${reset}"
		exit
	fi	
	echo "${cyan}Launching interface...${reset}"
	echo "${cyan}Everything is ready!${reset}"
	whiptail --backtitle 'LEMP Installer' --title 'Welcome' --msgbox 'This script will install Nginx,MySQL and PHP on Linux' 10 40
	if ! (whiptail --backtitle 'LEMP Installer' --title 'Setup' --yesno 'Do you want to install LEMP?' 10 40)
	then
		echo "${vermelho}LEMP was not installed!${reset}"
		exit
	fi

	echo "${cyan}Installing required packaged..."		
	echo "${cyan}Installing Nginx package...${reset}"
	if apt-get --yes install nginx >/dev/null
	then
		echo "${cyan}Done!${reset}"
	else
		echo  "${vermelho}Cannot install Nginx!${reset}"
		exit
	fi
	echo "${cyan}Installing MySQL package...${reset}"
	if apt-get --yes install mysql-server >/dev/null
        then
               	echo "${cyan}Done!${reset}"
        else
               	echo  "${vermelho}Cannot install MySQL Server!${reset}"
            	exit
 	fi
	echo "${cyan}Installing PHP package...${reset}"
        if apt-get --yes install php-fpm php-mysql >/dev/null
        then
               	echo "${cyan}Done!${reset}"
        else
               	echo  "${vermelho}Cannot install PHP!${reset}"
               	exit
        fi

	#Set Server Tokens Off
	echo "${cyan}Setting Server Tokens Off on Nginx...${reset}"
	if ! replace "# server_tokens off;" "server_tokens off;" -- /etc/nginx/nginx.conf
	then
		echo "${vermelho}[ERROR] Cannot setup server tokens!${reset}"
		exit
	fi
	echo "${cyan}Done!${reset}"
	#Reload Nginx
	echo "${cyan}Reloading Nginx...${reset}"
	if ! nginx -t > /dev/null
	then
		echo "${vermelho}[ERROR] There is an syntax error on nginx.conf!${reset}"
		exit
	fi
	reloadNginx > /dev/null
	echo "${cyan}Setting up error page...${reset}"
	replace "error_page 401 403 404 /404.html;" "" -- /etc/nginx/sites-enabled/default
	replace "root /var/www/html;" "root /var/www/html; error_page 401 403 404 /404.html;" -- /etc/nginx/sites-enabled/default
	echo "${cyan}Done!${reset}"

	PHPINI=$(php --ini | grep /php.ini | grep -oP "/etc/.*")
	PHPVERSION=$(php --ini | grep /php.ini | grep -oP "/etc/.*" | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
	
	replace ";cgi.fix_pathinfo=1" "cgi.fix_pathinfo=0" -- $PHPINI
	echo "PHP Configurated!"
	replace "index index.html index.htm index.nginx-debian.html;" "index index.php index.html index.htm;" -- /etc/nginx/sites-available/default

	FASTCGI="#       fastcgi_pass unix:/var/run/php/php"
	FASTCGI="$FASTCGI$PHPVERSION"
	FASTCGIEND="-fpm.sock;"
	FASTCGI="$FASTCGI$FASTCGIEND"
	CLOSECHAR="}"
	NEWFASTCGI=$(echo $FASTCGI | cut -d "#" -f 2)
	
	echo ""
	echo ""
	echo "${fundoVerde}=== Replace This ===${reset}"
	echo "#location ~ \.php$ {"
	echo "#       include snippets/fastcgi-php.conf;"
        echo "#"
        echo "#       # With php-fpm (or other unix sockets):"
	echo "$FASTCGI"
        echo "#       # With php-cgi (or other tcp sockets):"
        echo "#       fastcgi_pass 127.0.0.1:9000;"
        echo "#}"
	echo "${fundoVerde}====================${reset}"
	echo ""
	echo "${fundoVerde}===   With This  ===${reset}"
	echo "location ~ \.php$ {"
	echo "       include snippets/fastcgi-php.conf;"
        echo "#"
        echo "#       # With php-fpm (or other unix sockets):"
	echo "$NEWFASTCGI"
        echo "#       # With php-cgi (or other tcp sockets):"
        echo "#       fastcgi_pass 127.0.0.1:9000;"
        echo "}"
	echo "${fundoVerde}====================${reset}"
	read -p "${azul}Press [ENTER] to open text editor.${reset}"
	nano /etc/nginx/sites-available/default

	echo ""
	echo ""
	echo "${fundoVerde}=== Replace This ===${reset}"
	echo "#location ~ /\.ht {"
        echo "#       deny all;"
        echo "#}"
	echo "${fundoVerde}====================${reset}"
	echo ""
	echo "===   With This  ==="
	echo "location ~ /\.ht {"
        echo "       deny all;"
        echo "}"
	echo "${fundoVerde}====================${reset}"
	read -p "${azul}Press [ENTER] to open text editor.${reset}"
	nano /etc/nginx/sites-available/default

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
	
	echo 'Creating index page and error page...'
	rm /var/www/html/index.nginx-debian.html
	rm /var/www/html/index.html
	rm /var/www/html/404.html
	echo "<html><head><title>LEMP</title></head><body><h1>Welcome to LEMP</h1></body></html>" >> /var/www/html/index.html
	echo "<html><head><title>LEMP</title></head><body><h1>Page not found</h1></body></html>" >> /var/www/html/404.html

	ufwoff="Status: inactive"
	ufw=$(ufw status)
	if [ "$ufwoff" == "$ufw" ];
	then
		if (whiptail --backtitle 'LEMP Installer' --title 'Setup' --yesno 'Your firewall is offline. Do you want to enable it?' 10 40)
		then
			ufw enable
		fi
	fi
	echo 'Adding firewall rules...'
	ufw allow http

	whiptail --backtitle 'LEMP Installer' --title 'LEMP' --msgbox 'You have finished installing and setting up LEMP!' 10 40
	echo "Thank you for using this script"
fi
