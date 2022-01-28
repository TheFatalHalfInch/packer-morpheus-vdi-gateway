#!/bin/bash

#reference: https://docs.morpheusdata.com/en/latest/tools/vdi_pools.html#vdi-gateway-vm-install

#create array for strings to look for in our file
finds=("worker_url '" "worker\['appliance_url'\] = '" "worker\['apikey'\] = '")
#file we are altering
file="/etc/morpheus/morpheus-worker.rb"

#getting input from user for information to add to config file
echo "Enter Gateway Worker URL"
echo "This is the gateway URL that your Morpheus appliance can resolve and reach on 443"
echo -n "Gateway Worker URL: "
read gateway

echo ""
echo "Enter Appliance URL"
echo "The resolvable URL or IP address of your Morpheus appliance which the gateway can reach on 443"
echo -n "Appliance URL: "
read appliance

echo ""
echo "Enter API key"
echo "VDI gateway API key generated from your Morpheus appliance @ VDI Pools > VDI Gateways Configuration"
echo -n "API Key: "
read apikey

#for every string we are looking to alter
for find in "${finds[@]}"; do
  #switch case statement based on $find from foreach loop
  case $find in
    #if the string equals this value
    "worker_url '")
      #set the append variable equal to this var + a single quote to close the statement properly
      append="${gateway}'"
      ;;
    "worker\['appliance_url'\] = '")
      append="${appliance}'"
      ;;
    "worker\['apikey'\] = '")
      append="${apikey}'"
      ;;
  #end switch case
  esac
  #sed command to find our string and append it with our custom info
  sed -i "s,${find}.*,${find}${append}," "$file"
#end foreach loop
done

echo ""
cat "${file}"

#reconfigure morpheus now that the ip address has been changed in the file
morpheus-worker-ctl reconfigure