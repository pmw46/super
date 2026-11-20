#!/bin/bash

###################################################
# 기본 설정 (경로 및 사용자명은 환경에 맞게 수정)
SRC_PATH="/root/mwp"
TARGET_USER="rebellions"
TARGET_PATH="/home/rebellions/"
SUBNET_PREFIX="192.168.222."  # 공통 대역 주소
TARGET_PASSWORD="rebellions"  # 대상 서버들의 공통 암호
###################################################

# sshpass 미설치 시 자동 설치
if ! command -v sshpass >/dev/null 2>&1; then
    sudo apt-get update >/dev/null 2>&1
    sudo apt-get install -y sshpass >/dev/null 2>&1
fi

STATUS_DIR=$(mktemp -d /tmp/rsync_status.XXXXXX)
trap 'rm -rf "$STATUS_DIR"; tput cnorm 2>/dev/null' EXIT

# __HOST_LIST__ 아래의 주소들을 배열로 읽음 (빈 줄/주석 제외)
mapfile -t HOSTS < <(sed -n '/^__HOST_LIST__/{n;:a;p;n;ba}' "$0" | grep -v -e '^[[:space:]]*$' -e '^[[:space:]]*#')

BAR_WIDTH=30

# 각 서버 전송 (서버 수만큼 동시 실행) : 진행률(%)을 상태 파일에 기록
transfer() {
    local host="$1"
    local ip="${SUBNET_PREFIX}${host}"
    local status_file="$STATUS_DIR/$host"
    local pct rc

    echo 0 > "$status_file"

    sshpass -p "$TARGET_PASSWORD" rsync -az --info=progress2 \
        -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
        "$SRC_PATH" "${TARGET_USER}@${ip}:${TARGET_PATH}" \
        </dev/null 2>&1 | stdbuf -o0 tr '\r' '\n' | while read -r line; do
            if [[ $line =~ ([0-9]+)% ]]; then
                echo "${BASH_REMATCH[1]}" > "$status_file"
            fi
        done
    rc=${PIPESTATUS[0]}

    if [ "$rc" -eq 0 ]; then
        echo 100 > "$status_file"
    else
        echo FAIL > "$status_file"
    fi
}

# 화면에 게이지 출력
draw() {
    local host val filled bar
    for host in "${HOSTS[@]}"; do
        val=$(cat "$STATUS_DIR/$host" 2>/dev/null)
        [ -z "$val" ] && val=0
        printf '\033[2K'
        if [ "$val" = "FAIL" ]; then
            printf '[%s]  전송 실패\n' "$host"
        else
            filled=$(( val * BAR_WIDTH / 100 ))
            bar=$(printf '%*s' "$filled" '' | tr ' ' '#')
            printf '[%s]  [%-*s] %3d%%\n' "$host" "$BAR_WIDTH" "$bar" "$val"
        fi
    done
}

# 전체 병렬 시작 (메인)
## 전송 시작
for host in "${HOSTS[@]}"; do
    transfer "$host" &
done

## 0.3초마다 draw를 호출해 게이지 갱신
tput civis 2>/dev/null
draw
while (( $(jobs -rp | wc -l) > 0 )); do
    sleep 0.3
    printf '\033[%dA' "${#HOSTS[@]}"
    draw
done
wait
printf '\033[%dA' "${#HOSTS[@]}"
draw

exit 0

# =========================================================
# 대상 서버의 호스트 주소를 원하는 순서대로 추가
# =========================================================
__HOST_LIST__
22
24
26
