#!/bin/sh
# gets a list of every tor server. With this list, it finds the location of each server, then tells you how many servers are in each country. It will also use a local database of already located ip addresses and use that to determine the location of the server.
# This is a modified and safer version of the script, more respectful of a website's terms.
# You should wait an hour or more before running this again, otherwise you will get the exact same result.
# Alternative https://gist.github.com/tomac4t/ad197629456759b1c708b4a0a563d371 it provides instructions to create your own as well at the bottom. I prefer this because it's entirely bash, no python, no creating virtual environments, nothing needs to be installed besides curl, grep, and wget, not trying to learn what mmdb is, all familiar, all simple, all lightweight, all available within your own machine, with a lot less to request to the internet (basically, only the torbulkexitlist once you have your own database). 

mv torcountries.txt "Utorcountries $(date +"%Y-%m-%d %H-%M").txt"
rm exits*
wget -q -N https://check.torproject.org/torbulkexitlist
split -nl/3 -a1 --numeric-suffixes=1 torbulkexitlist exits --additional-suffix=.txt
mv torbulkexitlist "torbulkexitlist $(date +"%Y-%m-%d %H-%M")"

for iplist in $(ls | grep exits); do
	for ip in $(cat $iplist); do
		if grep -q $ip torgeodb.txt; then
			grep $ip torgeodb.txt | cut -d " " -f1 >> torcountries.txt
		else
			statuscheck=$(curl 0 -s -o /dev/null -I -w %{http_code} https://ipinfo.io)
			while [[ $statuscheck -ne 200 ]]; do echo "Your ip is blocked or has made too many requests, waiting a whole day just so you can resume this script"; read -n 1 -t 90000; statuscheck=$(curl 0 -s -o /dev/null -I -w %{http_code} https://ipinfo.io); done
			CC=$(curl -s https://ipinfo.io/$ip/country)   
			echo $CC >> torcountries.txt
			echo $CC $ip >> torgeodb.txt
			read -n 1 -t 10
		fi
	done
done

sort torcountries.txt | uniq -c | awk '{ printf("%03d %s\n", $1, $2); }' | sort -ro torcountries.txt
mv torcountries.txt "torcountries $(date +"%Y-%m-%d %H-%M").txt"
#cp torgeodb.txt "torgeodb $(date +"%Y-%m-%d %H-%M").txt"
rm exits*
