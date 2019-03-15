echo "design,cells,nets,pnets,pi,po,dff,x(n)or,mux,level" > metrics.csv
for file in *.stats.txt
do
  ../scripts/metrics.pl  $file >> metrics.csv
done
