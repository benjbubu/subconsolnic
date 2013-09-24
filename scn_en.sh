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
#                                            #
# This script allows you to control a        #
# a subsonic server (search and play music)  #
#                                            #
# Don't forget to change the parameters      #
# of the script (server, user, password      #
#  and version)                              #
#                                            #
# For the version parameter  of API, go to   #
# http://www.subsonic.org/pages/api.jsp      #
#                                            #
# For more details, look at README.md        #
##############################################

#Subsonic Server Parameter
server=http://changeme
user=changeme
password=changeme
version=changeme
client=myapp

#Checking tools

#Checking wget
if [ ! -e "/usr/bin/wget" ]; then
apt-get -y install wget
fi

#Checking mplayer
if [ ! -e "/usr/bin/mplayer" ]; then
apt-get -y install mplayer
fi

#Checking Xmlstarlet
if [ ! -e "/usr/bin/xmlstarlet" ]; then
apt-get -y install xmlstarlet
fi

#Fonction getMusicDirectory par ID
function getMusicDirectory {  
wget -q "$server/rest/getMusicDirectory.view?u=$user&p=$password&v=$version&c=$client&songCount=0&id=$id" -O - | xmlstarlet sel -N n=http://subsonic.org/restapi -t -m "//n:child" -v "concat(@title,'      ' ,@artist,'      ',@id)" -n | cat -n | sed -e '$d'
}


#Fonction du menu de Listing
function infosmenus {
echo "############################"
echo "#     Available choices    #"
echo "#	                         #"
echo "# i -> Details on folder   #"
echo "# p -> Play  album         #"
echo "#any key -> start menu     #"
echo "############################"
read chapichapo

case $chapichapo in 
i)
		echo -n "Enter the ID of the folder"
        	read id
        	if [ $(echo $id | grep -v [a-Z] | wc -l) -eq 0 ]; then
        		exec $0
        	else
        		getMusicDirectory
		fi
		;;
p)
		echo -n "Enter the ID of the album"
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
wget -q "$server/rest/getMusicDirectory.view?u=$user&p=$password&v=$version&c=$client&id=$id" -O - | xmlstarlet sel -N n=http://subsonic.org/restapi -t -m "//n:child" -v "concat(@id,'  ')" -n | while read line 
do
echo -e "$line\n"
mplayer -prefer-ipv4 -nocache "$server/rest/download.view?u=$user&p=$password&v=$version&c=$client&id=$line" < /dev/null
done
}


#Checking parameter of subsonic
testserver=`wget -q "$server/rest/ping.view?u=$user&p=$password&v=$version&c=$client" -O - | grep status | awk -F" " '{print $3}' |sed -e 's/status=//g' |sed -e 's/"//g'`

if [[ $testserver == ok ]]; then
echo "Testing Server : OK"
else
echo "No answer from the server. Check your parameters at the beginning of the script"
exit 0
fi


#Start menu
echo "Welcome to Subconsolnic !"
echo "Let's play !"
echo " --------------------------"
echo "| S-U-B-C-O-N-S-O-L-N-I-C  |"
echo "|__________________________|"
echo "|                          |"
echo "|   Availables keys        |"
echo "| 1 -> Search              |"
echo "| 2 -> Explore Folders     |"
echo "| 3 -> Enter ID            |"
echo "| 4 -> Quit                |"
echo "|__________________________|"
read choice


case $choice in

1)

	echo "Search by artist/track/album"
        echo -n "Enter your query"
	read search
	echo "I'm looking for :" $search
        #Envoi de la requete via l'api
        wget -q "$server/rest/search2.view?u=$user&p=$password&v=$version&c=$client&songCount=0&query=$search&songCount=0" -O - | xmlstarlet sel -N n=http://subsonic.org/restapi -t -m "//n:album" -v "concat(@title, '     ', @album, '      ', @artist, '    ', @id)" -n | cat -n | sed -e '$d'



	echo "################################"
	echo "#  Available choices           #"
	echo "# v -> see detail of the album #"
	echo "# p -> play the album	     #"
	echo "################################"
	read choice2

	case $choice2 in
		v)  
			echo -n "Enter ID (last column) of the album"
			read id
			getMusicDirectory			
			echo -n "Play Album  ? Y/N"
			read play
			if [[ $play == Y ]]; then
			jukebox
			else
			exec $0
			fi
;;	

		p) 
			echo -n "Enter ID of the album"
			read id
			jukebox
			;;

		*) 
			echo "Wrong key, dumbass :D" 
			exec $0
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
	echo -n "Enter ID of the album"
	read id
	jukebox
	;;

4)
        echo "Good luck without sound !"
	exit 0
        ;;

*)      
	echo "Wrong key, dumbass ! :D "
        exec $0
        ;;
esac
