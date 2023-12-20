import smtplib
import os
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
from platform import python_version
import datetime
import subprocess
from settings import server, user, password, sender, recipients

print (datetime.datetime.now())


## выполняем шелл-скрипт мониторинга вывод которого сохраним в файл body.html
#"/opt/scripts/monitoring/monitoring.sh 2> /opt/scripts/monitoring/error.txt 1> /opt/scripts/monitoring/body.html"
# создаем переменную
#script = "/opt/scripts/monitoring/monitoring.sh"
script = "./monitoring.sh"
# формируем переменную содержащую subprocess
result = subprocess.run(script, shell=True, stdout=subprocess.PIPE, text=True)
# проверяем код возврата
if result.returncode == 0:
    print("Subprocess executed successfully.")
else:
    print(f"Subprocess failed with return code {result.returncode}.")
# захватываем вывод
output = result.stdout
print(output)
# записываем вывод в файл
#output_file_path = "/opt/scripts/monitoring/body.html"
output_file_path = "./body.html"
with open(output_file_path, "w") as file:
    file.write(output)


## настройки почты мы импортируем из файла settings.py
#server = 'smtp.mail.ru'
#user = 'box@inbox.ru'
#password = 'password'
#imap_server = "imap.mail.ru"

body_message = './body.html'

#recipients = ['box@inbox.ru', 'box2@mail.ru', 'box3@yandex.ru', 'box@gmail.com']
#recipients = ['admin@microsoft.com']
#sender = 'box@inbox.ru'
subject = 'Report'
text = 'Body Message. Text.'
#html = '<html><head></head><body><p>'+text+'</p></body></html>'
# Тело сообщения находится в файле. Открываем простой текстовый файл для чтения.
with open(body_message, encoding='utf-8') as fp:
#with open(body_message) as fp:
    #msg = EmailMessage()
    html = fp.read()

filepath = "/opt/scripts/monitoring/attach.txt"
#filepath = "/root/scripts/rkhunter.log"
basename = os.path.basename(filepath)
filesize = os.path.getsize(filepath)

msg = MIMEMultipart('alternative')
msg['Subject'] = subject
msg['From'] = 'Report from Oracle Prog <' + sender + '>'
msg['To'] = ', '.join(recipients)
msg['Reply-To'] = sender
msg['Return-Path'] = sender
msg['X-Mailer'] = 'Python/'+(python_version())

part_text = MIMEText(text, 'plain')
part_html = MIMEText(html, 'html')
part_file = MIMEBase('application', 'octet-stream; name="{}"'.format(basename))
part_file.set_payload(open(filepath,"rb").read() )
part_file.add_header('Content-Description', basename)
part_file.add_header('Content-Disposition', 'attachment; filename="{}"; size={}'.format(basename, filesize))
encoders.encode_base64(part_file)

msg.attach(part_text)
msg.attach(part_html)
msg.attach(part_file)

mail = smtplib.SMTP_SSL(server)
mail.login(user, password)
mail.sendmail(sender, recipients, msg.as_string())
mail.quit()

print (datetime.datetime.now())

