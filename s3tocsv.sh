#!/bin/bash
function getFolder() {
  if [ $# -eq "0" ]; then
    echo "No arguments provided to function"
    exit 1
  fi
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
if [[ "$#" -eq "2" ]]; then
  singleImages="out/${2}"
  notFound="out/notFound.csv"
  >$singleImages
  >$notFound
  while IFS=, read -r col1 || [ -n "$col1" ]; do
    OIFS=$IFS
    col1=${col1%$'\r'}
    oldcol=$col1
    if [[ $col1 =~ ^R ]]; then
      col1=${col1%?}
    fi
    folder="$(getFolder "$col1")"
    fileName=$(rclone lsf "fenyw-s3:fenyw-images/${folder}" | egrep -m 1 ^${col1}\.)
    fileName=${fileName// /+}
    echo "Trying: $oldcol"
    if [[ "$fileName" ]]; then
      path="${endpoint}${folder}/${fileName}"
      echo "$oldcol,$path" >>$singleImages
      echo "$oldcol exists\n"
      doesE=$((doesE + 1))
    else
      echo "$col1 does not exist\n"
      echo "$oldcol","NA">>$singleImages
      echo "$col1" >>$notFound
      doesN=$((doesN + 1))
    fi
    IFS=$OIFS
  done <$1
  echo "Tried: $((doesE + doesN)) images"
  echo "${doesE} exist"
  echo "${doesN} do not exist"
  echo "Output stored in files"
else
  echo "Not enough arguments provided"
  exit 1
fi
