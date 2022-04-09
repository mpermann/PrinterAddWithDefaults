#!/bin/bash

# This script is inspired by https://machinecompatible.wordpress.com/2022/02/12/adding-an-airprint-printer-the-easy-way/
# to add a printer nearly identical to a GUI added printer. It requires end user click Continue button during set up process.
# Version 1.0
# Created 04-09-2022 by Michael Permann

# Provide the printer DNS address as parameter 4 variable
PRINTER_DNS_ADDRESS="$4"
# Provide the printer queue name as parameter 5 variable - typically this is the Bonjour name with underscore (_) replacing the spaces
PRINTER_QUEUE_NAME="$5"
# Provide any optional printer defaults that need set as parameter 6 variable - get these with lpoptions -p $PRINTER_QUEUE_NAME -l
PRINTER_DEFAULT_OPTIONS="$6"

if [ -f "/private/etc/cups/ppd/${PRINTER_QUEUE_NAME}.ppd" ] 
then
   echo "Printer already exists delete it first to avoid duplicate"
   /bin/rm "/private/etc/cups/ppd/${PRINTER_QUEUE_NAME}.ppd"
   /bin/rm "/private/etc/cups/ppd/${PRINTER_QUEUE_NAME}.ppd.O"
   /bin/rm "/private/etc/cups/ppd/${PRINTER_QUEUE_NAME}___Fax.ppd"
else
   echo "Printer does NOT already exist so nothing to delete"
fi

# Open the AddPrinter.app and pass the URL to the printer to add the device
# The end user must click the Continue button to complete the adding of the printer
open -a /System/Library/CoreServices/AddPrinter.app ipp://"$PRINTER_DNS_ADDRESS"

while [ ! -f "/private/etc/cups/ppd/${PRINTER_QUEUE_NAME}.ppd" ] # wait for ppd file to be written to disk
do
   /bin/sleep 5
done

if [ -n "$PRINTER_DEFAULT_OPTIONS" ] # Check if any default options are passed, if there are set them
then
   /usr/sbin/lpadmin -p "$PRINTER_QUEUE_NAME" "$PRINTER_DEFAULT_OPTIONS"
   echo "Printer ${PRINTER_DNS_ADDRESS} added using queue name ${PRINTER_QUEUE_NAME} and default options of ${PRINTER_DEFAULT_OPTIONS} set"
else
   echo "Printer ${PRINTER_DNS_ADDRESS} added using queue name ${PRINTER_QUEUE_NAME}"
fi
