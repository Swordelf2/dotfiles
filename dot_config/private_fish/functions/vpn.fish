function vpn
    set name $argv[1]
    if test $name = down
        set active_vpns (nmcli -t -f name,type connection show --active | grep ':vpn$' | cut -d ':' -f 1)
        for active_vpn_name in $active_vpns
            echo $active_vpn_name
            nmcli c down "$active_vpn_name"
        end
    else
        nmcli c up "vpn-$name" --ask
    end
    #   echo "Active VPN connection(s) found:" 
    #   # Cut out just the connection name
    #   echo "$active_vpns" | cut -d ':' -f 1 
    # else
    #   echo "No active VPN connections found."
    # fi
    #   nmcli c up vpn-$1 --ask
end
