#!/bin/bash
##############################################
#                                            #
#       SubConsolNic for Subsonic            #
#                                            #
#                                            #
# Forked from SubsonicPlayerCLI by ts123     #
#                                            #
# Version : 2.2                              #
#                                            #
# Author : Benjbubu                          #
# Contributor : LiZ                          #
#                                            #
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
server=changeme #ne pas mettre les http
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
#Fonction Recherche
function recherche {
    boucleRecherche=true
    while $boucleRecherche
    do
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
	#echo "# autre touche -> retour       #"
	echo "# q -> retour menu principal   #"
	echo "################################"
	read -n 1 choice2

	case $choice2 in
		v|V)   # voir le contenu de l'album
			echo -n "Taper l'ID (derniere colonne) de l'album"
			read id
			getMusicDirectory			
			# on reste dans la boucle recherche
			;;	

		p|P)    # jouer l'album
			echo -n "Taper l'ID (dernière colonne) de l'album"
			read id
			jukebox
			# une fois la lecture/jukebox finie, on revient au menuPrincipal
			boucleRecherche=false
			;;
			
		q|Q)    # retour au menu principal = quitter recherche
			boucleRecherche=false
			;;

		*) 	# saisie erronée
			echo "Saisie erronée, veuillez recommencer"
			# on reste dans la boucle recherche
			;;
	esac

    done
   
}

#Fonction getMusicDirectory par ID
function getMusicDirectory {  
	wget -q "$server/rest/getMusicDirectory.view?u=$user&p=$password&v=$version&c=$client&songCount=0&id=$id" -O - | xmlstarlet sel -N n=http://subsonic.org/restapi -t -m "//n:child" -v "concat(@title,'      ' ,@artist,'      ',@id)" -n | cat -n | sed -e '$d'
}

#Fonction du menu de Listing
function infosmenus {
    boucleInfosmenus=true
    while $boucleInfosmenus
    do
	echo "############################"
	echo "#     Choix disponibles    #"
	echo "#	                         #"
	echo "# i -> infos sur dossier   #"
	echo "# p -> jouer album         #"
	echo "# q -> menu principal      #"
	echo "############################"
	read -n 1 chapichapo
	
	case $chapichapo in 
	i)	# infos sur le dossier
		echo -n "Taper l'ID (chiffre sur la dernière colonne) pour plus d'informations sur le dossier"
        	read id
        	if [ $(echo $id | grep -v [a-Z] | wc -l) -eq 0 ]; then
        		echo "Saisie erronée, veuillez recommencer"
        	else
        		getMusicDirectory
		fi
		;;
	p)	# jouer l'album
		echo -n "Taper l'ID de l'album (dernière colonne)"
		read id
		jukebox
		# une fois la lecture/jukebox finie, retour au menuPrincipal
		boucleInfosmenus=false
		;;
	q|Q)	# retour menuPrincipal = quitter boucle infosMenus
		boucleInfosmenus=false
		;;
			
	*)	echo "Saisie erronée, veuillez recommencer"
		;;
	esac
    done
}


#Fonction de streaming
function jukebox {
	#Creation du fichier de controle mplayer en slave
	#si il n'existe pas

	echo "Chargement du lecteur..."
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
	
	#Verification de la présence de Mplayer et continuite de la playlist
	pidmplayer=`ps aux | grep /tmp/mplayer.pipe | grep -v grep | awk '{print $2}'`
	if [ -z $pidmplayer ]; then
	echo ""
	else
	kill -15 $pidmplayer
	fi
	

	wget -q "$server/rest/getMusicDirectory.view?u=$user&p=$password&v=$version&c=$client&id=$id" -O - | xmlstarlet sel -N n=http://subsonic.org/restapi -t -m "//n:child" -v "concat(@id,'  ')" -n | while read line 
	do
		#echo -e "$line\n"
		echo "http://$server/rest/download.view?u=$user&p=$password&v=$version&c=$client&id=$line" >> /tmp/playlist
	done
	
	echo "Chargement de la chanson"
		
	nohup mplayer -slave -input file=/tmp/mplayer.pipe -nocache -prefer-ipv4 -playlist /tmp/playlist > /tmp/scnlog 2>/dev/null &
	
	echo "..."
	#sleep permettant d'attendre le lancement de mplayer avant 
	#le début des tests de présence du processus
	sleep 5
	controlemplayer
}



function controlemplayer {
    boucleControlemplayer=true
    while $boucleControlemplayer
    do
	
	recuperationid=`cat /tmp/scnlog | grep subconsolnic | awk END{print} | awk -F"id=" '{print $2}' | sed -e 's/\.//g'`
	
	wget -q "$server/rest/getSong.view?u=$user&p=$password&v=$version&c=$client&id=$recuperationid" -O - | xmlstarlet sel -N n=http://subsonic.org/restapi -t -m "//n:song" -v "concat('Titre : ', @title)" -n -o " " -n -v "concat('Artiste : ', @artist)" -n -o " " -n -v "concat('Album : ',@album)" > /tmp/lolog
	
	clear
	echo " Vous ecoutez actuellement :"
	echo ""
	cat /tmp/lolog
	echo ""
	echo ""
        echo "#########################"
        echo "#   CONTROLE MPLAYER    #"
        echo "# P : Pause             #"
        echo "# N : Chanson Suivante  #"
        echo "# B : Chanson precedente#"
	echo "#                       #"
	echo "# E : Avancer morceau   #"
	echo "# R : Reculer morceau   #"
	echo "#                       #"
	echo "# S : Stop player       #"
	echo "# Q : Revenir au menu   #"
        echo "#########################"
        read -t 1 -n 1 controle
        
	case $controle in 
		p|P)	# PAUSE
			echo "pause" > /tmp/mplayer.pipe
			echo "=====PAUSE====="
			echo "Reprendre ? [O]"
			read -p "==============="
		 	
			echo "=====Reprise===="
			echo "pause" > /tmp/mplayer.pipe
			sleep 1
			;;
			
		n|N)	# chanson suivante
			echo "pt_step 1" > /tmp/mplayer.pipe
			echo "Chanson suivante..."
			sleep 5
			;;

		b|B)	# chanson précédente
			echo "pt_step -1" > /tmp/mplayer.pipe
			echo "Chanson precedente..."
			sleep 5
			;;
		
		e|E)	# avance rapide
			echo "Avance Rapide"
			echo "seek +20" > /tmp/mplayer.pipe
			;;
			
		r|R)	# retour rapide
			echo "Retour arriere"
			echo "seek -20" > /tmp/mplayer.pipe
			;;
			
		s|S)	# stop et retour menuprincipal
			echo "Arret du Player"
			echo "stop" > /tmp/mplayer.pipe
			echo "Suppression du controleur mplayer.pipe"
			rm /tmp/mplayer.pipe
			echo "Suppression de la playlist"
			rm /tmp/playlist
			echo "Suppression des logs"
			rm /tmp/scnlog
			rm /tmp/lolog
			# on quitte et on revient au menu principal
			boucleControlemplayer=false
			;;
		q|Q	
			# on quitte et on revient au menu principal
			boucleControlemplayer=false
			;;

		*)	# Soit la saisie est erronée, soit le read est parti en timeout : on n'a rien écrit
			;;
	esac
    done
} 




function startmenu {
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
	echo "| 4 -> controler mplayer   |"
	echo "| 5 -> Quitter             |"
	echo "|__________________________|"
	read -n 1 choice
	
	
	case $choice in
	
	1)	# rechercher un album, artiste...
		recherche	
		;;
		
	2) 	#Liste de tous les dossiers		
		wget -q "$server/rest/getIndexes.view?u=$user&p=$password&v=$version&c=$client" -O - | xmlstarlet sel -N n=http://subsonic.org/restapi -t -m "//n:artist" -v "concat(@name,'   ',@id)" -n
		infosmenus
		;; 
	
	3)	# jouer un ID connu
		echo -n "Entrer l'ID (dernière colonne) de l'album voulu"
		read id
		jukebox
		;;
		
	4)	# on relance le controlemplayer
		controlemplayer
	
	5)	# QUITTER
	        echo "Good luck without sound !"
		echo "stop" > /tmp/mplayer.pipe
		rm /tmp/playlist /tmp/scnlog /tmp/lolog /tmp/mplayer.pipe 2>/dev/null
		exit 0
	        ;;
	
	*)      # mauvaise saisie
		echo "Saisie erronée, veuillez recommencer"
	        ;;
esac
}


## MAIN LOOP
while true
do
	startmenu
done


