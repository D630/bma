#!/usr/bin/env bash

# bma
# Copyright (C) 2015,2017,2019 D630, GNU GPLv3
# <https://github.com/D630/bma>

function __bma {
	typeset \
		BMARKS_INDEX_FILE=${BMARKS_INDEX_FILE:-${XDG_DATA_HOME}/bmarks.txt};

	[[ -f $BMARKS_INDEX_FILE ]] ||
		> "$BMARKS_INDEX_FILE" ||
			return 1;

	case ${1#-} in
		(a)
			[[ -n $2 && -n $3 ]] || {
				printf 'error: bad arguments: %s\n' "$*" 1>&2;
				return 1;
			};
			hash -p "$2/.BMARKS" -- "$3" || {
				printf 'error: could not add %s\n' "$3" 1>&2;
				return 1;
			};
			if
				hash -l |
				command grep -F '/.BMARKS ' > "$BMARKS_INDEX_FILE";
			then
				printf 'added %s as %s \n' "$2" "$3" 1>&2;
			else
				printf '%s\n' "error: could not update index file" 1>&2;
				return 1;
			fi;;
		(c)
			[[ -n $2 ]] || {
				printf 'error: bad arguments: %s\n' "$*" 1>&2;
				return 1;
			};
			typeset b=$(hash -t "$2");
			builtin cd -- "${b%/.BMARKS}" || {
				printf 'error: could not cd into %s\n' "$2" 1>&2;
				return 1;
			};;
		(d)
			typeset p=$(
				__bma -p |
				command grep " ${2}$";
			);
			hash -d "$2" || {
				printf 'error: could not remove %s\n' "$2" 1>&2;
				return 1;
			};
			if
				hash -l |
				command grep -F '/.BMARKS ' > "$BMARKS_INDEX_FILE";
			then
				printf 'removed %s (%s)\n' "$2" "${p% *}" 1>&2;
			else
				printf '%s\n' "index file seems to be empty now" 1>&2;
				return 1;
			fi;;
		(i)
			. "$BMARKS_INDEX_FILE" ||
				printf 'error: could not source %s\n' "$BMARKS_INDEX_FILE" 1>&2;;
		(l)
			hash |
			command sed -n '/.\/\.BMARKS$/ s/\.BMARKS$// p';;
		(p)
			command sed -n 's/hash -p //;s/\.BMARKS / / p' "$BMARKS_INDEX_FILE";;
		(s)
			typeset \
				PS3='cd -- ' \
				i;
			select i in $(__bma -p | command sed 's/.* //' | command sort); do
				__bma -c "$i" && break;
			done;;
		(h)
			{ typeset help=$(</dev/fd/0) ; } <<'HELP'
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
			printf '%s\n' "$help";;
		(*)
			printf '%s\n' "usage: __bma -[acdhilps]" 1>&2;;
	esac;
};

function bcd {
	typeset dir;
	read -r dir _ < <(
		__bma -p |
		command fzf;
	);

	if
		[[ -d $dir ]];
	then
		builtin cd -- "$dir";
	else
		printf '%s\n' "no dir has been chosen" 1>&2;
		return 1;
	fi;
};

bind -x '"\C-xb": bcd';

function _bma_completion {
	typeset \
		BMARKS_INDEX_FILE=${BMARKS_INDEX_FILE:-${XDG_DATA_HOME}/bmarks.txt} \
		cur=${COMP_WORDS[COMP_CWORD]};

	typeset -a dirs="()";

	[[ -f $BMARKS_INDEX_FILE ]] ||
		return 1;

	mapfile -t dirs < <(
		command sed 's/.* //' "$BMARKS_INDEX_FILE"
	);

	mapfile -t COMPREPLY < <(
		compgen -W '${dirs[@]}' -- "$cur"
	);

	return 0;
};

complete -F _bma_completion -- __bma bma bb;

alias bb='\__bma -c';
alias bma='\__bma'
alias bs='\__bma -s';

# vim: set ts=4 sw=4 tw=0 noet :
