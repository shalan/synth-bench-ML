Set of Verilog designs (>70) and scripts to extract design metrics. They are intended for ML experimentation.

**Folder structure:**
- *verilog* (the designs HDL code)
- *rpt* (reports will be placed here by scripts)
- *tmp* (your working folder)
- *scripts*
  - *runall.sh* (main script)
  - *met_ext.sh* (extracts design metrics from the log files)
- *lib*

**How to use**
1) cd tmp
2) ../scripts/runall.sh
3) ../scripts/met_ext.sh
4) Import metrics.csv into Excel or Google sheets

**Design Extracted Metrics**
- Number of cells [GenLib]
- Number of FF [GenLib]
- Number of XOR/XNOR cells [GenLib]
- Number of MUXes [GenLib]
- Number of PIs and POs -- module ports as well as FFs Ds and Qs
- Number of nets [GenLib] 
- Number of RTL named nets (Public Nets) [GenLib]
- Number of logic levels [SCL]

**Notes:**
- synth_reduced.tcl has several abc scripts. However, only scpt_0, scpt_1 and scpt_2 are used.
- It is better to normalize the extracted metrics. I suggest dividing them by the cells count (except of the number of levels)
- The designs are executed according to the design size (ascending order)

**Todo:**
Speed up the execution on multi-core machines.
