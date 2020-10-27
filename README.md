# objsync
  Toolkit to synchronize target FlashBlade bucket with that of source FlashBlade bucket

  This repository contains three scripts

    list.sh - Lists the excessive objects of a given bucket at the target FlashBlade that are not in the source FlashBlade

    sync.sh - Removes the excessive objects identified by the list.sh script

    csv.sh - Reports the object count and size at Splunk index level in a csv format for both the source and target FB
 
## Who should be using this toolkit?

  If you are a FlashBlade customer with two FlashBlades setup in an asynchronous replication at a bucket level and are experiencing excessive objects at the target FlashBlade because of how the objects at the source were deleted (delete by version id doesn't propagate the deletes to the target) by the application.

## How to use this toolkit?

  The toolkit has two scripts which are packaged in a docker container image. 

  1. Run the docker image with list.sh as the first step which will create a separate command file (cmd) for every Splunk level index under the /pure directory within the container which is persisted at the host.
  2. Run the docker image with sync.sh which will go over the command files at an index level generated from the previous step and removes the object at the target FB. Once removed, it marks the command files as done. 
   
## What does the toolkit do?

  The list script compares the objects between the source and target using a combination of s5cmd command and comm command and identifies the excessive objects from the target FB and writes to a .cmd file.  The .cmd file contains the command to remove all the excessive objects.  The sync script goes after all the .cmd files generated and execute them through s5cmd to remove the objects.  Both scripts will generate a log file listing the activities performed.
  
## Build the docker image
  Make sure the shell scripts are in the same directory as the Dockerfile is.

Usage
```
  docker build -t objsync .
```

## Prerequisites to run the scripts
```
  1. Create a credentials file in the following format with the details of the source and target FlashBlade.

     [source]
     aws_access_key_id=xxxxxx
     aws_secret_access_key=xxxxxx

     [target]
     aws_access_key_id=xxxxx
     aws_secret_access_key=xxxxxxx
  
  2. Create an environment file named objsync.conf with following information.
 
     **Note:  It is very critical to provide the right source and target FlashBlades.
     Target or destination FB is where the excessive objects will be removed.**

     srccreds=<name from credentials>
     dstcreds=<name from credentials>
     srcvip=http://<source data vip>
     dstvip=http://<target data vip>
     srcbucket=<source bucket name>
     dstbucket=<target bucket name>

  3. Create a directory named pure which will hold the runtime files and log files.
     Note: Make sure to have enough storage space for this pure directory depending on the excessive object counts.
     Each Splunk object may consume around 150 bytes and hence 1M objects can consume around 150MB.

  4. Make sure the directory you are running the script from has the following files/dir.

     credentials
     objsync.conf
     pure (directory)

```

## Running the scripts

Usage
```
  To get the summary of objects and storage usage at an Splunk index level across both FBs 

  docker run --rm -v `pwd`/credentials:/root/.aws/credentials --env-file=`pwd`/objsync.conf --mount type=bind,source=`pwd`/pure,target=/pure objsync csv.sh

  To get the list of excessive objects across all Splunk indexes from the target FB

  docker run --rm -v `pwd`/credentials:/root/.aws/credentials --env-file=`pwd`/objsync.conf --mount type=bind,source=`pwd`/pure,target=/pure objsync list.sh

  To remove the excessive objects across all indexes at the target FB

  docker run --rm -v `pwd`/credentials:/root/.aws/credentials --env-file=`pwd`/objsync.conf --mount type=bind,source=`pwd`/pure,target=/pure objsync sync.sh
```
