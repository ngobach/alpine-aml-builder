#!/usr/bin/env bash

DEST="$(dirname "${BASH_SOURCE[0]}")"

meson_fatal() {
    echo "FATAL: $1"
    exit 1
}

meson_cp() {
    [[ -f "$PWD/Makefile" ]] || fatal "No Makefile found"
    KERNEL_RELEASE="$(make kernelrelease)"
    echo "KERNEL_RELEASE=$KERNEL_RELEASE"
    echo "$KERNEL_RELEASE" > $DEST/kernelrelease

    for FILE in \
        linux-*-arm.tar.* \
        arch/arm/boot/uImage \
        arch/arm/boot/dts/meson8b_m201_1G.dtb \
        arch/arm/boot/dts/meson8b-m201-1g.dtb \
    ; do
        if [[ -f $FILE ]]; then
            cp $FILE $DEST
        fi
    done
}

echo $DEST

case $1 in
cp)
    meson_cp
    echo "Files copied!"
    ;;
"")
    meson_fatal "Hello?"
    ;;
*)
    meson_fatal "Invalid command $1"
    ;;
esac
