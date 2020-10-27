#!/bin/bash
# To create a csv file showing the count of objects and total space usage at Splunk index level

# Usage: csv.sh 

ts=`date +%Y%m%d-%H%M%S`
AWS_PROFILE=$srccreds s5cmd --endpoint-url $srcvip ls 's3://'"$srcbucket"'/*' |awk ' {print $3"/"$4}' |awk -F/ '{ arr[$2] += $1; ct[$2]+=1} END {for (i in arr){print  i ","ct[i] "," arr[i]}}' > /pure/${srccreds}_${ts}.csv
AWS_PROFILE=$dstcreds s5cmd --endpoint-url $dstvip ls 's3://'"$dstbucket"'/*' |awk ' {print $3"/"$4}' |awk -F/ '{ arr[$2] += $1; ct[$2]+=1} END {for (i in arr){print  i ","ct[i] "," arr[i]}}' > /pure/${dstcreds}_${ts}.csv

