#!/bin/bash
function getFolder() {
  regex_BH="^BH"
  regex_R="^R"
  regex_B="^B"
  regex_N="^N"
  regex_C="^C"
  regex_E="^E"
  regex_P="^P"
  regex_S="^S"
  if [[ "$1" =~ $regex_BH ]]; then
    echo "PULSERAS CABALLERO"
    exit
  elif [[ "$1" =~ $regex_R ]]; then
    echo "ANILLOS"
  elif [[ "$1" =~ $regex_B ]]; then
    echo "BRAZALETES"
  elif [[ "$1" =~ $regex_N ]]; then
    echo "COLLARES"
  elif [[ "$1" =~ $regex_C ]]; then
    echo "COLLARES"
  elif [[ "$1" =~ $regex_P ]]; then
    echo "DIJES"
  elif [[ "$1" =~ $regex_E ]]; then
    echo "PENDIENTES"
  elif [[ "$1" =~ $regex_S ]]; then
    echo "SETS"
  else
    echo "DEFAULT"
  fi
}

endpoint="https://fenyw-images.s3.amazonaws.com/"
doesE=0
doesN=0
fileNum=0
notFound="out/failed.csv"
if [ ! -e "$notFound" ]; then touch $notFound; fi
    for csvfile in in/*.csv; do
    echo "***********"
    echo "Trying ${csvfile}"
    echo "***********"
    echo ""
    singleImages="out/${csvfile##*/}"
    if [ ! -e "$singleImages" ]; then touch "$singleImages"; fi
        while IFS=, read -r col1 || [ -n "$col1" ]; do
            OIFS=$IFS
            col1=${col1%$'\r'}
            oldcol=$col1
            if [[ $col1 =~ ^R ]]; then
                col1=${col1%?}
            fi
            col1=${col1//[^[:alnum:]]/}
            #fileName=${col1// /+}
            folder="$(getFolder "$col1")"
            echo ${csvfile}
            fileName=$(rclone lsf --files-only --include "${col1}.*" "fenyw-s3:fenyw-images/${folder}")
            fileName=${fileName// /+}
            echo "Trying: $oldcol"
            if [[ "$fileName" ]]; then
                path="${endpoint}${folder}/${fileName}"
                echo "$oldcol,$path" >>$singleImages
                echo "$oldcol exists\n"
                doesE=$((doesE + 1))
            else
                echo "$col1 does not exist\n"
                echo "$col1" >>$notFound
                echo "$oldcol","NA">>$singleImages
                doesN=$((doesN + 1))
            fi
            IFS=$OIFS
        done <$csvfile
        fileNum=$((fileNum + 1))
    done
echo "Tried: ${fileNum} file(s)"
echo "Tried: $((doesE + doesN)) image(s)"
echo "${doesE} exist"
echo "${doesN} do not exist"
echo "Output files stored in /out"
