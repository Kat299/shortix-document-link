#/bin/sh
# Terminal color variables:
NC='\033[0m'  
CY='\033[1;96m'
RE='\033[1;91m'  
YL='\033[1;93m'

PROTONTRICKS_NATIVE="protontricks"
PROTONTRICKS_FLAT="flatpak run com.github.Matoking.protontricks"
PROTONTRICKS_FLATID="com.github.Matoking.protontricks"

if [ "$(command -v kdialog)" ]; then
	USEKDIALOG=true
else
	USEKDIALOG=false
fi

#Check if and how protontricks is installed, if yes run, if no, stop the script
if [ "$(command -v $PROTONTRICKS_NATIVE)" ]; then
	echo "Protontricks is installed natively"
elif [ "$(flatpak info "$PROTONTRICKS_FLATID" >/dev/null 2>&1 && echo "true")" ]; then
	echo "Protontricks is installed as Flatpak"
else
	if [ $USEKDIALOG == true ]; then
		kdialog --title "Shortix Document Link installer" --error "Protontricks not found! Please install Protontricks either as Flatpak or native by using pacman or yay."
		exit
	else
		echo -e "${RE}Protontricks could not be found! Please install it. Aborting...${NC}"
		read -n 1 -s -r -p "Press any key to continue"
		exit
	fi

fi

if [ -d $HOME/Documents/ShortixDocLink ] || [ -f $HOME/.config/systemd/user/shortix_doclink.service ]; then
  TYPE="updater"
  if [ $USEKDIALOG == true ]; then
  	kdialog --title "Shortix Document Link $TYPE" --msgbox "Welcome to Shortix Document Link! This setup will update Shortix Document Link."
  else
  	echo -e "${CY}Welcome to Shortix Document Link-$TYPE. This setup will update Shortix Document Link.${NC}"
  	sleep 1
  fi
  rm -rf $HOME/Documents/ShortixDocLink
else
  TYPE="installer"
  if [ $USEKDIALOG == true ]; then
  	kdialog --title "Shortix Document Link installer" --msgbox "Welcome to Shortix Document Link! This setup will install Shortix Document Link."
  else
  	echo "${CY}Welcome to Shortix Document Link-$TYPE. This setup will install Shortix Document Link.${NC}"
  	sleep 1
  fi
fi

mkdir -p $HOME/Documents/ShortixDocLink
cp /tmp/shortix/shortix_doc_link.sh $HOME/Documents/ShortixDocLink
cp /tmp/shortix/remove_prefix.sh $HOME/Documents/ShortixDocLink
p /tmp/shortix/shortix_doc_link_uninstall.sh $HOME/Documents/ShortixDocLink
chmod +x $HOME/Documents/ShortixDocLink/shortix_doc_link.sh
chmod +x $HOME/Documents/ShortixDocLink/remove_prefix.sh
chmod +x $HOME/Documents/ShortixDocLink/shortix_doc_link_uninstall.sh


if [ $USEKDIALOG == true ]; then
	kdialog --title "Shortix  Document Link $TYPE" --yesno "Would you like to add the prefix id to the shortcut name?\nLike this:\nGame Name (123455678)" 2> /dev/null
	case $? in
	0)  if [ ! -f $HOME/Documents/ShortixDocLink/.id ]; then
	      touch $HOME/Documents/ShortixDocLink/.id
	    fi
	    ;;
	1)  if [ -f $HOME/Documents/ShortixDocLink/.id ]; then
	      rm -rf $HOME/Documents/ShortixDocLink/.id
	    fi
	    ;;
	esac
else
	read -p "Would you like to add the prefix id to the shortcut name? ike this: Game Name (123455678) " yn
	case $yn in
	yY)  if [ ! -f $HOME/Documents/ShortixDocLink/.id ]; then
	      touch $HOME/Documents/ShortixDocLink/.id
	    fi
	    ;;
	nN)  if [ -f $HOME/Documents/ShortixDocLink/.id ]; then
	      rm -rf $HOME/Documents/ShortixDocLink/.id
	    fi
	    ;;
	esac
fi

if [ $USEKDIALOG == true ]; then
	if [ -f $HOME/Documents/ShortixDocLink/.id ]; then
	  kdialog --title "Shortix  Document Link $TYPE" --yesno "Would you also like to add the size of the target directory to the shortcut name?\nLike this: \nGame Name (123455678) - 1.6G" 2> /dev/null
	  case $? in
	  0)  if [ ! -f $HOME/Documents/ShortixDocLink/.size ]; then
		touch $HOME/Documents/ShortixDocLink/.size
	      fi
	      ;;
	  1)  if [ -f $HOME/Documents/ShortixDocLink/.size ]; then
		rm -rf $HOME/Documents/ShortixDocLink/.size
	      fi
	      ;;
	  esac
	else
	  kdialog --title "Shortix  Document Link $TYPE" --yesno "Would you like to add the size of the target directory to the shortcut name?\nLike this:\nGame Name - 1.6G?"
	  case $? in
	  0)  if [ ! -f $HOME/Documents/ShortixDocLink/.size ]; then
		touch $HOME/Documents/ShortixDocLink/.size
	      fi
	      ;;
	  1)  if [ -f $HOME/Documents/ShortixDocLink/.size ]; then
		rm -rf $HOME/Documents/ShortixDocLink/.size
	      fi
	      ;;
	  esac
	fi
else
	if [ -f $HOME/Documents/ShortixDocLink/.id ]; then
	  read -p "Would you also like to add the size of the target directory to the shortcut name? Like this: Game Name (123455678) - 1.6G " yn 
	  case $yn in
	  yY)  if [ ! -f $HOME/Documents/ShortixDocLink/.size ]; then
		touch $HOME/Documents/ShortixDocLink/.size
	      fi
	      ;;
	  nN)  if [ -f $HOME/Documents/ShortixDocLink/.size ]; then
		rm -rf $HOME/Documents/ShortixDocLink/.size
	      fi
	      ;;
	  esac
	else
	  read -p "Would you like to add the size of the target directory to the shortcut name?\nLike this:\nGame Name - 1.6G? " yn
	  case $yn in
	  yY)  if [ ! -f $HOME/Documents/ShortixDocLink/.size ]; then
		touch $HOME/Documents/ShortixDocLink/.size
	      fi
	      ;;
	  nN)  if [ -f $HOME/Documents/ShortixDocLink/.size ]; then
		rm -rf $HOME/Documents/ShortixDocLink/.size
	      fi
	      ;;
	  esac
	fi
fi

if [ $USEKDIALOG == true ]; then
	kdialog --title "Shortix  Document Link $TYPE" --yesno "Would you like to setup system service for background updates?"
	case $? in
	0)  if [ ! -d $HOME/.config/systemd/user ]; then
	    mkdir -p $HOME/.config/systemd/user
	    fi
	    cp /tmp/shortix/shortix_doc_link.service $HOME/.config/systemd/user
	    systemctl --user daemon-reload
	    if ! systemctl is-enabled --quiet --user shortix_doc_link.service; then
	      systemctl --user enable shortix_doc_link.service
	    fi
	    systemctl --user restart shortix_doc_link.service
	    ;;
	1)  if systemctl is-enabled --quiet --user shortix_doc_link.service; then
	      systemctl --user disable shortix_doc_link.service
	    fi
	    if [ -f $HOME/.config/systemd/user/shortix_doc_link.service ]; then
	      rm $HOME/.config/systemd/user/shortix_doc_link.service
	    fi
	      systemctl --user daemon-reload
	    ;;
	esac
else
	read -p "Would you like to setup system service for background updates? " yn
	case $yn in
	yY)  if [ ! -d $HOME/.config/systemd/user ]; then
	    mkdir -p $HOME/.config/systemd/user
	    fi
	    cp /tmp/shortix/shortix_doc_link.service $HOME/.config/systemd/user
	    systemctl --user daemon-reload
	    if ! systemctl is-enabled --quiet --user shortix_doc_link.service; then
	      systemctl --user enable shortix_doc_link.service
	    fi
	    systemctl --user restart shortix_doc_link.service
	    ;;
	nN)  if systemctl is-enabled --quiet --user shortix_doc_link.service; then
	      systemctl --user disable shortix_doc_link.service
	    fi
	    if [ -f $HOME/.config/systemd/user/shortix_doc_link.service ]; then
	      rm $HOME/.config/systemd/user/shortix_doc_link.service
	    fi
	      systemctl --user daemon-reload
	    ;;
	esac
fi

if [ $USEKDIALOG == true ]; then
	kdialog --title "Shortix Document Link Backup" --yesno "Would you like to create a backup of Shortix Document Link on a different location?\nIf yes, please select the location where the Shortix-Backup directory should be created."
	case $? in
	  0)  if [ ! -f $HOME/Documents/ShortixDocLink/.backup ]; then
		touch $HOME/Documents/ShortixDocLink/.backup
	      fi
	      ;;
	  1)  if [ -f $HOME/Documents/ShortixDocLink/.backup ]; then
		rm -rf $HOME/Documents/ShortixDocLink/.backup
	      fi
	      ;;
	esac
else
	read -p "Would you like to create a backup of Shortix Document Link on a different location?" yn
	case $yn in
	  yY)  if [ ! -f $HOME/Documents/ShortixDocLink/.backup ]; then
		touch $HOME/Documents/ShortixDocLink/.backup
	      fi
	      ;;
	  nN)  if [ -f $HOME/Documents/ShortixDocLink/.backup ]; then
		rm -rf $HOME/Documents/ShortixDocLink/.backup
	      fi
	      ;;
	esac
fi

if [ $USEKDIALOG == true ]; then
	if [ -f $HOME/Documents/ShortixDocLink/.backup ]; then
	  kdialog --getexistingdirectory . > $HOME/Documents/ShortixDocLink/.backup
	  mkdir -p $(cat $HOME/Documents/ShortixDocLink/.backup)/Shortix-Backup
	fi
else
	if [ -f $HOME/Documents/ShortixDocLink/.backup ]; then
 	read -p "Please enter your path where the Shortix-Backup directory should be created (like '/home/deck'): " backdir
  	mkdir -p $backdir/Shortix-Backup
   	fi
fi


if [ -f $HOME/.config/user-dirs.dirs ]; then
  source $HOME/.config/user-dirs.dirs
  if [ $XDG_DESKTOP_DIR/shortix_doc_link_installer.desktop ]; then
    sed -i 's/Install/Update/' /tmp/shortix/shortix_doc_link_installer.desktop
    mv /tmp/shortix/shortix_doc_link_installer.desktop $XDG_DESKTOP_DIR/shortix_doc_link_updater.desktop
    rm -rf $XDG_DESKTOP_DIR/shortix_doc_link_installer.desktop
    chmod +x $XDG_DESKTOP_DIR/shortix_doc_link_updater.desktop
  fi
fi

if [ $USEKDIALOG == true ]; then
	kdialog --title "Shortix  Document Link $TYPE" --msgbox "Shortix Document Link is set up!"
else
	echo -e "${YL}Short is set up!${NC}"
	sleep 4
fi

[ $? = 0 ] && exit
