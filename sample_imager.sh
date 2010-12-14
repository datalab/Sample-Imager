#!/bin/bash

#Set the colors for the script's output.
color="\e[32;40m"
endColor="\e[0m"

#Define the functions for use in the script.

#Capture the desired output directory.
function capture_dest_dir {
  USER_CAPTURE="false"
  while [[ $USER_CAPTURE == "false" ]]; do
    #Prompt to enter the directory.
    echo -e "Enter the filepath to the directory you want to save the files in. [ENTER] for current directory:"
    read -p ">> " USER_DEST_PATH
    #Process the path.
    if [[ $USER_DEST_PATH == "" ]]; then
      DEST_PATH="$PWD"
      confirm_dest_dir
    #Alert the user if the path does not exist.
    elif [ ! -d "$USER_DEST_PATH" ]; then
      echo -e "\n\n\E[5mThat directory does not exist. You must save the files to an existing directory.\E[25m\n\n"
    else
      #Set the DEST_PATH variable.
      DEST_PATH="$USER_DEST_PATH"
      #Confirm the path with the user.
      confirm_dest_dir
    fi
  done
}

#Confirm the user's path.
function confirm_dest_dir {
  read -p "
You have chosen to download all files to \"$DEST_PATH\". Is this correct? (Y/n) "
  echo -e "\n"
  #Reset the USER_CAPTURE variable to return the user to the loop.
  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    USER_CAPTURE="true"
  fi
}

#Capture the user's desited size.
function capture_desired_size {
  SIZE_CHOSEN="none"
  #Define the sizes available from Flickr.
  size_options=( "1200px" "1024px" "640px" "500px" "240px" "100px" )
  while [[ $SIZE_CHOSEN == "none" ]]; do
    echo -e "Choose the size of the sample images you want to download [1-${#size_options[@]}]:\n"
    #output the choices.
    for (( i = 0 ; i < ${#size_options[@]} ; i++ )); do
      echo -e "$(($i + 1)) -> ${size_options[$i]}"
    done
    read -p ">> " SIZE_CHOICE
    #Tranlsate the choice to the SIZE_CHOSEN variable.
    for (( i = 0 ; i < ${#size_options[@]} ; i++ )); do
      if [[ $SIZE_CHOICE == $(($i + 1)) ]]; then
        SIZE_CHOSEN=${size_options[$i]}
      fi
    done
    #Alert if the selection is not valid.
    if [[ $SIZE_CHOSEN == "none" ]]; then
      echo -e "\n\E[5mThat does not appear to be a valid option.\E[25m\n"
      sleep 1.5
    else
      sleep .5
    fi
  done
}

#Capture the user's desired color.
function capture_desired_color {
  COLOR_CHOSEN="none"
  #define the color choices based on what is avialble from Flickr. That is to say that transparent images only appear as the original 1200px images.
  if [[ $SIZE_CHOSEN != "1200px" ]]; then
    color_options=( "grey" "color" "white" )
  else
    color_options=( "grey" "color" "transparent" )
  fi
  while [[ $COLOR_CHOSEN == "none" ]]; do
    echo -e "\nChoose the background type of sample images you want to download [1-${#color_options[@]}]:\n"
    #output the choices.
    for (( i = 0 ; i < ${#color_options[@]} ; i++ )); do
      echo -e "$(($i + 1)) -> ${color_options[$i]}"
    done
    read -p ">> " COLOR_CHOICE
    #Translate the choice to the COLOR_CHOSEN variable.
    for (( i = 0 ; i < ${#color_options[@]} ; i++ )); do
      if [[ $COLOR_CHOICE == $(($i + 1)) ]]; then
        COLOR_CHOSEN=${color_options[$i]}
      fi
    done
    #Alert if the selection is not valid.
    if [[ $COLOR_CHOSEN == "none" ]]; then
      echo -e "\n\E[5mThat does not appear to be a valid option.\E[25m\n"
      sleep 1.5
    else
      sleep .5
    fi
  done
}

#Capture the user's desired filetype.
function capture_desired_filetype {
  FILETYPE_CHOSEN="none"
  #If the user selected a size other than 1200px, then Flickr is only going to offer the filetype JPG, so reflect that in the FILETYPE_CHOSEN variable.
  if [[ $SIZE_CHOSEN != "1200px" ]]; then
    FILETYPE_CHOSEN="JPG"
  fi
  #define the filetype choices based on what is avialble from Flickr. That is to say that transparent images are only avialable as PNG or GIF.
  if [[ $COLOR_CHOSEN == "transparent" ]]; then
    filetype_options=( "PNG" "GIF" )
  else
    filetype_options=( "JPG" "PNG" "GIF" )
  fi
  while [[ $FILETYPE_CHOSEN == "none" ]]; do
    echo -e "\nChoose the file type of sample images you want to download [1-${#filetype_options[@]}]:\n"
    #output the choices.
    for (( i = 0 ; i < ${#filetype_options[@]} ; i++ )); do
      echo -e "$(($i + 1)) -> ${filetype_options[$i]}"
    done
    read -p ">> " FILETYPE_CHOICE
    #Translate the choice to the FILETYPE_CHOSEN variable.
    for (( i = 0 ; i < ${#filetype_options[@]} ; i++ )); do
      if [[ $FILETYPE_CHOICE == $(($i + 1)) ]]; then
        FILETYPE_CHOSEN=${filetype_options[$i]}
      fi
    done
    #Alert if the selection is not valid.
    if [[ $FILETYPE_CHOSEN == "none" ]]; then
      echo -e "\n\E[5mThat does not appear to be a valid option.\E[25m\n"
      sleep 1.5
    else
      sleep .5
    fi
  done
}

function review_desired_options {
  CONFIRM_OPTIONS="false"
  while [[ $CONFIRM_OPTIONS == "false" ]]; do
    #Assemble a statement that confirms the user's size, color, and filetype choices.
    echo -e "\nYou have chosen to download the \e[30;42m $COLOR_CHOSEN ${color} sample images at \e[30;42m $SIZE_CHOSEN ${color}, in a \e[30;42m $FILETYPE_CHOSEN ${color} format. Is this correct? (Y/n)"
    read -p ">> " CONFIRM_OPTIONS_ANSWER
    #If the user does not confirm the options, then the OPTIONS_COMPLETE variable is not set and the options loop starts again.
    if [[ $CONFIRM_OPTIONS_ANSWER =~ ^[Yy]$ ]]; then
      CONFIRM_OPTIONS="true"
      OPTIONS_COMPLETE="true"
    elif [[ $CONFIRM_OPTIONS_ANSWER =~ ^[Nn]$ ]]; then
      CONFIRM_OPTIONS="true"
    fi
  done
}

#Declare the set id, based on the user settings.
function get_desired_set_id {
  #Define the grey set ids.
  if [[ $COLOR_CHOSEN == "grey" ]] && [[ $FILETYPE_CHOSEN == "PNG" ]]; then
    SET_ID="72157625457869873"
  elif [[ $COLOR_CHOSEN == "grey" ]] && [[ $FILETYPE_CHOSEN == "GIF" ]]; then
    SET_ID="72157625472300785"
  elif [[ $COLOR_CHOSEN == "grey" ]] && [[ $FILETYPE_CHOSEN == "JPG" ]]; then
    SET_ID="72157625598067906"
  #Define the color set ids.
  elif [[ $COLOR_CHOSEN == "color" ]] && [[ $FILETYPE_CHOSEN == "PNG" ]]; then
    SET_ID="72157625457664947"
  elif [[ $COLOR_CHOSEN == "color" ]] && [[ $FILETYPE_CHOSEN == "GIF" ]]; then
    SET_ID="72157625597981356"
  elif [[ $COLOR_CHOSEN == "color" ]] && [[ $FILETYPE_CHOSEN == "JPG" ]]; then
    SET_ID="72157625472254329"
  #Define the transparent set ids.
  elif [[ $COLOR_CHOSEN == "transparent" ]] && [[ $FILETYPE_CHOSEN == "PNG" ]]; then
    SET_ID="72157625457282525"
  elif [[ $COLOR_CHOSEN == "transparent" ]] && [[ $FILETYPE_CHOSEN == "GIF" ]]; then
    SET_ID="72157625590130912"
  #Define the white set ids.
  elif [[ $COLOR_CHOSEN == "white" ]] && [[ $FILETYPE_CHOSEN == "JPG" ]]; then
    SET_ID="72157625464296579"
  #Fallback to an error.
  else
    echo -e "\n\E[5mCannot get the appropriate id for your selection, please try again later.\E[25m\E[0m\n"; exit 1
  fi
}

#download the sets images
function download_set_images {
  echo -e "\n"
  #Set up the faux progress bar.
  echo -en '=> '
  #Define the Constants
  TEMP_XML_FILE="$DEST_PATH/feed.xml" #The temporary file for the set's information
  TEMP_ENTRY_XML_FILE="$DEST_PATH/entry.xml" #The temporary file for an entry's information
  API_KEY="ff0582dcd0737a86ed66c1339b4d5b4e" #This is the Flickr API key for datalab
  get_size_abbrev #Convert the option size to the Flickr code shortcut for sizes
  URL_FILETYPE=$(echo $FILETYPE_CHOSEN | tr '[A-Z]' '[a-z]') #lower the filetype extension.
  #Add progress tick.
  add_progress_tick
  #WGET the set's xml file.
  XML_URL="http://api.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=$API_KEY&photoset_id=$SET_ID"
  wget "$XML_URL" -q -O "$TEMP_XML_FILE"
  #Test the XML file for flickr status validity. Look for the <rsp stat="ok"> tag that flickr adds
  if [ $(grep "<rsp stat=\"ok\">" "${TEMP_XML_FILE}" | wc -l) == 0 ]; then
    echo -e "\n\E[5mThat doesn't appear to be a valid Flickr feed. Please try again.\E[25m\E[0m\n"
    exit 1
  fi
  #count the total images.
  entry_count=$(grep "<photo id=" "${TEMP_XML_FILE}" | wc -l)
  #Parse each image.
  #for (( c=1; c<=4; c++ )); do #Limit to 10 for testing.
  for (( c=1; c<=$entry_count; c++ )); do
    #Add progress tick.
    add_progress_tick
    #Grab the entry information.
    photo_entry=$(grep -m $c "<photo id=" "${TEMP_XML_FILE}")
    #If the user is requesting the original, then we've got to parse extra information.
    if [[ $SIZE_CHOSEN == "1200px" ]]; then
      get_original_link
    else
      get_standard_link
    fi
    #WGET the appropriate url, and save it as the name of the image.
    entry_output_file="$title.$URL_FILETYPE"
    wget "$ENTRY_URL" -q -O "$DEST_PATH/$entry_output_file"
  done
  #Add completion message once all files have been downloaded
  echo -e "\n\nYour download is complete. Enjoy your images!\n"
}

function get_original_link {
  #Grab the entry's id and title.
  entry_id=$(echo $photo_entry | sed 's/.*id="//' |  sed 's/" secret=.*//')
  title=$(echo $photo_entry | sed 's/.*title="//' |  sed 's/" isprimary=.*//')
  #WGET the entry's xml file.
  size_xml_url="http://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=$API_KEY&photo_id=$entry_id"
  wget "$size_xml_url" -q -O "$TEMP_ENTRY_XML_FILE"
  #Test the XML file for flickr status validity. Look for the <rsp stat="ok"> tag that flickr adds
  if [ $(grep "<rsp stat=\"ok\">" "${TEMP_XML_FILE}" | wc -l) == 0 ]; then
    echo -e "\n\E[5mThat doesn't appear to be a valid Flickr feed. Please try again.\E[25m\E[0m\n"
    exit 1
  fi
  #Grab the original line.
  orig_line=$(grep -m $c "<size label=\"Original\"" "${TEMP_ENTRY_XML_FILE}")
  #extract the src of the original line.
  ENTRY_URL=$(echo $orig_line | sed 's/.*source="//' |  sed 's/" url=.*//')
  #remove the entry's temporary file.
  if [ -f "$TEMP_ENTRY_XML_FILE" ]; then
    rm "$TEMP_ENTRY_XML_FILE"
  fi
}

function get_standard_link {
  #parse the information about the entry from the XML file.
  farm=$(echo $photo_entry | sed 's/.*farm="//' |  sed 's/" title=.*//')
  server=$(echo $photo_entry | sed 's/.*server="//' |  sed 's/" farm=.*//')
  entry_id=$(echo $photo_entry | sed 's/.*id="//' |  sed 's/" secret=.*//')
  secret=$(echo $photo_entry | sed 's/.*secret="//' |  sed 's/" server=.*//')
  title=$(echo $photo_entry | sed 's/.*title="//' |  sed 's/" isprimary=.*//')
  #define the ENTRY_URL variable that will be used to download the standard image.
  ENTRY_URL="http://farm$farm.static.flickr.com/$server/"$entry_id"_"$secret$URL_SIZE"."$URL_FILETYPE
}

function get_size_abbrev {
  if [[ $SIZE_CHOSEN == "1200px" ]]; then
    URL_SIZE="_o" #Original
  elif [[ $SIZE_CHOSEN == "1024px" ]]; then
    URL_SIZE="_b" #Large
  elif [[ $SIZE_CHOSEN == "640px" ]]; then
    URL_SIZE="_z" #Medium
  elif [[ $SIZE_CHOSEN == "500px" ]]; then
    URL_SIZE="" #Medium
  elif [[ $SIZE_CHOSEN == "240px" ]]; then
    URL_SIZE="_m" #Small
  elif [[ $SIZE_CHOSEN == "100px" ]]; then
    URL_SIZE="_t" #Smallest
  else
    URL_SIZE="" #Default to MEdium 500px
  fi
}

function add_progress_tick {
  #The faux progress bar goes back 2 spaces, and adds a "=> "
  echo -en '\x08\x08=> '
}



#Without further ado...THE SCRIPT!

#Check user's machine for WGET. Exit if it is not present.
type -P wget &>/dev/null || { echo -e "\n##########################################################\n\E[5mYou must have wget installed to run this script. Aborting.\E[25m\n##########################################################\n" >&2; exit 1; }

#Display the welcome banner and give the instructions.
echo -e "$color"
echo -e "#########################
Welcome to Sample Imager!
#########################\n"
sleep 1
echo -e "This is a simple script that downloads sample images from dataLAB's \e[47;34m Flick\e[47;31mr ${color} account to your local machine using wget.\n"
echo -e "Before you begin downloading, you will need to provide certain details. Firstly, you will need tell me where to save the files. Secondly you will need to determine which of the sample images you wish to download.\n"
sleep 2

#Ask the user for the destination directory.
capture_dest_dir

#Ask the user to make choices about what they want to download.
OPTIONS_COMPLETE="FALSE"
while [[ $OPTIONS_COMPLETE == "FALSE" ]]; do
  #Ask the user what size image they want.
  capture_desired_size
  #Ask the user which color they want.
  capture_desired_color
  #Ask the user which file type they want.
  capture_desired_filetype
  #Review the user's options.
  review_desired_options
done

#Declare the set id for the desireed options.
get_desired_set_id

#Download images for specific set.
download_set_images

#Remove the temp XML File.
if [ -f "$TEMP_XML_FILE" ]; then
  rm "$TEMP_XML_FILE"
fi

#Add credits 
sleep 1
echo -e "\nIf this script or the sample images have been of use to you, let us know about it!"
echo -e "http://datalabprojects.com"
echo -e "http://flickr.com/photos/datalab"
echo -e "http://github.com/datalab"
echo -e "http://twitter.com/datalab"

#Return the colors to the default.
echo -e "$endColor"; alias Reset="tput sgr0"