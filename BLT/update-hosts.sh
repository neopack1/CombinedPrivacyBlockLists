#!/bin/bash
#Block List Tools (http://shorl.com/fovogretopiga)
#From the maintainer of Combined Privacy Block Lists (https://github.com/bongochong/CombinedPrivacyBlockLists)
#License: CPAL-1.0 (https://github.com/bongochong/CombinedPrivacyBlockLists/blob/master/LICENSE.md)
echo "Cleaning up & Fetching hosts lists..."
mkdir -p ~/BLT/hosts
cd ~/BLT/hosts
rm -f hosts.* *.final *.hosts newhosts.txt
sleep 1
wget -nv -O hosts.1 "http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
echo "Downloaded hosts list 1"
wget -nv -O hosts.2 "http://winhelp2002.mvps.org/hosts.txt"
echo "Downloaded hosts list 2"
wget -nv -O hosts.3 "http://www.malwaredomainlist.com/hostslist/hosts.txt"
echo "Downloaded hosts list 3"
wget -nv -O hosts.4 "https://block.energized.pro/spark/formats/hosts.txt"
echo "Downloaded hosts list 4"
wget -nv -O hosts.5 "https://raw.githubusercontent.com/bongochong/CombinedPrivacyBlockLists/master/ABP2Hosts/spam_404-hosts.txt"
echo "Downloaded hosts list 5"
wget -nv -O hosts.6 "https://raw.githubusercontent.com/bongochong/CombinedPrivacyBlockLists/master/ABP2Hosts/adguard_mobile-hosts.txt"
echo "Downloaded hosts list 6"
wget -nv -O hosts.7 "https://raw.githubusercontent.com/bongochong/CombinedPrivacyBlockLists/master/WindowsTelemetryBlockSupplements/SBBTYZ-IPv4.txt"
echo "Downloaded hosts list 7"
wget -nv -O hosts.8 "https://raw.githubusercontent.com/bongochong/CombinedPrivacyBlockLists/master/ABP2Hosts/easylist_desktop-hosts.txt"
echo "Downloaded hosts list 8"
wget -nv -O hosts.9 "https://raw.githubusercontent.com/bongochong/CombinedPrivacyBlockLists/master/ABP2Hosts/adguard_dns-hosts.txt"
echo "Downloaded hosts list 9"
echo "Parsing data..."
cat hosts.* > hosts-cat.final
pcregrep -v -f ~/BLT/parsing/hostpatterns.dat hosts-cat.final > hosts-pre.final
sort hosts-pre.final | uniq | sed "s/#.*$//" | sed "/[[:space:]]*#/d" | sed "/[[:blank:]]*#/d" | sed "s/\t/ /g" | sed "s/^127.0.0.1/0.0.0.0/g" | sed "s/^::1/0.0.0.0/g" | sed "s/^::/0.0.0.0/g" | sed "s/[[:space:]]*$//" | sed "s/[[:blank:]]*$//" | sed "s/[[:space:]]\+/ /g" | sed "/^0.0.0.0 /! s/^/0.0.0.0 /" > uniq-hosts.final
#Optional routine to check for and convert Unicode IDNs to Punycode
#if [[ $(grep -P -n "[^\x00-\x7F]" uniq-hosts.final) ]]; then
#    echo "Non-ASCII strings found in domains. Converting to Punycode..."
#    grep -P -v "[^\x00-\x7F]" uniq-hosts.final | sed "s/0.0.0.0 //" > uniq-hosts-na.final
#    grep -P "[^\x00-\x7F]" uniq-hosts.final | sed "s/0.0.0.0 //" | idn >> uniq-hosts-na.final
#    sed -i "/^0.0.0.0 /! s/^/0.0.0.0 /" uniq-hosts-na.final
#    rm -f uniq-hosts.final && mv uniq-hosts-na.final uniq-hosts.final
#else
#    echo "All domains are valid ASCII strings. Continuing compilation of lists..."
#fi
#End of Unicode IDN to Punycode conversion routine
sed -i -e '/0.0.0.0 device9.com/d' -e '/\^\document/d' -e '/\^/d' -e '/\*/d' -e '/\?/d' -e '/\//d' -e '/@/d' -e '/!/d' -e '/|/d' -e '/:/d' -e '/~/d' -e '/,/d' -e '/=/d' -e "s/\(.*\)/\L\1/" uniq-hosts.final
sort uniq-hosts.final | uniq -i > final-uniq.hosts
pcregrep -v -f ~/BLT/parsing/hostpatterns.dat final-uniq.hosts > hosts.final
perl -i -pe 'chomp if eof' hosts.final
echo "Successfully merged hosts lists!"
sed '35r hosts.final' < ~/BLT/parsing/newhosts-template.txt > newhosts.txt
sed -i "23s|DAYBONGODATEREPLACE|$(date)|" newhosts.txt
perl -i -pe 'chomp if eof' newhosts.txt
echo "Successfully cleaned up and formatted hosts file! Prompting for password to make backup of and overwrite /etc/hosts..."
sudo cp /etc/hosts hostsbackup.txt
sudo cp newhosts.txt /etc/hosts
sleep 1
rm -f hosts.* *.final *.hosts
echo "Your hosts file has been updated!"
xdg-open ~/BLT/hosts
exit
