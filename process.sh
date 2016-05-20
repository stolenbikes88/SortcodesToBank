#!/bin/bash

## Get the result output from web
for sortcode in $(cat sortcodetest.csv); do
	CLEANED=$(echo "$sortcode" | sed 's/\r$//')
	wget http://www.thebankcodes.com/sortcode/$CLEANED -P rawoutput
done

## Process into CSV
echo -e "SORTCODE \t STATUS \t BANK \t ADDRESS" >> output.csv
for sortcode in $(cat sortcodetest.csv); do
	CLEANED=$(echo "$sortcode" | sed 's/\r$//')
	LINE=$(cat rawoutput/$CLEANED | head -n 399 | tail -1)

	if grep -q "not find any sort code" <<< "$LINE"; then
		echo -e "$CLEANED \t NOT FOUND" >> output.csv
	else
		BANK=$(cat rawoutput/$CLEANED | head -n 399 | tail -1 | awk -F"<td><b>" '{print $3}' | awk -F"</b><br>" '{print $1'}) 
		ADDRESS=$(cat rawoutput/$CLEANED | head -n 399 | tail -1 | awk -F"<td><b>" '{print $3}' | awk -F"</b><br><br>" '{print $2}' | awk -F"</td></tr>" '{print $1}')
		FIND='<br>'
		REPLACE=' \t '
		ADDRESSCLEANED=${ADDRESS//$FIND/$REPLACE}
		echo -e "$CLEANED \t FOUND \t $BANK \t $ADDRESSCLEANED" >> output.csv
	fi

done