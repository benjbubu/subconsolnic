subconsolnic
============

A script to use subsonic in console

Version : 2.3

To choose the langage of the script change the lang variable at the beginning.

--------------------------------------------------------

Script forké et inspiré par SubsonicPlayerCLI by ts123

Ce script permet de controler un serveur subsonic directement depuis votre console
en utilisant l'ID unique qui identifie les fichiers et dossiers de subsonic

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

Vous ne devez pas toucher les autres options ! (playlist, slave, input)

Si mplayer coupe à cause de la connexion, enlevez l'option -nocache et ajoutez à la place "-cache-min 2 -cache 51200"


Attention le script lit directement le contenu d'un dossier. Si vous indiquez un dossier qui contient des sous-dossiers
à lire, le script ne fonctionnera pas. 

Exemple : 
 
     Dossier 1--
              |->Fichier 1
              |->Fichier 2
              
     --> Avec l'id du dossier 1, le script va lire le contenu de celui-ci
               
      Dossier 1--
                |-> Dossier 2 --
                               |->Fichier 1
                               |->Fichier 2
                
                |-> Dossier 3 --
                               |->Fichier 3
                               |->Fichier 4
     --> Vous devez indiquer l'ID du sous-dossier 2 ou 3 pour lire leurs fichiers et non l'ID du dossier 1

  ---------------------------------------
 
 
 Forked from SubsonicPlayerCLI by ts123     

 Author : Benjbubu                          
 Contributor : LiZ                          
                                            
 This script allows you to search and play       
 your favorite music on a subsonic server
 by using the unique ID of each file and folder
 of subsonic
 
 
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

Don't remove the other options ! (playlist, slave, input)
 
 If mplayer doesn't stream correctly, remove the -nocache option and add "-cache-min 2 -cache 51200"

 To use it just, chmod +x scn.sh and launch it ! 

 Warning : The script reads directly the folder that you want. But if you ask to play a folder with
 sub-folders, it doesn't work ! 
 
 Example : 
 
     Folder 1--
              |->File 1
              |->File 2
              
     --> With the ID of the Folder 1, the script will play the files inside this folder
               
       Folder 1--
                |-> Folder 2 --
                              |->File 1
                              |->File 2
                
                |-> Folder 3 --
                              |->File 3
                              |->File 4
     --> You need to take the ID of the sub-folder 2 or 3 to play the files and not the main folder 1
  
                                         
