#!/usr/bin/env bash
# mkdir -p ~/.fuzzpass

get_gpg_files() {
	local PASSWORD_STORE=${PASSWORD_STORE:-~/.password-store}
	find "${PASSWORD_STORE}" -name '*.gpg' |
		sed -E "s,(.*)${PASSWORD_STORE##*/}/(.*)\.gpg,\2,"
}

fuzzpass() {
	local path edit_path \
		create='create a new password' \
		push='push changes' \
		pull='pull changes' \
		edit='edit a password' \
		generate='generate a new password' \
		shell_session='start a shell session for pass'
	while true; do
		path=$(
		{
			get_gpg_files
			printf '%s\n%s\n%s\n%s\n%s\n%s' \
				"$(tput sitm)$(tput setaf 2)${create}" \
				"${push}" \
				"${pull}" \
				"${generate}" \
				"${shell_session}" \
				"$(tput setaf 1)${edit}"
		} |
			fzf +m --border \
			--prompt='choose a password or action (^D to quit): ' \
			--no-clear \
			--ansi
		)
		[[ -z ${path} ]] && { clear; return; }
		case $path in
			"${create}"|"${shell_session}"|"${generate}")
				clear
				PS1='pass-> ' bash --init-file ~/workspace/shell_functions/completion.d/pass.sh
				continue
				;;
			"${edit}")
				edit_path=$(
					get_gpg_files |
					fzf +m --border \
					--prompt='choose a password to edit (^D to quit): ' \
					--no-clear \
					--ansi
				)
				pass edit "${edit_path}"
				continue
				;;
			"${push}")
				pass git pull --rebase
				pass git push
				continue
				;;
			"${pull}")
				pass git pull --rebase
				continue
				;;
			*otp-key)
				printf '%s' "$(oathtool --base32 --totp "$(pass "${path}")")" | pbcopy
				continue
				;;
		esac
		pass -c "${path}"
	done
}
