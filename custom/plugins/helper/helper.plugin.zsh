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
        git log --oneline -1 "${!num%/}"
        git format-patch -1 --stdout "${!num%/}" | scripts/checkpatch.pl --strict -q -
        if [ $? -eq 1 ]; then
            (( retval++ ))
        fi
        (( num++ ))
    done
    return $retval
}

gitchkr () {
    gitchkp `git log "$1" --oneline --no-merges|sed "s/ .*//"`
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
