mkdir /usr/sv/out
curl -o /usr/sv/py_book.py https://raw.githubusercontent.com/SaintVamp/py_book/master/run.py
curl -o /usr/sv/book_urls.txt https://raw.githubusercontent.com/SaintVamp/py_book/master/book_urls.txt
nohup python /usr/sv/py_book.py > /usr/sv/out/run.log 2>&1 &