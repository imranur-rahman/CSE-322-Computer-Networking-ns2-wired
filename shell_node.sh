#!/bin/bash

node_start=20;
node_end=60;

flow_start=10;
flow_end=50;

pack_start=100;
pack_end=500;

coverage_start=1;
coverage_end=1000;

node_cur=$node_start;

printf "YUnitText: Throughput\nXUnitText: Num of Nodes\n\"\"\n0 0.0\n" > node_vs_throughput.xgr
printf "YUnitText: Delay\nXUnitText: Num of Nodes\n\"\"\n0 0.0\n" > node_vs_delay.xgr
printf "YUnitText: Delivery Ratio\nXUnitText: Num of Nodes\n\"\"\n0 0.0\n" > node_vs_delv_ratio.xgr
printf "YUnitText: Drop Ratio\nXUnitText: Num of Nodes\n\"\"\n0 0.0\n" > node_vs_drop_ratio.xgr
printf "YUnitText: Energy Consumption\nXUnitText: Num of Nodes\n\"\"\n0 0.0\n" > node_vs_energy_consumption.xgr



while [ $node_cur -le $node_end ]

do
	
	row=5;
	col=$(($node_cur/$row));

	ns wired.tcl $node_cur $flow_start $pack_start
	awk -f wired.awk wired.tr > wired.out

	l=0;
	while read line
	do
		l=$(($l+1))
		#printf $line
		if [ "$l" == "1" ]; then
			printf "$node_cur $line\n" >> node_vs_throughput.xgr
		elif [ "$l" == "2" ]; then
			printf "$node_cur $line\n" >> node_vs_delay.xgr
		elif [ "$l" == "3" ]; then
			printf "$node_cur $line\n" >> node_vs_delv_ratio.xgr
		elif [ "$l" == "4" ]; then
			printf "$node_cur $line\n" >> node_vs_drop_ratio.xgr
		fi
	done < wired.out
	
	node_cur=$(($node_cur+10))
done