mkdir /usr/sv/out
curl -o /usr/sv/py_book.py https://gitee.com/saintvamp/py_book/raw/master/run.py
curl -o /usr/sv/book_urls.txt https://gitee.com/saintvamp/py_book/raw/master/book_urls.txt
nohup python /usr/sv/py_book.py > /usr/sv/out/run.log 2>&1 &