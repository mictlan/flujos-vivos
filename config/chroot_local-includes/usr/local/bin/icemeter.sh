TYPE=ppm
NAME="flujos-niveles"

/usr/bin/meterbridge -n ${NAME} -t ${TYPE} -c 2 darkice-$(pgrep darkice):left darkice-$(pgrep darkice):right & > /dev/null 2>&1
