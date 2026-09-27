# Checks that an interactive zsh has the fish-like features wired up.
# Run as: zsh -i verify.zsh   (so ~/.zshrc is loaded first)

zmodload zsh/datetime
typeset -i failures=0

check() {
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then
    print -r -- "ok   $name"
  else
    print -r -- "FAIL $name"
    (( failures++ ))
  fi
}

binding_is() { [[ "$(bindkey -- "$1")" == *" $2" ]]; }

# use-omz defers compinit to the first prompt; run the prompt hooks like a real shell would.
for hook in $precmd_functions; do $hook; done

check "autosuggestions loaded"        eval '(( $+functions[_zsh_autosuggest_start] ))'
check "syntax highlighting loaded"    eval '(( $+functions[fast-theme] ))'
check "abbreviations loaded"          eval '(( $+functions[abbr] ))'
check "abbreviation 'dc' defined"     eval '[[ -n "$(abbr list-abbreviations 2>/dev/null | grep -F "\"dc\"")" ]]'
check "Up searches history by prefix" binding_is '^[[A' history-substring-search-up
check "Ctrl+R uses fzf"               binding_is '^R' fzf-history-widget
check "completion system loaded"      eval '(( $+functions[compdef] )) && (( ${#_comps} > 100 ))'
check "menu completion enabled"       eval '[[ "$(zstyle -L ":completion:\*" menu)" == *select* ]]'
check "OMZ git alias gst exists"      eval '(( $+aliases[gst] ))'
check "git-svn alias gsd removed"     eval '(( ! $+aliases[gsd] ))'
check "starship prompt active"        eval '[[ "$PROMPT" == *starship* ]]'
check "mise resolves node"            mise which node

# Startup: median of 5 runs until the first prompt is ready (precmd hooks,
# including the deferred compinit) must stay under 300ms.
typeset -a times
for i in {1..5}; do
  start=$EPOCHREALTIME
  zsh -i -c 'for hook in $precmd_functions; do $hook; done; exit' >/dev/null 2>&1
  times+=( $(( (EPOCHREALTIME - start) * 1000 )) )
done
median=${${(on)times}[3]}
print -r -- "startup median: ${median%.*}ms (runs: ${(j:, :)${times%.*}})"
check "startup under 300ms"           eval '(( median < 300 ))'

stderr_output="$(zsh -i -c 'for hook in $precmd_functions; do $hook; done; exit' 2>&1 >/dev/null)"
check "no startup errors"             eval '[[ -z "$stderr_output" ]]'
[[ -n "$stderr_output" ]] && print -r -- "$stderr_output"

(( failures == 0 )) || { print "verify.zsh: $failures check(s) failed"; exit 1; }
print "verify.zsh: all checks passed"
