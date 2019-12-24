#!/usr/bin/env bash

# run bat nicely within dvtm
bat() {
	[[ $TERM =~ dvtm ]] || { command bat "$@"; return; }
	command bat --italic-text never --theme base16 "$@"
}
