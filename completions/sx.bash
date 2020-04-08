__sxcomp_words_include() {
  local i=1
  while [[ "$i" -lt "$COMP_CWORD" ]]
  do
    if [[ "${COMP_WORDS[i]}" = "$1" ]]
    then
      return 0
    fi
    i="$((++i))"
  done
  return 1
}

__sxcomp() {
  # break $1 on space, tab, and newline characters,
  # and turn it into a newline separated list of words
  local list s sep=$'\n' IFS=$' '$'\t'$'\n'
  local cur="${COMP_WORDS[COMP_CWORD]}"

  for s in $1; do
    case "$s" in
      __file__)
        list="$list$(compgen -A file -- "$cur")"
        ;;
      __directory__)
        list="$list$(compgen -A directory -- "$cur")"
        ;;
      __command__)
        list="$list$(compgen -A command -- "$cur")"
        ;;
      *)
        __sxcomp_words_include "$s" && continue
        list="$list$s$sep"
        ;;
    esac
  done

  IFS="$sep"
  COMPREPLY=($(compgen -W "$list" -- "$cur"))
}

_sx() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "-f $(sx commands)" -- "$word") )
  elif [ "$COMP_CWORD" -eq 2 ] && [ "${COMP_WORDS[1]}" == '-f' ]; then
    COMPREPLY=( $(compgen -A file -- "$word") )
  elif [ "$COMP_CWORD" -eq 3 ] && [ "${COMP_WORDS[1]}" == '-f' ]; then
    COMPREPLY=( $(compgen -W "$(sx commands)" -- "$word") )
  else
    local words=("${COMP_WORDS[@]}")
    unset words[0]
    unset words[$COMP_CWORD]
    if [ "$COMP_CWORD" -gt 2 ] && [ "${COMP_WORDS[1]}" == '-f' ]; then
      unset words[1]
      unset words[2]
    fi
    __sxcomp "$(sx completions "${words[@]}")"
  fi
}

_sx_to_completion() {
  _sx
}

complete -o default -o bashdefault -F _sx sx
