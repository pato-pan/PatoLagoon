#!/bin/sh
# tor by default picks a server randomly based on just all the servers. Which means you are almost always being connected to a german, american, or netherlands server.
# This script modifies your torrc to make it so tor randomly picks a server based on location.
# It replaces any line that says "ExitNodes "
# It is required for the torrc file to have the word "ExitNodes "
# Bear in mind that in my experience, this causes you to lose connection more often since some countries only have a few servers. It is currently in the tweaking stages, where I try to determine which of countries with the least servers are too unstable to be considered for randomization. While I could remove some of the countries that have less servers, this reduces variety.
##My use case has nothing to do with Tor Browser, I use tor as a proxy. If your use case is concerned with fingerprinting or anonymity, don't do what I do.
# My use case is unbiased tracking. 1. By randomizing the information trackers receive, their ads, algorithmns, and other systems will have more varied suggestions and I will be treated in a very inconsistent and indiscriminate, unpersonalized manner. 2. websites will not budge on saying you are from a specific country if you are connected to that same country very often or you registered your account while being in that country, this prevents that. It also serves for privacy. 1. if you can't afford a vpn, then tor is a very ineffective alternative that despite being easily bypassed when used as a proxy it's all you have. 2. For some privacy use cases the more obfuscation and bogus info the trackers have the better. 3. Some vpns don't have a lot of locations available, tor may have more 4. Using a vpn on your router makes changing servers regularly take between 5-10 minutes, with tor you can change it regularly and effortlessly. Same with your vpn if you use the app, but an app has drawbacks that led you to install it in the router instead (resource comsumption/battery usage, unsupported in some devices, more bloat in minimalistic environments, not available as a proxy, etc). As a bonus, some websites are a lot more likely to block a vpn's ip address than a tor ip address, this bonus is actually the main reason I started writing this script.

CC[0]="ExcludeExitNodes {DE},{US},{NL},{LU},{SE},{PL},{RO},{FR},{CH},{UA},{NO},{GB},{IS},{DK},{AT},{HU},{CZ},{BG},{MD},{CA},{SG},{IT},{FI},{HK},{ZA},{AU},{VN},{JP},{BR},{TW},{KR},{CY},{CR},{CL},{BE}" # Only picks the countries with the least servers. It does so by excluding the ones with the most servers.
CC[1]="ExitNodes {DE}"
CC[2]="ExitNodes {US}"
CC[3]="ExitNodes {NL}"
CC[4]="ExitNodes {LU}"
CC[5]="ExitNodes {SE}"
CC[6]="ExitNodes {PL}"
CC[7]="ExitNodes {RO}"
CC[8]="ExitNodes {FR}"
CC[9]="ExitNodes {CH}"
CC[10]="ExitNodes {UA}"
CC[11]="ExitNodes {NO}"
CC[12]="ExitNodes {GB}"
CC[13]="ExitNodes {IS}"
CC[14]="ExitNodes {DK}"
CC[15]="ExitNodes {AT}"
CC[16]="ExitNodes {HU}"
CC[17]="ExitNodes {CZ}"
CC[18]="ExitNodes {BG}"
CC[19]="ExitNodes {MD}"
CC[20]="ExitNodes {CA}"
CC[21]="ExitNodes {SG}"
CC[22]="ExitNodes {IT}"
CC[23]="ExitNodes {FI}"
CC[24]="ExitNodes {HK}"
CC[25]="ExitNodes {ZA}"
CC[26]="ExitNodes {AU}"
CC[27]="ExitNodes {VN}"
CC[28]="ExitNodes {JP}"
CC[29]="ExitNodes {BR}"
CC[30]="ExitNodes {TW}"
CC[31]="ExitNodes {KR}"
CC[32]="ExitNodes {CY}"
CC[33]="ExitNodes {CR}"
CC[34]="ExitNodes {CL}"
CC[35]="ExitNodes {BE}"


rand=$[ $RANDOM % 35 ]
echo ${CC[$rand]}
sed -i "/ExitNodes /c${CC[$rand]}" /etc/tor/torrc
systemctl restart tor
