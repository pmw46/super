#!/bin/bash

### 2026-10-20
### Rebellions 검수 파일 (서버 세팅 / 1차 검수)
### AS-4125GS-TNRT2 & AS-5126GS-TNRT2


#################################################################
# 전역
#################################################################

mkdir -p /test/result/rbln_log > /dev/null 2>&1

# Log
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
OUT="/test/result/rbln_log/rbln_system_set_${TIMESTAMP}.log"

# 터미널 상태 저장
OLD_STTY=$(stty -g)

restore_tty() {
    exec > /dev/tty 2>&1
    [ -n "$OLD_STTY" ] && stty "$OLD_STTY" 2>/dev/null
}
trap restore_tty EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# 표준 출력, 에러를 동시에 화면에 출력 및 파일에 저장
exec > >(tee -a "$OUT") 2>&1


#################################################################
# 정보 입력 
#################################################################

####################################
# 사용자 입력 함수
####################################

get_users() {
    TARGET_USERS=()

    while true; do
        echo -n "사용자 계정 입력 : " > /dev/tty
        read user

        # 빈 값 방지
        if [[ -z "$user" ]]; then
            echo "계정을 입력하세요."
            continue
        fi

        # 계정 확인
        while true; do
            echo -n "입력한 계정이 맞습니까? (y/n): " > /dev/tty
            read confirm
            confirm=${confirm,,}

            case $confirm in
                y)
                    TARGET_USERS+=("$user")
                    break
                    ;;
                n)
                    echo "다시 입력해주세요." > /dev/tty
                    continue 2
                    ;;
                *)
                    echo "y 또는 n만 입력하세요." > /dev/tty
                    ;;
            esac
        done

        # 추가 입력 여부
        while true; do
            echo -n "추가 계정이 있습니까? (y/n): " > /dev/tty
            read more
            more=${more,,}

            case $more in
                y) break ;;      # 계속 입력
                n) return ;;     # 함수 종료
                *) echo "y 또는 n만 입력하세요." > /dev/tty
                   ;;
            esac
        done
    done
}

####################################
# 자동 매핑 (CSV 매핑 데이터)
####################################

MAP_FILE="/root/mwp/CSV/rbln_system_set_mapping.csv"

HW_SERIAL=$(dmidecode -s system-serial-number 2>/dev/null | tr -d ' \r\n')
AUTO_MATCHED=false

if [ -f "$MAP_FILE" ] && [ -n "$HW_SERIAL" ]; then
    MATCH_LINE=$(grep -v '#' "$MAP_FILE" | grep "^${HW_SERIAL}," | head -n 1)

    if [ -n "$MATCH_LINE" ]; then
        echo "[INFO] 시스템 시리얼 감지: $HW_SERIAL"
        echo "[INFO] 매핑 파일($MAP_FILE) 데이터를 자동으로 적용합니다."

        # CSV 2열 : Serial Number 저장
        SERIAL=$(echo "$MATCH_LINE" | cut -d',' -f2 | tr -d ' \r\n')

        # CSV 3열 : 사용자 계정 목록 분리 (계정 여러 개일 경우 ':' 구분)
        RAW_USERS=$(echo "$MATCH_LINE" | cut -d',' -f3 | tr -d ' \r\n')
        IFS=':' read -r -a TARGET_USERS <<< "$RAW_USERS"

        AUTO_MATCHED=true
    fi
fi

####################################
# 수동 (매핑 데이터가 없을 때만 수동 입력 실행)
####################################

if [ "$AUTO_MATCHED" = false ]; then
    # Serial Number 입력
    echo -n "Serial Number 입력 : " > /dev/tty
    read SERIAL

    # 사용자 계정 입력 함수 호출
    get_users
fi

####################################
# 결과 출력
####################################

echo
echo "================================="
echo "◇ Serial Number : $SERIAL"
echo
echo "◇ 사용자 계정 목록 :"

for user in "${TARGET_USERS[@]}"; do
    echo " - $user"
done

echo "================================="


#################################################################
# spinner 애니메이션 함수
#################################################################

spinner() {
    tput civis > /dev/tty 2>/dev/null

    bash -c "$*" &
    local pid=$!

    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local delay=0.1

    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        local char="${spinstr%"$temp"}"
        spinstr="${temp}${char}"

        printf "\r %s 진행 중..." "$char" > /dev/tty
        sleep "$delay"
    done

    wait "$pid"
    local exit_code=$?

    tput cnorm > /dev/tty 2>/dev/null
    printf "\r\033[K" > /dev/tty

    return $exit_code
}
export -f spinner


#################################################################
# 단락
#################################################################

function print_titleline() {
    echo
    echo
    echo
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "  ▶▶ $1"
    echo "╚══════════════════════════════════════════════════════════╝"
}

function print_startline() {
    echo
    echo
    echo "┌──────────────────────────────────────┐"
    echo "│ ▷▷ $1"
    echo "└──────────────────────────────────────┘"
}


#################################################################
# 패키지 설치
#################################################################

print_titleline "패키지 설치"

####################################
# 패키지 설치 - 검수 기본 패키지
####################################

print_startline "검수 기본 패키지"

# 프롬프트 및 대화형 팝업 창 차단
export DEBIAN_FRONTEND=noninteractive

OS_VERSION=$(grep -oP '(?<=VERSION_ID=")[^"]*' /etc/os-release)

COMMON_PKGS=(ipmitool vim net-tools pciutils smartmontools wget curl bc sosreport unzip ethtool lrzsz build-essential dkms)

if [ "$OS_VERSION" = "24.04" ]; then
    BASE_PKGS=(ntpsec-ntpdate chrony "${COMMON_PKGS[@]}")
elif [ "$OS_VERSION" = "22.04" ]; then
    BASE_PKGS=(ntp ntpdate "${COMMON_PKGS[@]}")
else
    BASE_PKGS=(ntp ntpdate "${COMMON_PKGS[@]}")
fi

LOG_DIR="/tmp/rbln/pkg/default"
mkdir -p "$LOG_DIR"

RESULTS=()

for pkg in "${BASE_PKGS[@]}"; do
    LOG_FILE="${LOG_DIR}/${pkg}.log"
    FAIL_LOG_FILE="${LOG_DIR}/${pkg}_fail.log"

    if dpkg -s "$pkg" >/dev/null 2>&1; then
        RESULTS+=("[INFO] $pkg 이미 설치됨")
        continue
    fi

    if spinner apt install -y "$pkg" > "$LOG_FILE" 2>&1; then
        RESULTS+=("[SUCCESS] $pkg")
    else
        mv "$LOG_FILE" "$FAIL_LOG_FILE"
        RESULTS+=("[FAILED] $pkg")
    fi
done

echo
echo "================="
echo "[INFO] 감지된 OS 버전 : Ubuntu $OS_VERSION"
for res in "${RESULTS[@]}"; do
    echo "$res"
done
echo
echo "[PATH] 설치 로그 경로 : $LOG_DIR"
echo "================="

sleep 2

####################################
# 패키지 설치 - 리벨리온 패키지
####################################

print_startline "리벨리온 패키지"

REBELLION_PKGS=(cifs-utils dkms ifenslave ipmitool jq net-tools nfs-common python3-pip vim libcmocka0)

LOG_DIR="/tmp/rbln/pkg/rbln"
mkdir -p "$LOG_DIR"

RESULTS=()

for pkg in "${REBELLION_PKGS[@]}"; do
    LOG_FILE="${LOG_DIR}/${pkg}.log"
    FAIL_LOG_FILE="${LOG_DIR}/${pkg}_fail.log"

    if dpkg -s "$pkg" >/dev/null 2>&1; then
        RESULTS+=("[INFO] $pkg 이미 설치됨")
        continue
    fi

    if spinner apt install -y "$pkg" > "$LOG_FILE" 2>&1; then
        RESULTS+=("[SUCCESS] $pkg")
    else
        mv "$LOG_FILE" "$FAIL_LOG_FILE" >/dev/null 2>&1
        RESULTS+=("[FAILED] $pkg")
    fi
done

echo
echo "================="
for res in "${RESULTS[@]}"; do
    echo "$res"
done
echo
echo "[PATH] 설치 로그 경로: $LOG_DIR"
echo "================="

sleep 2


#################################################################
# 검수 준비
#################################################################

print_titleline "검수 준비"

####################################
# 검수 준비 - kwafer 스크립트 다운로드
####################################

print_startline "kwafer 스크립트 다운로드"

KWAFER_DIR="/test/kwafer"

if [ -d "$KWAFER_DIR" ]; then
    echo "[INFO] 이미 다운로드 완료됨"
else
    mkdir -p /test/result && cd /test || { echo "[FAILED] /test 디렉토리 접근 실패"; exit 1; }

    if spinner wget -q ftp://192.168.1.253/download/kwafer/kwafer.tar.gz; then
        if tar -zxf kwafer.tar.gz; then
            rm -rf kwafer.tar.gz
            echo
            ls -alh
            echo
            echo "[SUCCESS] 다운로드 완료"
        else
            echo
            echo "[FAILED] 압축 해제 실패"
        fi
    else
        echo
        echo "[FAILED] 다운로드 실패"
    fi
fi

sleep 3

####################################
# 검수 준비 - kwafer 스크립트 설치
####################################

print_startline "kwafer 스크립트 설치"

echo "# kwafer 스크립트 명령어 alias 설정 : N"
echo "# SuperSolution 기본 패키지 설치"
echo "# 지역 및 언어 설정"
echo "# BIOS, BMC, OS 시간 동기화"
echo

spinner "printf 'N\n' | stdbuf -oL /test/kwafer/5-install 2>&1 | awk '/전체 결과 요약/,0' >> \"$OUT\""

sleep 3


#################################################################
# kwafer 스크립트
#################################################################

print_titleline "kwafer 스크립트"

if ! command -v expect >/dev/null 2>&1; then
    apt install -y expect >/dev/null 2>&1
fi

sleep 2

expect <<EOF
log_user 1
set timeout -1

spawn /test/kwafer/5-disk

expect "CHOICE"
send "1\r"
expect "CHOICE"
send "1\r"
expect "Write a serial"
send "$SERIAL\r"
sleep 2

expect "CHOICE"
send "5\r"
sleep 3

# 5번 완료 후 Ctrl + C
send "\003"
sleep 1
expect eof
EOF

sleep 2

# 6번 실행 후 Ctrl + C
expect <<EOF
log_user 1
set timeout -1
spawn /test/kwafer/5-disk

expect "CHOICE"
send "6\r"
sleep 2

send "\003"
sleep 1
expect eof
EOF

sleep 2

# 7번 실행 후 Ctrl + C
expect <<EOF
log_user 1
set timeout -1
spawn /test/kwafer/5-disk

expect "CHOICE"
send "7\r"
sleep 2

send "\003"
sleep 1
expect eof
EOF

stty sane
sleep 2

apt purge -y expect > /dev/null 2>&1
apt autoremove -y > /dev/null 2>&1

sleep 2


#################################################################
# 운영체제
#################################################################

print_titleline "운영체제"

print_startline "OS 버전"
awk -F'=' '$1=="ID_LIKE" {id_like=$NF}; $1=="ID" {id=$NF}; $1=="VERSION" {version=$NF}; END {printf "%s %s %s\n", id_like, id, version}' /etc/*release | sed 's/"//g'
sleep 1

print_startline "커널 버전"
uname -r
sleep 1

print_startline "HWE Support"
hwe-support-status
sleep 1


#################################################################
# 시간 동기화
#################################################################

print_titleline "시간 동기화"

echo "[INFO] OS / IPMI / BIOS 시간이 검수 시점과 모두 동일해야 합니다."

print_startline "OS 언어 및 지역 설정"

localectl set-locale LANG=en_US.UTF-8 && \
timedatectl set-timezone Asia/Seoul

current_locale=$(localectl status | grep "System Locale" | awk -F= '{print $2}' | xargs)
current_timezone=$(timedatectl status | grep "Time zone" | awk '{print $3}')

if [[ "$current_locale" == "en_US.UTF-8" ]] && [[ "$current_timezone" == "Asia/Seoul" ]]; then
    echo "[SUCCESS] 설정 성공"
    echo
    echo "현재 LANG : $current_locale"
    echo "현재 Timezone : $current_timezone"
else
    echo "[FAILED] 설정 실패"
    echo
    echo "현재 LANG : $current_locale"
    echo "현재 Timezone : $current_timezone"
fi

sleep 1

print_startline "OS 시간 동기화"

NTP_SERVER="192.168.1.254"
RESULT=1

OUTPUT=$(ntpdate $NTP_SERVER 2>&1)
RET=$?

echo "$OUTPUT"
echo

if [ $RET -eq 0 ]; then
    echo "[SUCCESS] ntpdate로 시간 동기화 완료"
    RESULT=0
elif echo "$OUTPUT" | grep -qi "NTP socket is in use"; then
    echo "[INFO] NTP 데몬(ntpd)이 이미 실행 중입니다."
    echo
    NTPQ_OUTPUT=$(ntpq -p 2>/dev/null)
    echo "[INFO] 현재 서버의 NTP 동기화 상태 확인"
    echo
    echo "$NTPQ_OUTPUT"
    echo

    if echo "$NTPQ_OUTPUT" | grep -q "^\*"; then
        echo "[SUCCESS] ntpd가 정상적으로 시간 동기화 중"
        RESULT=0
    else
        echo "[FAILED] ntpd는 실행 중이나 동기화 안 됨"
        RESULT=1
    fi
else
    echo "[FAILED] ntpdate 실행 실패"
    RESULT=1
fi

sleep 1

print_startline "IPMI 시간 동기화"
result=$(ipmitool sel time set now 2>&1)
RET=$?
echo "$result"
echo
if [ $RET -eq 0 ]; then
    echo "[SUCCESS] ipmitool 설정 완료"
else
    echo "[FAILED] ipmitool 설정 실패"
fi
sleep 1

print_startline "HW 시간 동기화"
if hwclock -w --localtime; then
    echo "[SUCCESS] hwclock 설정 완료"
else
    echo "[FAILED] hwclock 설정 실패"
fi
sleep 1

print_startline "OS 시간 확인"
date
sleep 1

print_startline "IPMI 시간 확인"
ipmitool sel time get
sleep 1

print_startline "HW 시간 확인"
hwclock --show
sleep 1


#################################################################
# PCI
#################################################################

print_titleline "PCI"

print_startline "PCI Update"
update-pciids --quiet 2>&1 | grep --line-buffered 'Done' 
RET=${PIPESTATUS[0]}
if [ $RET -eq 0 ]; then
    echo
    echo "[SUCCESS] 업데이트 완료"
else
    echo
    echo "[FAILED] 업데이트 실패"
fi
sleep 1

print_startline "lspci 버전 확인"
lspci --version
sleep 1


#################################################################
# Optional S/W (S/W RAID)
#################################################################

print_titleline "Optional S/W (S/W RAID)"

print_startline "RAID Management - mdraid"

shopt -s nullglob
md_devs=(/dev/md*)
filtered_md_devs=()
for md in "${md_devs[@]}"; do
    [[ -b "$md" && "$md" =~ /dev/md[0-9]+$ ]] && filtered_md_devs+=("$md")
done
md_devs=("${filtered_md_devs[@]}")

HW_RAID_REQUIRED=0

if [ ${#md_devs[@]} -gt 0 ]; then
    echo "[SUCCESS] S/W RAID 장치가 발견되었습니다."
    echo
    for md in "${md_devs[@]}"; do
        echo "===== RAID 장치 : $md ====="
        mdadm --detail "$md"
    done
    echo
    echo
    echo "[INFO] S/W RAID 확인 → H/W RAID - StorCLI 항목을 생략합니다."
    HW_RAID_REQUIRED=0
else
    echo "[INFO] S/W RAID 미구성 확인.. 물리적 H/W RAID 컨트롤러 존재 여부 확인 중..."
    echo
    if lspci | grep -qiE 'megaRAID|PERC|LSI Logic|Avago|Broadcom.*RAID'; then
        echo "[SUCCESS] 물리 H/W RAID 컨트롤러 장치가 감지되었습니다."
        echo "$(lspci | grep -iE 'megaRAID|PERC|LSI Logic|Avago|Broadcom.*RAID')"
        echo
        echo "[INFO] H/W RAID - StorCLI 설치 및 CC 설정을 진행합니다."
        HW_RAID_REQUIRED=1
    else
        echo "[INFO] H/W RAID 컨트롤러가 감지되지 않았습니다."
        echo "[INFO] H/W RAID - StorCLI 관련 모든 작업을 건너뜁니다."
        HW_RAID_REQUIRED=0
    fi
fi

sleep 1


#################################################################
# Optional S/W (H/W RAID)
#################################################################

print_titleline "Optional S/W (H/W RAID)"

print_startline "RAID Management - StorCLI"

echo "# StorCLI 다운로드 및 설치"

if [ "${HW_RAID_REQUIRED:-0}" -eq 0 ]; then
    echo
    echo "[INFO] H/W RAID 미대상이므로 StorCLI 설치를 생략합니다."
else
    echo
    echo "[INFO] H/W RAID 대상 장비이므로 StorCLI 설치를 진행합니다."
    echo
    echo

    echo "# OS 계열 확인 및 변수 등록"
    echo
    . /etc/os-release
    os_id_like=$(echo ${ID_LIKE} | grep -q 'debian' && echo "debian" || echo "rhel")
    echo "OS 유형: $os_id_like"
    echo
    echo
    sleep 1

    echo "# OS 계열별 storcli 설치 파일 다운로드"
    echo
    DEB_FILE="/test/storcli_007.3205.0000.0000_all.deb"
    RPM_FILE="/test/storcli-007.3205.0000.0000-1.noarch.rpm"

    if command -v storcli64 >/dev/null 2>&1 || [ -f /opt/MegaRAID/storcli/storcli64 ]; then
        echo "[INFO] storcli 설치 파일이 존재합니다. 다운로드를 건너뜁니다."
        echo
    else
        echo "[INFO] storcli 설치 파일이 없습니다. 다운로드를 진행합니다."
        echo
        if [ "${os_id_like}" == "debian" ]; then
            if wget -q -O "${DEB_FILE}" ftp://192.168.1.253/download/raid_controller/storcli_007.3205.0000.0000_all.deb >/dev/null 2>&1; then
                [ -s "${DEB_FILE}" ] && echo "[SUCCESS] storcli 다운로드 완료" || echo "[FAILED] 파일은 생성됐지만 사이즈가 0입니다."
            else
                echo "[FAILED] storcli 다운로드 실패"
            fi
        else
            if wget -q -O "${RPM_FILE}" ftp://192.168.1.253/download/raid_controller/storcli-007.3205.0000.0000-1.noarch.rpm >/dev/null 2>&1; then
                [ -s "${RPM_FILE}" ] && echo "[SUCCESS] storcli 다운로드 완료" || echo "[FAILED] 파일은 생성됐지만 사이즈가 0입니다."
            else
                echo "[FAILED] storcli 다운로드 실패"
            fi
        fi
    fi

    echo
    echo
    sleep 1

    echo "# OS 계열별 storcli 설치"
    echo
    if [ "${os_id_like}" == "debian" ]; then
        echo "[INFO] Debian 계열 확인"
        if dpkg -l | grep -q "^ii\s*storcli"; then
            echo "[INFO] storcli 이미 설치되어 있습니다."
        else
            echo "[INFO] 설치 진행"
            dpkg -i "${DEB_FILE}" >/dev/null 2>&1 && echo "[SUCCESS] storcli 설치 완료" || echo "[FAILED] storcli 설치 실패 (DEB)"
        fi
    else
        echo "[INFO] RHEL 계열 확인"
        if rpm -q storcli &>/dev/null; then
            echo "[INFO] storcli 이미 설치되어 있습니다."
        else
            echo "[INFO] 설치 진행"
            rpm -i "${RPM_FILE}" >/dev/null 2>&1 && echo "[SUCCESS] storcli 설치 완료" || echo "[FAILED] storcli 설치 실패 (RPM)"
        fi
    fi

    echo
    echo
    sleep 1

    echo "# storcli 설치 확인"
    echo
    STORCLI_PATH=$(find /opt -name "storcli64" 2>/dev/null | head -n 1)
    if [ -n "$STORCLI_PATH" ] && "$STORCLI_PATH" show >/dev/null 2>&1; then
        echo "[SUCCESS] storcli64 실행 완료"
        echo "[PATH] $STORCLI_PATH"
    else
        echo "[FAILED] storcli64 실행 실패 또는 파일 없습니다."
    fi

fi

echo
echo
sleep 1

STORCLI=/opt/MegaRAID/storcli/storcli64

echo "# CC(Consistency Check) Off 설정"
echo
if [ "${HW_RAID_REQUIRED:-0}" -eq 1 ] && [ -x "$STORCLI" ]; then
    $STORCLI /c0 set cc=off
else
    echo "[INFO] H/W RAID 미대상 또는 StorCLI 미설치 → CC 설정을 건너뜁니다."
fi

sleep 1

echo "# CC(Consistency Check) Off 확인"
echo
if [ "${HW_RAID_REQUIRED:-0}" -eq 1 ] && [ -x "$STORCLI" ]; then
    $STORCLI /c0 show cc | grep 'CC Operation Mode\|CC Current State'
else
    echo "[INFO] H/W RAID 미대상 또는 StorCLI 미설치 → CC 확인을 건너뜁니다."
fi

sleep 1


#################################################################
# Firmware Update
#################################################################

print_titleline "Firmware Update"

print_startline "Rebellions Firmware Download"
TARGET_DIR="/test/firm"
if [ -d "$TARGET_DIR" ]; then
    echo "[INFO] $TARGET_DIR 이미 존재합니다."
else
    if cd /test && \
       wget -q ftp://192.168.1.253/download/rbln/firm.tar.gz && \
       tar -zvxf firm.tar.gz &>/dev/null && \
       rm -f firm.tar.gz; then
        sleep 2
        echo
        echo "[SUCCESS] Firmware 다운로드 완료"
    else
        echo
        echo "[FAILED] Firmware 다운로드 실패"
    fi
fi
echo
echo "[INFO] 다운로드 확인 :"
ls -1 "$TARGET_DIR"
sleep 2

print_startline "PLX 버전 확인"
/test/firm/PLX_04.16.00.00/g4Xdiagnostics.x86_64 --list
sleep 1


#################################################################
# Rebellions OS 기본 세팅
#################################################################

print_titleline "Rebellions OS 기본 세팅"

print_startline "HostInterface OFF"
if ipmitool raw 0x30 0xB5 1 0; then
   echo "[SUCCESS] 설정 성공"
   echo
   status=$(ipmitool raw 0x30 0xB5 0)
   echo "[INFO] 현재 상태 : $status"
else
   echo "[FAILED] 설정 실패"
fi
sleep 1

print_startline "cloud-init 비활성화"
touch /etc/cloud/cloud-init.disabled
if [ -f /etc/cloud/cloud-init.disabled ]; then
    ls -l /etc/cloud/cloud-init.disabled
    echo
    echo "[SUCCESS] 비활성화 완료, 파일이 존재합니다."
else
    echo "[FAILED] 생성 실패, 파일이 없습니다."
fi
sleep 1

print_startline "자동 업데이트 중지"
sed -i "s/1/0/g" /etc/apt/apt.conf.d/20auto-upgrades /etc/apt/apt.conf.d/10periodic && \
sed -i "/Unattended-Upgrade/d" /etc/apt/apt.conf.d/10periodic && \
echo 'APT::Periodic::Unattended-Upgrade "0";' >> /etc/apt/apt.conf.d/10periodic

echo "[INFO] 설정 확인 (값이 0인지)"
echo
grep -n "APT::Periodic" /etc/apt/apt.conf.d/20auto-upgrades
grep -n "APT::Periodic" /etc/apt/apt.conf.d/10periodic
echo

if grep -q 'APT::Periodic::Unattended-Upgrade "0";' /etc/apt/apt.conf.d/10periodic; then
   echo "[SUCCESS] 자동 업데이트 비활성화 완료"
else
   echo "[FAILED] 설정 확인이 필요합니다."
fi
sleep 1

print_startline "GRUB 설정"

echo "# CLI 모드 부팅 설정"
sed -i "s/\#GRUB_TERMINAL/GRUB_TERMINAL/" /etc/default/grub && \
systemctl set-default multi-user.target
echo

grub_file="/etc/default/grub"
grub_terminal_line=$(grep 'GRUB_TERMINAL' "$grub_file")
if [[ -n "$grub_terminal_line" ]]; then
    echo "[SUCCESS] GRUB_TERMINAL 모드 활성화"
    echo
    echo -e "[INFO] 현재 설정 ($grub_file) :\n$grub_terminal_line"
    echo
else
    echo "[FAILED] GRUB_TERMINAL 설정 실패"
    echo
fi

default_target=$(systemctl get-default)
if [[ "$default_target" == "multi-user.target" ]]; then
    echo "[SUCCESS] CLI 모드 적용 완료"
else
    echo "[FAILED] CLI 모드 적용 실패"
fi
echo
echo "[INFO] 현재 설정 (systemctl get-default) : $default_target"
echo
echo
sleep 1

echo "# Rebellions GRUB 설정"
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="transparent_hugepage=madvise pcie_aspm=force pci=pcie_bus_perf pci=bfsort"/' /etc/default/grub
echo

changed_line=$(grep '^GRUB_CMDLINE_LINUX_DEFAULT=' /etc/default/grub)
if echo "$changed_line" | grep -q 'transparent_hugepage=madvise'; then
   echo "[SUCCESS] GRUB 커널 파라미터 적용"
else
   echo "[FAILED] GRUB 커널 파라미터 설정 실패"
fi
echo
echo "[INFO] 현재 설정 (/etc/default/grub) :"
echo "$changed_line"
echo
echo
sleep 1

echo "# GRUB 적용"
update-grub
echo
sleep 3


#################################################################
# Rebellions 세팅
#################################################################

print_titleline "Rebellions 세팅"

print_startline "Rebellions File Download"
TARGET_DIR="/test/rbln"
if [ -d "$TARGET_DIR" ]; then
    echo "[INFO] $TARGET_DIR 이미 존재함"
else
    if cd /test && \
       spinner wget -q ftp://192.168.1.253/download/rbln/rbln.tar.gz && \
       tar -zxvf rbln.tar.gz &>/dev/null && \
       rm -f rbln.tar.gz; then
        sleep 2
        echo "[SUCCESS] Rebellions File 다운로드 완료"
    else
        echo "[FAILED] Rebellions File 다운로드 실패"
    fi
fi
echo
echo "[INFO] 다운로드 확인 :"
ls -1 "$TARGET_DIR"
sleep 2

print_startline "Docker install"
LOG_FILE="/tmp/rbln/docker_install.log"
if command -v docker &>/dev/null; then
    echo "[INFO] Docker 가 이미 설치되어 있습니다."
else
    if spinner bash /test/rbln/docker_installer > "$LOG_FILE" 2>&1; then
        echo "[SUCCESS] Docker 설치 완료"
    else
        echo "[FAILED] Docker 설치 실패"
        echo
        echo "[INFO] 설치 로그 확인 : $LOG_FILE"
        echo
        tail -n 10 "$LOG_FILE"
    fi
fi
sleep 2

print_startline "Docker install check"
if systemctl is-active --quiet docker; then
   echo "Docker is running."
   echo
   echo "Docker version : $(docker --version 2>/dev/null)"
else
   echo "Docker is not running."
fi
sleep 1

print_startline "Docker 그룹 유저 추가"
for user in "${TARGET_USERS[@]}"; do
    if id -nG "$user" | grep -qw docker; then
        echo "[INFO] $user 계정은 이미 docker 그룹에 포함되어 있습니다."
    else
        usermod -aG docker "$user"
        if id -nG "$user" | grep -qw docker; then
            echo "[SUCCESS] $user 계정이 docker 그룹에 포함되었습니다."
        else
            echo "[FAILED] $user 계정 docker 그룹 추가 실패"
        fi
    fi
done
sleep 1

print_startline "Docker 그룹 유저 확인"
cat /etc/group | grep -i docker
sleep 1


#################################################################
# BMC 세팅
#################################################################

print_titleline "BMC 세팅"

print_startline "Sensor"
echo "# 3열 OK 확인"
echo
echo
ipmitool -I open sdr elist | tee /test/result/ipmitool_sdr_elist_$(dmidecode -s system-serial-number)_$(date +%Y%m%d"-"%H%M).log
sleep 1

print_startline "EventLog"
echo "# 특이사항 확인"
echo "# 특이사항 없을 경우 → ipmitool -I open sel clear 명령어 직접 실행할 것"
echo "# 이후 reboot 실행"
echo
echo
ipmitool -I open sel elist
echo
echo


#################################################################
# 마무리
#################################################################

exec > /dev/tty 2>&1
sleep 1

stty "$OLD_STTY" 2>/dev/null

if [ -f "$OUT" ]; then
    sed -i 's/\r//g' "$OUT"
    sed -i 's/\x1b\[[0-9;]*[HJ]//g' "$OUT"
    sed -i -e 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
           -e 's/\x1b\[[0-9;]*m//g' \
           -e 's/\x1b//g' "$OUT"
fi

echo
echo
sleep 1

echo "=========================================================="
echo " 검수가 완료되었습니다. 파일 확인 : $OUT"
echo "=========================================================="
echo
echo
