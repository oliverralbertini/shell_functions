#!/usr/bin/env bash

PATH=~/bin:$PATH

open_firefox() {
	# see https://github.com/mozilla/multi-account-containers/issues/365
	# and https://addons.mozilla.org/en-US/firefox/addon/open-url-in-container
	local PATH=/Applications/Firefox.app/Contents/MacOS:${PATH} container=$1 url=$2
	if [[ ${url} =~ ^https://nam04.safelinks.protection.outlook.com/\?url=(.*)$ ]]; then
		url=$(,urldecode "${BASH_REMATCH[1]}")
	elif [[ ${url} =~ ^https://urldefense.proofpoint.com/v2/url\?u=(.*)$ ]]; then
		# https-3A__source.vmware.com_portal_pages_RnD_modern-2Dapplications-2Dplatform-2Dbusiness-2Dunit
		: "${BASH_REMATCH[1]}"
		: "${_//_/\/}"
		: "${_//-/%}"
		url=$(,urldecode "${_}")
	fi
	firefox "ext+container:name=${container}&url=${url}"
	echo "$(date): opening ext+container:name=${container}&url=${url}" >>/tmp/open_firefox.log
}
