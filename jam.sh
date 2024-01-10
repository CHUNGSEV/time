#!/bin/sh
# Đồng bộ hóa ngày giờ 
# Hỗ trợ GMT+7
# Hỗ trợ VPN Tunnels: OpenClash, Passwall, ShadowsocksR, ShadowsocksR++, v2ray, v2rayA, xray, Libernet, Xderm Mini, Wegare

dtdir="/root/date"
initd="/etc/init.d"
logp="/root/logp"
jamup2="/root/jam2_up.sh"
jamup="/root/jamup.sh"
nmfl="$(basename "$0")"
scver="3.5"

function nyetop() {
	stopvpn="${nmfl}: Đang dừng"
	echo -e "${stopvpn} VPN nếu có."
	logger "${stopvpn} VPN nếu có."
	if [[ -f "$initd"/openclash ]] && [[ $(uci -q get openclash.config.enable)="1" ]]; then "$initd"/openclash stop && echo -e "${stopvpn} OpenClash"; fi
	if [[ -f "$initd"/passwall ]] && [[ $(uci -q get passwall.enabled)="1" ]]; then "$initd"/passwall stop && echo -e "${stopvpn} Passwall"; fi
	if [[ -f "$initd"/shadowsocksr ]] && [[ $(uci -q get shadowsocksr.@global[0].global_server)="1" ]]; then "$initd"/shadowsocksr stop && echo -e "${stopvpn} SSR++"; fi
	if [[ -f "$initd"/v2ray ]] && [[ $(uci -q get v2ray.enabled.enabled)="1" ]]; then "$initd"/v2ray stop && echo -e "${stopvpn} v2ray"; fi
	if [[ -f "$initd"/v2raya ]] && [[ $(uci -q get v2raya.config.enabled)="1" ]]; then "$initd"/v2raya stop && echo -e "${stopvpn} v2rayA"; fi
	if [[ -f "$initd"/xray ]] && [[ $(uci -q get xray.enabled.enabled)="1"  ]]; then "$initd"/xray stop && echo -e "${stopvpn} Xray"; fi
	if grep -q "screen -AmdS libernet" /etc/rc.local; then ./root/libernet/bin/service.sh -ds && echo -e "${stopvpn} Libernet"; fi
	if grep -q "/www/xderm/log/st" /etc/rc.local; then ./www/xderm/xderm-mini stop && echo -e "${stopvpn} Xderm"; fi
	if grep -q "autorekonek-stl" /etc/crontabs/root; then echo "3" | stl && echo -e "${stopvpn} Wegare STL"; fi
}

function nyetart() {
	startvpn="${nmfl}: Khởi động lại."
	echo -e "${startvpn} VPN nếu có."
	logger "${startvpn} VPN nếu có."
	if [[ -f "$initd"/openclash ]] && [[ $(uci -q get openclash.config.enable)="1" ]]; then "$initd"/openclash restart && echo -e "${startvpn} OpenClash"; fi
	if [[ -f "$initd"/passwall ]] && [[ $(uci -q get passwall.enabled)="1" ]]; then "$initd"/passwall restart && echo -e "${startvpn} Passwall"; fi
	if [[ -f "$initd"/shadowsocksr ]] && [[ $(uci -q get shadowsocksr.@global[0].global_server)="1" ]]; then "$initd"/shadowsocksr restart && echo -e "${startvpn} SSR++"; fi
	if [[ -f "$initd"/v2ray ]] && [[ $(uci -q get v2ray.enabled.enabled)="1" ]]; then "$initd"/v2ray restart && echo -e "${startvpn} v2ray"; fi
	if [[ -f "$initd"/v2raya ]] && [[ $(uci -q get v2raya.config.enabled)="1" ]]; then "$initd"/v2raya restart && echo -e "${startvpn} v2rayA"; fi
	if [[ -f "$initd"/xray ]] && [[ $(uci -q get xray.enabled.enabled)="1"  ]]; then "$initd"/xray restart && echo -e "${startvpn} Xray"; fi
	if grep -q "screen -AmdS libernet" /etc/rc.local; then ./root/libernet/bin/service.sh -sl && echo -e "${startvpn} Libernet"; fi
	if grep -q "/www/xderm/log/st" /etc/rc.local; then ./www/xderm/xderm-mini start && echo -e "${startvpn} Xderm"; fi
	if grep -q "autorekonek-stl" /etc/crontabs/root; then echo "2" | stl && echo -e "${startvpn} Wegare STL"; fi
}

function ngecurl() {
	curl -si "$cv_type" | grep Date > "$dtdir"
	echo -e "${nmfl}: Đã chọn $cv_type làm máy chủ."
	logger "${nmfl}: Đã chọn $cv_type làm máy chủ."
}

function sandal() {
    hari=$(cat "$dtdir" | cut -b 12-13)
    bulan=$(cat "$dtdir" | cut -b 15-17)
    tahun=$(cat "$dtdir" | cut -b 19-22)
    jam=$(cat "$dtdir" | cut -b 24-25)
    menit=$(cat "$dtdir" | cut -b 26-31)

    case $bulan in
        "Jan")
           bulan="01"
            ;;
        "Feb")
            bulan="02"
            ;;
        "Mar")
            bulan="03"
            ;;
        "Apr")
            bulan="04"
            ;;
        "May")
            bulan="05"
            ;;
        "Jun")
            bulan="06"
            ;;
        "Jul")
            bulan="07"
            ;;
        "Aug")
            bulan="08"
            ;;
        "Sep")
            bulan="09"
            ;;
        "Oct")
            bulan="10"
            ;;
        "Nov")
            bulan="11"
            ;;
        "Dec")
            bulan="12"
            ;;
        *)
           return

    esac

	date -u -s "$tahun"."$bulan"."$hari"-"$jam""$menit" > /dev/null 2>&1
	echo -e "${nmfl}: Đặt ngày giờ thành [ $(date) ]"
	logger "${nmfl}: Đặt ngày giờ thành [ $(date) ]"
}

if [[ "$1" == "update" ]]; then
	echo -e "${nmfl}: Update tệp lệnh..."
	echo -e "${nmfl}: Đang tải tệp lệnh..."
	wget --no-check-certificate "https://raw.githubusercontent.com/CHUNGSEV/time/main/jam.sh" -O "$jamup"
	chmod +x "$jamup"
	sed -i 's/\r$//' "$jamup"
	cat << "EOF" > "$jamup2"
#!/bin/sh
# Đồng bộ ngày giờ bằng tên miền/URL
jamsh='/usr/bin/jam.sh'
jamup='/root/jamup.sh'
[[ -e "$jamup" ]] && [[ -f "$jamsh" ]] && rm -f "$jamsh" && mv "$jamup" "$jamsh"
[[ -e "$jamup" ]] && [[ ! -f "$jamsh" ]] && mv "$jamup" "$jamsh"
echo -e 'time_open_wrt: update thành công.'
chmod +x "$jamsh"
EOF
	sed -i 's/\r$//' "$jamup2"
	chmod +x "$jamup2"
	ash "$jamup2"
	[[ -f "$jamup2" ]] && rm -f "$jamup2" && echo -e "${nmfl}: Đã xóa tệp update!" && logger "${nmfl}: Đã xóa tệp update!"
elif [[ "$1" =~ "http://" ]]; then
	cv_type="$1"
elif [[ "$1" =~ "https://" ]]; then
	cv_type=$(echo -e "$1" | sed 's|https|http|g')
elif [[ "$1" =~ [.] ]]; then
	cv_type=http://"$1"
else
	echo -e "Cách dùng: Thêm tên miền sau tệp lệnh!."
	echo -e "${nmfl}: Thiếu tên miền/URL!."
	logger "${nmfl}: Thiếu tên miền/URL!."
fi

function ngepink() {
	if [[ $(curl -si ${cv_type} | grep -c 'Date:') == "1" ]]; then
		echo -e "${nmfl}: Ping ${cv_type} OK, tiếp tục tác vụ..."
		logger "${nmfl}: Ping ${cv_type} OK, tiếp tục tác vụ..."
	else 
		if [[ "$2" == "cron" ]]; then
			echo -e "${nmfl}: Cron kết nối tới ${cv_type} không khả dụng, khởi động lại VPN..."
			logger "${nmfl}: Cron kết nối tới ${cv_type} không khả dụng, khởi động lại VPN..."
			nyetop
			nyetart
		else
			echo -e "${nmfl}: Ping ${cv_type} is không khả dụng, đang ping lại..."
			logger "${nmfl}: Ping ${cv_type} is không khả dụng, đang ping lại..."
			sleep 3
			ngepink
		fi
	fi
}

if [[ ! -z "$cv_type" ]]; then
	# Script Version
	echo -e "${nmfl}: Phiên bản v${scver} ."
	logger "${nmfl}: Phiên bản v${scver} ."
	
	# Runner
	if [[ "$2" == "cron" ]]; then
		ngepink
	else
		nyetop
		ngepink
		ngecurl
		sandal
		nyetart
	fi

	# Cleaning files
	[[ -f "$logp" ]] && rm -f "$logp" && echo -e "${nmfl}: Đã dọn thư mục logp!" && logger "${nmfl}: Đã dọn thư mục logp!"
	[[ -f "$dtdir" ]] && rm -f "$dtdir" && echo -e "${nmfl}: Đã dọn thư mục tmp dir!" && logger "${nmfl}: Đã dọn thư mục tmp dir!"
	[[ -f "$jamup2" ]] && rm -f "$jamup2" && echo -e "${nmfl}: Đã xóa tệp update!" && logger "${nmfl}: Đã xóa tệp update!"
else
	echo -e "Cách dùng: Thêm tên miền sau tệp lệnh!."
	echo -e "${nmfl}: Thiếu tên miền/URL!."
	logger "${nmfl}: Thiếu tên miền/URL!."
fi
