##### README

[bma](https://github.com/D630/bma) is a simple way to manage bookmarks of directories with the hash builtin command of GNU bash.

##### BUGS & REQUESTS

Please feel free to open an issue or put in a pull request on https://github.com/D630/bma

##### GIT

To download the very latest source code:

```
git clone https://github.com/D630/bma
```

In order to use the latest tagged version, do also something like this:

```
cd -- ./bma
git checkout $(git describe --abbrev=0 --tags)
```

##### INSTALL

Put the following to your `~/.bashrc`:

```
source FILENAME/OF/bma.bash && __bma -i
```

The above line will setup:
- three functions: `__bma`, `bcd` and `_bma_completion`
- one binding: `Ctrl-x b` to `bcd`
- three alias: `bb`, `bma` and `bs`
- one name completion for `__bma`, `bma` and `bb`
- one empty BMARKS_INDEX_FILE

bcd makes use of [fzf](https://github.com/junegunn/fzf). Modify it, when you do not wanna use it.

##### USAGE

```
__bma -[acdhilps]
```

###### ENVIRONMENT VARIABLES

```
BMARKS_INDEX_FILE       default: ${XDG_DATA_HOME}/bmarks.txt
```

###### OPTIONS

```
-a PATHNAME BMARK       Add bookmark and update index file
-c BMARK                Cd into bookmarked directory
-d BMARK                Remove boomark from the index file
-h                      Print help
-i                      Initialize index file
-l                      Execute 'hash' and filter bookmarks
-p                      Print all pathnames and bookmarks
-s                      Select bookmarks via the select compound
                        command of GNU bash
```

###### EXAMPLES

```sh
% cd $HOME
% bma -a $PWD home
added '/home/user1' as 'home'
% cd / && echo $PWD
/
% bb home
/home/user1
% bma -p
/home/user1 home
% cd /
% bms
1) home
cd -- 1
/home/user1
% bma -d home
index file seems to be empty now
```

###### INDEX FILE

The index file looks like this:

```sh
builtin hash -p /home/user1/.BMARKS home
builtin hash -p /home/user1/tmp/.BMARKS tmp
```

##### NOTICE

bma has been written in [GNU bash](http://www.gnu.org/software/bash/) on [Debian GNU/Linux 9 (stretch/sid)](https://www.debian.org) using these programs/packages:

- GNU bash 4.3.42(1)-release
- GNU coreutils 8.23: sort
- GNU grep 2.21
- GNU sed 4.2.2
- fzf 0.10.8

##### LICENCE

GNU GPLv3
