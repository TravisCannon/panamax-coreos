#!/bin/bash 

pmxCntUI='panamax-container-ui'
pmxCntAPI='panamax-container-api'
pmxImgUI='panamax/panamax-ui'
pmxImgAPI='panamax/panamax-api'
pmxSvcUI='panamax-ui.service'
pmxSvcAPI='panamax-api.service'


function stopPanamax {
    sudo systemctl stop $pmxSvcAPI
    sudo systemctl stop $pmxSvcUI
}

function startPanamax {
    sudo systemctl start $pmxSvcAPI
    sudo systemctl start $pmxSvcAPI
}

function installPanamax {

    if [[  $operation == "reinstall" ]]; then
        echo ""
        echo "Uninstalling Panamax"
        stopPanamax
        echo "Installing Panamax"
        startPanamax
    else
        sudo cp *.service /media/state/units/
        sudo systemctl restart local-enable.service
    fi

    #tail -f $VAULogFile | awk '/Phase/;/Phase 2 ended/ { exit }'
    openPanamax

    exit 0;
}


function openPanamax {
    echo "waiting for panamax to start....."
    until [ `curl -sL -w "%{http_code}" "http://localhost:3000"  -o /dev/null` == "200" ];
    do
      journalctl -n 2
      sleep 2
    done
}

function main {

    operation=$1
    
    if [[ $# -gt 0 ]]; then
	case $operation in
	    install) installPanamax; break;;
	    reinstall) installPanamax; break;;
	    restart)
	            stopPanamax
	            startPanamax
	            break;;

	esac
	
    else
        echo "Please select one of the following options: "
        select operation in "install" "restart" "reinstall"; do
        case $operation in
            install) installPanamax; break;;
            restart) restartPanamax; break;;
            reinstall) installPanamax; break;;
        esac
        done
    fi
}


main "$@";
