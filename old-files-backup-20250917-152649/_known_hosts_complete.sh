###
# add to ~/.bash_profile or add to ~/local/bash/, and close/reopen a shell.
# will autocomplete any hosts found in known_hosts.
#
# | grep -v "\["
complete -W "$(echo `cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq`;)" ssh
