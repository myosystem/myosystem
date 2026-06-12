# ==============================================================
# myosystem — 최상위 Makefile
# ==============================================================
# Usage:
#   make                  → 전체 Debug 빌드
#   make CONFIG=Release   → 전체 Release 빌드
#   make mykernel         → mykernel만 빌드 (의존성 포함)
#   make mylibc CONFIG=Release
#   make clean            → 전체 clean
#   make clean-mykernel   → mykernel만 clean
#
# 빌드 순서 (slnx 의존성 그래프 기준):
#   mylibc ──┬──→ mydisplay ──┐
#             ├──→ testp      ├──→ mykernel
#             └──────────────┘
#   mybootloader ────────────────→ mykernel
# ==============================================================

CONFIG ?= Debug
MAKE   := $(MAKE) --no-print-directory
export CONFIG

.PHONY: all clean \
        mylibc mybootloader mydisplay testp mykernel \
        clean-mylibc clean-mybootloader clean-mydisplay clean-testp clean-mykernel

# ---------------------------------------------------------------
# all: 전체 빌드
# ---------------------------------------------------------------
all: mykernel

# ---------------------------------------------------------------
# 개별 프로젝트 타겟
# ---------------------------------------------------------------
mylibc:
	@echo "=== [mylibc] CONFIG=$(CONFIG) ==="
	$(MAKE) -C mylibc CONFIG=$(CONFIG)

mybootloader:
	@echo "=== [mybootloader] CONFIG=$(CONFIG) ==="
	$(MAKE) -C mybootloader CONFIG=$(CONFIG)

mydisplay: mylibc
	@echo "=== [mydisplay] CONFIG=$(CONFIG) ==="
	$(MAKE) -C mydisplay CONFIG=$(CONFIG)

testp: mylibc
	@echo "=== [testp] CONFIG=$(CONFIG) ==="
	$(MAKE) -C testp CONFIG=$(CONFIG)

mykernel: mylibc mybootloader mydisplay testp
	@echo "=== [mykernel] CONFIG=$(CONFIG) ==="
	$(MAKE) -C mykernel CONFIG=$(CONFIG)

# ---------------------------------------------------------------
# clean 타겟
# ---------------------------------------------------------------
clean: clean-mylibc clean-mybootloader clean-mydisplay clean-testp clean-mykernel

clean-mylibc:
	$(MAKE) -C mylibc clean

clean-mybootloader:
	$(MAKE) -C mybootloader clean

clean-mydisplay:
	$(MAKE) -C mydisplay clean

clean-testp:
	$(MAKE) -C testp clean

clean-mykernel:
	$(MAKE) -C mykernel clean
