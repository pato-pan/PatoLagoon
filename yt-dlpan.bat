@echo off

echo "where there is a will, there is a bread. Always remember to share"
echo "Hey. Please remember to manually make a backup of the descriptions of the playlists"
SET idlists=~\Documents\idlists
SET nameformat=%(title)s - %(uploader)s [%(id)s].%(ext)s
SET Music=~\Music
SET Videos=~\Videos
SET ytlist=https://www.youtube.com/playlist?list
SET ytcreator=https://www.youtube.com/channel/
SET default=--cookies cookies.txt --embed-metadata --embed-thumbnail --embed-chapters --sub-langs all,-live_chat,-rechat -c
SET besta=-x -f ba --audio-format best --audio-quality 0
SET bestmp3=-x -f ba --audio-format mp3 --audio-quality 0
SET audiolite=-x --audio-format aac --audio-quality 64k
SET bestv=
SET v1080p=-f bv*[height<
SET v720p=-f bv*[height<
SET v480p=-f bv*[height<
SET v360p=-f bv*[height<
SET frugal=-S +size,+br,+res,+fps --audio-format aac --audio-quality 32k
SET thumbnailer=--force-write-archive --cookies cookies.txt --skip-download --write-thumbnail
SET websites=youtube |soundcloud 
SET logscleaner=WARNING\: \[.*|ERROR\: \[|\]|.*\/.*|\:.*|.*Sign in to confirm your age\. This video may be inappropriate for some users\..*|.*This content isn't available, try again later\..*
SET convset=-n -c:v copy -c:a aac
SET antiban=--sleep-requests 0.5 --min-sleep-interval 3 --max-sleep-interval 20
