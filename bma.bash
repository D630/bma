#!/usr/bin/env bash

# bma [GNU GPLv3]
# https://github.com/D630/bma

__bma ()
{
        builtin typeset \
                BMARKS_INDEX_FILE=${BMARKS_INDEX_FILE:-${XDG_DATA_HOME}/bmarks.txt}

        [[ -f $BMARKS_INDEX_FILE ]] || > "$BMARKS_INDEX_FILE" || builtin return 1

        case ${1#-} in
        a)
                if
                        [[ -n $2 && -n $3 ]]
                then
                        if
                                builtin hash -p "${2}/.BMARKS" -- "$3"
                        then
                                if
                                        builtin hash -l \
                                        | command fgrep '/.BMARKS ' \
                                        > "$BMARKS_INDEX_FILE"
                                then
                                        builtin printf 'added %s as %s \n' "$2" "$3" 1>&2
                                else
                                        builtin printf '%s\n' "error: could not update index file" 1>&2
                                fi
                        else
                                builtin printf 'error: could not add %s\n' "$3" 1>&2
                        fi
                else
                        builtin printf 'error: bad arguments: %s\n' "$*" 1>&2
                fi
        ;;
        c)
                if
                        [[ -n $2 ]]
                then
                        builtin typeset b="$(builtin hash -t "$2")"
                        if
                                builtin cd -- "${b%/.BMARKS}"
                        then
                                builtin printf 'cd -- %s\n' "$PWD" 1>&2
                        else
                                builtin printf 'error: could not cd into %s\n' "$2" 1>&2
                        fi
                else
                        builtin printf 'error: bad arguments: %s\n' "$*" 1>&2
                fi
        ;;
        d)
                if
                        builtin typeset p="$(
                                __bma -p \
                                | command grep " ${2}$"
                        )"
                        builtin hash -d "$2"
                then
                        if
                                builtin hash -l \
                                | command fgrep '/.BMARKS ' \
                                > "$BMARKS_INDEX_FILE"
                        then
                                builtin printf 'removed %s (%s)\n' "$2" "${p% *}" 1>&2
                        else
                                builtin printf '%s\n' "index file seems to be empty now" 1>&2
                        fi
                else
                        builtin printf 'error: could not remove %s\n' "$2" 1>&2
                fi
        ;;
        i)
                builtin source "$BMARKS_INDEX_FILE" || {
                        builtin printf 'error: could not source %s\n' "$BMARKS_INDEX_FILE" 1>&2
                }
        ;;
        l)
                builtin hash \
                | command sed -n '/\/\.BMARKS$/ s/\/\.BMARKS$// p'
        ;;
        p)
                command sed -n 's/\/\.BMARKS//;s/builtin hash -p // p' "$BMARKS_INDEX_FILE"
        ;;
        s)
                builtin typeset \
                        PS3='cd -- ' \
                        i;
                select i in $(__bma -p | command sed 's/.* //' | command sort)
                do
                        __bma -c "$i" && builtin break
                done
        ;;
        h)
                { builtin typeset help="$(</dev/fd/0)" ; } <<'HELP'
Usage
        __bma -[acdhilps]

Options
        -a PATHNAME BMARK       Add bookmark and update index file
        -c BMARK                Cd into bookmarked directory
        -d BMARK                Remove boomark from the index file
        -h                      Print help
        -i                      Initialize index file
        -l                      Execute 'hash' and filter bookmarks
        -p                      Print all pathnames and bookmarks
        -s                      Select bookmarks via the select compound command
                                of GNU bash
Environment variables
        BMARKS_INDEX_FILE       default: ${XDG_DATA_HOME}/bmarks.txt
HELP
                builtin printf '%s\n' "$help"
        ;;
        *)
                builtin printf '%s\n' "usage: __bma -[acdhilps]" 1>&2
        esac
}

bcd ()
{
        builtin typeset dir
        builtin read -r dir _ < <(
                __bma -p \
                | command fzf
        )

        if
                [[ -d $dir ]]
        then
                builtin cd -- "$dir" && builtin printf 'cd -- %s\n' "$PWD" 1>&2
        else
                builtin printf '%s\n' "no dir has been chosen" 1>&2
                builtin return 1
        fi
}

builtin bind -x '"\C-xb": bcd'

_bma_completion ()
{
        builtin typeset \
                BMARKS_INDEX_FILE=${BMARKS_INDEX_FILE:-${XDG_DATA_HOME}/bmarks.txt} \
                cur=${COMP_WORDS[COMP_CWORD]};

        builtin typeset -a dirs="()"

        [[ -f $BMARKS_INDEX_FILE ]] || builtin return 1

        builtin mapfile -t dirs < <(
                command sed 's/.* //' "$BMARKS_INDEX_FILE"
        )

        builtin mapfile -t COMPREPLY < <(
                builtin compgen -W '${dirs[@]}' -- "$cur"
        )

        builtin return 0
}

builtin complete -F _bma_completion -- __bma bma bb

alias bb='__bma -c'
alias bma=__bma
alias bs='__bma -s'

# vim: set ts=8 sw=8 tw=0 et :
