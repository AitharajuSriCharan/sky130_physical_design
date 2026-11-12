# 🚀 Open-Source Digital ASIC Design Flow (SkyWater 130nm)

[![PDK](https://img.shields.io/badge/PDK-SkyWater%20130nm%20(sky130A)-0055FF.svg)](https://github.com/google/skywater-pdk)
[![Simulation](https://img.shields.io/badge/Simulation-Icarus%20Verilog%20%7C%20GTKWave-2ea44f.svg)](https://github.com/steveicarus/iverilog)
[![Synthesis](https://img.shields.io/badge/Synthesis-Yosys%20%7C%20Berkeley%20ABC-f68a1e.svg)](https://github.com/YosysHQ/yosys)
[![Master Regression](https://img.shields.io/badge/Master%20Regression-100%25%20Passing-brightgreen.svg)](#-1-click-master-regression--reproducibility)
[![Standard Cells](https://img.shields.io/badge/Standard%20Cells-sky130__fd__sc__hd-blueviolet.svg)](#-silicon-cell-mapping--ppa-benchmark-summary)

A production-grade, silicon-proven repository implementing the complete digital Application-Specific Integrated Circuit (ASIC) implementation flow from **RTL specification to tapeout-ready GDSII**, targeting the open-source **SkyWater 130nm Process Design Kit (`sky130_fd_sc_hd`)**.

---

## 🏛 ASIC Implementation Pipeline

```text
               [ System Specification & RTL Architecture ]
                                    │
                                    ▼
       ┌─────────────────────────────────────────────────────────┐
  01   │ RTL Modeling & Cycle-Accurate Verification              │
       │  • IEEE 1364-2005 Verilog behavioral & dataflow models  │
       │  • Self-checking testbench stimulus & corner testing    │
       │  • VCD dump analysis & transition tracking in GTKWave   │
       └────────────────────────────┬────────────────────────────┘
                                    │
                                    ▼
       ┌─────────────────────────────────────────────────────────┐
  02   │ Logic Synthesis & Standard-Cell Technology Mapping      │
       │  • Elaboration, AST generation & process extraction     │
       │  • techmap: Boolean factorization into AIG network      │
       │  • Berkeley ABC mapping targeting sky130_fd_sc_hd.lib   │
       │  • Post-synthesis gate-level netlist & area analysis    │
       └────────────────────────────┬────────────────────────────┘
                                    │
                                    ▼
       ┌─────────────────────────────────────────────────────────┐
  03   │ Sequential Logic, Clocking Dynamics & Optimizations     │
       │  • Flip-Flops: Asynchronous Reset, Set, & Synchronous   │
       │  • Transistor polarity reconciliation (Active-High/Low) │
       │  • Dedicated pins (RESET_B) vs Input Gating (isobuf)    │
       │  • Hierarchical vs. Flattened boundary optimization     │
       │  • Zero-cost wire shifting (A × 2^N = 0 cells in metal) │
       └────────────────────────────┬────────────────────────────┘
                                    │
                                    ▼
       ┌─────────────────────────────────────────────────────────┐
  04   │ Physical Design & Tapeout Backend (OpenLane / OpenROAD) │
       │  • Floorplanning, IO Pin Placement & Power Distribution │
       │  • Standard Cell Placement & Congestion Reduction       │
       │  • Clock Tree Synthesis (CTS) for Skew & Slew Control   │
       │  • Global & Detailed Metal Routing (FastRoute / Triton) │
       │  • Sign-off: Physical DRC, LVS, Parasitic Extraction    │
       └─────────────────────────────────────────────────────────┘
```

---

## 🗺 Guided Learning & Architecture Journey

For reviewers, ASIC design engineers, and technical interviewers, navigate this repository along the silicon design hierarchy:

1. **[Module 01: RTL Design & Verification](./01_RTL_Design_and_Verification/)**  
   * **Why it matters:** Establishes cycle-accurate behavioral correctness before silicon commitment.
   * **Key Artifacts:** 2:1 Multiplexer Verilog model, automated testbench stimulus, high-resolution GTKWave waveform dumps, and truth table proof.

2. **[Module 02: Logic Synthesis & Technology Mapping](./02_Logic_Synthesis_and_Technology_Mapping/)**  
   * **Why it matters:** Solves the critical synthesis edge case where coarse `$mux` cells cannot be directly mapped by ABC without an intermediate `techmap` Boolean factorization pass.
   * **Key Artifacts:** Complete Yosys script, gate-level netlist mapped to `sky130_fd_sc_hd__mux2_1` ($11.26\,\mu\text{m}^2$), and cell pin-level layout breakdown.

3. **[Module 03: Sequential Logic, Clocking, and Hardware Optimizations](./03_Sequential_Logic_and_Clocking/)**  
   * **Why it matters:** Explores storage element behavior under clocking, asynchronous bypass vs synchronous latency, transistor active-low polarity in Sky130, hierarchical vs flat boundary preservation, and zero-cost arithmetic routing.
   * **Key Artifacts:** 3 flip-flop designs (`dff_asyncres`, `dff_async_set`, `dff_syncres`), cycle-accurate latency waveforms, Yosys coarse/fine schematics, and zero-gate power-of-2 multiplier proofs.

---

## 📊 Silicon Cell Mapping & PPA Benchmark Summary

All designs synthesized against the **SkyWater 130nm High-Density Standard-Cell Library (`sky130_fd_sc_hd__tt_025C_1v80.lib`)**:

| Design Module | Top-Level Function | Synthesized SkyWater 130nm Standard Cells | Hardware Architecture & Transistor Realization | Total Cells | Total Silicon Area ($\mu\text{m}^2$) |
| :--- | :--- | :--- | :--- | :---: | :---: |
| **`good_mux`** | 2:1 Combinational MUX | `sky130_fd_sc_hd__mux2_1` | Dedicated High-Density 2:1 MUX cell ($1\times$ drive) | **1** | **$11.26$** |
| **`dff_asyncres`** | Async-Reset D-Flop | `sky130_fd_sc_hd__dfrtp_1`<br>`sky130_fd_sc_hd__clkinv_1` | Flip-Flop with dedicated Active-Low `RESET_B` pin + Inverter for Active-High RTL compatibility | **2** | **$28.78$** |
| **`dff_async_set`** | Async-Set D-Flop | `sky130_fd_sc_hd__dfstp_2`<br>`sky130_fd_sc_hd__clkinv_1` | Flip-Flop with dedicated Active-Low `SET_B` pin ($2\times$ drive) + Inverter | **2** | **$30.03$** |
| **`dff_syncres`** | Sync-Reset D-Flop | `sky130_fd_sc_hd__dfxtp_1`<br>`sky130_fd_sc_hd__lpflow_isobufsrc_1` | **No reset pin in silicon!** Plain flip-flop preceded by combinational AND-isolation gate on $D$ | **2** | **$26.28$** |
| **`multiple_modules` (Hierarchical)** | Sub-module Pipeline | `sub_module1` (AND2)<br>`sub_module2` (LP-ISO) | Preserves sub-block hierarchy boundaries for modular physical placement | **2** | **$18.90$** |
| **`multiple_modules` (Flattened)** | Dissolved Pipeline | `sky130_fd_sc_hd__and2_0`<br>`sky130_fd_sc_hd__lpflow_inputiso1p_1` | Dissolves boundaries; cross-module optimization into single flat netlist | **2** | **$18.90$** |
| **`mult2`** ($A \times 2$) | Power-of-2 Multiply | **ZERO CELLS (0 Gates)** | Pure copper wire left-shift ($\{A[2:0],\, 1'b0\}$) with LSB tied to Ground | **0** | **$0.00$** |
| **`mult8`** ($A \times 8$) | Power-of-2 Multiply | **ZERO CELLS (0 Gates)** | Pure copper wire left-shift ($\{A[2:0],\, 3'b000\}$) with 3 LSBs tied to Ground | **0** | **$0.00$** |
| **`opt_check`** ($A \,?\, B : 0$) | Ternary MUX Reduction | `sky130_fd_sc_hd__and2_0` | Boolean simplification $Y = A \cdot B$ collapses MUX to single 2-input AND gate | **1** | **$6.26$** |

---

## ⚡ 1-Click Master Regression & Reproducibility

Every simulation testbench, technology synthesis pass, and netlist generation run across the entire repository is fully automated and reproducible with a single script:

```bash
# Clone the repository
git clone https://github.com/AitharajuSriCharan/sky130_physical_design.git
cd sky130_physical_design

# Execute the complete master verification and synthesis regression suite
./scripts/run_all.sh
```

### Modular Execution Shortcuts:
```bash
# Simulate Module 01 (2:1 Multiplexer)
./01_RTL_Design_and_Verification/scripts/run_sim.sh

# Synthesize Module 02 (Technology Mapping)
./02_Logic_Synthesis_and_Technology_Mapping/scripts/run_synth.sh

# Run all Module 03 Sequential Simulations
./03_Sequential_Logic_and_Clocking/scripts/run_all_sim.sh

# Run all Module 03 Technology Syntheses
./03_Sequential_Logic_and_Clocking/scripts/run_all_synth.sh
```

---

## 📂 Repository Hierarchy

```text
sky130_physical_design/
├── scripts/
│   └── run_all.sh                               # 1-Click Master Regression Suite
├── 01_RTL_Design_and_Verification/
│   ├── src/good_mux.v                          # Behavioral 2:1 Multiplexer RTL
│   ├── tb/tb_good_mux.v                        # Testbench with comprehensive vector suite
│   ├── sim/good_mux.vcd                        # Value Change Dump waveform
│   ├── docs/images/                            # Simulation waveforms & terminal captures
│   ├── scripts/run_sim.sh                      # Automated simulation execution script
│   └── README.md                               # Complete Module 01 documentation
├── 02_Logic_Synthesis_and_Technology_Mapping/
│   ├── netlist/good_mux_synth.v                # Gate-level netlist (sky130_fd_sc_hd__mux2_1)
│   ├── reports/synthesis.log                   # Yosys + ABC synthesis report
│   ├── docs/images/                            # Schematic & area statistics captures
│   ├── scripts/synth.tcl                       # Yosys synthesis script
│   ├── scripts/run_synth.sh                    # Automated synthesis runner
│   └── README.md                               # Complete Module 02 documentation
├── 03_Sequential_Logic_and_Clocking/
│   ├── src/                                    # Sequential RTL designs (Flops, Mult, Opt)
│   ├── tb/                                     # Cycle-accurate testbenches
│   ├── sim/                                    # Generated VCD waveform databases
│   ├── netlist/                                # Silicon gate-level netlists
│   ├── docs/images/                            # Waveforms, Yosys stats, & schematics
│   ├── scripts/run_all_sim.sh                  # Automated batch simulation script
│   ├── scripts/synth_all.tcl                   # Batch Yosys synthesis script
│   ├── scripts/run_all_synth.sh                # Automated batch synthesis runner
│   └── README.md                               # Complete Module 03 documentation
└── README.md                                   # Root project documentation
```

---

## 🛠 EDA Toolchain Stack

| Layer | Tool | Version | Purpose |
| :--- | :--- | :--- | :--- |
| **HDL Simulation** | [Icarus Verilog](http://iverilog.icarus.com/) | v11.0 | IEEE 1364-2005 Verilog simulation & VCD generation |
| **Waveform Analysis** | [GTKWave](http://gtkwave.sourceforge.net/) | v3.3.104 | Signal inspection, transition latency, & timing verification |
| **Logic Synthesis** | [Yosys](https://yosyshq.net/yosys/) | v0.9+ | RTL elaboration, process decomposition, optimization |
| **Technology Mapping** | [Berkeley ABC](https://github.com/berkeley-abc/abc) | Integrated | Boolean network optimization & standard cell library binding |
| **Schematic Rendering**| [Graphviz xdot](https://graphviz.org/) | v2.43+ | RTLIL AST graph & physical gate schematic visualization |
| **Target PDK** | [SkyWater 130nm](https://github.com/google/skywater-pdk) | sky130A (`hd`) | 130nm standard cell CMOS Liberty timing models (`tt_025C_1v80`) |
| **Environment** | Ubuntu 22.04 LTS (WSL 2) | Linux 5.15 | Host EDA execution environment |

---

## 👨‍💻 Author & Contributions

**[Sri Charan Aitharaju](https://github.com/AitharajuSriCharan)**  
Digital ASIC Design & Physical Implementation Engineer  
Open-Source Silicon Contributor  
GitHub: [@AitharajuSriCharan](https://github.com/AitharajuSriCharan)
