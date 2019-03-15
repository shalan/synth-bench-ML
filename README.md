Set of Verilog designs (>70) and scripts to extract design metrics. They are intended for ML experiment.

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

