#!/bin/sh
echo "This will uninstall Shortix Document Link from your system!"
read -p "Press ENTER if you want to continue, otherwise close this window"

if [ ! -d $HOME/Documents/ShortixDocLink ]; then
  echo "Shortix Document Link is not installed in $HOME/Documents/ShortixDocLink!"
  echo "Please remove your Shortix Document Link directory manually if there's one"
else
  if [ -f $HOME/Documents/ShortixDocLink/.backup ]; then
    rm -rf $(cat $HOME/Documents/ShortixDocLink/.backup)/Shortix-Backup
  fi
  if [ -f $HOME/.config/systemd/user/shortix_doclink.service ]; then
    systemctl --user stop shortix_doclink.service
    systemctl --user disable shortix_doclink.service
    rm -rf $HOME/.config/systemd/user/shortix_doclink.service
  fi
  rm -rf $HOME/Documents/ShortixDocLink
fi

echo "Everything is done! Shortix Document Link is uninstalled, including backup and service (if it was installed).\nThanks and Bye!"
exit
