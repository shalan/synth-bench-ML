#!/usr/bin/perl
open (myfile, $ARGV[0]) || die "couldn't open the file!";

my	$dff_cnt = 0;
my	$mux_cnt = 0;
my	$enxor_cnt = 0;
my	$level_cnt = 0;
my	$net_cnt = 0;
my	$pnet_cnt = 0;
my	$pi_cnt = 0;
my	$po_cnt = 0; 
my	$cell_cnt = 0;
my	$design = $ARGV[0];

$design =~ s{\.[^.]+$}{};
$design =~ s{\.[^.]+$}{};


while (<myfile>) {
	if(/Number of wire bits:/){
		m/Number of wire bits:\s+(\d+)/;
		$net_cnt = $1;
	} 
	elsif(/Number of public wire bits:/){
		m/Number of public wire bits:\s+(\d+)/;
		$pnet_cnt = $1;
	}
	elsif(/Number of cells:/){
		m/Number of cells:\s+(\d+)/;
		$cell_cnt = $1;
	}
	elsif(/\$_DFF_/){
		m/\$_DFF_\S+\s+(\d+)/;
		$dff_cnt = $dff_cnt + $1;
#		print "$1 - $dff_cnt\n";
	}
	elsif(/\$_XOR/){
		m/\$_XOR_\s+(\d+)/;
		$enxor_cnt = $enxor_cnt + $1;
#		print "$1 - $enxor_cnt\n";
	}
	elsif(/\$_XNOR/){
		m/\$_XNOR_\s+(\d+)/;
		$enxor_cnt = $enxor_cnt + $1;
#		print "$1 - $enxor_cnt\n";
	}
	elsif(/\$_MUX/){
		m/\$_MUX_\s+(\d+)/;
		$mux_cnt = $1;
	}
	elsif(/ABC: netlist/){
		m/ABC: netlist\s+\:\s+[^=]+\=\s+(\d+)\/\s+(\d+)/;
		$pi_cnt = $1;
		$po_cnt = $2;
		m/lev = (\d+)/;
		$level_cnt = $1;
		#print "$1, $2\n";
		last;
	}
	
}
print "design,cells,nets,pnets,pi,po,dff,x(n)or,mux,level\n" if($ARGV[1] eq "h"); 
print "$design,$cell_cnt,$net_cnt,$pnet_cnt,$pi_cnt,$po_cnt,$dff_cnt,$enxor_cnt,$mux_cnt,$level_cnt\n";

close(myfile);