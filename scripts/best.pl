#!/usr/bin/perl
open (myfile, $ARGV[0]) || die "couldn't open the file!";

$aw = 0.5;
$dw = 0.5;
$ascale = 100;
$minArea = 1000000000;
$minGates = $minArea;
$minDelay = $minArea;
$bestArea = "";
$bestDelay = "";
$sn = "";
while (<myfile>) {
  #print chomp($line);
  if(/none/){
    m/Delay\s+\=\s+(\S+)/;
    my $delay = $1;
    m/Area\s+\=\s+(\S+)/;
    my $area = $1;

    my @data = split;
    #print "$_";
    my $factor = $aw*$area/$ascale + $dw*$delay;
    #print "$data[6]\t$area\t$delay\n";
    if($area < $minArea) {
      $minArea = $area;
      $bestArea = $sn;
    }
    if($delay < $minDelay) {
      $minDelay = $delay;
      $bestDelay = $sn;
    }
    if($data[6] < $minGates) {
      $minGates = $data[6];
      $bestGates = $sn;
    }

  } else {
    my @data = split;
    #print "$_";
    #print "$data[3]\t\t";
    $sn = $data[3];
  }
}
print "Best Gate Count: $minGates ($bestGates)\n";
print "Best Area: $minArea ($bestArea)\n";
print "Best Delay: $minDelay ($bestDelay)\n";

seek myfile, 0, 0;

printf ("Script\tGates\tArea\tDelay\tGR\tAR\tDR\n");

while (<myfile>) {
  #print chomp($line);
  if(/none/){

    m/Delay\s+\=\s+(\S+)/;
    my $delay = $1;
    m/Area\s+\=\s+(\S+)/;
    my $area = $1;

    my @data = split;
    #print "$_";

    my $dfactor = 0.25*$area/$minArea + 0.75*$delay/$minDelay;
    my $afactor = 0.75*$area/$minArea + 0.25*$delay/$minDelay;

    printf ("%.0f\t%.0f\t%.0f\t%.3f\t%.3f\t%.3f",$data[6],$area,$delay,$data[6]/$minGates,$area/$minArea,$delay/$minDelay);

    $dratio = $delay/$minDelay;
    $aratio = $area/$minArea;

    print " + Best Area" if($aratio < 1.0001);
    print " + Best Delay" if($dratio < 1.0001);

    if(($dratio < 1.15) && ($aratio < 1.15)){
      printf (" <== Best Ratio: %.3f - %.3f\n", $aratio, $dratio);
    } else {
      print "\n";
    }

  } else {
    my @data = split;
    #print "$_";
    print "$data[3]\t";
    $sn = $data[3];
  }
}


close(myfile);
print "\n";
