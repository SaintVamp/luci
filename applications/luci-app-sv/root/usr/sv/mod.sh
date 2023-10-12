chmod +x /etc/init.d/aliddns
chmod +x /etc/init.d/syncdb
chmod +x /usr/bin/ethinfo


cronfile="/usr/sv/cronfile"
tempfile="/usr/sv/tempfile"
conf_set(){
  rm -rf $cronfile
  rm -rf $tempfile
  `crontab -l > $tempfile`
  while read -r line
  do
    if [[ "$line" == "*$1*" ]]
    then
      pass
    else
      `echo "$line" >> $cronfile`
    fi
  done < $tempfile
}
conf_set "down_book"
crontab -r
crontab $cronfile
conf_set "check_2_start"
crontab -r
crontab $cronfile
`echo "0 0 * * * /bin/bash /usr/sv/book/down_book.sh" >> $cronfile`
`echo "*/20 * * * * /bin/bash /usr/sv/rss/check_2_start.sh" >> $cronfile`
`/bin/bash /usr/sv/nginx/update-nginx.sh`
/etc/init.d/uhttpd restart