#!/bin/ksh

function getCurrentMirrorList {
	echo "[*] Pobieranie listy serwerow lustrzanych z oficjalnej strony";
	ftp -o mirrorList.html https://openbsd.org/ftp.html

}

function checkMirrorList {

	echo "[*] Wybieranie najlepszego serwera lustrzanego bazujac na ping";
	
	address=$(cat $1 | grep -ne "<table>" -e "</table>" | sed -n "${mode}p" | cut -d ":" -f 1 | awk '{printf $1","}' | sed 's/,//2') 

	locationsCount=$(cat $1 | sed -n "${address}p" | grep "<strong>" | wc -l | awk '{printf $1}');

	LocationList=$(cat $1 | sed -n "${address}p" | grep "<strong>" | sed 's/ /_/g' | sed -e 's/<strong>//g' -e 's/<\/strong>//g');

	if [ $mode = "5,6" ]; then 
		LinkList=$(cat $1 | sed -n "${address}p" | grep "rsync");
	else
		LinkList=$(cat $1 | sed -n "${address}p" | grep ".*</a>" | sed 's/<\/a>//g');
	fi

	i=1;
	while [ $i -le $locationsCount ]; do
	
		location=$(echo $LocationList | cut -d " " -f $i); 

		link=$(echo $LinkList | cut -d " " -f $i);

		mirrorHostname=$(echo $link | cut -d "/" -f 3);
		#echo "${location}=${link}";

		if ping -c 1 $mirrorHostname | grep -o "time=.*" >> /dev/null 2>&1; then 
			pingTime=$(ping -c 1 $mirrorHostname 2>/dev/null | grep -o "time=.*" | cut -d "=" -f 2 | awk '{printf $1}');
			
			if [ ! $pingTime ]; then 
				#echo "$(echo $location | sed 's/_/ /g'): nie odpowiada ping";
				continue;
			fi
		
			if [ ! $lowestPing ]; then 
				lowestPing=$pingTime;
				index=$i;
			else
				if [ $(echo "$pingTime < $lowestPing" | bc -l) = "1" ] ; then 
					lowestPing=$pingTime;
					index=$i;
				fi
			fi
			#echo "$(echo $location | sed 's/_/ /g'): $pingTime"; 
		#else
			#echo "$(echo $location | sed 's/_/ /g'): nie odpowiada na ping";

		fi	

		i=$(expr $i + 1);

	done
	echo "[+] Wybrano: $(echo $LocationList | cut -d " " -f $index | sed 's/_/ /g'): $(echo $LinkList | cut -d " " -f $index): $lowestPing ms";

}

function setFastesMirror {

	if [ $(whoami) = "root" ]; then

		export PKG_PATH="${1}$(uname -r)/packages/$(uname -m)";		
	
		echo "[+] Ustawiono najszybysz serwer lustrzany jako domyslne repozytorium pakietow";
	else
		echo "[-] Nie wystarczajace uprawnienia. Uruchom skrypt jako root.";
	fi

}

if [ $1 ]; then
	if [ $(echo $1) = "rsync" ]; then
		mode='5,6';
	elif [ $(echo $1) = "ftp" ]; then
		mode='3,4';
	else
		mode='1,2';
	fi 
fi

if [ ! $2 ]; then
	getCurrentMirrorList;
	mirrorList="mirrorList.html";
else
	mirrorList="$2";
fi

#echo $mirrorList;
checkMirrorList $mirrorList $mode;
setFastesMirror $(echo $LinkList | cut -d " " -f $index);	

if [ -f mirrorList.html ]; then rm mirrorList.html; fi
