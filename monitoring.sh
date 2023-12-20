#!/bin/bash
#
# таймируем скрипт
start=$(date +%s.%2N)
#
errors=0
#echo '<table style="font-size:24px" width="auto" height="auto" bgcolor="#f7f7f7" cellpadding="0" cellspacing="0" border="0" font-color="blue" font-size="9px" overflow="auto">'
echo '<table style="font-size:12px;font-family:Arial,sans-serif;color:#3f4140" width="auto" height="auto" bgcolor="#f7f7f7" cellpadding="0" cellspacing="1" border="1" overflow="auto">'
echo "Сценарий выполняется на сервере: <b style='color: black; font-size: 14px;'> `hostname` </b>"
echo '<hr style="opacity:0">'
echo "Начало работы сценария: `date +'%d-%m-%Y %T.%3N'`"
echo '<br>'
# проверка наличия установленных системных пэкеджей
# apt
which apt >/dev/null 2>&1
if [ $? -eq 0 ]
then
    echo "В системе используется пакетный менеджер apt"
    # Ubuntu
    # список пакетов, которые должны быть установлены
    packages=("telnet" "bc" "s-nail" "postfix" "smartmontools" "bind-utils")
    for pkg in ${packages[@]}; do
    is_pkg_installed=$(dpkg-query -W --showformat='${Status}\n' ${pkg} | grep "install ok installed")
    if [ "${is_pkg_installed}" == "install ok installed" ]; then
        echo "${pkg} is installed. "
    else echo "${pkg} not installed. "
    fi
done
fi
#
which dnf >/dev/null 2>&1
if [ $? -eq 0 ]
then
    echo "В системе используется пакетный менеджер dnf. "
    # список пакетов, которые должны быть установлены
    list=("telnet" "bc" "s-nail" "postfix" "smartmontools" "bind-utils")
    # проверяем наличие пакетов в системе и сохраняем в list_packages.txt названия утилит которые должны быть установлены
    check_list=$(rpm -q "${list[@]}" | grep -e "not installed" | awk 'BEGIN { FS = " " } ; { print $2}' > ./list_packages.txt)
    # проверяем файл list_packages.txt пустой?
    grep -q '[^[:space:]]' < ./list_packages.txt
    EMPTY_FILE=$?
    # если list_packages.txt пустой, то ничего не делаем
    if [[ $EMPTY_FILE -eq 1 ]]; then
    echo "Все требуемые пакеты установлены."

    else

    # если list_packages.txt не пустой, то можно вывести имена утилит для установки
    for PACKAGES in `cat ./list_packages.txt`; do

    #dnf install -y $PACKAGES
    echo "Для работы скрипта требуются следующие системные утилиты: $PACKAGES "
done
fi

fi
#

echo '
<table width="auto" height="50px" bgcolor="#bef9ba" cellpadding="0" cellspacing="0" border="1" font-size="6px">'
echo ''
###
max_iteration_a=5

echo "Получаем внешний IP сервера через ifconfig.me ----o "
for i in $(seq 1 $max_iteration_a)
do
  curl -sSf ifconfig.me
  result=$?
  if [[ $result -eq 0 ]]
  then
    echo -e " &#9989; Request successful!"
    break
  else
    echo -e " &#10060; Request failed..."
        ((errors++))
    sleep 1
  fi
done

if [[ $result -ne 0 ]]
then
  echo "Все попытки неуспешны!!!"
fi

echo '<br>'

max_iteration_b=5

echo "Получаем внешний IP сервера через icanhazip.com ----o "
for i in $(seq 1 $max_iteration_b)
do
  curl -sSf icanhazip.com
  result=$?
  if [[ $result -eq 0 ]]
  then
    echo -e " &#9989; Request successful!"
    break
  else
    echo -e " &#10060; Request failed..."
        ((errors++))
    sleep 1
  fi
done

if [[ $result -ne 0 ]]
then
  echo "Все попытки неуспешны!!!"
fi
###
echo '
</table>'

# проверка кода ответа локального сервиса
#echo -e "Проверка кода ответа локального сервиса на порту :80 "
#timeout 5 curl -sSL 127.0.0.1:443 -w "GET /healthcheck --- %{http_code}\n" -o /dev/null
#timeout 5 curl -sSL 127.0.0.1:80 -w "GET --> %{http_code}" -o /dev/null
echo '<br>'
# проверка доступности порта
#echo -e "Telnet на локальный порт SMTP: "
#timeout 5 bash -c "echo OK | telnet 127.0.0.1 25"
echo '<br>'
# Uptime системы
#uptime | sed 's/,.*//' | sed 's/.*up //'
echo 'Uptime: '
uptime
echo '<br>'
#
# Мониторинг SSL сертификатов
echo '<br>'
current_epoch=$(date +"%s")
host="ba03.ecom-it.ru"
#echo | openssl s_client -servername ba03.ecom-it.ru -connect ba03.ecom-it.ru:8006 2>/dev/null | openssl x509 -enddate -noout | cu\t -d '=' -f2 | xargs -I{} date -d "{}" '+%F %T'
#expiry_date=$( echo | openssl s_client -showcerts -servername $host -connect $host:8006 2>/dev/null | openssl x509 -noout -enddate | cut -d "=" -f 2 )
#issuer=$( echo | openssl s_client -showcerts -servername $host -connect $host:8006 2>/dev/null | openssl x509 -noout -issuer | sed -e "s/.*O = \([^\/]*\).*/\1/" )
#CN=$( echo | openssl s_client -showcerts -servername $host -connect $host:8006 2>/dev/null | openssl x509 -noout -subject | cut -d "=" -f 3 )
#expiry_epoch=$( date -d "$expiry_date" +%s )
#expiry_days="$(( ($expiry_epoch - $current_epoch) / (3600 * 24) ))"
#echo "ssl_certificate,hostname="$line "value="$expiry_days >> /root/test_mail/monitoring.txt
#echo "Проверка SSL сертификата для домена : $host."
#echo "CN= $CN "
#echo "Сертификат истекает через: " $expiry_days " дней."
#echo "Выпустил: $issuer ."

#
# Collect CPU information
cpu_info() {
echo -en "Model name:\t\t${green}$(lscpu | grep -oP 'Model name:\s*\K.+')${nc}\n"
echo -en "Vendor ID:\t\t${green}$(lscpu | grep -oP 'Vendor ID:\s*\K.+')${nc}\n"
echo -e "CPU Cores\t\t" `awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo`
echo -e "CPU MHz:\t\t" `lscpu | grep -oP 'CPU MHz:\s*\K.+'`
echo -e "Hypervisor vendor:\t" `lscpu | grep -oP 'Hypervisor vendor:\s*\K.+'`
echo -e "Virtualization:\t\t" `lscpu | grep -oP 'Virtualization:\s*\K.+'`
# lscpu | grep -i virtualization
echo -e "Virtualization type:\t\t" `lscpu | grep -oP virtualization`
echo -e "CPU Usage:\t\t" `cat /proc/stat | awk '/cpu/{printf("%.2f%\n"), ($2+$4)*100/($2+$4+$5)}' |  awk '{print $0}' | head -1`
}
#
echo '<br>'
echo '<br>'
echo '<b>CPU information:</b>'
echo '
<table width="100%" bgcolor="#bef9ba" cellpadding="0" cellspacing="0" border="1">'
echo '<pre>'
cpu_info
echo '</pre>'
echo '
</table>'

echo '<br>'
echo '<b>Hardware info:</b>'
echo '
<table width="100%" bgcolor="#bef9ba" cellpadding="0" cellspacing="0" border="1">'
echo '<pre>'
/usr/sbin/lshw -short
echo '</pre>'
echo '
</table>'

echo '<br>'
echo '<b>hostnamectl:</b>'
echo '
<table width="100%" bgcolor="#bef9ba" cellpadding="0" cellspacing="0" border="1">'
echo '<pre>'
hostnamectl
echo '</pre>'
echo '
</table>'

echo '<br>'
echo '<b>Check Top Processes sorted by RAM or CPU Usage:</b>'
echo '
<table width="100%" bgcolor="#bef9ba" cellpadding="0" cellspacing="0" border="1">'
echo '<pre>'
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head
echo '</pre>'
echo '
</table>'

echo '<br>'
echo '<b>Информация о дистрибутиве:</b>'
echo '
<table width="100%" bgcolor="#bef9ba" cellpadding="0" cellspacing="0" border="1">'
echo '<pre>'
cat /etc/os-release
echo '</pre>'
echo '
</table>'

echo '<br>'
echo '<b>Show process using socket:</b>'
echo 'TCP/UDP'
echo '
<table width="100%" bgcolor="#bef9ba" cellpadding="0" cellspacing="0" border="1">'
echo '<pre>'
/usr/sbin/ss -tuapr
echo '</pre>'
echo '
</table>'

echo '<br>'
echo '<b>Список дисков в системе:</b>'
echo '
<table width="auto" height="auto" bgcolor="#0bcf9f" cellpadding="0" cellspacing="0" border="1">'
echo '<pre>'
# краткий список дисков в системе
/usr/sbin/lshw -short -C disk
echo '</pre>'
echo '
</table>'

echo '<br>'
echo '<b>Данные о блочных устройствах:</b>'
echo '
<table width="auto" height="auto" bgcolor="#0bcf9f" cellpadding="0" cellspacing="0" border="1">'
echo '<pre>'
#lsblk -o +FSAVAIL,KNAME,FSTYPE,LABEL,RM,MODEL,ROTA,DISC-GRAN
lsblk -O
echo '</pre>'
echo '
</table>'

echo '<br>'
echo '<b>S.M.A.R.T. статус:</b>'
echo '
<table width="auto" height="auto" bgcolor="#fbdbec" cellpadding="0" cellspacing="0" border="1">'
echo '<pre>'
#smartctl -i -a /dev/sda
/usr/sbin/smartctl -i -a /dev/sda
echo '</pre>'
echo '
</table>'

echo '<br>'
echo '<b>FREE:</b>'
echo '
<table width="auto" height="auto" bgcolor="#01fcbf" cellpadding="0" cellspacing="0" border="1">'
echo '<pre>'
free -h
echo '</pre>'
echo '
</table>'

echo '<br>'
echo '<b>Identification of Zombie Processes:</b>'
echo '
<table width="auto" height="auto" bgcolor="#01fcbf" cellpadding="0" cellspacing="0" border="1">'
echo '<pre>'
echo 'zombie processes:'
ps axo stat,ppid,pid,comm | grep -w defunct
echo '</pre>'
echo '
</table>'

echo '
</table>'

echo '<hr style="opacity:0">'

echo "Ошибок во время работы скрипта: $errors"

echo "<br>"
#echo '<p><a href="http://ya.ru">See article on Sitepoint</a></p>'
#
# подсчет тайминга скрипта
end=$(date +%s.%2N)
runtime=$( echo "$end - $start" | bc -l )
echo "Время выполнения скрипта: $runtime секунд"
#
echo "<br>"
echo "Окончание работы сценария: `date +'%d-%m-%Y %T.%3N'`"

exit 0

