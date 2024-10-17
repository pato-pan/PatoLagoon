#!/bin/bash
echo "where there is a will, there is a bread. Always remember to share"
echo "Hey. Please remember to manually make a backup of the descriptions of the playlists" # I had a false scare before only to find out it's a browser issue, but I still don't trust google regardless.
# You might get some "folder does not exist" if blindly run. Mainly, create idlists folders and put cookies.txt in those folders.
idlists="~/Documents/idlists" # where all the lists of all downloaded ids are located.
exec &> >(tee "${idlists}/logs/yt-dlp $(date +"%Y-%m-%d %H%M%S").log") # Makes a log of the script while showing it in the terminal without colors. For terminal, do script "/path/to/idlists/logs/yt-dlp $(date +"%Y-%m-%d %H-%M-%S").log" -c "/path/to/yt-dlp-archiver.sh". For startup, xfce4-terminal -e "script '/path/to/idlists/logs/yt-dlp $(date +"%Y-%m-%d %H-%M-%S").log' -c '/path/to/yt-dlp-archiver.sh'"
nameformat="%(title)s - %(uploader)s [%(id)s].%(ext)s"
Music="~/Music"
Videos="~/Videos"
ytlist="https://www.youtube.com/playlist?list="
ytcreator="https://www.youtube.com/channel/"
default='--cookies cookies.txt --embed-metadata --embed-thumbnail --embed-chapters --sub-langs all,-live_chat,-rechat -c'
besta='-x -f ba --audio-format best --audio-quality 0'
bestmp3='-x -f ba --audio-format mp3 --audio-quality 0'
audiolite='-x --audio-format aac --audio-quality 64k'
bestv=''
v1080p='-f bv*[height<=1080]+ba/b[height<=1080]'
v720p='-f bv*[height<=720]+ba/b[height<=720]'
v480p='-f bv*[height<=480]+ba/b[height<=480]'
v360p='-f bv*[height<=360]+ba/b[height<=360]'
frugal='-S +size,+br,+res,+fps --audio-format aac --audio-quality 32k' #note to self: don't use -f "wv*[height<=240]+wa*"
thumbnailer='--force-write-archive --cookies cookies.txt --skip-download --write-thumbnail'
websites="youtube |soundcloud "
logscleaner="WARNING\: \[.*|ERROR\: \[|\]|.*\/.*|\:.*|.*Sign in to confirm your age\. This video may be inappropriate for some users\..*|.*This content isn't available, try again later\..*" # removed from yt-dlp logs obtained by findremoved. Output should be "youtube [id]"
#convset='-n -c:v copy -c:a flac --compression-level 12' # better quality, significantly higher filesize
convset='-n -c:v copy -c:a aac'
#prevents your account from getting unavailable on all videos when you use cookies.txt, even when watching videos. This is not foolproof, and it's not necessary in many cases. Recommended when making giant downloads (200+ requests in my experience)
#antiban='--sleep-requests 1.5 --min-sleep-interval 60 --max-sleep-interval 90' # Depending on many videos you have to download, this is safer but it can take much longer.
antiban='--sleep-requests 0.5 --min-sleep-interval 3 --max-sleep-interval 20' # My version, much faster, higher risk. Based on my usual timeouts.
#antiban=''

# These functions will run after you finish downloading all the files in a parent directory.
function findremoved() {
	echo "Detecting deleted videos, to link them to another folder"
	# rate limits won't break this. You don't need cookies. $antiban is optional if you are concerned about ip ban.
	local parent="$1"
	local target="$2"
	local archive="$3"
	local tracking="$4"
	rm "${idlists}"/offline.txt; rm "${idlists}"/found.txt
	if [ $tracking ]; then
 		# Antiban is not necessary since the error won't interfere. It's only here to play it safe. I suggest you take the risk and remove it since it will take so much longer with antiban.
		yt-dlp ${antiban} -s ${target} 2>&1 >/dev/null | perl -pe "s/(${logscleaner})//g" | sed -r '/^\s*$/d' | tee offline.txt # detector of deleted videos. To get full logs, which also serves as a progress bar, replace "2>&1 >/dev/null" with "2> >(tee >(cat 1>&2) pipes)". Full logs are the same as download, so they are limited by default. Warbo stackoverflow 45798436
		found=$(comm -1 -2 <(sort "${archive}") <(sort offline.txt)); echo "$found" > found.txt # Gets only the deleted files that had been downloaded previously. This is unnecessary, and it only reduces the amount of commands, the log size(arguably), and it insignificantly decreases time.
	else
 		# Antiban is not necessary because it's only a few requests.
		yt-dlp --download-archive offline.txt --force-write-archive --flat-playlist -s ${target} >/dev/null 2>&1 # lists every video the channel has. To get full logs, which also serves as a progress bar, remove >/dev/null 2>&1. There's no logs by default because this is similar to your download command.
		found=$(comm -2 -3 <(sort "${archive}") <(sort offline.txt)); echo "$found" > found.txt # if a video is not on the channel, but you have it downloaded, it's assumed that it has been removed.
	fi
	sed -i -r "s/(${websites})//g" found.txt
	for gone in $(cat found.txt); do if ! grep -Exq "${parent}/preserving/.* \[$gone\]\..*" "${idlists}"/foundremoved.txt; then # If user deletes a file from folder, it won't be recopied. This is optional, feel free to remove or disable.
		if ( [ -f "${parent}"/*$gone* ] || [ -f "${parent}"/thumbs/*$gone* ] ) && [[ $direxists != true ]]; then mkdir -p "${parent}"/preserving/thumbs; local direxists=true; fi # creates folder only if you have a removed file. This is a good notification, and the if is necessary to prevent spam.
		cp -vs "${parent}"/*"$gone"* "${parent}"/preserving/
		cp -vs "${parent}"/thumbs/*"$gone"* "${parent}"/preserving/thumbs
		find "${parent}"/preserving/ -name "*$gone*" >> "${idlists}"/foundremoved.txt 
	fi; done
	mv -vf "${idlists}"/offline.txt "${parent}"/preserving/ # full list
	mv -vf "${idlists}"/found.txt "${parent}"/preserving/ # what you are preserving
}
function frugalizer() { # provides a video of much lower filesize than remnant.
	local parent="$1"
	echo "compressing videos even further"
	mkdir "${parent}"/temp
 	for f in "${parent}"/*.*; do
  		filename=${f##*\/} # removes everything before the last / to get the filename.
		if grep -Fxq "$f" "${idlists}"/frugal.txt; then # checks if the file has already been converted
			:
		else
			if ffmpeg -hwaccel cuda -i "$f" -y "${frugal}" "${parent}"/temp/"${filename}"; then echo "$f" >> "${idlists}"/frugal.txt; fi; # adds to archive only if the previous command was successful. Equivalent to yt-dlp's download archive. Prevents recompressing files that were already compressed.
		fi
 	done
 	mv -vf "${parent}"/temp/* "${parent}"/
	rm -r "${parent}"/temp
}
function conveac3() {
	local parent="$1"
 	local archive="$2"
 	for f in "${parent}"/*.m4a; do
  		if [[ $(ffprobe -v error -select_streams a:0 -of csv=p=0 -show_entries stream=codec_name "$f" | awk -F, '{print $1}') == "eac3" ]]; then # checks if video is eac3
			id=${f%]*} # removes everything after the last ]
   			id=${id##*[} # removes everything before the last [
      			if grep -Fxq "$f" "${idlists}"/conveac3.txt; then # checks if the file has already been converted with dedicated archive. This is better because yt-dlp archives won't account for ffmpeg failing. I also don't know how yt-dlp works, it's less predictable.
				echo "$f has already been converted"
    			else
       				mkdir "${parent}"/compat
	   			name="${parent}/compat/${f##*/}"
       				# left overs from yt-dlp errors. Always the case when --embed-metadata is used on a eac3 codec.
	   			rm "${f%%.*}.temp.m4a"
				rm "${f%%.*}.webp"
				yt-dlp --download-archive ${archive} --cookies cookies.txt --force-overwrites --embed-thumbnail --embed-chapters --sub-langs all,-live_chat,-rechat -c ${besta} $id -o "${parent}/${nameformat}"
				success=$?
       				#ffmpeg -i "$f" ${convset} "${nemu%.m4a}".flac
				ffmpeg -i "$f" ${convset} "${nemu%.m4a}".m4a #I know adding m4a here is redundant. It should only be $f instead. This is only here for consistency.
    				if [ "$(($success+$?))" -eq 0 ]; then echo "$f" >> "${idlists}"/conveac3.txt; fi; # adds to archive only if the previous command was successful. Equivalent to yt-dlp's download archive. Necessary because in yt-dlp you can't specify the directory of the download archive without cd'ing into it, and I don't want to redownload the files every time the script is run.
					#if [ -z arkif ]; then echo -e "\nyoutube $id" | tee -a *.txt; for f in *.txt; do sort -uo $f $f; sed -i '/^\s*$/d' $f; done; fi; # Partially tested, might not work. [IMPORTANT: cookies can't have the txt extension] If arkif is for a group of archives (no archive is provided), it adds the ids to all the archives in the current folder. If a video is added to a playlist but is already part of another playlist in the group of archives, it won't be added again. I think this makes it not worth using, I don't recommend it, but you can use it if you wish. For now, I suggest changing your yt-dlp command so it ignores the files that had been converted, this is safer
    			fi
		fi
	done
	if [[ $parentdone != true ]]; then local parentdone=true; # Prevents an infinite loop, this part only runs once. Necessary when the function will call itself.
		for folder in "${parent}"/*; do if [ -d "$folder" ]; then conveac3 "$folder" "${archive}"; fi; done # recursively runs the conversion in every subfolder
	fi
}

cd "${idlists}"
#yt-dlp -U
# --no-check-certificate
#read -n 1 -t 30 -s
echo downloading MyMusic Playlist
read -n 1 -t 3 -s
yt-dlp ${antiban} --download-archive mymusic.txt --yes-playlist ${default} ${besta} "${ytlist}PLmxPrb5Gys4cSHD1c9XtiAHO3FCqsr1OP" -o "${Music}/YT/${nameformat}"
echo "Creating compatibility for eac3"; conveac3 "${Music}/YT" mymusic.txt
findremoved "${Music}/YT" "${ytlist}PLmxPrb5Gys4cSHD1c9XtiAHO3FCqsr1OP" mymusic.txt true
echo downloading Gaming Music
yt-dlp ${antiban} --download-archive gamingmusic.txt --yes-playlist ${default} ${besta} "${ytlist}PL00nN9ot3iD8DbeEIvGNml5A9aAOkXaIt" "${ytlist}PLbk0w-b2PpkdWRITIHO9AnNRaXTTxsKSK" -o "${Music}/YTGaming/${nameformat}"
echo "Creating compatibility for eac3"; conveac3 "${Music}/YTGaming" gamingmusic.txt
findremoved "${Music}/YTGaming" "${ytlist}PL00nN9ot3iD8DbeEIvGNml5A9aAOkXaIt" gamingmusic.txt true
echo "finished the music!"
read -n 1 -t 3 -s

# ////////////////////////////////////////////////

## add songs that you got outside of youtube after --reject-title. No commas, just space and ""

echo downloading some collections
read -n 1 -t 3 -s
echo funny videos from reddit
read -n 1 -t 3 -s
yt-dlp ${antiban} --download-archive funnyreddit.txt --yes-playlist ${default} ${bestv} "${ytlist}PL3hSzXlZKYpM8XhxS0v7v4SB2aWLeCcUj" -o "${Videos}/funnyreddit/${nameformat}"
findremoved "${Videos}/funnyreddit" "${ytlist}PL3hSzXlZKYpM8XhxS0v7v4SB2aWLeCcUj" funnyreddit.txt true
echo Dance practice
read -n 1 -t 3 -s
yt-dlp ${antiban} --download-archive dancepractice.txt --yes-playlist ${default} ${bestv} "${ytlist}PL1F2E2EF37B160E82" -o "${Videos}/Dance Practice/${nameformat}"
findremoved "${Videos}/Dance Practice" "${ytlist}PL1F2E2EF37B160E82" dancepractice.txt true
echo Soundux Soundboard
read -n 1 -t 3 -s
yt-dlp ${antiban} --download-archive soundboard.txt --yes-playlist ${default} ${bestmp3} "${ytlist}PLVOrGcOh_6kXwPvLDl-Jke3iq3j9JQDPB" -o "${Music}/soundboard/${nameformat}"
findremoved "${Music}/soundboard" "${ytlist}PLVOrGcOh_6kXwPvLDl-Jke3iq3j9JQDPB" soundboard.txt true
echo Videos to send as a message
read -n 1 -t 3 -s
yt-dlp ${antiban} --download-archive fweapons.txt ${default} ${bestv} --recode-video mp4 "${ytlist}PLE3oUPGlbxnK516pl4i256e4Nx4j2qL2c" -o "${Videos}/forumweapons/${nameformat}" #alternatively -S ext:mp4:m4a or -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b"
findremoved "${Videos}/forumweapons" "${ytlist}PLE3oUPGlbxnK516pl4i256e4Nx4j2qL2c" fweapons.txt true
echo Podcast Episodes
read -n 1 -t 3 -s
yt-dlp ${antiban} --download-archive podcast.txt ${default} ${audiolite} "${ytlist}PLJkXhqcWoCzL-p07DJh_f7JHQBFTVIg-o" -o "${Music}/Podcasts/${nameformat}"
findremoved "${Music}/Podcasts" "${ytlist}PLJkXhqcWoCzL-p07DJh_f7JHQBFTVIg-o" podcast.txt true

echo "archiving playlists"
cd "${idlists}"/YTArchive/
echo "liked videos, requires cookies.txt"
yt-dlp ${antiban} --download-archive likes.txt --yes-playlist ${default} ${frugal} "${ytlist}LL" -o "${Videos}/Archives/Liked Videos/${nameformat}"
findremoved "${Videos}/Archives/Liked Videos" "--cookies cookies.txt ${ytlist}LL" likes.txt true
echo "Will it? by Good Mythical Morning"
yt-dlp ${antiban} --download-archive willit.txt --yes-playlist ${default} ${v480p} "${ytlist}PLJ49NV73ttrucP6jJ1gjSqHmhlmvkdZuf" -o "${Videos}/Archives/Will it - Good Mythical Morning/${nameformat}"
findremoved "${Videos}/Archives/Will it - Good Mythical Morning" "${ytlist}PLJ49NV73ttrucP6jJ1gjSqHmhlmvkdZuf" willit.txt true

echo "archiving channels"
echo "HealthyGamerGG"
yt-dlp ${antiban} --download-archive HealthyGamerGG.txt --match-filter '!is_live & !was_live & is_live != true & was_live != true & live_status != was_live & live_status != is_live & live_status != post_live & live_status != is_upcoming & original_url!*=/shorts/ & title ~= (?i)@|w/|ft.|interviews & view_count >=? 60000' --dateafter 20200221 ${default} ${frugal} "${ytcreator}UClHVl2N3jPEbkNJVx-ItQIQ/videos" -o "${Videos}/Archives/HealthyGamerGG/${nameformat}"
frugalizer "${Videos}/Archives/HealthyGamerGG"
findremoved "${Videos}/Archives/HealthyGamerGG" "${ytlist}UClHVl2N3jPEbkNJVx-ItQIQ" HealthyGamerGG.txt
echo "Veritasium"
yt-dlp ${antiban} --download-archive veritasium.txt --match-filter '!is_live & !was_live & is_live != true & was_live != true & live_status != was_live & live_status != is_live & live_status != post_live & live_status != is_upcoming & view_count >=? 1000000' ${default} ${frugal} "${ytcreator}UCHnyfMqiRRG1u-2MsSQLbXA" -o "${Videos}/Archives/veritasium/${nameformat}"
findremoved "${Videos}/Archives/veritasium" "${ytlist}UCHnyfMqiRRG1u-2MsSQLbXA" veritasium.txt
echo "JCS"
yt-dlp ${antiban} --download-archive JCS.txt --match-filter '!is_live & !was_live & is_live != true & was_live != true & live_status != was_live & live_status != is_live & live_status != post_live & live_status != is_upcoming' ${default} ${v480p} "${ytcreator}UCYwVxWpjeKFWwu8TML-Te9A" -o "${Videos}/Archives/JCS/${nameformat}"
findremoved "${Videos}/Archives/JCS" "${ytlist}UCYwVxWpjeKFWwu8TML-Te9A" JCS.txt
echo "Creating compatibility for eac3"; conveac3 "$Show/Videos/Archives"

echo "it's done!"
read -n 1 -t 30 -s
exit

# echo collect thumbnails. Currently, no nice and short way to do it without doubling the amount of lines in your script. Here's the command I use which I include at the bottom of my script, I also included that I prefer to run reper here, since that prioritizes the downloads
cd "${idlists}"/thumbs
yt-dlp ${antiban} --download-archive likes.txt ${thumbnailer} "${ytlist}LL" -o "${Videos}/Archives/Liked Videos/thumbs/${nameformat}"
findremoved "${Videos}/Archives/Liked Videos" "--cookies cookies.txt ${ytlist}LL" likes.txt true
yt-dlp ${antiban} --download-archive HealthyGamerGG.txt ${thumbnailer} "${ytcreator}UClHVl2N3jPEbkNJVx-ItQIQ/videos" -o "${Videos}/Archives/HealthyGamerGG/thumbs/${nameformat}"
findremoved "${Videos}/Archives/HealthyGamerGG" "${ytlist}UClHVl2N3jPEbkNJVx-ItQIQ" HealthyGamerGG.txt
# (not used, untested) --match-filter "duration < 3600" exclude videos that are over one hour
# (not used, untested) --match-filter "duration > 120" exclude videos that are under 2 minutes
