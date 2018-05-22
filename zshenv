
which gpg-agent >/dev/null 2>&1
if [ $? -eq 0 ] ; then
    # Set GPG TTY
    export GPG_TTY=$(tty)

    # Refresh gpg-agent tty in case user switches into an X session
    gpg-connect-agent updatestartuptty /bye >/dev/null
fi
