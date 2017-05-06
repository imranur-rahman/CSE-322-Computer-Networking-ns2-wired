set time_duration 25 ; #[lindex $argv 5] ;#50
set start_time 50 ;#100
set extra_time 10

set num_node [lindex $argv 0]
set num_random_flow [lindex $argv 1]
set cbr_pckt_per_sec [lindex $argv 2]
set cbr_interval 0.005;#[expr 1.0/$cbr_pckt_per_sec]

set tcp_src Agent/UDP
set tcp_sink Agent/Null
set crb_src Application/Traffic/CBR

####################Configure Simulator
#create a Simulator
set ns_ [new Simulator]

#set the trace files for output
set tracefd [open ex1.tr w]
$ns_ trace-all $tracefd
set namtracefd [open ex1.nam w]
$ns_ namtrace-all $namtracefd

set topo_file topo.txt
set topofile [open $topo_file "w"]

#now set the routing protocol. By default an static routing algorithm is used.
$ns_ rtproto DV ;#Distance Vector

##################create topology (= nodes + links)
#create nodes
for {set i 0} {$i < $num_node} {incr i} {
	set node_($i) [$ns_ node]
}

#create links
for {set i 0} {$i < $num_node} {incr i} {
	$ns_ duplex-link $node_($i) $node_([expr ($i+1) % $num_node]) 1Mb 10ms DropTail
}


for {set i 0} {$i < $num_random_flow} {incr i} { ;#sink
#    set udp_($i) [new Agent/UDP]
#    set null_($i) [new Agent/Null]

	set udp_($i) [new $tcp_src]
#	$udp_($i) set class_ $i ;# bujhi nai
	#$udp_($i) set fid_ $i ;# flow id
	set null_($i) [new $tcp_sink]
	set cbr_($i) [new $crb_src]
	$cbr_($i) set packetSize_ 500
	$cbr_($i) set interval_ .005;#ei line e jhamela
	$cbr_($i) attach-agent $udp_($i)
	if { [expr $i%2] == 0} {
		$ns_ color $i Blue
	} else {
		$ns_ color $i Red
	}

} 

#create flows
set rt 0
for {set i 1} {$i < [expr $num_random_flow+1]} {incr i} {
	set udp_node [expr int($num_random_flow*rand())] ;# src node
	set null_node $udp_node
	while {$null_node==$udp_node} {
		set null_node [expr int($num_random_flow*rand())] ;# dest node
	}
	$ns_ attach-agent $node_($udp_node) $udp_($rt)
  	$ns_ attach-agent $node_($null_node) $null_($rt)
  	$ns_ connect $udp_($rt) $null_($rt)
	puts -nonewline $topofile "RANDOM:  Src: $udp_node Dest: $null_node\n"
	incr $rt
} 





#############finish
proc finish {} \
{
	global ns_ namtracefd tracefd
	$ns_ flush-trace ;#flushes the trace file
	close $namtracefd
	close $tracefd
	exec nam ex1.nam &
	exit 0
}

##############Schedule
# Tell nodes when the simulation ends

for {set i 0} {$i < $num_random_flow } {incr i} {
    $ns_ at [expr $start_time] "$cbr_($i) start"
    #$ns_ at [expr $start_time] "$cbr_($i) stop"
}
$ns_ at [expr $start_time+$time_duration+$extra_time] "finish"
#$ns_ at [expr $start_time+$time_duration +20] "puts \"NS Exiting...\"; $ns_ halt"
#$ns_ at [expr $start_time+$time_duration +$extra_time] "$ns_ nam-end-wireless [$ns_ now]; puts \"NS Exiting...\"; $ns_ halt"

$ns_ at [expr $start_time+$time_duration/2] "puts \"half of the simulation is finished\""
$ns_ at [expr $start_time+$time_duration] "puts \"end of simulation duration\""
# $ns at 1.0 "$cbr0 start"
# $ns at 3.0 "$cbr0 stop"
# $ns at 4.0 "finish"

###########start simulation
puts "Starting Simulation..."
$ns_ run

