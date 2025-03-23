#!/bin/bash

# Установим необходимые переменные
DONE_FILE="/run/htpdate/done"
SUCCESS_FILE="/run/htpdate/success"
LOG="/var/log/htpdate.log"

# Создаем лог-файл с нужными правами
install -o htp -g nogroup -m 0644 /dev/null "${LOG}"

# Запускаем htpdate с заданными параметрами
/usr/local/sbin/htpdate --log_file "${LOG}" --allowed_per_pool_failure_ratio 0.34 --user htp --done_file "${DONE_FILE}" --success_file "${SUCCESS_FILE}" --pool1 "puscii.nl,espiv.net,db.debian.org,epic.org,mail.riseup.net,www.gnu.org,squat.net,www.autistici.org,www.1984.is,www.eff.org,www.immerda.ch,securitylab.amnesty.org,www.torproject.org"  --pool2 "cve.mitre.org,www.openpgp.org,lkml.org,www.gnome.org,www.apache.org,getfedora.org,www.libreoffice.org,www.duckduckgo.com,nextcloud.com,www.kernel.org,www.gimp.org,www.stackexchange.com,www.startpage.com,www.xkcd.com" --pool3 "www.google.com,github.com,login.live.com,login.yahoo.com,flickr.com,tumblr.com,twitter.com,www.adobe.com,www.gandi.net,facebook.com,www.paypal.com,www.rackspace.com,www.sony.com" --proxy 127.0.0.1:9050
