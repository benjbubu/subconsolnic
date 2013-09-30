#!/bin/bash
##############################################
#                                            #
#       SubConsolNic for Subsonic            #
#                                            #
#                                            #
# Forked from SubsonicPlayerCLI by ts123     #
#                                            #
# Version : 2.3                              #
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
#lang: fr, en
lang=fr

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
#Interface Utilisateur
case $lang in
fr|FR)
UI_startMenu="\
Bienvenue sur Subconsolnic !\n\
Let's play !\n\
----------------------------\n\
| S-U-B-C-O-N-S-O-L-N-I-C  |\n\
|__________________________|\n\
|                          |\n\
|   Touches Disponibles    |\n\
| 1 -> Recherche Albums    |\n\
| 2 -> Parcourir dossiers  |\n\
| 3 -> Entrer ID           |\n\
| 4 -> controler mplayer   |\n\
| 5 -> Quitter             |\n\
|__________________________|"

UI_searchMenu="\
################################\n\
#  Choix possibles :           #\n\
# v -> voir contenu de l'album #\n\
# p -> jouer l'album	       #\n\
# q -> retour menu principal   #\n\
################################"

UI_infosmenu="\
############################\n\
#     Choix disponibles    #\n\
#	                   #\n\
# i -> infos sur dossier   #\n\
# p -> jouer album         #\n\
# q -> menu principal      #\n\
############################"

UI_controlemplayermenu="\
#########################\n\
#   CONTROLE MPLAYER    #\n\
# P : Pause             #\n\
# N : Chanson Suivante  #\n\
# B : Chanson precedente#\n\
#                       #\n\
# E : Avancer morceau   #\n\
# R : Reculer morceau   #\n\
#                       #\n\
# S : Stop player       #\n\
# Q : Revenir au menu   #\n\
#########################"

# controlemplayer function
UI_nowListening="Vous ecoutez actuellement :"
UI_pause="\
=====PAUSE=====\n\
Reprendre ? [O]"
UI_unpause="=====Reprise===="
UI_nextSong="Chanson suivante..."
UI_prevSong="Chanson precedente..."
UI_fastForward="Avance Rapide"
UI_fastBackward="Retour arriere"
UI_stopPlayer="Arret du Player"
UI_purgingPlayerPipe="Suppression du controleur mplayer.pipe"
UI_purginPlaylist="Suppression de la playlist"
UI_purgingLogs="Suppression des logs"

# Jukebox function
UI_jukeboxLoading="Chargement du lecteur..."
UI_songLoading="Chargement de la chanson"
UI_3dot="..."

# serach function
UI_searchtitle="Recherche d'albums par artiste/piste/albums"
UI_searchInput="Tapez votre recherche"
UI_searching="Je recherche tout de suite :"

# infosmenu function
UI_fileInput="Taper l'ID (chiffre sur la dernière colonne) pour plus d'informations sur le dossier"

# startmenu function
UI_quit="Good luck without sound !"

# global 
UI_albumIDinput="Taper l'ID de l'album (dernière colonne)"
UI_wrongKey="Saisie erronée, veuillez recommencer"

;;
en|EN)
UI_startMenu="\
Welcome to Subconsolnic !\n\
Let's play !\n\
----------------------------\n\
| S-U-B-C-O-N-S-O-L-N-I-C  |\n\
|__________________________|\n\
|                          |\n\
|   Available keys         |\n\
| 1 -> Search Albums       |\n\
| 2 -> Explore Folders     |\n\
| 3 -> Enter ID            |\n\
| 4 -> Mplayer Controls    |\n\
| 5 -> Quit                |\n\
|__________________________|"

UI_searchMenu="\
################################\n\
#  Available choices :         #\n\
# v -> Details about album     #\n\
# p -> Play the album	       #\n\
# q -> Main menu               #\n\
################################"

UI_infosmenu="\
############################\n\
#     Available choices    #\n\
#	                   #\n\
# i -> Infos about folder  #\n\
# p -> Play the album      #\n\
# q -> Main menu           #\n\
############################"

UI_controlemplayermenu="\
#########################\n\
#    MPLAYER CONTROL    #\n\
# P : Pause             #\n\
# N : Next Song         #\n\
# B : Previous Song     #\n\
#                       #\n\
# E : Seeking Forward   #\n\
# R : Seeking Backward  #\n\
#                       #\n\
# S : Stop player       #\n\
# Q : Main menu         #\n\
#########################"

# controlemplayer function
UI_nowListening="Currently Listening :"
UI_pause="\
=====PAUSE=====\n\
Resume ? [O]"
UI_unpause="=====Reprise===="
UI_nextSong="Next Song..."
UI_prevSong="Previous Song..."
UI_fastForward="Seeking forward"
UI_fastBackward="Seeking backward"
UI_stopPlayer="Stopping Player"
UI_purgingPlayerPipe="Removing mplayer.pipe"
UI_purginPlaylist="Removing playlist"
UI_purgingLogs="Removing logs"

# Jukebox function
UI_jukeboxLoading="Loading player..."
UI_songLoading="CLoading Song"
UI_3dot="..."

# serach function
UI_searchtitle="Search albums by artist/song/albums"
UI_searchInput="Enter your keywords"
UI_searching="I'm looking for :"

# infosmenu function
UI_fileInput="Enter the ID (number in the last column) for more details"

# startmenu function
UI_quit="Good luck without sound !"

# global 
UI_albumIDinput="Enter the ID (number in the last column)"
UI_wrongKey="Wrong key !"

;;
*)
	echo "wrong lang parameter"
	echo "paramètre lang erroné"
	exit 2
	;;
esac

#Fonction Recherche
function recherche {
    boucleRecherche=true
    while $boucleRecherche
    do
	echo -e $UI_searchtitle
        echo -n -e $UI_searchInput
	read search
	echo -e $UI_searching $search
        #Envoi de la requete via l'api
        wget -q "$server/rest/search2.view?u=$user&p=$password&v=$version&c=$client&songCount=0&query=$search&songCount=0" -O - | xmlstarlet sel -N n=http://subsonic.org/restapi -t -m "//n:album" -v "concat(@title, '     ', @album, '      ', @artist, '    ', @id)" -n | cat -n | sed -e '$d'

	echo -e $UI_searchMenu
	read -n 1 choice2

	case $choice2 in
		v|V)   # voir le contenu de l'album
			echo -n -e $UI_albumIDinput
			read id
			getMusicDirectory			
			# on reste dans la boucle recherche
			;;	

		p|P)    # jouer l'album
			echo -n -e $UI_albumIDinput
			read id
			jukebox
			# une fois la lecture/jukebox finie, on revient au menuPrincipal
			boucleRecherche=false
			;;
			
		q|Q)    # retour au menu principal = quitter recherche
			boucleRecherche=false
			;;

		*) 	# saisie erronée
			echo -e $UI_wrongKey
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
	echo -e $UI_infosmenu
	read -n 1 chapichapo
	
	case $chapichapo in 
	i|I)	# infos sur le dossier
		echo -n $UI_fileInput
        	read id
        	if [ $(echo $id | grep -v [a-Z] | wc -l) -eq 0 ]; then
        		echo -e $UI_wrongKey
        	else
        		getMusicDirectory
		fi
		;;
	p|P)	# jouer l'album
		echo -n -e $UI_albumIDinput
		read id
		jukebox
		# une fois la lecture/jukebox finie, retour au menuPrincipal
		boucleInfosmenus=false
		;;
	q|Q)	# retour menuPrincipal = quitter boucle infosMenus
		boucleInfosmenus=false
		;;
			
	*)	echo -e $UI_wrongKey
		;;
	esac
    done
}


#Fonction de streaming
function jukebox {
	#Creation du fichier de controle mplayer en slave
	#si il n'existe pas

	echo -e $UI_jukeboxLoading
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
	
	echo -e $UI_songLoading
		
	nohup mplayer -slave -input file=/tmp/mplayer.pipe -nocache -prefer-ipv4 -playlist /tmp/playlist > /tmp/scnlog 2>/dev/null &
	
	echo -e $UI_3dot
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
	echo -e $UI_nowListening
	echo ""
	cat /tmp/lolog
	echo ""
	echo ""
        echo -e $UI_controlemplayermenu
        read -t 1 -n 1 controle
        
	case $controle in 
		p|P)	# PAUSE
			echo "pause" > /tmp/mplayer.pipe
			echo -e $UI_pause
			read -p "==============="
		 	
			echo -e $UI_unpause
			echo "pause" > /tmp/mplayer.pipe
			sleep 1
			;;
			
		n|N)	# chanson suivante
			echo "pt_step 1" > /tmp/mplayer.pipe
			echo -e $UI_nextSong
			sleep 5
			;;

		b|B)	# chanson précédente
			echo "pt_step -1" > /tmp/mplayer.pipe
			echo -e $UI_prevSong
			sleep 5
			;;
		
		e|E)	# avance rapide
			echo -e $UI_fastForward
			echo "seek +20" > /tmp/mplayer.pipe
			;;
			
		r|R)	# retour rapide
			echo -e $UI_fastBackward
			echo "seek -20" > /tmp/mplayer.pipe
			;;
			
		s|S)	# stop et retour menuprincipal
			echo -e $UI_stopPlayer
			echo "stop" > /tmp/mplayer.pipe
			echo -e $UI_purgingPlayerPipe
			rm /tmp/mplayer.pipe
			echo -e $UI_purginPlaylist
			rm /tmp/playlist
			echo -e $UI_purgingLogs
			rm /tmp/scnlog
			rm /tmp/lolog
			# on quitte et on revient au menu principal
			boucleControlemplayer=false
			;;
		q|Q)	
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
	echo -e $UI_startMenu
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
		echo -n -e $UI_albumIDinput
		read id
		jukebox
		;;
		
	4)	# on relance le controlemplayer
		controlemplayer
		;;
	
	5)	# QUITTER
	        echo -e $UI_quit
		echo "stop" > /tmp/mplayer.pipe
		rm /tmp/playlist /tmp/scnlog /tmp/lolog /tmp/mplayer.pipe 2>/dev/null
		exit 0
	        ;;
	
	*)      # mauvaise saisie
		echo -e $UI_wrongKey
	        ;;
esac
}


## MAIN LOOP
while true
do
	startmenu
done


