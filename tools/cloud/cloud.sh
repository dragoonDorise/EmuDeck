#!/bin/bash
# prevent possible LD_PRELOAD entries from steam being passed to browser
LD_PRELOAD=""

browsercommand() {
  { # try flatpak with specified browserapp
	"/usr/bin/flatpak" run ${FLATPAKOPTIONS} ${BROWSERAPP} @@u @@ ${BROWSEROPTIONS} ${LINK}
  } || { # if that fails, try running the browserapp natively
	${BROWSERAPP} ${BROWSEROPTIONS} ${LINK}
  } || { # if browserapp fails, try looking up and using default browser given by xdg-settings
	DEFAULTBROWSERAPP=$(cat /usr/share/applications/"$(xdg-settings get default-web-browser)" | grep Exec= | head -n 1 | cut -d = -f 2 | cut -d " " -f1)
	${DEFAULTBROWSERAPP} ${BROWSEROPTIONS} ${LINK}
  }
}