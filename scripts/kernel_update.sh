#!/bin/bash

# 프롬프트 및 대화형 팝업 창 차단
export DEBIAN_FRONTEND=noninteractive

# 시스템 모델 확인
MODEL=$(cat /sys/class/dmi/id/product_name 2>/dev/null || dmidecode -s system-product-name)

case "${MODEL}" in
  *4125GS*) TARGET_VER="6.8.0-138-generic" ;;
  *5126GS*) TARGET_VER="6.8.0-139-generic" ;;
  *)
    echo "[ERROR] 지원하지 않는 모델입니다 : '${MODEL}'" >&2
    exit 1
    ;;
esac

CURRENT_VER=$(uname -r)
echo
echo
echo "# 모델 : ${MODEL} / 현재 커널 : ${CURRENT_VER} / 대상 커널 : ${TARGET_VER}"
echo
echo

# 대상 커널 설치
apt update
apt install -y \
  linux-image-${TARGET_VER} \
  linux-headers-${TARGET_VER} \
  linux-modules-${TARGET_VER} \
  linux-modules-extra-${TARGET_VER} || exit 1

# 커널 자동 업데이트 방지 (hold)
apt-mark hold \
  linux-image-${TARGET_VER} \
  linux-headers-${TARGET_VER} \
  linux-modules-${TARGET_VER} \
  linux-modules-extra-${TARGET_VER}

# GRUB 설정 변경
sed -i '/^GRUB_SAVEDEFAULT=/d' /etc/default/grub
sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved\nGRUB_SAVEDEFAULT=true/' /etc/default/grub

# GRUB 설정 갱신
update-grub

# GRUB 엔트리 존재 확인
ENTRY="Ubuntu, with Linux ${TARGET_VER}"
if ! grep -q "menuentry '${ENTRY}'" /boot/grub/grub.cfg; then
  echo "[ERROR] GRUB 엔트리를 찾을 수 없습니다 : ${ENTRY}" >&2
  exit 1
fi

# 대상 커널로 부팅 고정
grub-set-default "Advanced options for Ubuntu>Ubuntu, with Linux ${TARGET_VER}"
