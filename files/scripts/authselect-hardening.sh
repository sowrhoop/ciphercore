#!/usr/bin/env bash

set -oue pipefail

uncomment_and_modify() {
    local file="$1"
    local pattern="$2"
    local replacement="$3"
    
    sed -i "s/^# \(.*$pattern.*\)/\1/g" "$file"
    sed -i "s/$pattern.*/$pattern $replacement/g" "$file"
}

pwquality_file="/etc/security/pwquality.conf"

uncomment_and_modify "$pwquality_file" "minlen" "15"
uncomment_and_modify "$pwquality_file" "dcredit" "-1"
uncomment_and_modify "$pwquality_file" "ucredit" "-1"
uncomment_and_modify "$pwquality_file" "lcredit" "-1"
uncomment_and_modify "$pwquality_file" "ocredit" "-1"
uncomment_and_modify "$pwquality_file" "maxrepeat" "3"
uncomment_and_modify "$pwquality_file" "dictcheck" "1"
uncomment_and_modify "$pwquality_file" "usercheck" "1"
uncomment_and_modify "$pwquality_file" "usersubstr" "5"
uncomment_and_modify "$pwquality_file" "enforcing" "1"
uncomment_and_modify "$pwquality_file" "retry" "5"
uncomment_and_modify "$pwquality_file" "enforce_for_root" ""

faillock_file="/etc/security/faillock.conf"

uncomment_and_modify "$faillock_file" "audit" ""
uncomment_and_modify "$faillock_file" "deny" "25"
uncomment_and_modify "$faillock_file" "unlock_time" "86400"
uncomment_and_modify "$faillock_file" "even_deny_root" ""

authselect create-profile ciphercore -b sssd > /dev/null 2>&1

new_delay="5000000"

pwd_files=(
    "/etc/authselect/custom/ciphercore/password-auth"
    "/etc/authselect/custom/ciphercore/system-auth"
)

for file in "${pwd_files[@]}"; do
    if [ -f "$file" ]; then
        sed -i "s/\(auth\s*required\s*pam_faildelay.so\s*delay=\).*$/\1$new_delay/" "$file"
    else
        echo "File not found: $file"
    fi
done

authselect select custom/ciphercore with-pamaccess with-faillock without-nullok --quiet 1> /dev/null
