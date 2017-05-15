#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in post-fs-data mode
# More info in the main Magisk thread
exec &> $MODDIR/xiaomi-safetynet-fix.log

set -x

LOGFILE="/cache/magisk.log"

log_print() {
    echo "$1"
    echo "$1" >> $LOGFILE
    log -p i -t Magisk "$1"
}

if [ -f "/magisk/.core/bin/resetprop" ]; then RESETPROP="/magisk/.core/bin/resetprop"
elif [ -f "/data/magisk/resetprop" ]; then RESETPROP="/data/magisk/resetprop"
elif [ -f "/sbin/resetprop" ]; then RESETPROP="/sbin/resetprop"
else exit 1; fi

get_prop() {
    set +x
    cat /system/build.prop | sed -n "s/^$1=//p"
    set -x
}

set_prop() {
    set +x
    [ "$(get_prop ro.product.name)" == "$1" ] || \
    [ "$(get_prop ro.product.device)" == "$1" ] || \
    [ "$(get_prop ro.build.product)" == "$1" ] && {
        if [ "$5" ]; then MODEL="$5"; else MODEL="$1"; fi
        set -x
        $RESETPROP -v -n "ro.build.fingerprint" "Xiaomi/$MODEL/$1:$2/$3/$4:user/release-keys"
        $RESETPROP -v -n "ro.bootimage.build.fingerprint" "Xiaomi/$MODEL/$1:$2/$3/$4:user/release-keys"
        script_end &
        exit
    }
    set -x
}

grep_logcat() {
    set +x
    while :; do logcat -d | grep "$1" && break; sleep 1; done
    set -x
}

script_end() {
    while :; do [ "$(getprop persist.magisk.hide)" == "0" ] && \
    break || setprop "persist.magisk.hide" "0"; sleep 1; done
    set +x
    while :; do [ "$(getprop sys.boot_completed)" == "1" ] && \
    [ "$(getprop init.svc.magisk_service)" == "stopped" ] && break; sleep 1; done
    set -x
    log_print "* Starting MagiskHide"
    sh -x /magisk/.core/magiskhide/enable
    setprop "persist.magisk.hide" "1"
    getprop
    sleep 1
    cat $LOGFILE
    echo "Waiting for Magisk Manager SafetyNet check..."
    grep_logcat "MANAGER: SN: Google API Connected"
    grep_logcat "MANAGER: SN: Check with nonce"
    grep_logcat "MANAGER: SN: Response"
    grep_logcat "MANAGER: StatusFragment: SafetyNet UI refresh triggered"
    echo "Waiting for MagiskHide unmount..."
    while :; do grep "MagiskHide: Unmounted (/sbin)" "$LOGFILE" && \
    grep "MagiskHide: Unmounted (/magisk)" "$LOGFILE" && break; sleep 1; done
    sleep 1
    MAGISKHIDE_LOG=$(grep -n -x "* Starting MagiskHide" "$LOGFILE")
    /data/magisk/busybox tail +${MAGISKHIDE_LOG%%:*} "$LOGFILE"
}

# Redmi Note 2
set_prop "hermes" "5.0.2" "LRX22G" "V8.2.1.0.LHMCNDL"

# Redmi Note 3 MTK
set_prop "hennessy" "5.0.2" "LRX22G" "V8.2.1.0.LHNCNDL"

# Redmi Note 3 Qualcomm
set_prop "kenzo" "6.0.1" "MMB29M" "V8.2.1.0.MHOCNDL"

# Redmi Note 4 MTK
set_prop "nikel" "6.0" "MRA58K" "V8.2.2.0.MBFCNDL"

# Mi 5
set_prop "gemini" "7.0" "NRD90M" "V8.2.2.0.NAACNEB"

# Mi 5s
set_prop "capricorn" "6.0.1" "MXB48T" "V8.2.4.0.MAGCNDL"

# Mi 5s Plus
set_prop "natrium" "6.0.1" "MXB48T" "V8.2.4.0.MBGCNDL"

# Mi MIX
set_prop "lithium" "6.0.1" "MXB48T" "V8.2.3.0.MAHCNDL"

# Mi Max
set_prop "hydrogen" "6.0.1" "MMB29M" "V8.2.3.0.MBCCNDL"

# Mi Max Prime
set_prop "helium" "6.0.1" "MMB29M" "V8.2.3.0.MBDCNDL"

# Redmi 3S/Prime/3X
set_prop "land" "6.0.1" "MMB29M" "V8.1.5.0.MALCNDI"

# Mi 4c
set_prop "libra" "5.1.1" "LMY47V" "V8.2.1.0.LXKCNDL"

# Mi 5c
set_prop "meri" "6.0" "MRA58K" "V8.1.15.0.MCJCNDI"

# Redmi Note 3 Special Edition
set_prop "kate" "6.0.1" "MMB29M" "V8.1.3.0.MHRMIDI"

# Mi Note 2
set_prop "scorpio" "6.0.1" "MXB48T" "V8.2.5.0.MADCNDL"

# Redmi Note 4X
set_prop "mido" "6.0.1" "MMB29M" "V8.2.18.0.MCFCNDL"

# Redmi 2 Prime
set_prop "wt88047" "5.1.1" "LMY47V" "V8.2.5.0.LHJCNDL"

# Redmi 2/4G
set_prop "HM2014811" "4.4.4" "KTU84P" "V8.2.3.0.KHJCNDL" "2014811"

# Redmi 3/Prime
set_prop "ido" "5.1.1" "LMY47V" "V8.1.3.0.LAIMIDI"

# Mi 4i
set_prop "ferrari" "5.0.2" "LRX22G" "V8.1.5.0.LXIMIDI"

# Redmi 4
set_prop "prada" "6.0.1" "MMB29M" "V8.1.5.0.MCECNDI"

# Redmi 4 Prime
set_prop "markw" "6.0.1" "MMB29M" "V8.2.4.0.MBEMIDL"

# Redmi 4A
set_prop "rolex" "6.0.1" "MMB29M" "V8.1.4.0.MCCMIDI"

# Mi Pad
set_prop "mocha" "4.4.4" "KTU84P" "V8.2.2.0.KXFCNDL"

# Mi Note
set_prop "virgo" "6.0.1" "MMB29M" "V8.1.4.0.MXEMIDI"

# Mi 3/Mi 4
set_prop "cancro" "6.0.1" "MMB29M" "V8.1.6.0.MXDMIDI"

# Mi 2/2S
set_prop "aries" "5.0.2" "LRX22G" "V8.1.3.0.LXAMIDI"

# Mi Pad 2
set_prop "latte" "5.1" "LMY47I" "V8.2.2.0.LACCNDL"

# Mi Pad 3
set_prop "cappu" "7.0" "NRD90M" "V8.2.8.0.NCICNEB"

# Mi 6
set_prop "sagit" "7.1.1" "NMF26X" "V8.2.17.0.NCACNEC"
