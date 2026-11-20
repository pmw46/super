#!/bin/bash

BASE_DIR="/root/rbln/NIC_Firm_Update"
NICCLI_DIR="$BASE_DIR/niccli"
NICCLI_BIN="./niccli"
FIRM_DIR="$BASE_DIR/NIC_Firm"

# Broadcom 커널 모듈(bnxt_en) 로드
if ! lsmod | grep -q bnxt_en; then
    echo "Broadcom 커널 모듈(bnxt_en)을 로드합니다..."
    modprobe bnxt_en
fi

# niccli 디렉토리 이동
if [ ! -d "$NICCLI_DIR" ]; then
    echo "ERROR: niccli 디렉토리를 찾을 수 없습니다: $NICCLI_DIR"
    exit 1
fi

cd "$NICCLI_DIR" || exit 1
chmod +x "$NICCLI_BIN"

echo "=============================================="
echo "Broadcom NIC 자동 감지 및 펌웨어 업데이트 시작"
echo "=============================================="

# 시스템의 모든 Broadcom NIC 스캔
INDEX_LIST=$($NICCLI_BIN --list | grep -E '^[[:space:]]*[0-9]+\)' | awk -F')' '{print $1}' | tr -d ' ')

if [ -z "$INDEX_LIST" ]; then
    echo "시스템에서 감지된 Broadcom NIC가 없습니다."
    exit 1
fi

# 실제 장착된 NIC 포트 기준으로 루프 실행
for idx in $INDEX_LIST; do
    LINE=$($NICCLI_BIN --list | grep -E "^[[:space:]]*$idx\)")
    BOARD_ID=$(echo "$LINE" | awk '{print $2}')
    PCI_ADDR=$(echo "$LINE" | awk '{print $5}')
    NIC_LABEL="${BOARD_ID:-NIC} [${PCI_ADDR:-PCI}]"

    echo ""
    echo "------------------------------------------"
    echo "장치 검사 중: $NIC_LABEL"
    echo "------------------------------------------"

    DEV_INFO=$($NICCLI_BIN -i $idx show)
    ACTUAL_DEV_ID=$(echo "$DEV_INFO" | grep "PCI Device ID" | awk -F':' '{print $2}' | tr -d ' ' | tr 'a-z' 'A-Z')

    MATCH_FOUND=0

    # 저장된 패키지 중 매칭되는 펌웨어 탐색
    for pkg_file in "$FIRM_DIR"/*.pkg; do
        [ -e "$pkg_file" ] || continue
        pkg_name=$(basename "$pkg_file")

        SHOW_OUT=$($NICCLI_BIN -i $idx show -D -f "$pkg_file" 2>&1)

        # Device ID 일치 여부 확인
        if [ -n "$ACTUAL_DEV_ID" ] && echo "$SHOW_OUT" | grep -i "Target PCI-ID" | grep -qi "$ACTUAL_DEV_ID"; then
            MATCH_FOUND=1
            echo "[패키지 매칭] 호환 패키지 발견: $pkg_name"
            echo ""
            
            UPDATE_OUT=$($NICCLI_BIN -i $idx fw --update -f "$pkg_file" -y 2>&1)
            UPDATE_STATUS=$?

            echo "$UPDATE_OUT"
            echo ""

            if [ $UPDATE_STATUS -eq 0 ]; then
                echo "[성공] $NIC_LABEL 펌웨어 업데이트 완료. NIC Reset 진행..."
                $NICCLI_BIN -i $idx fw --reset
            elif echo "$UPDATE_OUT" | grep -qi "already up-to-date"; then
                echo "[최신 상태] $NIC_LABEL 은 이미 최신 펌웨어 상태입니다."
            else
                echo "[실패] $NIC_LABEL 펌웨어 업데이트 중 오류 발생."
            fi
            break
        fi
    done

    if [ $MATCH_FOUND -eq 0 ]; then
        echo "[스킵] $NIC_LABEL 장치와 일치하는 펌웨어 패키지(.pkg)가 폴더에 없습니다."
    fi
done

echo ""
echo "=========================================="
echo ">> 모든 검사 및 업데이트 절차가 완료되었습니다."
echo "=========================================="
echo ""

