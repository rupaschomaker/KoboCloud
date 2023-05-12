#!/bin/sh

baseURL="$1"
outDir="$2"

#load config
. $(dirname $0)/config.sh

baseURL=`echo "$baseURL" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`

# get directory listing
echo "Getting $baseURL"
# get directory listing
$CURL -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.89 Safari/537.36" -k -L --silent "$baseURL" | # get listing. Need to specify a user agent, otherwise it will download the directory
grep -Eo 'ShmodelFolderEntriesPrefetch.*' | 
grep -Eo 'https?://www.dropbox.com/sh/[^\"]*' | # find links
sort -u | # remove duplicates
while read linkLine
do
  if [ "$linkLine" = "$baseURL" ]
  then
    continue
  fi
  #echo $linkLine
  # process line 
  outFileName=`echo $linkLine | sed -e 's|.*/\(.*\)?dl=.*|\1|'`
  #echo $outFileName
  localFile="$outDir/$outFileName"
  $KC_HOME/getRemoteFile.sh "$linkLine" "$localFile"
  if [ $? -ne 0 ] ; then
      echo "Having problems contacting Dropbox. Try again in a couple of minutes."
      exit
  fi
done
