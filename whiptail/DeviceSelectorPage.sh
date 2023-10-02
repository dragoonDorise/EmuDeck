#!/bin/bash
while true; do
	device=$(whiptail --title "Choose your Device" \
   --radiolist "We tailor the experience depending on the selected device, each device has its own special configuration, different emulators and adjusted bezels." 10 80 4 \
	"RP2" "Retroid Pocket 2" OFF \
	"RP2+" "Retroid Pocket 2+" OFF \
	"ODIN" "ODIN Base or Pro" OFF \
	"ODINLITE" "ODIN Lite" OFF \
	"RG552" "Anbernic RG552" OFF \
	"ANDROID" "Other Android Device" OFF \
   3>&1 1<&2 2>&3)
	case $device in
		[RP2]* ) break;;
		[RP2+]* ) break;;
		[ODIN]* ) break;;
		[ODINLITE]* ) break;;
		[RG552]* ) break;;
		[ANDROID]* ) break;;
		* ) echo "Please choose your device.";;
	esac
done

case $device in
  "RP2")
		setSetting hasSDCARD true
		setSetting devicePower 0
		setSetting deviceAR 43
		setSetting android 9
  ;;
  "RP2+")
		  setSetting hasSDCARD true
		  setSetting devicePower 1
		  setSetting deviceAR 43
		  setSetting android 10
	;;
  "ODIN")
		setSetting hasSDCARD true
		setSetting devicePower 2
		setSetting deviceAR 169
		setSetting android 10		
	;;  
	"ODINLITE")		
		setSetting hasSDCARD true
		setSetting devicePower 2
		setSetting deviceAR 169
		setSetting android 11
	;;  
	"RG552")		
		setSetting hasSDCARD true
		setSetting devicePower 0
		setSetting deviceAR 53
		while true; do
			androidV=$(whiptail --title "What Android Version are you running?" \
		   --radiolist "What Android Version are you running?" 10 80 4 \
			"7" "Android 7. The version that comes preinstalled" ON \
			"9" "Android 9" OFF \
			"11" "Android 11" OFF \
		   3>&1 1<&2 2>&3)
			case $androidV in
				[7]* ) break;;
				[9]* ) break;;
				[11]* ) break;;
				* ) echo "What android version do you have.";;
			esac
		done
		case $androidV in
			"7")
				setSetting android 7
			;;
			"9")
				setSetting android 9
			;;  
			"11")
				setSetting android 11
			;;  
			*)
				  echo "default"
			;;
		esac
		
	;;  
	"ANDROID")
		while true; do
			androidV=$(whiptail --title "What Android Version are you running?" \
	   	--radiolist "What Android Version are you running?" 10 80 4 \
			"10" "Android 10 or older" OFF \
			"11" "Android 11 or newer" OFF \
	   	3>&1 1<&2 2>&3)
			case $androidV in				
				[10]* ) break;;
				[11]* ) break;;
				* ) echo "What android version do you have.";;
			esac
		done
		case $androidV in
			"10")
				setSetting android 10
			;;
			"11")
				setSetting android 11
			;;  
			*)
			  	echo "default"
			;;
		esac
		while true; do
			sdcardV=$(whiptail --title "Does your device have a SD Card?" \
		   --radiolist "Does your device have a SD Card?" 10 80 4 \
			"YES" "Yes" OFF \
			"NO" "No" OFF \
		   3>&1 1<&2 2>&3)
			case $sdcardV in
				[YES]* ) break;;
				[NO]* ) break;;
				* ) echo "Do you have a SD Card?";;
			esac
		done
		case $sdcardV in
			"YES")
				setSetting hasSDCARD true
			;;
			"NO")
				setSetting hasSDCARD false
			;;  
			*)
				  echo "default"
			;;
		esac
		while true; do
			cpuV=$(whiptail --title "What is your Android CPU power grade?" \
		   --radiolist "What is your Android CPU power grade?" 10 80 4 \
			"HIGH" "Snapdragon 845, Dimensity D900 or superior" OFF \
			"MEDIUM" "It's a midrage Android Phone" OFF \
			"LOW" "It's an entry level Android Phone" OFF \
		   3>&1 1<&2 2>&3)
			case $cpuV in
				[HIGH]* ) break;;
				[MEDIUM]* ) break;;
				[LOW]* ) break;;
				* ) echo "What CPU do you have..";;
			esac
		done
		case $cpuV in
			"HIGH")
				setSetting devicePower 2
			;;
			"MEDIUM")
				setSetting devicePower 1
			;;  
			"LOW")
				setSetting devicePower 0
			;;
			*)
				  echo "default"
			;;
		esac
		
		while true; do
			arV=$(whiptail --title "What is your Android Device Aspect Ratio?" \
		   --radiolist "What is your Android Device Aspect Ratio?" 10 80 4 \
			"169" "16:9" OFF \
			"43" "4:3" OFF \
			"OTHER" "Another" OFF \
		   3>&1 1<&2 2>&3)
			case $arV in
				[169]* ) break;;
				[43]* ) break;;
				[OTHER]* ) break;;
				* ) echo "What AR do you have..";;
			esac
		done
		case $arV in
			"169")
				setSetting deviceAR 169
			;;
			"43")
				setSetting deviceAR 43
			;;  
			"OTHER")
				setSetting deviceAR 0
			;;
			*)
				echo "default"
			;;
		esac
	
	;;  
	
  *)
  	echo "default"
  ;;
esac
