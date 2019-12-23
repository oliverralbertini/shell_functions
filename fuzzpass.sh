#!/usr/bin/env bash

fuzzpass() {
	local path
	while true; do
		path=$(
			find ~/.password-store -name '*.gpg' | \
			sed -E 's,(.*)\.password-store/(.*)\.gpg,\2,' | \
			fzf +m
		)
		[[ -z ${path} ]] && continue
		if [[ ${path} =~ otp-key ]]; then
			local pin
			pin=$(oathtool --base32 --totp "$(pass "${path}")")
			printf '%s' "${pin}" | pbcopy
			continue
		fi
		pass -c "${path}"
	done
}
