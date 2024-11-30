#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

sed -i 's@DefaultZone=public@DefaultZone=FedoraServer@g' /etc/firewalld/firewalld.conf
