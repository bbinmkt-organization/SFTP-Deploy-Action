#!/bin/sh -l

#set -e at the top of your script will make the script exit with an error whenever an error occurs (and is not explicitly handled)
set -eu

TEMP_SSH_PRIVATE_KEY_FILE='../private_key.pem'
TEMP_SFTP_FILE='../sftp'

# make sure remote path is not empty
if [ -z "$6" ]; then
   echo 'remote_path is empty'
   exit 1
fi

# use password
if [ -z != ${10} ]; then
	echo 'use sshpass'
	apk add sshpass

	# Create an SFTP batch file with mkdir command if directory creation is required
	if [ "$7" != "true" ]; then
		echo 'Create directory if needed'
		printf "%s\n" "mkdir $6" >$TEMP_SFTP_FILE
	fi
	
	# Add the put command to transfer files
	echo 'SFTP Start'
	printf "%s\n" "put -r $5 $6" >>$TEMP_SFTP_FILE
	# Execute SFTP batch file using sshpass with password
	SSHPASS=${10} sshpass -e sftp -oBatchMode=no -b $TEMP_SFTP_FILE -P $3 $8 -o StrictHostKeyChecking=no $1@$2

	echo 'Deploy Success'
    exit 0
fi

# keep string format
printf "%s" "$4" >$TEMP_SSH_PRIVATE_KEY_FILE
# avoid Permissions too open
chmod 600 $TEMP_SSH_PRIVATE_KEY_FILE

# Create an SFTP batch file with mkdir command if directory creation is required
if [ "$7" != "true" ]; then
  echo 'Create directory if needed'
  printf "%s\n" "mkdir $6" >$TEMP_SFTP_FILE
fi

# Add the put command to transfer files
echo 'SFTP Start'
printf "%s\n" "put -r $5 $6" >>$TEMP_SFTP_FILE

# Execute SFTP batch file using private key authentication
sftp -b $TEMP_SFTP_FILE -P $3 -o StrictHostKeyChecking=no -i $TEMP_SSH_PRIVATE_KEY_FILE $1@$2

echo 'Deploy Success'
exit 0
