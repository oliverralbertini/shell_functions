#!/usr/bin/env bash

# https://github.com/johndgiese/dotvim/issues/4
# https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard/issues/31
bracket_mode_on() {
	printf '\e[?2004h'
}

bracket_mode_off() {
	printf '\e[?2004l'
}

# https://superuser.com/questions/931873/o-and-i-appearing-on-iterm2-when-focus-lost
focus_reporting_off() {
	printf '\e[?1004l'
}
