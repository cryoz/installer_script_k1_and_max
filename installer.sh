#!/bin/sh

read -p "Do you want to install or uninstall? (install/uninstall) " choice

case $choice in
    install|INSTALL)
        read -p "Are you sure you want to install? (yes/no) " install_confirm
        case $install_confirm in
            yes|YES)
                echo "Downloading Klipper Repository"
		git config --global http.sslVerify false
                git config --global http.postBuffer 131072000
		git clone https://github.com/cryoz/klipper.git /usr/data/klipper
		mv /usr/share/klipper /usr/data/old.klipper
		ln -s /usr/data/klipper /usr/share/klipper
  		cp /usr/data/printer_data/config/printer.cfg /usr/data/printer_data/config/printer.bak
		cp /usr/data/printer_data/config/gcode_macro.cfg /usr/data/printer_data/config/gcode_macro.bak
		mv /usr/data/printer_data/config/sensorless.cfg /usr/data/printer_data/config/sensorless.bak
		wget --no-check-certificate -P /usr/data/printer_data/config/ https://raw.githubusercontent.com/cryoz/installer_script_k1_and_max/main/sensorless.cfg
		wget --no-check-certificate -P /usr/data/printer_data/config/ https://raw.githubusercontent.com/cryoz/installer_script_k1_and_max/main/loadcell_probe.cfg
    		sed -i '/^\[bl24c16f\]/,/^$/d' /usr/data/printer_data/config/printer.cfg
      		sed -i '/^square_corner_max_velocity: 200.0$/d' /usr/data/printer_data/config/printer.cfg
		sed -i '/\[gcode_macro START_PRINT\]/,/CX_PRINT_DRAW_ONE_LINE/d' /usr/data/printer_data/config/gcode_macro.cfg
		sed -i 's/CXSAVE_CONFIG/SAVE_CONFIG/g' /usr/data/printer_data/config/gcode_macro.cfg
		sed -i 's/230400/921600/g' /usr/data/printer_data/config/printer.cfg
		sed -in '/\[include printer_params.cfg\]$/a\[include start_macro.cfg\]' /usr/data/printer_data/config/printer.cfg
                wget --no-check-certificate -P /usr/data/printer_data/config/ https://raw.githubusercontent.com/cryoz/installer_script_k1_and_max/main/start_macro.cfg 
		/usr/share/klippy-env/bin/python3 -m compileall /usr/data/klipper/klippy
  		mv /etc/init.d/S55klipper_service /usr/data/S55klipper_service.bak
  		mv /etc/init.d/S13mcu_update /usr/data/S13mcu_update.bak
    		wget --no-check-certificate -P /etc/init.d/ https://raw.githubusercontent.com/cryoz/installer_script_k1_and_max/main/S55klipper_service
    		wget --no-check-certificate -P /etc/init.d/ https://raw.githubusercontent.com/cryoz/installer_script_k1_and_max/main/S13mcu_update
		chmod +x /etc/init.d/S55klipper_service
		chmod +x /etc/init.d/S13mcu_update
		# /etc/init.d/S55klipper_service restart
  		echo "Please reboot machine by using power switch on back to complete installation (be sure to compile/download new FW for MCU)"
                ;;
            no|NO)
                echo "Installation cancelled."
                ;;
            *)
                echo "Invalid input. Please enter 'yes' or 'no'."
                ;;
        esac
        ;;
    uninstall|UNINSTALL)
        read -p "Are you sure you want to uninstall? (yes/no) " uninstall_confirm
        case $uninstall_confirm in
            yes|YES)
                echo "Uninstalling..."
                rm /usr/share/klipper
		rm -rf /usr/data/klipper
		mv /usr/data/old.klipper /usr/share/klipper
  		mv /usr/data/printer_data/config/printer.bak /usr/data/printer_data/config/printer.cfg
  		mv /usr/data/printer_data/config/gcode_macro.bak /usr/data/printer_data/config/gcode_macro.cfg
    		mv /usr/data/printer_data/config/sensorless.bak /usr/data/sensorsless.cfg
		rm /usr/data/printer_data/config/loadcell_probe.cfg
      		rm /etc/init.d/S55klipper_service
      		rm /etc/init.d/S13mcu_update
		mv /usr/data/S55klipper_service.bak /etc/init.d/S55klipper_service
		mv /usr/data/S13mcu_update.bak /etc/init.d/S13mcu_update
		rm /usr/data/printer_data/config/start_macro.cfg
		/etc/init.d/S55klipper_service restart
		;;
            no|NO)
                echo "Uninstallation cancelled."
                ;;
            *)
                echo "Invalid input. Please enter 'yes' or 'no'."
                ;;
        esac
        ;;
    *)
        echo "Invalid input. Please enter 'install' or 'uninstall'."
        ;;
esac
