function exit_on_error {
    if [[ 0"$?" != 0"0" ]]; then
	    echo "ERROR: $@"
	    exit 1
    fi
}

function godir() {
    basedir="$GOPATH/src"
    # If not argument is provided, go the $basedir
    # Otherwise, use the argument as a regex to jump to the first matching path
    if [ -z $1 ]; then
	    pushd "${basedir}"
    else
        newdir=$(find "$GOPATH/src" -type d -path "*${1}*" -print -quit)
        pushd "${newdir}"
    fi
}

# NOTE: not needed as autopep8 has built in recursive functionality now
# recurs from given path to find and format all python files to PEP8 style
# $1 is start directory
#function autopep() {
#  echo "formatting all Python files in $1 to PEP8 style"
#
#  for i in "$1"/*; do
#    if [ -d "$i" ];then
#        echo "dir: $i"
#          autopep "$i"
#    elif [ -f "$i" ]; then
#      fname=$i
#      fext=${fname: -2}
#      if [ "$fext" = "py" ]; then
#        echo "formatting: $i"
#				autopep8 --in-place --aggressive $i
#      fi
#    fi
#  done
#}
