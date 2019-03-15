synth (){
  #cd ../scripts
  design=$2
  clock=$1
  vfile=$3
  echo "$design Synthesis is starting" -- Time:`date +"%T"`
  echo "yosys -import" > $design.tcl
  echo "set vfile \"./$vfile\"" >> $design.tcl
  echo "set vtop \"$design\"" >> $design.tcl
  echo "set clock $clock"  >> $design.tcl
  echo "set max_FO    5"  >> $design.tcl
  #echo "set max_Tran  $trans"  >> $design.tcl

  cat ../scripts/synth_reduced.tcl  >> $design.tcl

  #cd ../tmp
  ts1=$(python -c 'from time import time; print int(round(time() * 1000))')
  yosys -c ../tmp/$design.tcl > $design.log.txt

  grep -e "XYZ" -e "ABC: netlist" -e "Number of public wire bits" -e "Number of wire bits" -e "Number of cells" -e "  \$_XOR" -e "  \$_XNOR" -e "  \$_MUX" -e "  \$_ZERO" -e "  \$_ONE" -e "  \$_DFF_" $design.log.txt | perl -lne 'print if  // .. /ABC/' | grep -v "XYZ" > $design.stats.txt

  grep WireLoad $design.log.txt > synth_$design.txt
  ../scripts/best.pl synth_$design.txt > ../rpt/best_$design.txt
  ../scripts/analyze.pl synth_$design.txt > ../rpt/report_$design.html
  ts2=$(python -c 'from time import time; print int(round(time() * 1000))')
  echo "$design Synthesis has finished" -- Time:`date +"%T"`
  tm=`expr $ts2 - $ts1`
  #echo $tm mSec
  echo `expr $tm / 60000` minutes and `expr $tm / 1000 % 60` seconds
}


#lfsr -- 7 gates
synth 200 "lfsr" "../verilog/lfsr.v"

#arbiter -- 11
synth 350 "arbiter" "../verilog/arbiter.v"

#hc -- 28
synth 800 "hc" "../verilog/hc.v"

#cache_coherence -- 42
synth 650 "cache_coherence" "../verilog/cache_coherence.v"

#SPM -- 160 gates
synth 350 "SPM" "../verilog/spm.v"

#zx ula -- 174
synth 800 "ula" "../verilog/ula.v"

#iiravg -- 184
synth 2500 "iiravg" "../verilog/iiravg.v"

#rle -- 189 gates
synth 1000 "rle" "../verilog/rle.v"

#JTAG tap_top -- 192
synth 900 "tap_top" "../verilog/jtag.v"

#USB1.1 -- 255
synth 1000 "usb_phy" "../verilog/usb11.v"

#KSA32 -- 309
synth 1100 "KSA32" "../verilog/ksa.v"

#jpeg_rle -- 404 gates
synth 1200 "jpeg_rle" "../verilog/jpeg_rle.v"

#pic8 -- 406 gates
synth 1300 "pic8" "../verilog/pic8.v"

#ca_prng -- 472
synth 1000 "ca_prng" "../verilog/ca_prng.v"

#uart -- 586
synth 1500 "uart" "../verilog/uart.v"

#cic_interpolator -- 629
synth 1400 "cic_interpolator" "../verilog/cic_interpolator.v"

#cic_decimator -- 626
synth 1400 "cic_decimator" "../verilog/cic_decimator.v"

#MUL16 -- 719
synth 5200 "mul16" "../verilog/mul16.v"

#chacha_qr -- 779
synth 7100 "chacha_qr" "../verilog/chacha.v"

# i2c master -- 787
synth 1800 "i2cmaster" "../verilog/i2c_master.v"

#KSA64 -- 832
synth 1300 "KSA64" "../verilog/ksa.v"

#zipdiv -- 1126
synth 2500 "zipdiv" "../verilog/zipdiv.v"

#sbox -- 1163
synth 1500 "sbox" "../verilog/sbox.v"

#Booth_Multiplier_4xA -- 1202
synth 2800 "Booth_Multiplier_4xA" "../verilog/booth_mul.v"

#CAN -- 1285
synth 2200 "wb_conbus_top" "../verilog/can.v"

#6502 CPU -- 1420
synth 4000 "cpu6502" "../verilog/cpu6502.v"

#i8080 -- 1517
synth 3200 "vm80a" "../verilog/vm80a.v"

#aes_encipher_block -- 1818
synth 1800 "aes_encipher_block" "../verilog/aes.v"

#jpeg zigzag  -- 1920
synth 800 "zigzag" "../verilog/zigzag.v"

#RGB2YCBCR -- 2148
synth 2500 "RGB2YCBCR" "../verilog/RGB2YCBCR.v"

#prv32_CPU -- 3070
synth 4200 "prv32_CPU" "../verilog/prv32.v"

#r8051 -- 3332
synth 6500 "r8051" "../verilog/r8051.v"

#NES APU -- 3407
synth 3700 "APU" "../verilog/APU.v"

#multiplier -- 3769
synth 4400 "multiplier" "../verilog/sp_mul.v"

#ArrayMultiplier -- 3844
synth 15500 "ArrayMultiplier" "../verilog/array_mul.v"

#MD5 -- 5141
synth 8000 "md5" "../verilog/md5.v"

#aes_decipher_block -- 5153
synth 2800 "aes_decipher_block" "../verilog/aes.v"

#approx_mul.v -- 5548
synth 5700 "mult_bth_app_signed" "../verilog/approx_mul.v"

#xtea -- 6040
synth 4100 "xtea" "../verilog/xtea.v"

#CNU_7 -- 6535
synth 5000  "CNU_7" "../verilog/ldpc.v"

#cordic -- 6782
synth 1800 "cordic" "../verilog/cordic.v"

#axi_fifo -- 7374
synth 1600 "axi_fifo" "../verilog/axi_fifo.v"

#sub86 -- 7554
synth 5100 "sub86" "../verilog/sub86.v"

#y_quantizer -- 8453
synth 1000 "y_quantizer" "../verilog/y_quantizer.v"

#qspi_mem_controller -- 9191
synth 2700 "qspi_mem_controller" "../verilog/qspi.v"

#Cortex M0 -- 10191
#synth 7000 "cortexm0ds_logic" "../verilog/cortexm0ds_logic.v"

#chacha_qr -- 10741
synth 8100 "chacha_core" "../verilog/chacha.v"

# NES ppu -- 11093
synth 3500 "PPU" "../verilog/ppu.v"

#y_huff -- 11521
synth 1500 "y_huff" "../verilog/y_huff.v"

#SHA3 -- 12261
synth 2500 "sha3" "../verilog/sha3.v"

#PICRORV32A -- 13243
synth 5000 "picorv32a" "../verilog/picorv32a.v"

#PICRORV32 -- 16118
synth 5400 "picorv32" "../verilog/picorv32.v"

#PICRORV32C -- 16855
synth 5400 "picorv32c" "../verilog/picorv32c.v"

#des -- 16793
synth 1800 "des" "../verilog/3des.v"


#salsa20 -- 17337
synth 8000 "salsa20" "../verilog/salsa20.v"

#aes -- 18346 
synth 4500 "aes_core" "../verilog/aes.v"

#aes -- 20117 -- crashes script 2 and 3
synth 4500 "aes_core" "../verilog/aes.v"

#SHA512 -- 21690
synth 8000 "sha512" "../verilog/sha512_trng.v"

#tea -- 31608
synth 36000 "TEA" "../verilog/tea.v"

#genericfir -- 34607
synth 1600 "genericfir" "../verilog/genericfir.v"

#ecg point_add -- 45102
synth 2500 "point_add" "../verilog/ecg.v"

#Cortex M3 -- 46336
#synth 9600 "cortexm3ds_logic" "../verilog/cortexm3ds_logic.v"

#3des -- 50691
synth 1800 "des3" "../verilog/3des.v"

#ecg point_scalar_mult -- 51709
synth 2500 "point_scalar_mult" "../verilog/ecg.v"

#y_dct -- 117468
synth 4200 "y_dct" "../verilog/y_dct.v"

#yd_q_h.v -- 138788
synth 4200 "yd_q_h" "../verilog/yd_q_h.v"

#fastfir -- 149980
synth 4000 "fastfir" "../verilog/fastfir.v"

#LDPC ~3M Gates!
synth  5500 "ldpc" "../verilog/ldpc.v"
