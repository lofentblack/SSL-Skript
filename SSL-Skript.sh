#!/bin/bash

# Gucken ob der Benutzer root ist
if [ "$(id -u)" != "0" ]; then
  echo $(tput setaf 1)Bitte wechseln Sie zu einem Admin/Root Benutzer$(tput sgr0)
  exit 1;
fi

#Name vom Script
SCRIPTNAME="SSL"
LOCK=".lock-ssl"

#Benutzer
Benutzer1=root
Benutzer2=admin

# Fehler Codes
FEHLER1='Vermutlich wurde crontab noch nie benutzt und wurde deshalb nicht generiert versuche ein test command in "crontab -e" hinzuzufügen und versuche es erneut FehlerCode(01)'
FEHLER2="Fehler der Benutzername, mit dem sie Eingeloggt sind, ist unbekannt! FehlerCode(02)"
FEHLER3="Die Domain, die Sie Hinzufügen möchte, existiert bereits! FehlerCode(03)"
FEHLER4="Domain wurde nicht Hinzugefügt. Prüfe od die Domain ein Typ von A/AAAA hat! FehlerCode(04)"
FEHLER5="Das Zertifikat ist nicht älter als 10 Minuten! FehlerCode(05)"
FEHLER6="Der Apache2 dienst wurde wohl möglich an einem besondem ort insterliert?! FehlerCode(06)"

content=$(wget https://raw.githubusercontent.com/lofentblack/SSL-Skript/refs/heads/main/version.txt -q -O -)
Version=$content

checkUpdate() {
content=$(wget https://raw.githubusercontent.com/lofentblack/SSL-Skript/refs/heads/main/version.txt -q -O -)
version=$content

# Eingabedatei
AnzahlZeilen=$(wc -l ${LOCK} | awk ' // { print $1; } ')
for LaufZeile in $(seq 1 ${AnzahlZeilen})
 do
  Zeile=$(sed -n "${LaufZeile}p" ${LOCK})
  Test=${Zeile}
	if [[ "$Test" == *"version"* ]]; then
		if [[ "$Test" == *"version"* ]]; then
		  var1=$(sed 's/version=//' <<< "$Test")
		  var2=$(sed 's/^.//;s/.$//' <<< "$var1")
		  SkriptVersion=$var2
		fi
	fi
done

if ! [[ $version == $SkriptVersion ]]; then
	sudo apt-get install wget -y
	clear
	clear

	echo $(tput setaf 3)"Update von Version "$SkriptVersion" zu "$version"."
	echo "$(tput sgr0)"
	wget https://raw.githubusercontent.com/lofentblack/SSL-Skript/refs/heads/main/SSL-Skript.sh -O SSL-Skript.sh-new.sh
	rm $LOCK
	chmod 775 SSL-Skript-new.sh
	rm SSL-Skript.sh
	mv SSL-Skript.sh-new.sh SSL-Skript.sh.sh

fi
}

checkUpdate

lofentblackDEScript() {

rot="$(tput setaf 1)"
gruen="$(tput setaf 2)"
gelb="$(tput setaf 3)"
dunkelblau="$(tput setaf 4)"
lila="$(tput setaf 5)"
turkies="$(tput setaf 6)"

# Notwendige Packete
installations_packete() {

apt-get install sudo -y
sudo apt-get update -y
sudo apt-get install screen -y

screen=instalations_packete_lb.de_script
screen -Sdm $screen apt-get install figlet -y && screen -Sdm $screen sudo apt install certbot python-certbot-apache -y && screen -Sdm $screen sudo apt-get upgrade -y && screen -Sdm $screen sudo apt-get install certbot -y

sleep 10

echo "Notwendige Pakete Installiert"

sleep 1

clear
clear
echo $gruen"Bitte starte das Script neu!"
echo "$(tput sgr0)"
}

LOGO() {
	clear
	clear
	echo "$(tput setaf 2)"
	figlet -f slant -c $SCRIPTNAME
	echo $rot
	echo "Mit dem Ausführen Akzeptieren Sie den Datenschutz von Shop-LB.de."
	echo "$(tput sgr0)"
}

# Script Verzeichniss
	reldir=`dirname $0`
	cd $reldir
	SCRIPTPATH=`pwd`

clear
clear

  if [ -s $SCRIPTPATH/$LOCK ]; then
	echo "$(tput setaf 2)"
	figlet -f slant -c $SCRIPTNAME
	echo $rot
	echo "Mit dem Ausführen Akzeptieren Sie den Datenschutz von Shop-LB.de."
	echo "Achtung dieses Skript funktioniert nur mit dem Webdienst Apache2"
	echo "$(tput sgr0)"
	echo "1) SSL Zertifikat Hinzufügen"
	echo "2) Manuell Updaten"
	echo "3) Monatlich Updaten (immer zum 1.)"
	echo "4) Monatliches Updaten Deaktivieren"
	echo "5) Lösche SSL"
	echo "6) Beenden"
	read -p "Was möchten Sie machen? " machen
	
	if [ $machen == 1 ]; then
		read -p "Bitte gebe nun die Domain ein, die du Hinzufügen möchtest: " domain
		read -p 'Bitte gebe nun das webroot verzeiniss an (z.b. "/var/www/html/"): ' verzeichniss
		
		if ! [ -d /etc/letsencrypt/live/$domain ]; then 
					
			if ! [ -d $verzeichniss ]; then
				
				mkdir $verzeichniss
				if ! [ -s $Verzeichnis/ ]; then
					echo "Verzeichnis konnte nicht erstellt werden da es zu viele Unterordner sind."
					echo "Versuchen Sie das Verzeichnis selber zu Erstellen"
				else
					echo "Verzeichniss wurde Erstellt."
				fi
			else
				echo "Verzeiniss gefunden."	
			fi
			
			sleep 1
			
			if ! [ -d /etc/apache2/sites-available/ ]; then
				echo $FEHLER6
				exit 0;
			fi
			
			cd /etc/apache2/sites-available/
			> $domain.conf
			
echo -e '<IfModule mod_ssl.c>
	<VirtualHost *:443>

		ServerAdmin '$domain'@localhost
		DocumentRoot /var/www/html

		ErrorLog ${APACHE_LOG_DIR}/error.log
		CustomLog ${APACHE_LOG_DIR}/access.log combined

		ServerName '$domain'
		Include /etc/letsencrypt/options-ssl-apache.conf
		ServerAlias '$domain'
		SSLCertificateFile /etc/letsencrypt/live/'$domain'/fullchain.pem
		SSLCertificateKeyFile /etc/letsencrypt/live/'$domain'/privkey.pem
							
	</VirtualHost>
</IfModule>' >> $domain.conf
					
			read -p "Ist die Domain eine Subdomain J/N " wasdas
			
			if [ $wasdas = "y" ] || [ $wasdas = "Y" ] || [ $wasdas = "J" ] || [ $wasdas = "j" ] || [ $wasdas = "ja" ] || [ $wasdas = "Ja" ] || [ $wasdas = "Yes" ] || [ $wasdas = "yes" ] || [ $wasdas = "ok" ] || [ $wasdas = "Ok" ] || [ $wasdas = "OK" ] || [ $wasdas = "oK" ] || [ $wasdas = "JA" ] || [ $wasdas = "jA" ] || [ $wasdas = "YES" ] || [ $wasdas = "YEs" ] || [ $wasdas = "yES" ] || [ $wasdas = "yeS" ] || [ $wasdas = "YeS" ] || [ $wasdas = "yES" ] || [ $wasdas = "yEs" ]; then
				sudo certbot -d $domain --expand
			else
				sudo certbot --authenticator webroot --installer apache -w $verzeichniss -d $domain
			fi
			
			
			
			sleep 1
			
			sudo a2ensite $domain.conf
			systemctl reload apache2
			
			sleep 1
			
			
			if [ -d /etc/letsencrypt/live/$domain ]; then			
				LOGO
				echo $gruen
				echo "Domain wurde Erfolgreich Hinzugefügt"
				echo "$(tput sgr0)"
				
			else
				
				echo $rot
				echo "Domain wurde nicht Hinzugefügt"
				sudo a2dissite $domain.conf
				rm /etc/apache2/sites-available/$domain
				rm /etc/apache2/sites-enabled/$domain
				systemctl reload apache2
				echo $FEHLER4
				echo "$(tput sgr0)"
				exit 1;			
			fi	
		else
			echo $FEHLER3
			exit 0;
		fi		
	fi
	
	if [ $machen == 2 ]; then
		
		echo "Manuelles Updaten wird Ausgeführt"
		sleep 1
		
		sudo certbot renew --force-renewal

		cd /etc/letsencrypt/live/
		
		ls > verzeichnisinhalt.txt
		DATEI=$(head -n 1 verzeichnisinhalt.txt)
		TNOW=$(date "+%s")
		TDATEI=$(stat -c %Z $DATEI)
 		ALTER=$(($TNOW - $TDATEI))
 		rm -r verzeichnisinhalt.txt
 		
 		LOGO
 		
		if ! [ $ALTER -gt 600 ]; then 
			#weniger als 10min
			echo $gruen
			echo "SSL Zertifikat Erfolgreich Erneuert."
			echo "$(tput sgr0)"
			exit 0;
		else
			#alter als 10 min
			echo $rot
			echo "SSL Zertifikat Nicht Erneuert."
			echo "$(tput sgr0)"
			echo $FEHLER5
			exit 0;
		fi
		
		
	fi
	
	if [ $machen == 3 ]; then
		if [ -d /var/spool/cron/crontabs/ ]; then
		
			cd /var/spool/cron/crontabs/
			
			if [ -f root ]; then
				echo -e "0 0 1 * * sudo certbot renew --force-renewal" > root				
			else
				echo $FEHLER2
				exit 1;
			fi
			
			if [ -f admin ]; then
					echo -e "0 0 1 * * sudo certbot renew --force-renewal" > admin
			else
				echo $FEHLER2
				exit 1;
			fi
			
			if [ -f $Benutzer1 ]; then
				DATEI=$Benutzer1
			elif [ -f $Benutzer2 ]; then
				DATEI=$Benutzer2
			else 
				echo $FEHLER2
				exit 1;
			fi
			
			TNOW=$(date "+%s")
			TDATEI=$(stat -c %Z $DATEI)
 			ALTER=$(($TNOW - $TDATEI))
 			
 			LOGO
 			
 			if ! [ $ALTER -gt 600 ]; then 
				#weniger als 10min
				echo $gruen
				echo "Automatisches Update Aktiviert."
				echo "$(tput sgr0)"
				exit 0;
			else
				#alter als 10 min
				echo $rot
				echo "Automatisches Update nicht Aktiviert."
				echo "$(tput sgr0)"
				echo $FEHLER5
				exit 1;
			fi
			
		else
			echo $FEHLER1
		fi
	fi
	
	if [ $machen == 4 ]; then
		cd /var/spool/cron/crontabs/
		
		if [ -f $Benutzer1 ]; then
			DATEI=$Benutzer1
		elif [ -f $Benutzer2 ]; then
			DATEI=$Benutzer2
		else 
			echo $FEHLER2
			exit 1;
		fi
		
		sed '/^.*certbot.*$/d' $DATEI > ubergang.txt
		rm -r $DATEI
		mv ubergang.txt $DATEI
		chmod 600 $DATEI
		chgrp crontab $DATEI
		
		TNOW=$(date "+%s")
		TDATEI=$(stat -c %Z $DATEI)
 		ALTER=$(($TNOW - $TDATEI))
 			
 		LOGO
 			
 		if ! [ $ALTER -gt 600 ]; then 
			#weniger als 10min
			echo $gruen
			echo "Automatisches Update Deaktiviert."
			echo "$(tput sgr0)"
			exit 0;
		else
			#alter als 10 min
			echo $rot
			echo "Automatisches Update wurde nicht Deaktiviert."
			echo "$(tput sgr0)"
			echo $FEHLER5
			exit 1;
		fi
	fi
	
	if [ $machen == 5 ]; then
		read -p "Welche Domain möchten sie löschen? " del
		sudo a2dissite $del.conf
		sudo certbot delete --cert-name $del
		systemctl reload apache2
		echo "$(tput sgr0)"
		echo "Erfolgreich Entfernt"
		sleep 3
	fi
	
	if [ $machen == 6 ]; then
		echo $turkies
		echo "Einen schönen Tag Noch!"
		echo "$(tput sgr0)"
		exit 0;
	fi
	
	if [ -z $machen ] || [[ $machen =~ ^[a-z,A-Z]+$ ]]; then
		exit 0;
	fi



	elif ! [ -s $SCRIPTPATH/$LOCK ]; then
    > $LOCK
    echo -e 'int=true\nversion="'$Version'"\n\n#Mit dieser Datei erkennt das Skript das alle notwendigen Pakete installiert worden sind.' > $SCRIPTPATH/$LOCK
    installations_packete
fi

}
lofentblackDEScript
