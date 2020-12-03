#!/bin/bash
# To create listing of files on dst that are not on src (to be deleted)

# Usage: list.sh 

mesg()
{
  mdt=`date +"%Y/%m/%d %H:%M:%S"`
  echo "$mdt: INFO: $2" >> $1
}

ts=`date +%Y%m%d-%H%M%S`
logfile=/pure/object_list_${ts}.log

AWK='{etag=$3; size=$4; $1=""; $2=""; $3=""; $4=""; key=$0; print key,size,etag}'

mesg $logfile "Starting object comparison at index level on the target ==> $dstvip"

ct=0
AWS_PROFILE=$dstcreds s5cmd --endpoint-url $dstvip ls 's3://'"$dstbucket" | while read ignore index;
do
  ((ct++))
  index=$(echo "$index" | tr -d '/$') # remove trailing slash
  mesg $logfile "$ct - Index: $index"

  SED='s/^  *\(.*\) .* .*$/rm s3:\/\/'"$dstbucket\/$index"'\/\1/'

   LC_COLLATE=C comm -1 -3 \
   <(AWS_PROFILE=$srccreds s5cmd --endpoint-url $srcvip ls -e 's3://'"$srcbucket/$index"'/*' | awk "$AWK" ) \
   <(AWS_PROFILE=$dstcreds s5cmd --endpoint-url $dstvip ls -e 's3://'"$dstbucket/$index"'/*' | awk "$AWK") \
   | sed "$SED" > /pure/$index.cmd
done 

mesg $logfile "========= Excessive objects at target ==> $dstvip ========= "
wc -l /pure/*.cmd >> $logfile
mesg $logfile "Completed object comparisons on indexes."
