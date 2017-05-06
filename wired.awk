BEGIN {
	max_node = 2000;
	nSentPackets = 0.0 ;		
	nReceivedPackets = 0.0 ;
	rTotalDelay = 0.0 ;
	max_pckt = 10000;

	header = 20;	

	idHighestPacket = 0;
	idLowestPacket = 100000;
	rStartTime = 10000.0;
	rEndTime = 0.0;
	nReceivedBytes = 0;
	rEnergyEfficeincy = 0;

	nDropPackets = 0.0;

	total_energy_consumption = 0;

	temp = 0;
	
	for (i=0; i<max_node; i++) {
		energy_consumption[i] = 0;		
	}

	total_retransmit = 0;
	for (i=0; i<max_pckt; i++) {
		retransmit[i] = 0;		
	}

}

{
#	event = $1;    time = $2;    node = $3;    type = $4;    reason = $5;    node2 = $5;    
#	packetid = $6;    mac_sub_type=$7;    size=$8;    source = $11;    dest = $10;    energy=$14;

	strEvent = $1 ;			rTime = $2 ;
	fromNode = $3 ;
	toNode = $4 ;			protocol = $5;
	packetSize = $6 ;
	flowId = $8;
	sourceNode = $9;		destNode = $10;
	seqNumber = $11; 		idPacket = $12;


	if (strType == "cbr") {
		if (idPacket > idHighestPacket) idHighestPacket = idPacket;
		if (idPacket < idLowestPacket) idLowestPacket = idPacket;

#		if(rTime>rEndTime) rEndTime=rTime;
#			printf("********************\n");
		if(rTime<rStartTime) {
#			printf("********************\n");
#			printf("%10.0f %10.0f %10.0f\n",rTime, node, idPacket);
			rStartTime=rTime;
		}

		if ( strEvent == "s" ) {
			nSentPackets += 1 ;	rSentTime[ idPacket ] = rTime ;
#			printf("%15.5f\n", nSentPackets);
		}
#		if ( strEvent == "r" ) {
			if ( strEvent == "r" && idPacket >= idLowestPacket) {
				nReceivedPackets += 1 ;		
				nReceivedBytes += (nBytes-header);
#				printf("%15.0f\n", $6); #nBytes);
				rReceivedTime[ idPacket ] = rTime ;
				rDelay[idPacket] = rReceivedTime[ idPacket] - rSentTime[ idPacket ];
#				rTotalDelay += rReceivedTime[ idPacket] - rSentTime[ idPacket ];
				rTotalDelay += rDelay[idPacket]; 

#				printf("%15.5f   %15.5f\n", rDelay[idPacket], rReceivedTime[ idPacket] - rSentTime[ idPacket ]);
			}
		}
		else if( strEvent = )

	if( strEvent == "D"   &&   strType == "cbr" )
	{
		if(rTime>rEndTime) rEndTime=rTime;
#		if(rTime<rStartTime) rStartTime=rTime;
		nDropPackets += 1;
	}

	if( strType == "tcp" )
	{
#		printf("%d \n", idPacket);
#		printf("%d %15d\n", idPacket, num_retransmit);
		retransmit[idPacket] = num_retransmit;		
	}
	
#	if(rTime<rStartTime) rStartTime=rTime;
	if(rTime>rEndTime) rEndTime=rTime;

}

END {
	rTime = rEndTime - rStartTime ;
	rThroughput = nReceivedBytes*8 / rTime;
	rPacketDeliveryRatio = nReceivedPackets / nSentPackets * 100 ;
	rPacketDropRatio = nDropPackets / nSentPackets * 100;


	if ( nReceivedPackets != 0 ) {
		rAverageDelay = rTotalDelay / nReceivedPackets ;
	}


#	printf( "AverageDelay: %15.5f PacketDeliveryRatio: %10.2f\n", rAverageDelay, rPacketDeliveryRatio ) ;


	printf( "%15.2f\n%15.5f\n%15.2f\n%15.2f\n%15.2f\n%10.2f\n%10.2f\n%10.5f\n", rThroughput, rAverageDelay, nSentPackets, nReceivedPackets, nDropPackets, rPacketDeliveryRatio, rPacketDropRatio,rTime) ;
#	printf("%15.5f\n%15.5f\n%15.5f\n%15.5f\n%15.0f\n%15.9f\n", total_energy_consumption, avg_energy_per_bit, avg_energy_per_byte, avg_energy_per_packet, total_retransmit, rEnergyEfficeincy);

#	printf("%15.2f, %15.2f", rStartTime, rEndTime);

#	printf("ABCD %15.5f", nReceivedBytes);

#	printf( "Throughput: %15.2f AverageDelay: %15.5f \nSent Packets: %15.2f Received Packets: %15.2f Dropped Packets: %15.2f \nPacketDeliveryRatio: %10.2f PacketDropRatio: %10.2f\nTotal time: %10.5f\n", rThroughput, rAverageDelay, nSentPackets, nReceivedPackets, nDropPackets, rPacketDeliveryRatio, rPacketDropRatio,rTime) ;
#	printf("\n\nTotal energy consumption: %15.5f Average Energy per bit: %15.5f Average Energy per byte: %15.5f Average energy per packet: %15.5f\n", total_energy_consumption, avg_energy_per_bit, avg_energy_per_byte, avg_energy_per_packet);
}


