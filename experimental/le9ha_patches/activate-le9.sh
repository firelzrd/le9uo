#!/bin/sh

# Working set protection (le9ha)
if [ -e /proc/sys/vm/clean_min_kbytes ]; then
	clean_min_kb=$((totalmem_kb * 3 / 100))
	clean_low_kb=$((totalmem_kb * 5 / 100))
	clean_min_kb_min=8192
	clean_low_kb_min=`echo "v=e(l($totalmem_kb)*l(sqrt(2)))*1000;scale=0;v/1" | bc -l`
	if [ $clean_min_kb -lt $clean_min_kb_min ]; then clean_min_kb=$clean_min_kb_min; fi
	if [ $clean_low_kb -lt $clean_low_kb_min ]; then clean_low_kb=$clean_low_kb_min; fi
	sysctl -w vm.clean_low_kbytes=$clean_low_kb
	sysctl -w vm.clean_min_kbytes=$clean_min_kb
	sysctl -w vm.swappiness=1
	echo n | tee /sys/kernel/mm/lru_gen/enabled
fi

