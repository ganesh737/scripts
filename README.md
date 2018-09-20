# scripts
Scripts for updating Andoid and Yocto based builds onto SD Card for RPI3 board

Source for Android: https://github.com/android-rpi/device_brcm_rpi3
Source for Yocto: http://www.jumpnowtek.com/rpi/Raspberry-Pi-Systems-with-Yocto.html

Sample run:
    For Android-
        backingup: ./backup_artifacts_android.sh oreo
        flashing : ./flash_android.sh --dir=~/src/rpi3/bin/android/oreo/20180919145451889 --drive=/dev/sdf

    For Yocto-
        backingup: ./backup_artifacts_yocto.sh ~/src/rpi3_yocto/ws/build
        flashing : ./flash_yocto.sh --dir=~/src/rpi3/bin/yocto/20180903030171395/ --drive=/dev/sdf
