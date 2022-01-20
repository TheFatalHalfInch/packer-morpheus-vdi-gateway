#!/bin/bash

#reference: https://www.geeksforgeeks.org/bash-scripting-split-string/

#vars
ips=$(hostname -i)
file="/etc/morpheus/morpheus.rb"
find="appliance_url"

# Set space as the delimiter
IFS=' '

# Read the split words into an array
# based on space delimiter
read -ra newarr <<< "$ips"

#foreach line in the new array we created
for val in "${newarr[@]}"; do
  #if the line doesn't contain 127.0.*
  if [[ ! $val =~ 127.0.*$ ]]; then
    #set ip equal to the line (this should get your current ip address)
    ip="$val"
  #end if
  fi
#end foreach
done

#open the file defined earlier, find the line with the string you are
#looking for, and replace it with the string you are looking for and
#'https://(the ip address we found)'
sudo sed -i "s/$find.*/$find \'https:\/\/$ip\'/" "$file"

#reconfigure morpheus now that the ip address has been changed in the file
sudo morpheus-ctl reconfigure