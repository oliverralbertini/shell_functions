#!/usr/bin/env bash

dl_mp3 () {
    url=$1
    [[ -z $url ]] && {
        echo 'pass a url'
        return 1
    }
    path=/tmp/${url##*/}
    wget -O "${path}" "${url}"
    open "${path}"
    sleep 2
    rm "${path}"
}

