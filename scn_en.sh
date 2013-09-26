#!/bin/bash
##############################################
#                                            #
#       SubConsolNic for Subsonic            #
#                                            #
#                                            #
# Forked from SubsonicPlayerCLI by ts123     #
#                                            #
#Version : 2.1                               #
#                                            #
# Author : Benjbubu                          #
# Contributor : LiZ                          #
#                                            #
# This script allows you to control a        #
# a subsonic server (search and play music)  #
#                                            #
# Don't forget to change the parameters      #
# of the script (server, user, password,     #
# version)                                   #
#                                            #
# For the version parameter  of API, go to   #
# http://www.subsonic.org/pages/api.jsp      #
##############################################


## PARAMETERS
#Subsonic Server Parameter
server=changeme #(don't put http://)
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
echo "Checking connection..OK"
else
echo "No answer from the server. Check the parameters"
exit 0
fi

## FUNCTION REPO ##
#Fonction Search
function recherche {
echo "Search your album"
        echo -n "Enter your keyword"
	read search
	echo "Im' looking for" $search
        #Sending api request
        wget -q "$server/rest/search2.view?u=$user&p=$password&v=$version&c=$client&songCount=0&query=$search&songCount=0" -O - | xmlstarlet sel -N n=http://subsonic.org/restapi -t -m "//n:album" -v "concat(@title, '     ', @album, '      ', @artist, '    ', @id)" -n | cat -n | sed -e '$d'



	echo "################################"
	echo "#  Available choices:          #"
	echo "# v -> see detail of album     #"
	echo "# p -> play the album	     #"
	echo "# other key  -> retour         #"
	echo "# q -> main menu               #"
	echo "################################"
	read choice2

	case $choice2 in
		v|V)  
			echo -n "Enter ID of the album (number in last column)"
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
			echo -n "Enter ID of the album (number in last column)"
			read id
			jukebox
			;;

		q|Q)
			startmenu
			;;
		*) 
			recherche
			;;
		esac
        
}

#Fonction getMusicDirectory par ID
function getMusicDirectory {  
wget -q "$server/rest/getMusicDirectory.view?u=$user&p=$password&v=$version&c=$client&songCount=0&id=$id" -O - | xmlstarlet sel -N n=http://subsonic.org/restapi -t -m "//n:child" -v "concat(@title,'      ' ,@artist,'      ',@id)" -n | cat -n | sed -e '$d'
}

#Fonction du menu de Listing
function infosmenus {
echo "############################"
echo "#     Available choices    #"
echo "#	                         #"
echo "# i -> detail about folder #"
echo "# p -> play album          #"
echo "#any key -> main menu      #"
echo "############################"
read chapichapo

case $chapichapo in 
i)
		echo -n "Enter ID of the album (number in last column)"
        	read id
        	if [ $(echo $id | grep -v [a-Z] | wc -l) -eq 0 ]; then
        		exec $0
        	else
        		getMusicDirectory
		fi
		;;
p)
		echo -n "Enter ID of the album (number in last column)"
		read id
		jukebox
		;;
*)
		exec $0
		;;
esac
}


#Streaming function
function jukebox {
#Checking if a mplayer's file of slave mode is present
echo "Loading Player"
fifo=`ls /tmp/ | grep mplayer.pipe`
if [ -z $fifo ]; then
mkfifo /tmp/mplayer.pipe
fi

#Remove any old exisiting playlist
presenceplaylist=`ls /tmp/ | grep playlist`
if [ -z $presenceplaylist ]; then
echo ""
else
rm /tmp/playlist
fi

#Checking presence of mplayer
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

echo "Loading Song"
	
nohup mplayer -slave -input file=/tmp/mplayer.pipe -nocache -prefer-ipv4 -playlist /tmp/playlist > /tmp/scnlog 2>/dev/null &

echo "..."
#sleep for waiting mplayer launch before the test of processus presence
sleep 5
controlemplayer
}


#Function to control Mplayer
function controlemplayer {

while true; do

recuperationid=`cat /tmp/scnlog | grep subconsolnic | awk END{print} | awk -F"id=" '{print $2}' | sed -e 's/\.//g'`

wget -q "$server/rest/getSong.view?u=$user&p=$password&v=$version&c=$client&id=$recuperationid" -O - | xmlstarlet sel -N n=http://subsonic.org/restapi -t -m "//n:song" -v "concat('Titre : ', @title)" -n -o " " -n -v "concat('Artiste : ', @artist)" -n -o " " -n -v "concat('Album : ',@album)" > /tmp/lolog

clear
echo " Currently Listening :"
echo ""
cat /tmp/lolog
echo ""
echo ""
        echo "#########################"
        echo "#   MPLAYER CONTROL     #"
        echo "# P : Pause             #"
        echo "# N : Next song         #"
        echo "# B : Previous song     #"
	echo "#                       #"
	echo "# E : Seek Forward      #"
	echo "# R : Seek Backward     #"
	echo "#                       #"
	echo "# S : Stop player       #"
	echo "# Q : Main menu         #" 
        echo "#########################"
        read -t 1 -n 1 controle && break
 done       
	case $controle in 
		p|P)
			echo "pause" > /tmp/mplayer.pipe
			echo "=====PAUSE====="
			echo "Resume ? [Y]"
			read -p "==============="
		 	
			echo "=====Resuming===="
			echo "pause" > /tmp/mplayer.pipe
			sleep 1
			controlemplayer
			;;
		n|N)
			echo "pt_step 1" > /tmp/mplayer.pipe
			echo "Next song..."
			sleep 5
			controlemplayer
			;;

		b|B)
			echo "pt_step -1" > /tmp/mplayer.pipe
			echo "Previous song..."
			sleep 5
			controlemplayer
			;;
		
		e|E)
			echo "Seeking forward"
			echo "seek +20" > /tmp/mplayer.pipe
			controlemplayer
			;;
		r|R)
			echo "Seeking backward"
			echo "seek -20" > /tmp/mplayer.pipe
			controlemplayer
			;;
		s|S)
			echo "Stoping Player"
			echo "stop" > /tmp/mplayer.pipe
			echo "Remove control file mplayer.pipe"
			rm /tmp/mplayer.pipe
			echo "Remove playlist"
			rm /tmp/playlist
			echo "Remove logs"
			rm /tmp/scnlog
			rm /tmp/lolog
			startmenu
			;;
		q|Q) 
			startmenu
			;;

		*)
			controlemplayer
			;;
esac

} 




function startmenu {
#Start menu
echo "Welcome in Subconsolnic"
echo "Let's play !"
echo " --------------------------"
echo "| S-U-B-C-O-N-S-O-L-N-I-C  |"
echo "|__________________________|"
echo "|                          |"
echo "|    Available choices     |"
echo "| 1 -> Search Albums       |"
echo "| 2 -> Explore folders     |"
echo "| 3 -> Enter ID            |"
echo "| 4 -> Quit                |"
echo "| 5 -> Control Player      |"
echo "|__________________________|"
read choice


case $choice in

1)
	recherche	
	;;
2) 
	#Listing folders 		
	wget -q "$server/rest/getIndexes.view?u=$user&p=$password&v=$version&c=$client" -O - | xmlstarlet sel -N n=http://subsonic.org/restapi -t -m "//n:artist" -v "concat(@name,'   ',@id)" -n
	while true
	do
	infosmenus
	done

	;; 

3)
	echo -n "Enter ID of the album (number in last column)"
	read id
	jukebox
	;;

4)
        echo "Good luck without sound !"
	echo "stop" > /tmp/mplayer.pipe
	rm /tmp/playlist /tmp/scnlog /tmp/lolog /tmp/mplayer.pipe 2>/dev/null
	exit 0
        ;;

5) 
	controlemplayer
	;;		
*)      
        startmenu
        ;;
esac
}
startmenu
