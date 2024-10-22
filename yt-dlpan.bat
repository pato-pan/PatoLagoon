@echo off
echo "where there is a will, there is a bread. Always remember to share"
echo "Hey. Please remember to manually make a backup of the descriptions of the playlists" :: I had a false scare before only to find out it's a browser issue, but I still don't trust google regardless.
:: You might get some "folder does not exist" if blindly run. Mainly, create idlists folders and put cookies.txt in those folders. Under idlists, the folders are YTArchive, logs, thumbs
set "idlists=%USERPROFILE%\Documents\idlists" :: where all the lists of all downloaded ids are located.
:: Missing logger code goes here.
set "Music=%USERPROFILE%\Music"
set "Videos=%USERPROFILE%\Videos"
set "ytlist=https://www.youtube.com/playlist?list="
set "ytcreator=https://www.youtube.com/channel/"
set "default=--cookies cookies.txt --embed-metadata --embed-thumbnail --embed-chapters --sub-langs all,-live_chat,-rechat -c"
set "besta=-x -f ba --audio-format best --audio-quality 0"
set "bestmp3=-x -f ba --audio-format mp3 --audio-quality 0"
set "audiolite=-x --audio-format aac --audio-quality 64k"
set "bestv="
set "v1080p=-f bv*[height^<=1080]+ba/b[height^<=1080]"
set "v720p=-f bv*[height^<=720]+ba/b[height^<=720]"
set "v480p=-f bv*[height^<=480]+ba/b[height^<=480]"
set "v360p=-f bv*[height^<=360]+ba/b[height^<=360]"
set "frugal=-S +size,+br,+res,+fps --audio-format aac --audio-quality 32k" :: note to self: don't use -f "wv*[height<=240]+wa*"
set "thumbnailer=--force-write-archive --cookies cookies.txt --skip-download --write-thumbnail"
:: set "thumbnailer=--force-write-archive --cookies cookies.txt --skip-download --write-thumbnail --write-description --write-info-json --write-playlist-metafiles --write-link --sub-langs all --write-subs"
set "websites=youtube^|soundcloud "
set "logscleaner=WARNING:^[.*^|ERROR:^[.*^|.*^/.*^|:.*^|.*Sign in to confirm your age\. This video may be inappropriate for some users\..*^|.*This content isn't available, try again later\..*" :: removed from yt-dlp logs obtained by findremoved. Output should be "youtube [id]"
:: set "convset=-n -c:v copy -c:a flac --compression-level 12" :: better quality, significantly higher filesize
set "convset=-n -c:v copy -c:a aac"
:: prevents your account from getting unavailable on all videos when you use cookies.txt, even when watching videos. This is not foolproof, and it's not necessary in many cases. Recommended when making giant downloads (200+ requests in my experience)
:: set "antiban=--sleep-requests 1.5 --min-sleep-interval 60 --max-sleep-interval 90"
set "antiban=--sleep-requests 0.5 --min-sleep-interval 3 --max-sleep-interval 20"
:: set "antiban="

:: These functions will run after you finish downloading all the files in a parent directory.
:findremoved
setlocal enableextensions disabledelayedexpansion
:: Currently set to skip if it was last run less than 3 months old. Necessary since this makes too many requests and takes too much time. This can only be calculated in days if you want to change this.
for /f %%i in ('powershell -command "([DateTime]::Now - (Get-Item '%idlists%\found.txt').LastWriteTime).TotalDays"') do set /a lastcheck=%%i
if %lastcheck% GEQ 90 (
    echo Not checking for deleted videos because the last check was too recent
) else (
    echo Detecting deleted videos, to link them to another folder
    :: rate limits won't break this. You don't need cookies. $antiban is optional if you are concerned about a harsher ban.
    set "parent=%~1"
    set "target=%~2"
    set "archive=%~3"
    set "tracking=%~4"
    del "%idlists%\offline.txt"
    del "%idlists%\found.txt"
	if defined tracking (
		yt-dlp %antiban% -s %target% 2>&1 >nul | perl -pe "s/(%logscleaner%)//g" | findstr /v /r "^$" > offline.txt
		set /p found=<offline.txt
) else
		yt-dlp --download-archive offline.txt --force-write-archive --flat-playlist -s %target% >nul 2>&1
		set /p found=<offline.txt
)
	echo %found% > found.txt
	find /i "%websites%" offline.txt > nul
	for /f "tokens=*" %%a in (found.txt) do (
	    if not exist "%parent%\preserving\%%a" (
			mkdir "%parent%\preserving\thumbs"
			xcopy /y "%parent%\*" "%parent%\preserving\*"
			xcopy /y "%parent%\thumbs\*" "%parent%\preserving\thumbs\"
			echo %%a >> %idlists%\foundremoved.txt
	    )
	)
	move /y "%idlists%\offline.txt" "%parent%\preserving\"
	move /y "%idlists%\found.txt" "%parent%\preserving\"
)

echo "it's done!"
timeout 30
exit
