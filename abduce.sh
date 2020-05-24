#!/usr/bin/env bash

# ABDUCO
export ABDUCO_CMD=tmux
abduce() {
	local session create='create a new session' kill='kill a session' refresh='refresh list of sessions'

	while true; do
		set_badge_and_title abduce
		session=$(
				{
					get_abduco_sessions
					printf -- '%s\n%s\n%s' "$(tput sitm)$(tput setaf 2)${create}" "$(tput setaf 1)${kill}" "$(tput setaf 3)${refresh}"
				} | \
					fzf +m --border \
						--prompt='choose a valid session (^D to quit): ' \
						--ansi
		)
		# [[ -z ${session} ]] && continue
		[[ -z ${session} ]] && return 1 # user entered ^D or EOF
		case $session in
			"${refresh}")
				continue
				;;
			"${create}")
				echo "provide name and command (default is ${ABDUCO_CMD}):"
				local desired_session_and_command
				read -ra desired_session_and_command
				set_badge_and_abduce "${desired_session_and_command[@]}"
				;;
			"${kill}")
				session_to_kill=$(
					get_abduco_sessions | \
						fzf +m --border \
							--prompt='choose abduco session to kill (^D to cancel): '
				)
				[[ -z ${session_to_kill} ]] && continue # user entered ^D or EOF
				local pids
				mapfile -t pids < <(pgrep -f "^abduco -[Aa] ${session_to_kill}.*$")
				kill "${pids[@]}"
				;;
			*)
				set_badge_and_abduce "${session}"
				;;
		esac
		session=""
	done
}

get_abduco_sessions() {
	abduco | tail -n +2 | awk '{print $NF}'
}

set_badge_and_abduce() {
	local desired_session=$1 desired_command
	[[ -z ${desired_session} ]] && return 1
	shift
	desired_command=("$@")
	set_badge_and_title "${desired_session}"
	DVTM_EDITOR=vim abduco -A "${desired_session}" "${desired_command[@]}"
}

set_badge_and_title() {
	local title=${1}
	# set Iterm badge
	printf "\e]1337;SetBadgeFormat=%s\a" "$(echo -n "${title}" | base64)"
	# set xterm title
	printf '\033]0;%s\007' "${title}"
	# turn off focus-reporting
	printf '\e[?1004l'
}
