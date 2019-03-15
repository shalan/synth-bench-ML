#yosys -import

set sclib "../lib/osu018.lib"

set max_Tran [expr $clock * 0.2]

# Script parameters
# The strategy: 0 - 11, 100: Explore
set strategy  100
set schematic 0
set sta       0

set opt 1
# 0: area, 1: delay

# Mapping parameters
set A_factor  0.00
set B_factor  0.88
set F_factor  0.00

# Don't change these unless you know what you are doing
set stat_ext    ".stat.rpt"
set gl_ext      ".gl.v"
set constr_ext  ".$clock.constr"
set timing_ext  ".timing.txt"
set abc_ext     ".abc"

set rpt_file "$vtop$timing_ext"
set stat_file "$vtop$stat_ext"
set constr_file "$vtop$constr_ext"


set   outfile [open "$vtop$constr_ext" w]
#puts  $outfile "set_driving_cell $driving_cell"
#puts  $outfile "set_load $cap_load"
close $outfile


# ABC Scrips
set abc_rs_K    "resub,-K,"
set abc_rs      "resub"
set abc_rsz     "resub,-z"
set abc_rw_K    "rewrite,-K,"
set abc_rw      "rewrite"
set abc_rwz     "rewrite,-z"
set abc_rf      "refactor"
set abc_rfz     "refactor,-z"
set abc_b       "balance"

set abc_resyn2        "${abc_b}; ${abc_rw}; ${abc_rf}; ${abc_b}; ${abc_rw}; ${abc_rwz}; ${abc_b}; ${abc_rfz}; ${abc_rwz}; ${abc_b}"
set abc_share         "strash; multi,-m; ${abc_resyn2}"

set abc_resyn2a       "${abc_b};${abc_rw};${abc_b};${abc_rw};${abc_rwz};${abc_b};${abc_rwz};${abc_b}"
set abc_resyn3        "balance;resub;resub,-K,6;balance;resub,-z;resub,-z,-K,6;balance;resub,-z,-K,5;balance"
set abc_resyn2rs      "${abc_b};${abc_rs_K},6;${abc_rw};${abc_rs_K},6,-N,2;${abc_rf};${abc_rs_K},8;${abc_rw};${abc_rs_K},10;${abc_rwz};${abc_rs_K},10,-N,2;${abc_b},${abc_rs_K},12;${abc_rfz};${abc_rs_K},12,-N,2;${abc_rwz};${abc_b}"
set compress2rs       "${abc_b},-l; ${abc_rs_K},6,-l; ${abc_rw},-l; ${abc_rs_K},6,-N,2,-l; ${abc_rf},-l; ${abc_rs_K},8,-l; ${abc_b}, -l; ${abc_rs_K},8,-N,2,-l; ${abc_rw},-l; ${abc_rs_K},10,-l; ${abc_rsz}, -l; ${abc_rs_K},10, -N, 2, -l; ${abc_b}, -l; ${abc_rs_K}, 12, -l; ${abc_rfz}, -l; ${abc_rs_K},12,-N,2,-l; ${abc_rwz}, -l; ${abc_b}, -l"

set abc_script        "+read_constr,${constr_file};strash;ifraig;retime,-D,{D},-M,6;strash;dch,-f;map,-p,-B,$B_factor,-A,$A_factor,-M,1,{D},-F,$F_factor,-f;retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D};dnsize,{D};stime,-p;"
set abc_script1       "+read_constr,${constr_file};strash; dc2; scorr; ifraig; ${abc_resyn2rs}; retime,-o,{D}; strash; dch,-f; ${abc_resyn3}; map,{D},-p ; retime,-D,{D}; buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D}; dnsize,{D};stime,-p;"
set abc_script_s      "+read_constr,${constr_file};strash;ifraig;retime,-D,{D},-M,3;dch,-f;map,-r,-p,-B,0.85,-A,0.1,-M,1,{D},-F,$F_factor,-f;retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D};dnsize,{D};stime,-p;"
set abc_script_dly    "+read_constr,${constr_file};strash; dc2; scorr; ifraig; ${abc_resyn2rs}; retime,-o,{D}; dch,-f; ${abc_resyn3}; map,{D},-p; ; retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D}; dnsize,{D};stime,-p;"

#set abc_script2       "+read_constr,${constr_file};strash; dc2; scorr; ifraig; ${compress2rs}; retime,-o,{D}; strash; dch,-f; ${compress2rs}; map,{D},-p ; retime,-D,{D}; buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D}; dnsize,{D};stime,-p;"
#set abc_script5       "+read_constr,${constr_file};strash;ifraig;retime,-D,{D},-M,6;strash;dch,-f;map,-p,-B,$B_factor,-A,$A_factor,-M,1,{D},-F,$F_factor,-f,-r;retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D};dnsize,{D};stime,-p;"
#set abc_script6       "+read_constr,${constr_file};strash;ifraig;retime,-D,{D},-M,6;strash;dch,-f;map,-p,-B,$B_factor,-A,$A_factor,-M,1,{D},-F,$F_factor,-f,-r,-a;retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D};dnsize,{D};stime,-p;"
#set abc_script_area   "+read_constr,${constr_file};strash; dc2,-b; ifraig; ${abc_resyn2rs}; retime,-o,{D}; strash; dch,-f; ${abc_resyn3}; amap,-m,-x,-Q,100.0,-F,100,-A,100,-C,1000,-v;  ;  retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D}; dnsize,{D};stime,-p;"
#set abc_script7       "+read_constr,${constr_file};strash; dc2,-b; ifraig; ${abc_resyn2rs}; retime,-o,{D}; strash; dch,-f; ${abc_resyn3}; amap,-m,-x,-Q,100.0,-F,100,-A,100,-C,1000,-v;  ;  retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D}; dnsize,{D};stime,-p;"

#set ms_opt            "strash; dch,-f; ${abc_resyn2}; strash; dch,-f; ${abc_resyn2}; strash; dch,-f; ${abc_resyn2}; strash; dch,-f; ${abc_resyn2rs};"
set ms_opt            "dch; ${abc_resyn2};dch;${abc_resyn2};dch;${abc_resyn2};dch,-f;${abc_resyn2rs};"

set ms_opt_           "strash; dch,-f; ${abc_resyn2};retime,-o,{D};"
set ms_opt2           "${ms_opt};${ms_opt}"
set ms_opt4           "${ms_opt2};${ms_opt2}"
set ms_opt8           "${ms_opt4};${ms_opt4}"



set abc_map_old       "map,-p,-B,0.88,-A,0.0,-M,1,{D},-F,$F_factor,-f"
set abc_old_opt       "strash; dc2,-b,-l,-p;ifraig"
set abc_new_opt       "strash;dch,-p;ifraig"
set abc_retime_area   "retime,-D,{D},-M,5"
set abc_retime_dly    "retime,-D,{D},-M,6"

set abc_fine_tune     "buffer,-N,${max_FO},-S,${max_Tran};upsize,{D};dnsize,{D}; "
set abc_map_new       	"amap,-m,-Q,0.2,-F,50,-A,50,-C,1000"
set abc_map_new_area      "amap,-m,-Q,0.0,-F,20,-A,20,-C,1000, ${abc_retime_area}, ${abc_fine_tune}"
set abc_map_new_dly       "amap,-i,-Q,1.0,-F,5,-A,5,-C,1000,${abc_retime_dly}, ${abc_fine_tune}"
set abc_map_new_std       	"amap,-m;${abc_retime_dly};${abc_fine_tune}"

#set abc_script8       "+read_constr,${constr_file}; strash; dc2,-b; ifraig; ${abc_resyn2}; ${ms_opt_}; ${ms_opt4};${ms_opt4};${ms_opt_}; amap,-m,-x,-Q,100.0,-F,10,-A,500,-C,1000;  ;  retime,-D,{D};buffer,-N,6,-S,${max_Tran};upsize,{D}; dnsize,{D};stime,-p;"
#set abc_script9       "+read_constr,${constr_file}; strash; dc2,-b; ifraig; ${abc_resyn2}; ${ms_opt_}; ${ms_opt4};${ms_opt4};${ms_opt_};map,-p,-B,$B_factor,-A,$A_factor,-M,1,{D},-F,$F_factor,-f;retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D};dnsize,{D};stime,-p;"
# gives good area
#set abc_script10      "+read_constr,${constr_file}; strash; dc2,-b; ifraig; ${abc_resyn2}; ${ms_opt_}; ${ms_opt4};${ms_opt4};${ms_opt_};map,-p,-B,0.0,-A,0.7,-M,1,{D},-F,$F_factor,-f;retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D};dnsize,{D};stime,-p;"
#set abc_script100      "+read_constr,${constr_file}; strash; dc2,-b; ifraig; ${abc_resyn2}; ${ms_opt_}; ${ms_opt4};${ms_opt4};${ms_opt_};map,-p,-B,0.0,-A,0.7,-M,1,{D},-F,$F_factor,-f;retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D};dnsize,{D};stime,-p;"
#set abc_script11      "+read_constr,${constr_file}; strash; dc2,-b; ifraig; refactor; ${abc_resyn2}; ${ms_opt_}; ${ms_opt4};${ms_opt4};${ms_opt_}; amap,-m,-x,-Q,100.0,-F,10,-A,500,-C,1000;retime,-D,{D};buffer,-N,6,-S,${max_Tran};upsize,{D}; dnsize,{D};stime,-p;"
#set abc_script_s1     "+read_constr,${constr_file}; strash; ifraig; dch,-p; retime,-D,{D},-M,5; ${abc_resyn2}; ${ms_opt_}; ${ms_opt4}; map,-p,-B,0.70,-A,0.25,-M,1,{D},-F,$F_factor,-f; retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D};dnsize,{D};stime,-p;"
#set abc_script80      "+read_constr,${constr_file}; strash; dc2,-b,-l,-p; ifraig; retime,-D,{D},-M,5; ${abc_resyn2}; ${ms_opt_}; ${ms_opt4};${ms_opt4};${ms_opt_}; amap,-m,-x,-Q,0.85,-F,50,-A,50,-C,1000; ; retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran};upsize,{D}; dnsize,{D};stime,-p;"

#set abc_script80_0    "+read_constr,${constr_file}; ${abc_new_opt}; ${abc_new_opt}; ${abc_retime_area}; ${abc_new_opt}; ${abc_resyn2}; ${abc_map_new}; ${abc_retime_area}; ${abc_fine_tune};stime,-p;"
#set abc_script80_3    "+read_constr,${constr_file}; ${abc_new_opt}; ${abc_new_opt}; ${abc_retime_dly}; ${abc_new_opt}; ${abc_resyn2}; ${abc_map_old}; ${abc_retime_dly}; ${abc_fine_tune};stime,-p;"

#set scripts(0) $abc_script
#set scripts(1) $abc_script1
#set scripts(2) $abc_script_dly
#set scripts(3) $abc_script_s
#set scripts(3) $abc_script80_0
#set scripts(4) $abc_script80_3

#set scriptname(0) "abc_script"
#set scriptname(1) "abc_script1"
#set scriptname(2) "abc_script_dly"
#set scriptname(3) "abc_script_s"
#set scriptname(3) "abc_script80_0"
#set scriptname(4) "abc_script80_3"

#set abc_script__0        "+read_constr,${constr_file};fx;mfs;strash;refactor;${abc_resyn2};retime,-D,{D},-M,6;scleanup;map,-p,-B,0.5,-A,0.0,-M,1,-F,$F_factor,-f;retime,-D,{D};buffer,-N,10,-S,${max_Tran}; upsize,{D};dnsize,{D};stime,-p;"
#set abc_script__1        "+read_constr,${constr_file};fx;mfs;strash;refactor;${abc_resyn2};retime,-D,{D},-M,6;scleanup;map,-p,-B,0.5,-A,0.0,-M,1,-F,$F_factor;retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D};dnsize,{D};stime,-p;"
#set abc_script__1        "+read_constr,${constr_file};fx;mfs;strash;refactor;${abc_resyn2};retime,-D,{D},-M,6;scleanup;map,-B,0.5,-A,0.0,-M,1,-F,$F_factor,-f;retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D};dnsize,{D};stime,-p;"
#set abc_script__2        "+read_constr,${constr_file};fx;mfs;strash;refactor;${abc_resyn2};retime,-D,{D},-M,6;scleanup;map,-B,0.5,-A,0.0,-M,1,-F,$F_factor;retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D};dnsize,{D};stime,-p;"
#set abc_script__3        "+read_constr,${constr_file};fx;mfs;strash;refactor;${abc_resyn2};retime,-D,{D},-M,6;scleanup;map,-p,-B,0.25,-A,0.0,-M,1,-F,$F_factor,-f;retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D};dnsize,{D};stime,-p;"
#set abc_script__4        "+read_constr,${constr_file};fx;mfs;strash;refactor;${abc_resyn2};retime,-D,{D},-M,6;scleanup;map,-p,-B,0.75,-A,0.0,-M,1,-F,$F_factor,-f;retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D};dnsize,{D};stime,-p;"
#set abc_script__6        "+read_constr,${constr_file};fx;mfs;strash;refactor;${abc_resyn2};retime,-D,{D},-M,6;scleanup;map,-p,-B,0.0,-A,0.75,-M,1,-F,$F_factor,-f;retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D};dnsize,{D};stime,-p;"
#set abc_script__5        "+read_constr,${constr_file};fx;mfs;strash;refactor;${abc_resyn2};retime,-D,{D},-M,6;scleanup;map,-B,0.85,-A,0.0,-M,1,-F,$F_factor;retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran}; upsize,{D};dnsize,{D};stime,-p;"

#set abc_script__8        "+read_constr,${constr_file};mfs;strash;dc2,-b;ifraig;${abc_resyn2};${ms_opt8};${ms_opt8};${ms_opt8};scleanup;amap,-m,-x,-Q,0.0,-F,10,-A,500,-C,1000;retime,-D,{D},-M,5;buffer,-N,${max_FO},-S,${max_Tran};upsize,{D};dnsize,{D};stime,-p;"
#set abc_script__8        "+read_constr,${constr_file};mfs;strash;dc2,-b;ifraig;${abc_resyn2};${ms_opt4};;scleanup;amap,-m,-x,-Q,0.0,-F,10,-A,500,-C,1000;retime,-D,{D},-M,5;buffer,-N,${max_FO},-S,${max_Tran};upsize,{D};dnsize,{D};stime,-p;"
#set abc_script__9        "+read_constr,${constr_file};mfs;strash;dc2,-b;ifraig;${abc_resyn2};${ms_opt8};scleanup;amap,-m,-x,-Q,100.0,-F,10,-A,500,-C,1000;retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran};upsize,{D}; dnsize,{D};stime,-p;"
#set abc_script__10        "+read_constr,${constr_file};mfs;strash;dc2,-b;ifraig;${abc_resyn2};${ms_opt8};${ms_opt8};amap,-m,-x,-Q,100.0,-F,10,-A,500,-C,1000;retime,-D,{D};buffer,-N,${max_FO},-S,${max_Tran};upsize,{D}; dnsize,{D};stime,-p;"
#set abc_script__dly       "+read_constr,${constr_file};mfs;strash;dc2,-b,-l;ifraig;${abc_resyn2};${ms_opt4};${abc_retime_dly};scleanup;${abc_map_new_dly};stime,-p;"

#set abc_script__area       "+read_constr,${constr_file};fx;mfs;strash;refactor;ifraig;${abc_resyn2};${ms_opt4};${abc_retime_dly};scleanup;${abc_map_new_area};stime,-p;"

#set abc_script_new__1		"+read_constr,${constr_file}; ${abc_new_opt}; ${abc_new_opt}; ${abc_retime_dly}; ${abc_new_opt}; ${abc_resyn2}; ${abc_map_new_dly};stime,-p;"
#set abc_script_new__2		"+read_constr,${constr_file}; ${abc_new_opt}; ${abc_new_opt}; ${abc_retime_dly}; ${abc_new_opt}; ${abc_resyn2}; ${abc_map_new_std};stime,-p;"
#set abc_script_new__3        "+read_constr,${constr_file};fx;mfs;strash;refactor;${abc_resyn2};retime,-D,{D},-M,6;scleanup;${abc_map_new_dly};stime,-p;"
#set abc_script_new__4        "+read_constr,${constr_file};fx;mfs;strash;refactor;${abc_resyn2};retime,-D,{D},-M,6;scleanup;${abc_map_new_std};stime,-p;"		
#set abc_script_new__5        "+read_constr,${constr_file};fx;mfs;strash;refactor;${abc_resyn2};retime,-D,{D},-M,6;scleanup;${abc_map_new_area};stime,-p;"		


set map_old_cnt			"map,-p,-a,-B,0.2,-A,0.9,-M,0"
set map_old_dly			"map,-p,-B,0.2,-A,0.9,-M,0"
set abc_retime_area   	"retime,-D,{D},-M,5"
set abc_retime_dly    	"retime,-D,{D},-M,6"
set abc_map_new_area  	"amap,-m,-Q,0.1,-F,20,-A,20,-C,5000"
set abc_fine_tune		"buffer,-N,${max_FO},-S,${max_Tran};upsize,{D};dnsize,{D}"

set scpt_0        "+read_constr,${constr_file};fx;mfs;strash;refactor;${abc_resyn2};${abc_retime_area};scleanup;${map_old_cnt};retime,-D,{D};${abc_fine_tune};stime,-p;print_stats,-p,-g;"
set scpt_1        "+read_constr,${constr_file};fx;mfs;strash;refactor;${abc_resyn2};${abc_retime_dly};scleanup;${map_old_dly};retime,-D,{D};${abc_fine_tune};stime,-p;print_stats,-p,-g;"
set scpt_2        "+read_constr,${constr_file};fx;mfs;strash;refactor;${abc_resyn2};${abc_retime_area};scleanup;${abc_map_new_area};retime,-D,{D};${abc_fine_tune};stime,-p;print_stats,-p,-g;"

set scripts(0) $scpt_0
set scripts(1) $scpt_1
set scripts(2) $scpt_2
set scriptname(0) "scpt_0"
set scriptname(1) "scpt_1"
set scriptname(2) "scpt_2"



# create the constraints file; library specific
set outfile [open "design.constr" w]
          puts  $outfile  "set_driving_cell INVX8"
          puts  $outfile  "set_load 0.0746269"
close $outfile

# read design
read_verilog $vfile
hierarchy -check -top $vtop

if {$schematic==1} {
  json -o "${vtop}.json"
}

#tee -o "$vtop.0.stat" stat

puts "==> Executing synth cmd"
synth  -top $vtop -flatten

#tee -o "$vtop.1.stat" stat

if {$opt==0} {
  share -aggressive
  opt
  share -aggressive
  opt
  share -aggressive
  opt
}

opt_clean -purge

#tee -o "$vtop-pre.stat" stat

puts "==> Executing dfflibmap cmd"
dfflibmap -liberty $sclib

#write_verilog "$vtop.blif"

#tee -o "$vtop-dff.stat" stat

if {$strategy==100} {
  design -save myDesign
  for { set index 0 }  { $index < [array size scriptname] }  { incr index } {
      puts "XYZ: WireLoad : $scriptname($index)"
      design -load myDesign

      if {$sta == 1} {
        set outfile [open "$vtop$index$abc_ext" w]
          puts  $outfile  "read_lib -w $sclib"
          puts  $outfile  "read_verilog -m $vtop$index$gl_ext"
          puts  $outfile  "topo"
          puts  $outfile  "stime -p"
        close $outfile
      }

      if {$opt==1} {
        abc -D $clock -constr "design.constr" -liberty $sclib  -script $scripts($index)
      } else {
        abc -D $clock -constr "design.constr" -liberty $sclib -script $scripts($index)
      }

      opt_clean -purge
      write_verilog -noattr -noexpr "$vtop.$clock.$index$gl_ext"
      tee -o "$vtop-final.$clock.$index$stat_ext" stat -top $vtop -liberty $sclib
      #tee -o "$vtop-finl.stat" stat
      design -reset
  }
} else {
    if {$sta == 1} {
      set outfile [open "$vtop$abc_ext" w]
        puts  $outfile  "read_lib -w $sclib"
        #puts  $outfile  "read_verilog -m secc.gl.v"
        puts  $outfile  "read_verilog -m $vtop$gl_ext"
        puts  $outfile  "topo"
        puts  $outfile  "stime -p"
        #puts  $outfile  "read_verilog -m $vtop$gl_ext"
      close $outfile
    }

    puts "ABC: WireLoad : S_$strategy"

    if {$opt==1} {
      abc -D $clock -constr "$vtop$constr_ext" -liberty $sclib  -script $scripts($strategy)
    } else {
      abc -D $clock -constr "$vtop$constr_ext" -liberty $sclib -script $scripts($strategy)
    }

    opt_clean -purge
    write_verilog -noattr -noexpr "$vtop.$clock.$strategy$gl_ext"

    tee -o "$vtop.$strategy$stat_ext" stat -top $vtop -liberty $sclib
}
