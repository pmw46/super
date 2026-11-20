#!/bin/bash

INTERFACE="eno1"
TARGET_NET="192.168.222.0/24"
LINE="------------------------------------------------------------------"

# arp-scan 설치
if ! command -v arp-scan &> /dev/null; then
    apt-get install -y -qq arp-scan &> /dev/null
fi

# 스캔 수행 후 메모리에 저장 (-g : 같은 IP의 중복 응답 패킷 제거)
echo "Scanning network ($TARGET_NET) on $INTERFACE..."
SCAN_RESULT=$(sudo arp-scan -I "$INTERFACE" --bandwidth=1M -g "$TARGET_NET")

echo -e "\n=== Scan Results ==="

# 아래 '__MAC_LIST__' 이후의 항목을 순서대로 읽어서 검색
sed -n '/^__MAC_LIST__/,$p' "$0" | tail -n +2 | while read -r entry; do
    # 빈 줄이나 주석(#) 제외
    [[ -z "$entry" || "$entry" =~ ^# ]] && continue

    # [라벨] 형식이면 그대로 출력
    if [[ "$entry" =~ ^\[.*\]$ ]]; then
        echo "$entry"
        continue
    fi

    # MAC 검색 (매칭되는 줄 전부 출력, 없으면 NOT FOUND)
    result=$(echo "$SCAN_RESULT" | grep -i "$entry")
    if [[ -n "$result" ]]; then
        echo "$result"
    else
        echo -e "-\t\t$entry\tNOT FOUND"
    fi

    # MAC별 구분선
    echo "$LINE"
done

exit 0

# =========================================================
# 아래에 스캔할 MAC 주소를 원하는 순서대로 추가
# [라벨] 형식의 줄은 구분용으로 그대로 출력됨
# =========================================================
__MAC_LIST__
[BMC]
7c:c2:55:61:3e:3b
[OS]
90:5a:08:9d:b6:96
