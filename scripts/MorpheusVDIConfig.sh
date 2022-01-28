#!/bin/bash

#create array for strings to look for in our file
finds=("worker_url '" "worker['appliance_url'] = '" "worker['apikey'] = '")
#file we are altering
file="/etc/morpheus/morpheus-worker.rb"

#getting input from user for information to add to config file
echo "Enter Gateway Worker URL"
echo "This is the gateway URL that your Morpheus appliance can resolve and reach on 443"
read gateway

echo "Enter Appliance URL"
echo "The resolvable URL or IP address of your Morpheus appliance which the gateway can reach on 443"
read appliance

echo "Enter API key"
echo "VDI gateway API key generated from your Morpheus appliance @ VDI Pools > VDI Gateways Configuration"
read apikey

#for every string we are looking to alter
for find in "${finds[@]}"; do
  #switch case statement based on $find from foreach loop
  case $find in
    #if the string equals this value
    "worker_url '")
      #set the append variable equal to this var + an escaped single quote to properly close the sed statement
      append="${gateway}\'"
      ;;
    "worker['appliance_url'] = '")
      append="${appliance}\'"
      ;;
    "worker['apikey'] = '")
      append="${apikey}\'"
      ;;
  #end switch case
  esac
  #sed command to find our string and append it with our custom info
  sed -i "s/${find}.*/${find}${append}/" "$file"
#end foreach loop
done

#reconfigure morpheus now that the ip address has been changed in the file
morpheus-worker-ctl reconfigure