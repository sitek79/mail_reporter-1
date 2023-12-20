# mail reporter bash+python
**Crontab**
```
crontab -e
30 3,6,9,12,15,18,21 * * * cd /opt/scripts/monitoring && /usr/bin/python3 /opt/scripts/monitoring/python_send_mail_smtplib_v2.py >> /opt/scripts/monitoring/protocol_smtplib_v2.txt 2>&1
```

```
cat settings.py
server = 'smtp.mail.ru'
user = 'box@inbox.ru'
password = 'password'
sender = 'box@inbox.ru'
recipients = ['box@inbox.ru', 'box@mail.ru', 'mail3@yandex.ru', 'mail4@gmail.com']
```


