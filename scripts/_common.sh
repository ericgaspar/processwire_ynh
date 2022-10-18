#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================
# PHP APP SPECIFIC
#=================================================
# Depending on its version, YunoHost uses different default PHP version:
## YunoHost version "11.X" => PHP 7.4
## YunoHost version "4.X"  => PHP 7.3
#
# This behaviour can be overridden by setting the YNH_PHP_VERSION variable
#YNH_PHP_VERSION=7.3
#YNH_PHP_VERSION=7.4
#YNH_PHP_VERSION=8.0
# For more information, see the PHP application helper: https://github.com/YunoHost/yunohost/blob/dev/helpers/php#L3-L6
# Or this app package depending on PHP: https://github.com/YunoHost-Apps/grav_ynh/blob/master/scripts/_common.sh
# PHP dependencies used by the app (must be on a single line)
#php_dependencies="php$YNH_PHP_VERSION-deb1 php$YNH_PHP_VERSION-deb2"
# or, if you do not need a custom YNH_PHP_VERSION:
php_dependencies="php$YNH_DEFAULT_PHP_VERSION-gd"

# dependencies used by the app (must be on a single line)
pkg_dependencies="$php_dependencies"

#=================================================
# PERSONAL HELPERS
#=================================================

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

# Send an email to inform the administrator
#
# usage: ynh_send_readme_to_admin app_message [recipients]
# | arg: app_message - The message to send to the administrator.
# | arg: recipients - The recipients of this email. Use spaces to separate multiples recipients. - default: root
#	example: "root admin@domain"
#	If you give the name of a YunoHost user, ynh_send_readme_to_admin will find its email adress for you
#	example: "root admin@domain user1 user2"
ynh_send_readme_to_admin() {
	local app_message="${1:-...No specific information...}"
	local recipients="${2:-root}"

	# Retrieve the email of users
	find_mails () {
		local list_mails="$1"
		local mail
		local recipients=" "
		# Read each mail in argument
		for mail in $list_mails
		do
			# Keep root or a real email address as it is
			if [ "$mail" = "root" ] || echo "$mail" | grep --quiet "@"
			then
				recipients="$recipients $mail"
			else
				# But replace an user name without a domain after by its email
				if mail=$(ynh_user_get_info "$mail" "mail" 2> /dev/null)
				then
					recipients="$recipients $mail"
				fi
			fi
		done
		echo "$recipients"
	}
	recipients=$(find_mails "$recipients")

	local mail_subject="☁️🆈🅽🅷☁️: \`$app\` has important message for you"

	local mail_message="This is an automated message from your beloved YunoHost server.
Specific information for the application $app.
$app_message
---
Automatic diagnosis data from YunoHost
$(yunohost tools diagnosis | grep -B 100 "services:" | sed '/services:/d')"
	
	# Define binary to use for mail command
	if [ -e /usr/bin/bsd-mailx ]
	then
		local mail_bin=/usr/bin/bsd-mailx
	else
		local mail_bin=/usr/bin/mail.mailutils
	fi

	# Send the email to the recipients
	echo "$mail_message" | $mail_bin -a "Content-Type: text/plain; charset=UTF-8" -s "$mail_subject" "$recipients"
}


#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
