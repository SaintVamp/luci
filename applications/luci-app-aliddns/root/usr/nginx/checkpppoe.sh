REFUSED_NUM=$(nslookup 404.svsoft.fun | grep -c REFUSED)
if [ $((REFUSED_NUM)) -gt 0 ]
then
    echo "restart wan"
    `ifup wan`
else
    echo "pass"
fi
if ps w | grep -v grep | grep -q "nginx: master process"; then
    echo "Nginx is running"
else
    echo "Nginx start"
    /etc/init.d/nginx start
fi