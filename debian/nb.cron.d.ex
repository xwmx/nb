#
# Regular cron jobs for the nb package
#
0 4	* * *	root	[ -x /usr/bin/nb_maintenance ] && /usr/bin/nb_maintenance
