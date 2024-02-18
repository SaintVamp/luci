REFUSED_NUM=$(nslookup 404.svsoft.fun | grep -c REFUSED)
if [ $((REFUSED_NUM)) -gt 0 ]
then
    echo "restart wan"
    `ifup wan`
else
    echo "pass"
fi