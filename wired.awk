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

}

{

	strEvent = $1 ;
	strType = $5;
	rTime = $2 ;
	nBytes = $6 ;
	seqNumber = $11; 		idPacket = $12;

#	printf("%c\n",strEvent);


	if (strType == "cbr") {
		if (idPacket > idHighestPacket) idHighestPacket = idPacket;
		if (idPacket < idLowestPacket) idLowestPacket = idPacket;

		if ( strEvent == "r" ) {
		
			nReceivedPackets += 1 ;		
			nReceivedBytes += (nBytes-header);
			rReceivedTime[ idPacket ] = rTime ;
			rDelay[idPacket] = rReceivedTime[ idPacket ] - rSentTime[ idPacket ];
			rTotalDelay += rDelay[idPacket]; 

			#printf("Rcv byte : %f\n",nReceivedBytes);
		
		}
		
		else if( strEvent == "+" ){
			nSentPackets += 1;
			rSentTime[ idPacket ] = rTime;
		}
		else if( strEvent == "d" ){
			nDropPackets += 1;
		}

	
	if(rTime<rStartTime) rStartTime=rTime;
	if(rTime>rEndTime) rEndTime=rTime;

	}

}

END {
	rTime = rEndTime - rStartTime ;
	rThroughput = nReceivedBytes*8 / rTime;

	if(nSentPackets != 0){

	rPacketDeliveryRatio = nReceivedPackets / nSentPackets * 100 ;
	rPacketDropRatio = nDropPackets / nSentPackets * 100;
	}

	if ( nReceivedPackets != 0 ) {
		rAverageDelay = rTotalDelay / nReceivedPackets ;
	}


#	printf( "%15.2f\n%15.5f\n%15.2f\n%15.2f\n%15.2f\n%10.2f\n%10.2f\n%10.5f\n", rThroughput, rAverageDelay, nSentPackets, nReceivedPackets, nDropPackets, rPacketDeliveryRatio, rPacketDropRatio,rTime) ;
#	printf("%15.5f\n%15.5f\n%15.5f\n%15.5f\n%15.0f\n%15.9f\n", total_energy_consumption, avg_energy_per_bit, avg_energy_per_byte, avg_energy_per_packet, total_retransmit, rEnergyEfficeincy);


#	printf( "Throughput: %15.2f AverageDelay: %15.5f \nSent Packets: %15.2f Received Packets: %15.2f Dropped Packets: %15.2f \nPacketDeliveryRatio: %10.2f PacketDropRatio: %10.2f\nTotal time: %10.5f\n", rThroughput, rAverageDelay, nSentPackets, nReceivedPackets, nDropPackets, rPacketDeliveryRatio, rPacketDropRatio,rTime) ;
#	printf("\n\nTotal energy consumption: %15.5f Average Energy per bit: %15.5f Average Energy per byte: %15.5f Average energy per packet: %15.5f\n", total_energy_consumption, avg_energy_per_bit, avg_energy_per_byte, avg_energy_per_packet);


#	printf( "%15.2f\n%15.5f\n%15.2f\n%15.2f\n%15.2f\n%10.2f\n%10.2f\n%10.5f\n", rThroughput, rAverageDelay, nSentPackets, nReceivedPackets, nDropPackets, rPacketDeliveryRatio, rPacketDropRatio,rTime) ;

	printf("Thr : %f\n",rThroughput);
	printf("Delay : %f\n",rAverageDelay);
	printf("Del ratio : %f\n",rPacketDeliveryRatio);
	printf("Drop ratio : %f\n",rPacketDropRatio);



}


