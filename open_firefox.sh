#!/usr/bin/env bash

open_firefox() {
	# see https://github.com/mozilla/multi-account-containers/issues/365
	# and https://addons.mozilla.org/en-US/firefox/addon/open-url-in-container
	local PATH=/Applications/Firefox.app/Contents/MacOS:${PATH} container=$1 url=$2
	firefox "ext+container:name=${container}&url=${url}"
}
