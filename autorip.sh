#!/bin/sh
#=====================================================================================
#
#         FILE: autorip.sh
#
#        USAGE: ./autorip.sh
#
#  DESCRIPTION: Incron script to auto rip a DVD using Handbrake, & auto insert into 
#               a Plex Media Library.  
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: IAN THOMAS 
#      COMPANY: Parker Software LLC
#      VERSION: 0.6
#      CREATED: 03/14/2016 11:12 AM EST
#     REVISION: ---
#
#   EXIT CODES:
#               0 : NO ERRORS 
#               1 : LOCK FILE PRESENT
#               2 : INSUFFICIENT PRIVILEGES (NOT ROOT USER)
#               3 : FAILED TO MOUNT DVD DRIVE 
#               4 : `VIDEO_TS` FOLDER MISSING FROM DISK (NOT A DVD) 
#               5 : HANDBRAKE ENCODING ERROR 
#               6 : VOBCOPY ERROR (ERROR GETTING DVD NAME)
#               7 : MOVIE ALREADY IN LIBRARY
#
#
#=====================================================================================
AUTORIP_VERSION="0.1.3"
LOG_FILE="/scripts/autorip.log"
SCRIPT_FINISHED()
{
	# Play Starwars Theme song, to signal script has finished!	
	beep -l 350 -f 392 -D 100 --new -l 350 -f 392 -D 100 --new -l 350 -f 392 -D 100 --new -l 250 -f 311.1 -D 100 --new -l 25 -f 466.2 -D 100 --new -l 350 -f 392 -D 100 --new -l 250 -f 311.1 -D 100 --new -l 25 -f 466.2 -D 100 --new -l 700 -f 392 -D 100 --new -l 350 -f 587.32 -D 100 --new -l 350 -f 587.32 -D 100 --new -l 350 -f 587.32 -D 100 --new -l 250 -f 622.26 -D 100 --new -l 25 -f 466.2 -D 100 --new -l 350 -f 369.99 -D 100 --new -l 250 -f 311.1 -D 100 --new -l 25 -f 466.2 -D 100 --new -l 700 -f 392 -D 100 --new -l 350 -f 784 -D 100 --new -l 250 -f 392 -D 100 --new -l 25 -f 392 -D 100 --new -l 350 -f 784 -D 100 --new -l 250 -f 739.98 -D 100 --new -l 25 -f 698.46 -D 100 --new -l 25 -f 659.26 -D 100 --new -l 25 -f 622.26 -D 100 --new -l 50 -f 659.26 -D 400 --new -l 25 -f 415.3 -D 200 --new -l 350 -f 554.36 -D 100 --new -l 250 -f 523.25 -D 100 --new -l 25 -f 493.88 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 25 -f 440 -D 100 --new -l 50 -f 466.16 -D 400 --new -l 25 -f 311.13 -D 200 --new -l 350 -f 369.99 -D 100 --new -l 250 -f 311.13 -D 100 --new -l 25 -f 392 -D 100 --new -l 350 -f 466.16 -D 100 --new -l 250 -f 392 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 700 -f 587.32 -D 100 --new -l 350 -f 784 -D 100 --new -l 250 -f 392 -D 100 --new -l 25 -f 392 -D 100 --new -l 350 -f 784 -D 100 --new -l 250 -f 739.98 -D 100 --new -l 25 -f 698.46 -D 100 --new -l 25 -f 659.26 -D 100 --new -l 25 -f 622.26 -D 100 --new -l 50 -f 659.26 -D 400 --new -l 25 -f 415.3 -D 200 --new -l 350 -f 554.36 -D 100 --new -l 250 -f 523.25 -D 100 --new -l 25 -f 493.88 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 25 -f 440 -D 100 --new -l 50 -f 466.16 -D 400 --new -l 25 -f 311.13 -D 200 --new -l 350 -f 392 -D 100 --new -l 250 -f 311.13 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 300 -f 392.00 -D 150 --new -l 250 -f 311.13 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 700 -f 392 
}

REMOVE_LOCK_FILE()
{
	rm "${LOCK_FILE}"
}

INFO()
{
    	msg="$1"
    	echo "I:   $msg" >> $LOG_FILE
	echo "I:   $msg" 
}

DEBUG()
{
    	msg="$1"
    	echo "D:   $msg" >> $LOG_FILE
	echo "D:   $msg" 
}

PREPARE_SCRIPT_EXIT()
{
	INFO "Unmounting dvd drive ..."
	umount "${DVD_DIR}"

	INFO "Ejecting dvd drive ..."
	eject "${DVD_DEV}"

	INFO "Removing lock file ..."
	rm "${LOCK_FILE}"
}

ERROR()
{
	msg="$1"
	echo "E:   $msg" >> $LOG_FILE
	echo "E:   $msg"
}

SCRIPT_EXIT_CODE()
{

	EXIT_CODE="$1"

	case $EXIT_CODE in
	0)
		MESSAGE="No Errors"
		PREPARE_SCRIPT_EXIT
		;;
	1)
		MESSAGE="Lock file present"
		INFO " if you're sure there isnt another instance of this script"
		INFO " running, you can remove /scripts/autorip.lock"
		;;
	2)
		MESSAGE="Insufficient Privileges"
		;;
	3)
		MESSAGE="Failed to mount dvd drive"
		;;
	4)
		MESSAGE="`VIDEO_TS` Folder missing from disk"
		;;
	5)
		MESSAGE="Handbrake encoding error"
		PREPARE_SCRIPT_EXIT
		;;
	6)
		MESSAGE="VOBCOPY error"
		PREPARE_SCRIPT_EXIT
		;;
	7)
		MESSAGE="Movie has been previously ripped"
		PREPARE_SCRIPT_EXIT
		;;
	*)
		MESSAGE="Unknown exit code"
		PREPARE_SCRIPT_EXIT
		;;
	esac

	echo "Exit Code: ${EXIT_CODE} (${MESSAGE})" >> $LOG_FILE
	echo "Exit Code: ${EXIT_CODE} (${MESSAGE})"
	exit "${EXIT_CODE}"
}

# Perform user check. Script must be run as root user
if [ "$(id -u)" != "0" ]; then
	SCRIPT_EXIT_CODE 2
fi

INFO "Starting DVD Auto Ripper v${AUTORIP_VERSION}"
INFO ""

# ---- Output File Settings ----  
MP4_DIR="/media/new_ripped"
MEDIA_LIBRARY="/media/Movies"

# ---- Lock File Settings ----
LOCK_FILE="/scripts/autorip.lock"

# ---- DVD Drive Settings ----
DVD_DIR="/cdrom/"
DVD_DEV="/dev/sr0" 

# Check to see if there is a lock file present?
if [ -f "${LOCK_FILE}" ]; then
	SCRIPT_EXIT_CODE 1
fi

# Sleep for 5 Seconds
sleep 5

# Create the log file
touch "${LOG_FILE}"

# Create the lock file
INFO "Creating lock file ..."
touch "${LOCK_FILE}"

# Attempt to Mount the DVD Drive
INFO "Mounting dvd drive ..."
 
mount | grep "${DVD_DIR}" >> "${LOG_FILE}" || mount "${DVD_DEV}" "${DVD_DIR}" >> "${LOG_FILE}"
if [ $? -ne 0 ]; then
   	# Drive could not be mounted!
	
	# Remove Lock File
	REMOVE_LOCK_FILE

	# Exit Script
   	SCRIPT_EXIT_CODE 3
fi

# Check to see if it is a Valid DVD
INFO "Verifying disk is a DVD ..."

if [ ! -d "${DVD_DIR}/VIDEO_TS" ]; then
   	# Disk in drive is not a DVD
	
	# Remove Lock File 	
	REMOVE_LOCK_FILE

	# Exit Script
	SCRIPT_EXIT_CODE 4
fi

# Get DVD Name
INFO "Getting dvd title ..."

DVD_FILE_NAME="$(vobcopy -I 2>&1 > /dev/stdout | grep DVD-name | sed -e 's/.*DVD-name: //')"
if [ -z "$DVD_FILE_NAME" ]; then
	# Error getting DVD Name
	ERROR "Failed to get dvd title!"
	# Exit Script
	SCRIPT_EXIT_CODE 6
fi

# Replace SPACES with UNDERSCORES ' ' -> '_'  
DVD_NAME="$(echo $DVD_FILE_NAME | tr ' ' '_')"

INFO ""
INFO "DVD Title: '${DVD_NAME}'"
INFO "Output filename is: ${DVD_NAME}.mp4"

INFO ""
INFO "Checking plex library for dvd ..."

# Check for existing copy in $MEDIA_LIBRARY...
FIND_MEDIA_LIBRARY=$(find "${MEDIA_LIBRARY}/" -maxdepth 1 -iname "${DVD_NAME}.mp4")
FIND_MP4_LIBRARY=$(find "${MP4_DIR}/" -maxdepth 1 -iname "${DVD_NAME}.mp4") 
if [ ! -z "$FIND_MEDIA_LIBRARY" ] ; then
	INFO "A existing copy was found in '${MEDIA_LIBRARY}/'"

	# Exit Script
	SCRIPT_EXIT_CODE 7 
fi

# Check for existing copy in $MP4_DIR...
if [ ! -z "$FIND_MP4_LIBRARY" ]; then
	INFO "A existing copy was found in '${MP4_DIR}/'" 

	# Exit Script
	SCRIPT_EXIT_CODE 7
fi


INFO "No existing copies found"

# Rip Movie with handbrake
INFO ""
INFO "Starting handbrake ..."
HandBrakeCLI -e x264 -q 20.0 -a 1,1 -E ffaac,copy:ac3 -B 160,160 -6 dpl2,none -R Auto,Auto -D 0.0,0.0 --audio-copy-mask aac,ac3,dtshd,dts,mp3 --audio-fallback ffac3 -f mp4 -4 --decomb --loose-anamorphic --modulus 2 -m --x264-preset veryfast --h264-profile main --h264-level 4.0 --native-language=eng -i "$DVD_DEV" -o "${MP4_DIR}/${DVD_NAME}.mp4" >> "${LOG_FILE}"
if [ $? -ne 0 ]; then
   	# encoding failed

	# Delete the movie, it encountered a error. it will not be complete.
	ERROR "Removing incomplete file -> ${DVD_NAME}.mp4"
	rm "${MP4_DIR}/${DVD_NAME}.mp4"

	# Exit Script
	SCRIPT_EXIT_CODE 5
fi

INFO ""
INFO "Checking file size ..."
minimumsize=900000000
actualsize=$(stat -c%s "${MP4_DIR}/${DVD_NAME}.mp4")
if [ $actualsize -ge $minimumsize ]; then
    	INFO "Moving '${DVD_NAME}.mp4' to '${MEDIA_LIBRARY}/'"

	# Move the movie to the library folder
	mv "${MP4_DIR}/${DVD_NAME}.mp4" "${MEDIA_LIBRARY}/${DVD_NAME}.mp4"

	INFO ""
	INFO "Rip Complete!"
	INFO ""
	INFO "Encoded to '${MEDIA_LIBRARY}/${DVD_NAME}.mp4'"
else
	ERROR "Movie size is less then 800mb."
	ERROR "Skipping file copy."
	ERROR ""
	ERROR "You must manually review the movie, then copy to"
	ERROR "  '${MEDIA_LIBRARY}/'"
	INFO ""
	INFO "Rip Complete!"
	INFO ""
	INFO "Encoded to '${MP4_DIR}/${DVD_NAME}.mp4'"
fi


# Script finished, Play `Finished` song... 
SCRIPT_FINISHED

# Exit the Script
SCRIPT_EXIT_CODE 0


