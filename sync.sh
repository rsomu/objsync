# To create listing of files on dst that are not on src (to be deleted)

# Usage: sync.sh 

mesg()
{
  mdt=`date +"%Y/%m/%d %H:%M:%S"`
  echo "$mdt: INFO: $2" >> $1
}

ts=`date +%Y%m%d-%H%M%S`
logfile=/pure/object_sync_${ts}.log

AWK='{etag=$3; size=$4; $1=""; $2=""; $3=""; $4=""; key=$0; print key,size,etag}'

mesg $logfile "Starting object synchornization at index level on $dstvip"
ct=0
if [ `ls -1 /pure/*.cmd 2>/dev/null | wc -l` -eq 0 ]; 
then
  mesg $logfile "No cmd files found"
  exit -1
fi

for index in `ls -1 /pure/*.cmd`
do
  (( ct=ct+1 ))
  mesg $logfile "Deleting excess objects from index: $index"
  AWS_PROFILE=$dstcreds s5cmd --endpoint-url $dstvip run $index |wc -l >> $logfile
  mv $index $index.deleted
done
mesg $logfile "Completed object synchornization for $ct indexes." 
