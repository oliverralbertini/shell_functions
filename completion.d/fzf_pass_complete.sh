#!/usr/bin/env bash

source /usr/local/opt/fzf/shell/completion.bash

# pass completion suggested by @d4ndo (#362)
_fzf_complete_pass() {
  _fzf_complete '+m' "$@" < <(
    local pwdir=${PASSWORD_STORE_DIR-~/.password-store/}
    local stringsize=${#pwdir}
    find "${pwdir}" -name '*.gpg' -print |
        cut -c $((stringsize + 1))- |
        sed -e 's/\(.*\)\.gpg/\1/'
  )
}

[[ -n $BASH ]] && complete -F _fzf_complete_pass -o default -o bashdefault pass
