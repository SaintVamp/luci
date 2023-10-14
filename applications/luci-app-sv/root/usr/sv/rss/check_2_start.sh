hostname=$(uci get system.@system[0].hostname)
if [ "$hostname" = 'R404' ]; then
    echo 'pass'
elif [ "$hostname" = 'R2804' ]; then
    curl -o /usr/sv/rss/rss.py https://gitee.com/saintvamp/py_qbRssDown/raw/master/rss-2804.py
fi
sleep 2
nohup python /usr/sv/rss/rss.py >> /usr/sv/rss/oresult.log 2>&1 &