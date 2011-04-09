#!/bin/bash
# Dumb Terminal BRencoder ( Blu-ray encoder )
# Transcoder/Encoder of blu-ray m2ts files - Linux/Bash
VER="0.3"
# by: MikereDD
#
# This script uses 
# MPlayer/Mencoder - http://www.mplayerhq.hu/
# X264             - http://www.videolan.org/developers/x264.html
# MKVToolNix       - http://www.bunkus.org/videotools/mkvtoolnix/index.html
# MediaInfo        - http://mediainfo.sourceforge.net
# tsMuxeR          - http://www.smlabs.net/tsmuxer_en.html
#

# Working Folder Paths
# Rip Folder - The working rip folder Main
#RIP="$HOME/Rip"
RIP="$HOME/Rip"
# M2TS Folder - this is where you will put the *.m2ts file you want to encode.
M2TS="m2ts"
# Meta files are dumped here.
META="meta"
# Raw264 Folder - this is where your encoded m2ts file ends up as a *.264
RAW264="raw264"
# Audio files dumped here.
AUDIO="audio"
# Raw 264 files are dumped here.
VIDEO="raw264"
# Text files are dumped here.
TEXT="txt"
# Subtitles are dumped here
SUBTITLE="subtitles"
# Finished files are dumped here.
DONE="done"
# Sample files are dumped here.
SAMPLE="sample"
# NFO files are dumped here.
NFO="nfo"

# Applications
# path to mplayer
MPLAYER="/usr/bin/mplayer"
# path to mencoder
MENCODER="/usr/bin/mencoder"
# path to a52dec
A52DEC="/usr/bin/a52dec"
# path to faac
FAAC="/usr/bin/faac"
# path to mkvmerge
MKVMERGE="/usr/bin/mkvmerge"
# path to mkvinfo
MKVINFO="/usr/bin/mkvinfo"
# path to mediainfo
MEDIAINFO="/usr/bin/mediainfo"
# path to tsmuxer
TSMUXER="/opt/tsMuxeR/tsMuxeR"

# My Scripts
# miNfo - http://github.com/MikereDD/funscripts/tree/master/miNfo/
# add path to MI-NFOcreate.sh
MINFOC="$HOME/apps/miNfo/mi-nfocreate.sh"
# add path to iMBD-Dump.sh
IMDBDUMP="$HOME/apps/miNfo/imdb-dump.sh"
# add path to iMDB-thumbgrab.sh
IMDBTGRAB="$HOME/apps/miNfo/imdb-thumbgrab.sh"

# Start Loop
while true
do
# BRenc Get Info
getinfo ()
{
    echo "BREncoder V. $VER"
    echo "Dumping M2TS Info"
    echo "------------------"
    echo ""
    $MEDIAINFO $RIP/$M2TS/*
}

# BRenc Extract Audio
xaudio ()
{
    echo "BREncoder V. $VER"
    echo ""
    echo "Listing Tracks"
    echo " Please choice the Audio Track ID:"
    echo " You want to extract."
    echo "------------------"
    sleep 2
    $TSMUXER $RIP/$M2TS/*.m2ts > $RIP/$META/tsmuxerdump.txt
    cat $RIP/$META/tsmuxerdump.txt
    echo ""
    echo "------------------"
    echo "Enter the Track ID: Number"
    echo "------------------"
    read AID
        echo "------------------"
        echo "You Entered..."
        echo "Track ID: $AID"
        echo "------------------"
        Y="$(cat -n $RIP/$META/tsmuxerdump.txt | grep "$AID" | awk '{print $1}')"
        Z="$(($Y + 2))"
        echo ""
        echo "Info for Track"
        echo ""
        echo "------------------"
        cat $RIP/$META/tsmuxerdump.txt | head -$Z | tail -3 | awk '{printf $0}' > $RIP/$META/tsextracta.txt
        sed -e 's|Track ID:   ||g' -e 's|Stream type:||g' -e 's|Stream ID:  ||g' $RIP/$META/tsextracta.txt > $RIP/$META/extractb.txt
        MAKEMETA="$(cat $RIP/$META/extractb.txt | awk '{print $3}')"
        MAKEMETB="$(cat $RIP/$META/extractb.txt | awk '{print "track="$1}')"
        echo -e "$MAKEMETA, $RIP/$M2TS/movie.m2ts, $MAKEMETB" > $RIP/$META/movie.meta
        cat $RIP/$META/movie.meta
        echo "------------------"
        echo ""
        echo "Now Extracting Audio Track ID: $AID"
        $TSMUXER $RIP/$META/movie.meta $RIP/$AUDIO
        echo ""
        echo "------------------" 
        echo ""
        echo "Done Extracting Audio Track ID: $AID"
}
# BRenc Run Enc
encbr ()
{
    echo "BREncoder V. $VER"
    echo ""
    echo "----------------"
    echo "Auto Grabbing Crop Value"
#grab crop
    echo "----------------"
    sleep 1
    $MENCODER $RIP/$M2TS/movie.m2ts -oac lavc -ovc lavc -vf cropdetect -o /dev/null > $RIP/$TEXT/cropdetect.txt & PID=$!; sleep 15; kill "$PID"
    CROP="$(awk '/-vf/{crop=$9} END{sub(").","", crop); print crop}' $RIP/$TEXT/cropdetect.txt)"
    sleep 1
    echo "Done Grabbing Crop Value"
    echo -e "$CROP"
# Change Scale Value
    echo "----------------"
    sleep 1
    SCALE='scale=720:-2'
	echo " Enter Scale Value - Default is $SCALE, should be fine"
    echo "  need to scale down then add values like example "
    echo " Example: $SCALE  "
    echo " need help here? http://google.com"
    echo " Want to Change Scale Value? (Press y/n)"
    echo "----------------"
    read SCALE
    case $SCALE in
	y|yes)
          echo "Enter Scale Value"
          echo "----------------"
	   	read SCALE ;;
	n|no)
		SCALE='scale=720:-2' ;;
	*)
	echo "Error Valid Choices are y|n"
	exit 1 ;;
    esac
    echo ""
    echo "----------------"
# XOPS
############################
############################
##### X264 OPTS EXTRA  #####
############################
############################
#
    echo "What do you want to do?"
    echo "A) Good Quality"
    echo "B) High Quality"
    echo "C) Very High Quality"
    echo "D) Extreme High Quality"
    echo "E) Insane High Quality"
    echo "F) Near Lossless Quality"
    echo "G) Anime Good Quality"
    echo "H) Anime High Quality"
    echo " "
    echo "-------------------------"
    echo "Valid Choices are A,B,C,D,E,F,G,H,I,J"
    echo " Choice a Letter hit Enter"
    echo "-------------------------"
    read CHOICE

    case $CHOICE in
        A|a)
                echo "Choice was Good Quality"
                XOPS='frameref=3:mixed_refs:bframes=4:b_adapt=2:weight_b:direct_pred=auto:me=umh:me_range=16:subq=6:psy_rd=0.6,0.2:chroma_me:trellis=1:cabac:deblock:8x8dct:partitions=p8x8,b8x8,i8x8,i4x4:nofast_pskip:nodct_decimate:level_idc=41'
                ;;
        B|b)
                echo "Choice was High Quality"
                XOPS='frameref=4:mixed_refs:bframes=5:b_adapt=2:weight_b:direct_pred=auto:me=umh:me_range=24:subq=7:psy_rd=0.6,0.2:chroma_me:trellis=1:cabac:deblock:8x8dct:partitions=p8x8,b8x8,i8x8,i4x4:nofast_pskip:nodct_decimate:level_idc=41'
                ;;
        C|c) 
                echo "Choice was Very High Qaulity"
                XOPS='frameref=5:mixed_refs:bframes=6:b_adapt=2:weight_b:direct_pred=auto:me=umh:me_range=32:subq=8:psy_rd=0.6,0.2:chroma_me:trellis=1:cabac:deblock:8x8dct:partitions=p8x8,b8x8,i8x8,i4x4:nofast_pskip:nodct_decimate:level_idc=41'
                ;;
        D|d)
                echo "Choice was Extreme High Quality"
                XOPS='frameref=6:mixed_refs:bframes=7:b_adapt=2:weight_b:direct_pred=auto:me=esa:me_range=48:subq=9:psy_rd=0.6,0.2:chroma_me:trellis=1:cabac:deblock:8x8dct:partitions=p8x8,b8x8,i8x8,i4x4:nofast_pskip:nodct_decimate:level_idc=41'
                ;;
        E|e)
                echo "Choice was Insane High Quality"
                XOPS='frameref=16:mixed_refs:bframes=10:b_adapt=2:weight_b:direct_pred=auto:me=tesa:me_range=64:subq=9:psy_rd=0.6,0.2:chroma_me:trellis=2:cabac:deblock:8x8dct:partitions=all:nofast_pskip:nodct_decimate:level_idc=41'
                ;;
        F|f) 
                echo "Choice was Near Lossless Quality"
                XOPS='bitrate=crf=18:frameref=2:bframes=3:b_adapt=2:weight_b:subq=5:me=dia:direct_pred=spatial:partitions=p8x8,b8x8,i4x4:deblock:chroma_me:trellis=1:cabac:no8x8dct:fast_pskip:nodct_decimate:level_idc=41'
                ;;
        G|g)
                echo "Choice was Anime Good Quality"
                XOPS='frameref=8:mixed_refs:bframes=5:b_adapt=2:noweight_b:direct_pred=auto:me=hex:me_range=16:subq=6:psy_rd=0.0,0.0:aq_strength=0.5:chroma_me:trellis=1:cabac:deblock:8x8dct:partitions=p8x8,b8x8,i8x8,i4x4:nofast_pskip:nodct_decimate:level_idc=41'
                ;;
        H|h)
                echo "Choice was Anime High Quality"
                XOPS='frameref=10:mixed_refs:bframes=5:b_adapt=2:noweight_b:direct_pred=auto:me=umh:me_range=24:subq=7:psy_rd=0.0,0.0:aq_strength=0.5:chroma_me:trellis=1:cabac:deblock:8x8dct:partitions=p8x8,b8x8,i8x8,i4x4:nofast_pskip:nodct_decimate:level_idc=41'
                ;;
          *)
                echo "Valid Choices are A,B,C,D,E,F,G,H,I,J"
                exit 1
                ;;
        esac
    echo " "
# Change Bitrate
    BITRATE='3500'
    echo ""
    echo "----------------"
    echo " Bitrate Default: $BITRATE "
    echo "Use a Bitrate Calc. or Judge by Time "
    echo " 3500 will result in about 3.5G (Press y/n)"
    echo "----------------"
    read BITRATE
    case $BITRATE in
        y|yes)
            echo "Enter Bitrate:    "
            echo "----------------"
            read BITRATE ;;
        n|no)
		BITRATE='3500' ;;
    *)
        echo "Error Valid Choices are y|n"
        exit 1 ;;
esac
    echo ""
#
############################
############################
#####  END x264 OPTS   #####
############################
############################
#
    echo ""
    echo "----------------"
    echo "Encoding M2TS File"
    echo "----------------"
    echo ""
# Pass 1
    echo "Starting Encode Pass 1"
# Removed            -vf pullup,softskip,$CROP,$SCALE \
#    $MENCODER -v $RIP/$M2TS/movie.m2ts \
#                     -demuxer lavf -sws 9 -fps 100 \
#                     -vf yadif=1,mcdeint,softskip -ofps 23.976 \
#                     -oac pcm -ovc x264 -x264encopts  $XOPS:bitrate=$BITRATE:turbo=1:pass=1 \
#                     -o $RIP/$RAW264/encoded.264
   $MENCODER  -v $RIP/$M2TS/movie.m2ts \
                     -nosound \
                     -vf pullup,softskip,$CROP,$SCALE \
                     -ovc x264 -x264encopts $XOPS:bitrate=$BITRATE:turbo=1:pass=1 \
                     -of rawvideo \
                     -o $RIP/$RAW264/encoded.264
    echo "First Pass Done!..............."
    echo ""
# Pass 3
    echo "Starting Third Pass of Encode Before Second.. Sync Reasons!"
#    $MENCODER -v $RIP/$M2TS/movie.m2ts \
#                     -demuxer lavf -sws 9 -fps 100 \
#                     -vf yadif=1,mcdeint,softskip -ofps 23.976 \
#                     -oac pcm -ovc x264 -x264encopts  $XOPS:bitrate=$BITRATE:turbo=1:pass=3\
#                     -o $RIP/$RAW264/encoded.264
   $MENCODER  -v $RIP/$M2TS/movie.m2ts \
                      -nosound \
                      -vf pullup,softskip,$CROP,$SCALE \
                      -ovc x264 -x264encopts $XOPS:bitrate=$BITRATE:pass=3 \
                      -of rawvideo \
                      -o $RIP/$RAW264/encoded.264

    echo "Third Pass Done............"
    echo ""
# Pass 2
    echo "Starting Second, Last Pass of Encode!"
#    $MENCODER -v $RIP/$M2TS/movie.m2ts \
#                     -demuxer lavf -sws 9 -fps 100 \
#                     -vf yadif=1,mcdeint,softskip -ofps 23.976 \
#                     -oac pcm -ovc x264 -x264encopts  $XOPS:bitrate=$BITRATE:turbo=1:pass=2\
#                     -o $RIP/$RAW264/encoded.264
   $MENCODER  -v $RIP/$M2TS/movie.m2ts \
                      -nosound \
                      -vf pullup,softskip,$CROP,$SCALE \
                      -ovc x264 -x264encopts $XOPS:bitrate=$BITRATE:pass=2 \
                      -of rawvideo \
                      -o $RIP/$RAW264/encoded.264

    echo "Second Pass is Last and is Done............"
    echo "----------------"
    echo "Done Encoding M2TS File"
    echo "----------------"
}

# BRenc Mux - Audio|Video to MKV
muxit ()
{
    echo "BREncoder V. $VER"
    echo "Muxing Audio and Video Files"
    cd $RIP/$DONE
    VIDEOFILE=$(ls $RIP/$RAW264/)
    VIDEOTOMUX="$RIP/$RAW264/$VIDEOFILE"
    AUDIOFILE=$(ls $RIP/$AUDIO/)
    AUDIOTOMUX="$RIP/$AUDIO/$AUDIOFILE"
#   echo "$VIDEOTOMUX"
#   echo "$AUDIOTOMUX" 
# FPS
    if [ -e $RIP/$TEXT/fps.txt ]; then
        rm $RIP/$TEXT/fps.txt
    fi
    $MEDIAINFO $VIDEOTOMUX | grep fps | cut -f 2 -d ":" | cut -f 1 -d "f" | tr -d " " | tail -1 > $RIP/$TEXT/fps.txt
    MKVFPS="$(cat $RIP/$TEXT/fps.txt)"
    if [ $MKVFPS = "29.970" ]; then
        MKVFPS="29.97fps"
    elif [ $MKVFPS = "25.000" ]; then
        MKVFPS="25fps"
    elif [ $MKVFPS = "24.000" ]; then
        MKVFPS="24fps"
    elif [ $MKVFPS = "23.976" ]; then
        MKVFPS="23.976fps"
    fi
    echo " FPS FOUND: $MKVFPS"
    echo ""
    echo "------------------"
    echo "What Language is the Audio File?"
    echo "Use  mkvmerge --list-languages"
    echo " to get an understanding of how to enter language"
    echo "Examples: English=eng French=fre Italian=ita Spanish=spa"
    echo "Enter The Language Now."
    echo "------------------"
    read LANGUAGE
    echo ""
    echo "------------------"
    echo " Enter a Title name for your Finished Movie File"
    echo "------------------"
    read TITLE
    echo ""
    echo "------------------"
    echo " You Entered.."
    echo " Language: $LANGUAGE"
    echo " Title: $TITLE"
    echo " Now Muxing Audio|Video"
    echo ""
# Dimensions
    X="$(mediainfo $VIDEOTOMUX | grep -w Width | sed 's/[A-Za-z]*//g' | cut -f 2 -d ":" | sed 's| ||g')"
    Y="$(mediainfo $VIDEOTOMUX | grep -w Height | sed 's/[A-Za-z]*//g' | cut -f 2 -d ":" | sed 's| ||g')"
    DIMENSIONS=""$X"x"$Y""
    echo " Video File: $VIDEOTOMUX"
    echo " Audio File: $AUDIOTOMUX"
    echo " Video Dimensions: $DIMENSIONS"
 # Merge files
#    echo -e "mkvmerge -o "$TITLE.mkv" --language 0:"$LANGUAGE" "$AUDIOTOMUX" --default-duration 0:"$MKVFPS" "$VIDEOTOMUX""
    mkvmerge --title "$TITLE" --default-language $LANGUAGE -o $TITLE.mkv --default-duration 0:$MKVFPS --display-dimensions 0:"$X"x"$Y" --noaudio $VIDEOTOMUX --language 0:$LANGUAGE $AUDIOTOMUX
    echo ""
    echo " Done Muxing your file.."
    echo " $RIP/$DONE/$TITLE.mkv is ready for viewing"
    echo ""
}

# BRenc Create Sample File
csample ()
{
# Split Sample with mkvmerge - 3 files made use second file
# mkvmerge --split timecodes:00:10:00,00:11:00 --split-max-files 3 file.mkv -o file-sample.mkv
    echo "BREncoder V. $VER"
    echo "Creating Sample File"
    TITLE="$(ls $RIP/$DONE/)"
    mkvmerge --split timecodes:00:10:00,00:11:00 --split-max-files 3 $RIP/$DONE/$TITLE -o $RIP/$SAMPLE/SAMPLE-$TITLE
    echo ""
    rm $RIP/$SAMPLE/*-001.mkv $RIP/$SAMPLE/*-003.mkv
    mv $RIP/$SAMPLE/*-002.mkv $RIP/$SAMPLE/SAMPLE-$TITLE
    echo "Sample File Created: $RIP/$SAMPLE/SAMPLE-$TITLE"
}

# BRenc Create NFO
cnfo ()
{
    echo "BREncoder V. $VER"
    echo "Let's Create an NFO File"
    $MINFOC
}

# Quit App
quit ()
{
    echo "!!!!!!!!!!!!!!!!!!"
    echo " OK.. Bye Now.."
    echo " Thanx for Using.."
    echo "BRencoder V. $VER"
    echo "!!!!!!!!!!!!!!!!!!"
    exit 0
}

# BR Start
echo "BREncoder V. $VER"
sleep 1 
echo ""
echo " A) Dump M2TS Info"
echo " B) Extract Audio from M2TS File"
echo " C) Encode M2TS File"
echo " D) Mux Audio - Video to .mkv"
echo " E) Create Sample File"
echo " F) Create NFO File"
echo " Q) Quit BRencoder"
echo "-----------------------------------"

read CHOICE
       case $CHOICE in
           "a" ) getinfo ;;
           "b" ) xaudio ;;
           "c" ) encbr ;;
           "d" ) muxit ;;
           "e" ) csample ;;
           "f" ) cnfo ;;
           "q" ) quit ;;
             *)
                 echo "Error ... Valid Choices are A, B, C, D, E, Q"
                 exit 1 ;;
         esac
# End Loop
done
