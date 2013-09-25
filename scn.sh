#!/bin/bash
##############################################
#                                            #
#       SubConsolNic for Subsonic            #
#                                            #
#                                            #
# Forked from SubsonicPlayerCLI by ts123     #
#                                            #
# Author : Benjbubu                          #
# Contributor : LiZ                          #
# version 2.0                                          #
# This script allows you to control a        #
# a subsonic server (search and play music)  #
#                                            #
# Don't forget to change the parameters      #
# of the script (server, user, password)     #
#                                            #
# For the version parameter  of API, go to   #
# http://www.subsonic.org/pages/api.jsp      #
##############################################


## PARAMETERS
#Subsonic Server Parameter
server=changeme (ne pas mettre http://)
user=changeme
password=changeme
version=changeme
client=subconsolnic


## CHECKING TOOLS
#Checking wget
if [ ! -e "/usr/bin/wget" ]; then
sudo apt-get -y install wget
fi

#Checking mplayer
if [ ! -e "/usr/bin/mplayer" ]; then
sudo apt-get -y install mplayer
fi

#Checking Xmlstarlet
if [ ! -e "/usr/bin/xmlstarlet" ]; then
sudo apt-get -y install xmlstarlet
fi

#Checking parameter of subsonic
testserver=`wget -q "$server/rest/ping.view?u=$user&p=$password&v=$version&c=$client" -O - | grep status | awk -F" " '{print $3}' |sed -e 's/status=//g' |sed -e 's/"//g'`
if [[ $testserver == ok ]]; then
echo "Connexion au server OK"
else
echo "Le serveur ne ping pas. Verifiez les parametres du serveur"
exit 0
fi


## FUNCTION REPO ##

#Fonction getMusicDirectory par ID
function getMusicDirectory {  
wget -q "$server/rest/getMusicDirectory.view?u=$user&p=$password&v=$version&c=$client&songCount=0&id=$id" -O - | xmlstarlet sel -N n=http://subsonic.org/restapi -t -m "//n:child" -v "concat(@title,'      ' ,@artist,'      ',@id)" -n | cat -n | sed -e '$d'
}

#Fonction du menu de Listing
function infosmenus {
echo "############################"
echo "#     Choix disponibles    #"
echo "#	                         #"
echo "# i -> infos sur dossier   #"
echo "# p -> jouer album         #"
echo "#any key -> menu principal #"
echo "############################"
read chapichapo

case $chapichapo in 
i)
		echo -n "Taper l'ID (chiffre sur la dernière colonne) pour plus d'informations sur le dossier"
        	read id
        	if [ $(echo $id | grep -v [a-Z] | wc -l) -eq 0 ]; then
        		exec $0
        	else
        		getMusicDirectory
		fi
		;;
p)
		echo -n "Taper l'ID de l'album (dernière colonne)"
		read id
		jukebox
		;;
*)
		exec $0
		;;
esac
}


#Fonction de streaming
function jukebox {
#Creation du fichier de controle mplayer en slave
#si il n'existe pas
fifo=`ls /tmp/ | grep mplayer.pipe`
if [ -z $fifo ]; then
mkfifo /tmp/mplayer.pipe
fi

#Suppression de la playlist existante
presenceplaylist=`ls /tmp/ | grep playlist`
if [ -z $presenceplaylist ]; then
echo ""
else
rm /tmp/playlist
fi


wget -q "$server/rest/getMusicDirectory.view?u=$user&p=$password&v=$version&c=$client&id=$id" -O - | xmlstarlet sel -N n=http://subsonic.org/restapi -t -m "//n:child" -v "concat(@id,'  ')" -n | while read line 
do
	#echo -e "$line\n"
	echo "http://$server/rest/download.view?u=$user&p=$password&v=$version&c=$client&id=$line" >> /tmp/playlist
done

echo "Chargement de la chanson"
	
mplayer -slave -input file=/tmp/mplayer.pipe -nocache -prefer-ipv4 -playlist /tmp/playlist < /dev/null >/dev/null 2>&1 &

#sleep permettant d'attendre le lancement de mplayer avant 
#le début des tests de présence du processus
sleep 10
#	mplayer -quiet -prefer-ipv4 -nocache "$server/rest/download.view?u=$user&p=$password&v=$version&c=$client&id=$line"
controlemplayer
}



function controlemplayer {
clear

        echo "#########################"
        echo "#   CONTROLE MPLAYER    #"
        echo "# P : Pause             #"
        echo "# N : Chanson Suivante  #"
        echo "# S : Stop player       #"
	echo "# Q : Revenir au menu   #" 
        echo "#########################"
	echo "Vous ecoutez : $nowlisten"
        read controle
        
	case $controle in 
		p|P)
			echo "pause" > /tmp/mplayer.pipe
			echo "=====PAUSE====="
			echo "Reprendre ? [O]"
			echo "==============="
		 	read resume
				if [ $resume == O -o $resume == o ]; then
				echo "pause" > /tmp/mplayer.pipe
				=====Reprise=====
				sleep 2
				controlemplayer
				else
				echo "CHANSON EN PAUSE"
				controlemplayer
				fi
			;;
		n|N)
			echo "pt_step 1" > /tmp/mplayer.pipe
			echo "Chanson suivante..."
			sleep 5
			controlemplayer
			;;
		s|S)
			echo "Arret du Player"
			echo "stop" > /tmp/mplayer.pipe
			rm /tmp/mplayer.pipe
			rm /tmp/playlist
			exec $O
			;;
		q|Q) 
			exec $O
			;;

		*)
			controlemplayer
			;;
esac

} 



        #recup des infos de la chanson en cours         
        nowlisten=`wget -q "$server/rest/getSong.view?u=$user&p=$password&v=$version&c=$client&id=$id" -O - | xmlstarlet sel -N n=http://subsonic.org/restapi -t -m "//n:song" -v "concat(@title,'       ',@artist,'       ',@album)" -n`
#Start menu
echo "Bienvenue sur Subconsolnic !"
echo "Let's play !"
echo " --------------------------"
echo "| S-U-B-C-O-N-S-O-L-N-I-C  |"
echo "|__________________________|"
echo "|                          |"
echo "|   Touches Disponibles    |"
echo "| 1 -> Recherche Albums    |"
echo "| 2 -> Parcourir dossiers  |"
echo "| 3 -> Entrer ID           |"
echo "| 4 -> Quitter             |"
echo "| 5 -> Controle Player     |"
echo "|__________________________|"
echo "============================"
echo "Vous ecoutez : $nowlisten"
echo "============================"
read choice


case $choice in

1)

	echo "Recherche d'albums par artiste/piste/albums"
        echo -n "Tapez votre recherche"
	read search
	echo "Je recherche tout de suite :" $search
        #Envoi de la requete via l'api
        wget -q "$server/rest/search2.view?u=$user&p=$password&v=$version&c=$client&songCount=0&query=$search&songCount=0" -O - | xmlstarlet sel -N n=http://subsonic.org/restapi -t -m "//n:album" -v "concat(@title, '     ', @album, '      ', @artist, '    ', @id)" -n | cat -n | sed -e '$d'



	echo "################################"
	echo "#  Choix possibles :           #"
	echo "# v -> voir contenu de l'album #"
	echo "# p -> jouer l'album	     #"
	echo "################################"
	read choice2

	case $choice2 in
		v|V)  
			echo -n "Taper l'ID (derniere colonne) de l'album"
			read id
			getMusicDirectory			
			echo -n "Jouer l'album ? O/N"
			read play
			if [[ $play == O ]]; then
			jukebox
			else
			exec $0
			fi
;;	

		p|P) 
			echo -n "Taper l'ID (dernière colonne) de l'album"
			read id
			jukebox
			;;

		*) 
			echo "Mauvaise touche,boulet" 
			exec 0
			;;
		esac
        ;;

2) 
	#Liste de tous les dossiers		
	wget -q "$server/rest/getIndexes.view?u=$user&p=$password&v=$version&c=$client" -O - | xmlstarlet sel -N n=http://subsonic.org/restapi -t -m "//n:artist" -v "concat(@name,'   ',@id)" -n
	while true
	do
	infosmenus
	done

	;; 

3)
	echo -n "Entrer l'ID (dernière colonne) de l'album voulu"
	read id
	jukebox
	;;

4)
        echo "Good luck without sound !"
	exit 0
        ;;

5) 
	controlemplayer
	;;		
*)      
	echo "Mauvaise touche boulet !"
        exec $0
        ;;
esac
