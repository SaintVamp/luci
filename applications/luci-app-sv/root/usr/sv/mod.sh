chmod +x /etc/init.d/aliddns
chmod +x /etc/init.d/syncdb
chmod +x /usr/bin/ethinfo
[ ! "$1" ] && echo "lose param" && exit 1
uci set system.@system[0].hostname="$1"
uci get system.@system[0].hostname
cron_file="/usr/sv/cronfile"
temp_file="/usr/sv/tempfile"
conf_set(){
    rm -rf $cron_file
    rm -rf $temp_file
    $(crontab -l > $temp_file)
    while read -r line
    do
        if [[ "$line" == "*$1*" ]]
        then
            echo 'pass'
        else
            $(echo "$line" >> $cron_file)
        fi
    done < $temp_file
}
conf_set "down_book"
crontab -r
crontab $cron_file
conf_set "check_2_start"
crontab -r
crontab $cron_file
$(echo "0 0 * * * /bin/bash /usr/sv/book/init-book.sh" >> $cron_file)
$(echo "*/20 * * * * /bin/bash /usr/sv/rss/init-rss.sh" >> $cron_file)
crontab -r
crontab $cron_file
/bin/bash /usr/sv/nginx/init-nginx.sh
/etc/init.d/uhttpd restart