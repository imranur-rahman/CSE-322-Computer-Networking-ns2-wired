set num_node [lindex $argv 0]
set num_flow [lindex $argv 1]
set num_pckt_per_sec [lindex $argv 2]

#Create a simulator object
set ns [new Simulator]

#Tell the simulator to use dynamic routing
$ns rtproto DV

#Open the nam trace file
set nf [open wired.nam w]
$ns namtrace-all $nf
#set the trace files for output
set tracefd [open wired.tr w]
$ns trace-all $tracefd

set topofile [open wired.txt "w"]

#Define a 'finish' procedure
proc finish {} {
        global ns nf tracefd topofile
        $ns flush-trace
	#Close the trace file
        close $nf
        close $tracefd
        close $topofile
	#Execute nam on the trace file
        #exec nam wired.nam &
        exit 0
}

#Create nodes
for {set i 0} {$i < $num_node} {incr i} {
        set n($i) [$ns node]
}


#Create links between the nodes
for {set i 0} {$i < $num_node} {incr i} {
        $ns duplex-link $n($i) $n([expr ($i+1)%$num_node]) 1Mb 10ms DropTail
}

for {set i 0} {$i < $num_flow} {incr i} {
	#Create a UDP agent and attach it to node n(0)
	set udp($i) [new Agent/UDP]
	#$ns attach-agent $n($i) $udp($i)

	# Create a CBR traffic source and attach it to udp0
	set cbr($i) [new Application/Traffic/CBR]
	$cbr($i) set packetSize_ 500
	$cbr($i) set interval_ [expr 1.0/$num_pckt_per_sec]
	$cbr($i) attach-agent $udp($i)

	#Create a Null agent (a traffic sink) and attach it to node n(3)
	set null($i) [new Agent/Null]
	#$ns attach-agent $n($i) $null($i)

	#Connect the traffic source with the traffic sink
	#$ns connect $udp($i) $null($i) 
}
if {$num_node >= $num_flow} {
	set cnt $num_flow
} else {
	set cnt $num_node
}
for {set i 0} {$i < $num_flow} {incr i} {
	set udp_node [expr int($cnt*rand())] ;# src node
	set null_node $udp_node
	while {$null_node==$udp_node} {
		set null_node [expr int($cnt*rand())] ;# dest node
	}
	$ns attach-agent $n($udp_node) $udp($i)
  	$ns attach-agent $n($null_node) $null($i)
  	$ns connect $udp($i) $null($i)
  	puts -nonewline $topofile "Src: $udp_node Dest: $null_node\n"
}


for {set i 0} {$i < $num_flow} {incr i} {
	$ns at 0.5 "$cbr($i) start"
}

#Schedule events for the CBR agent and the network dynamics
# $ns at 0.5 "$cbr0 start"
# $ns rtmodel-at 1.0 down $n(1) $n(2)
# $ns rtmodel-at 2.0 up $n(1) $n(2)
# $ns at 4.5 "$cbr0 stop"
#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"

#Run the simulation
$ns run
