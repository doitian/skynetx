if [[ ! -o interactive ]]; then
  return
fi

compdef _sx sx

_sx() {
  local curcontext="$curcontext" state state_descr line expl
  local ret=1
  local -a values alternatives
  local arg

  _arguments '-f[Read given file as .env]:files:_files' "1:command:($(sx commands))" '*::values:->values' && return 0
  case "$state" in
    values)
      line[-1]=()

      for arg in ${(f)"$(sx completions "${line[@]}")"}; do
        case "$arg" in
          __file__)
            alternatives+=('files:files:_files')
            ;;
          __directory__)
            alternatives+=('directories:directories:{_files -/}')
            ;;
          __command__)
            alternatives+=('commands:commands:_path_commands')
            ;;
          *)
            if [ "${line[(i)$arg]}" -gt "${#line[@]}" ]; then
              values+=("$arg")
            fi
        esac
      done
      if [ "${#values[@]}" -gt 0 ]; then
        alternatives+=("values:values:{_describe 'values' values}")
      fi
      if [ "${#alternatives[@]}" -gt 0 ]; then
        _alternative "${alternatives[@]}" && return 0
      fi
      ;;
  esac

  return ret
}
