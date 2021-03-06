githuback() {
    ACKNOWLEDGE=$'```\nAcked-by: Steffen Pengel <spengel@de.adit-jv.com>\n```'
    echo "$ACKNOWLEDGE" | xclip -selection c
    echo '"' 
    echo "$ACKNOWLEDGE" 
    echo '"'
    echo copied to clipboard
}

gitchkp () {
    # exit code: num of commits with issues.
    num=1
    retval=0
    plist=""
    while [ $num -le $# ]
    do
        echo "----------"
        git --no-pager log --oneline -1 "$@[num]"
        git format-patch -1 --stdout "$@[num]" | scripts/checkpatch.pl --strict -q -
        if [ $? -eq 1 ]; then
            (( retval++ ))
        fi
        (( num++ ))
    done
    return $retval
}

gitpatchid () {
    num=1
    retval=0
    printf " %-9s | %-70s | %s |\n" "hash" "subject" "patch-id"
    while [ $num -le $# ]
    do
        commithash="$(git --no-pager log --pretty="%h" -1 "$@[num]")"
        printf " %-9s |" $commithash
        commit="$(git --no-pager log --pretty="%s" -1 "$@[num]")"
        printf " %-70s |" $commit
        echo " $(git show "$@[num]" | git patch-id --stable | awk '{if(length($1)>8) $1=substr($1,1,8); print $1;}') |"
        if [ $? -eq 1 ]; then
            (( retval++ ))
        fi
        (( num++ ))
    done
    # handle from stdin
    if [ $# -eq 0 ]; then
        while read line; do
            commithash="$(git --no-pager log --pretty="%h" -1 "$line")"
            printf " %-9s |" $commithash
            commit="$(git --no-pager log --pretty="%s" -1 "$line")"
            printf " %-70s |" $commit
            echo " $(git show "$line" | git patch-id --stable | awk '{if(length($1)>8) $1=substr($1,1,8); print $1;}') |"
            if [ $? -eq 1 ]; then
                (( retval++ ))
            fi
        done < /dev/stdin
    fi

    return $retval
}

extcphash () {
    num=1
    retval=0
    while [ $num -le $# ]
    do
        git log -1 "$@[num]" | grep "(cherry picked from commit" | awk {'print $5'} | cut -d")" -f 1
        if [ $? -eq 1 ]; then
            (( retval++ ))
        fi
        (( num++ ))
    done
    return $retval
}

extcphashr () {
    extcphash `git log "$1" --oneline --no-merges|sed "s/ .*//"`
}

gitchkr () {
    gitchkp `git log "$1" --oneline --no-merges|sed "s/ .*//"`
}

gitpatchidr () {
    gitpatchid `git log "$1" --oneline --no-merges|sed "s/ .*//"`
}

gitsortauth () {
    retval=0
    list=""
    while read line
    do
        list="${list}""$(git --no-pager log --pretty="format:%at %H%n" $line -1)"$'\n'
        (( retval++ ))
    done < "${1:-/dev/stdin}"

    list_sorted=$(echo $list | sort)
    echo "$list_sorted" | while read line
    do
        if [ -n "${line-}" ]; then
            echo $(echo $line | sed 's/.* //' | \
                    git --no-pager log \
                    --pretty=format:'%h - %Cgreen(%aD)%Creset %s' \
                    -1 --stdin)
        fi
    done

    return $retval
}

gitsortcom () {
    retval=0
    list=""
    while read line
    do
        list="${list}""$(git --no-pager log --pretty="format:%ct %H%n" $line -1)"$'\n'
        (( retval++ ))
    done < "${1:-/dev/stdin}"

    list_sorted=$(echo $list | sort)
    echo "$list_sorted" | while read line
    do
        if [ -n "${line-}" ]; then
            echo $(echo $line | sed 's/.* //' | \
                    git --no-pager log \
                    --pretty=format:'%h - %Cgreen(%ct)%Creset %s' \
                    -1 --stdin)
        fi
    done

    return $retval
}

gitpick () {
    retval=0
    while read line
    do
        out=$(git cherry-pick -x -s $line)
        echo $out
    done < "${1:-/dev/stdin}"

    return $retval
}

h2d(){
      echo "ibase=16; $@"|bc
}
d2h(){
      echo "obase=16; $@"|bc
}

dtb2dts () {
      if [ $# -ne 2 ]
      then	
         echo "usage: dtb2dts <in dtb file> <out dts file>" 
      else
         ~/linux-meibp-314/scripts/dtc/dtc -I dtb -O dts $1 -o $2
	 echo "$1 -> $2"
      fi
}

teatimer () {
      if [ $# -ne 1 ]
      then	
         echo "usage: teatimer <seconds>" 
      else
        minutes=$(echo $1/60 | bc)
	(sleep $1 && notify-send -u critical --icon=applications-java 'Teatime!' "Tee has steeped $minutes minutes." &) &> /dev/null  
      fi
}
