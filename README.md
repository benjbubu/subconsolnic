subconsolnic
============

A script to use subsonic in console
Version : 1.0

The scn.sh is in French
If you want it in english, download scn_en.sh


--------------------------------------------------------

Script forké et inspiré par SubsonicPlayerCLI by ts123

Ce script permet de controler un serveur subsonic directement depuis votre console

Pour l'utiliser vous avez besoin 
* Wget
* Mplayer
* Xmlstarlet
(Disponibles dans les paquets Debian et en install dans le script si non détecté)

N'oubliez pas de changer les paramètres server/user/password/version en début de script.

Pour le paramètre version de l'API, le chiffre à indiquer dépend de votre version de subsonic. Allez sur
 http://www.subsonic.org/pages/api.jsp  pour vérifier
 
Pour utiliser le script un simple /scn.sh suffit (chmod +x scn.sh pour le rendre exécutable)

Vous avez la possibilité de modifier les paramètres de mplayer pour le streaming en fonction de votre débit.
Les paramètres actuels sont :
-prefer-ipv4 : cela permet d'éviter les tentatives superflues de connexion en ipv6 au server
-nocache : permet de lancer le stream plus vite

Si mplayer coupe à cause de la connexion, enlevez l'option -nocache et ajoutez à la place "-cache-min 2 -cache 51200"

  ---------------------------------------
 
 
 Forked from SubsonicPlayerCLI by ts123     

 Author : Benjbubu                          
 Contributor : LiZ                          
                                            
 This script allows you to search and play       
 your favorite music on a subsonic server
 
 
 To use it you need :
 * Wget
 * Mplayer
 * Xmlstarlet
 
 The script will check if the 3 programs are present and will install them.
                                            
 Don't forget to change the parameters    
 of the script (server, user, password, version)    
 
  For the version parameter  of API, the number depends of your subsonic server version. go to   
 http://www.subsonic.org/pages/api.jsp   
 
 You can change the options of mplayer for streaming. The actual parameters are : 
 -prefer-ipv4 : force mplayer to connect only in ipv4
 -nocache : stream is faster 
 
 If mplayer doesn't stream correctly, remove the -nocache option and add "-cache-min 2 -cache 51200"

 To use it just, chmod +x scn.sh and launch it ! 

                                            
  
                                         
