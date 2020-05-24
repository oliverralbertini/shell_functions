#!/usr/bin/env bash

yt_dl_audio () {
	yt_dl_audio_usage() {
		echo 'yt_dl_audio [-n N] [-p <playlist_name>] search terms'
	}

	local dir=~/Downloads/yt_dl format payload choices=() path{,s} osa_cmd
	local o OPT{IND,ARG} count=10 playlist
	while getopts ":n:p:" o; do
	case ${o} in
		n)
			count=${OPTARG}
			[[ $count =~ ^[1-9]+[0-9]*$ ]] || { yt_dl_audio_usage; return 1; }
			;;
		p)
			playlist=${OPTARG//\'/\\\'}
			;;
		\?)
			yt_dl_audio_usage
			return 1
			;;
	esac
	done
	shift $((OPTIND - 1))
	[[ -z $playlist ]] && playlist=${*//\'/\\\'}

	(( $# < 1 )) && { yt_dl_audio_usage; return 2; }
	format="${dir}/%(title)s.f%(format_id)s.%(ext)s"
	mkdir -p "${dir}"
	echo "Querying yt for the query '$*'..."
	payload=$(youtube-dl -4j "ytsearch${count}:$*" -o "${format}")
	mapfile -t choices < <(jq -r .fulltitle <<< "$payload" | fzf -m --border --prompt='choose a title to download')
	local pids=()
	for choice in "${choices[@]}"; do
		youtube-dl \
			-f bestaudio \
			-o "${format}" \
			--extract-audio \
			--no-progress \
			--audio-format mp3 \
			"$(jq -r --arg choice "$choice" 'select(.fulltitle == $choice).webpage_url' <<< "${payload}")" \
			>/dev/null 2>&1 &
		pids+=( "$!" )
	done

	wait "${pids[@]}"
	# https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/OSX10-10.html#//apple_ref/doc/uid/TP40014508-CH109-SW1
	# https://www.macstories.net/tutorials/getting-started-with-javascript-for-automation-on-yosemite/
	osa_cmd="iTunes = Application('iTunes')
		playlist = '${playlist}'
		playlists = iTunes.playlists
		if (!iTunes.exists(playlists.byName(playlist))) {
			iTunes.Playlist({ name: playlist }).make()
		}
		iTunes.add(["
	paths=( "${dir}/"*.mp3 )
	for path in "${paths[@]}"; do
		osa_cmd+="Path('${path//\'/\\\'}'), "
	done
	osa_cmd=${osa_cmd%, }
	osa_cmd+="], {to: playlists[playlist]})"
	osascript -l JavaScript -e "${osa_cmd}" \
		&& rm "${paths[@]}" # we can remove the file now since it's in the iTunes library
}

yt_dl () {
	local count=10 dir=~/Downloads/yt_dl format payload choices=() path
	[[ $1 == -n ]] && { count=$2; shift 2; }
	(( $# < 1 )) && { echo 'pass a search term'; return 1; }
	mkdir -p "${dir}"
	format="${dir}/%(title)s.f%(format_id)s.%(ext)s"
	echo "Querying yt for the query '$*'..."
	payload=$(youtube-dl -4j "ytsearch${count}:$*" -o "${format}")
	mapfile -t choices < <(jq -r .fulltitle <<< "$payload" | fzf -m --border --prompt='choose a title to download')
	for choice in "${choices[@]}"; do
		youtube-dl \
			 -o "${format}" \
			 --no-progress \
			 "$(jq -r --arg choice "$choice" 'select(.fulltitle == $choice).webpage_url' <<< "${payload}")"
	done
}
