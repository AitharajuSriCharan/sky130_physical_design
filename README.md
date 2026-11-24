# 🚀 Open-Source Digital ASIC Design Flow (SkyWater 130nm)

[![PDK](https://img.shields.io/badge/PDK-SkyWater%20130nm%20(sky130A)-0055FF.svg)](https://github.com/google/skywater-pdk)
[![Architecture](https://img.shields.io/badge/Architecture-RISC--V%20(RV32IMC)-red.svg)](https://github.com/YosysHQ/picorv32)
[![Core](https://img.shields.io/badge/Core-PicoRV32a%20(32--Bit%20CPU)-orange.svg)](./05_OpenLane_Floorplanning_and_Placement/)
[![Simulation](https://img.shields.io/badge/Simulation-Icarus%20Verilog%20%7C%20GTKWave-2ea44f.svg)](https://github.com/steveicarus/iverilog)
[![Synthesis](https://img.shields.io/badge/Synthesis-Yosys%20%7C%20Berkeley%20ABC-f68a1e.svg)](https://github.com/YosysHQ/yosys)
[![Master Regression](https://img.shields.io/badge/Master%20Regression-100%25%20Passing-brightgreen.svg)](#-1-click-master-regression--reproducibility)
[![Standard Cells](https://img.shields.io/badge/Standard%20Cells-sky130__fd__sc__hd-blueviolet.svg)](#-silicon-cell-mapping--ppa-benchmark-summary)

A production-grade, silicon-proven repository implementing the complete digital Application-Specific Integrated Circuit (ASIC) implementation flow from **RTL specification to tapeout-ready GDSII**, targeting the open-source **SkyWater 130nm Process Design Kit (`sky130_fd_sc_hd`)**.

> 🏆 **Flagship Microprocessor Implementation:** Features the complete backend physical implementation of Claire Wolf's **32-Bit RISC-V CPU Core (`picorv32a` - RV32IMC)**, synthesized into **9,624 standard cells** (1,596 D-Flip-Flops), floorplanned onto a **$557\,\mu\text{m} \times 568\,\mu\text{m}$ square silicon die** ($35.16\%$ Core Utilization), and legally placed with **`+12.89 ns` Setup Slack** and **`✔ DRC=0`** errors in Magic VLSI.

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
  04   │ Gate-Level Simulation (GLS) & Synthesis Mismatches      │
       │  • Sensitivity list omissions (bad_mux vs MUX hardware) │
       │  • Out-of-order blocking assignments (blocking_caveat)  │
       │  • Accidental latch inference (incomp_if / incomp_case) │
       │  • GLS verification with Sky130 primitives & models     │
       └────────────────────────────┬────────────────────────────┘
                                    │
                                    ▼
       ┌─────────────────────────────────────────────────────────┐
  05   │ Physical Design & Tapeout Backend (OpenLane / OpenROAD) │
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

4. **[Module 04: Gate-Level Simulation (GLS) & Synthesis-Simulation Mismatches](./04_Gate_Level_Simulation_and_Synthesis_Mismatches/)**  
   * **Why it matters:** Eliminates the #1 cause of catastrophic silicon re-spins by proving divergence between behavioral simulator event queues and synthesized CMOS hardware. Analyzes sensitivity list bugs (`bad_mux`), blocking race conditions (`blocking_caveat`), and unwanted latch inference (`incomp_if`, `incomp_case`).
   * **Key Artifacts:** Comparative RTL vs GLS waveform timing traces (GTKWave), gate-level schematics, execution logs against SkyWater 130nm standard cell models (`primitives.v` + `sky130_fd_sc_hd.v`), and Yosys `$dlatch` vs `mux4_2` comparative reports.

5. **[Module 05: OpenLane Backend Flow — Synthesis, Floorplanning & Placement](./05_OpenLane_Floorplanning_and_Placement/)**  
   * **Why it matters:** Initiates the physical ASIC backend flow for Claire Wolf's 32-bit RISC-V CPU core (`picorv32a`) on SkyWater 130nm. Explores Docker containerization, interactive OpenLane Tcl orchestration, mathematical Flop Ratio derivation (16.58%), square floorplanning (Aspect Ratio 1.0, 35.16% Utilization), Decoupling Capacitor and Well-Tap insertion, force-directed Global Placement (RePLace), Detailed Placement (OpenDP), setup timing slack (+12.89ns margin), and physical DEF inspection in Magic VLSI.
   * **Key Artifacts:** Placed silicon DEF layout, Magic VLSI layout captures, terminal execution logs, Flop Ratio calculations, and cell-level pin abstracts (`VPWR`, `VGND`, `VNB`, `A`, `X`).

---

## 📊 Silicon Cell Mapping & PPA Benchmark Summary

All designs synthesized against the **SkyWater 130nm High-Density Standard-Cell Library (`sky130_fd_sc_hd__tt_025C_1v80.lib`)**:

| Design Module | Top-Level Function | Synthesized SkyWater 130nm Standard Cells | Hardware Architecture & Transistor Realization | Total Cells | Total Silicon Area ($\mu\text{m}^2$) |
| :--- | :--- | :--- | :--- | :---: | :---: |
| **`good_mux`** | 2:1 Combinational MUX | `sky130_fd_sc_hd__mux2_1` | Dedicated High-Density 2:1 MUX cell ($1\times$ drive) | **1** | **$11.26$** |
| **`bad_mux`** | MUX (GLS Mismatch) | `sky130_fd_sc_hd__mux2_1` | Correct physical MUX synthesized despite sensitivity list omission | **1** | **$11.26$** |
| **`blocking_caveat`** | Out-of-Order Blocking | `sky130_fd_sc_hd__o21a_1` | Pure combinational OR-AND gate ($X = (A_1 + A_2) \cdot B_1$), 0 memory delay | **1** | **$6.26$** |
| **`incomp_if`** | Missing `else` Branch | `$_DLATCH_P_` (Transparent D-Latch) | Synthesizer forced to infer level-sensitive latch to hold state | **1** | **Latch Inferred** |
| **`comp_case`** | 4:1 MUX with `default` | `sky130_fd_sc_hd__mux4_2` | Fully specified 4:1 multiplexer cell with zero latches | **1** | **$17.52$** |
| **`dff_asyncres`** | Async-Reset D-Flop | `sky130_fd_sc_hd__dfrtp_1`<br>`sky130_fd_sc_hd__clkinv_1` | Flip-Flop with dedicated Active-Low `RESET_B` pin + Inverter for Active-High RTL compatibility | **2** | **$28.78$** |
| **`dff_async_set`** | Async-Set D-Flop | `sky130_fd_sc_hd__dfstp_2`<br>`sky130_fd_sc_hd__clkinv_1` | Flip-Flop with dedicated Active-Low `SET_B` pin ($2\times$ drive) + Inverter | **2** | **$30.03$** |
| **`dff_syncres`** | Sync-Reset D-Flop | `sky130_fd_sc_hd__dfxtp_1`<br>`sky130_fd_sc_hd__lpflow_isobufsrc_1` | **No reset pin in silicon!** Plain flip-flop preceded by combinational AND-isolation gate on $D$ | **2** | **$26.28$** |
| **`multiple_modules` (Hierarchical)** | Sub-module Pipeline | `sub_module1` (AND2)<br>`sub_module2` (LP-ISO) | Preserves sub-block hierarchy boundaries for modular physical placement | **2** | **$18.90$** |
| **`multiple_modules` (Flattened)** | Dissolved Pipeline | `sky130_fd_sc_hd__and2_0`<br>`sky130_fd_sc_hd__lpflow_inputiso1p_1` | Dissolves boundaries; cross-module optimization into single flat netlist | **2** | **$18.90$** |
| **`mult2`** ($A \times 2$) | Power-of-2 Multiply | **ZERO CELLS (0 Gates)** | Pure copper wire left-shift ($\{A[2:0],\, 1'b0\}$) with LSB tied to Ground | **0** | **$0.00$** |
| **`mult8`** ($A \times 8$) | Power-of-2 Multiply | **ZERO CELLS (0 Gates)** | Pure copper wire left-shift ($\{A[2:0],\, 3'b000\}$) with 3 LSBs tied to Ground | **0** | **$0.00$** |
| **`opt_check`** ($A \,?\, B : 0$) | Ternary MUX Reduction | `sky130_fd_sc_hd__and2_0` | Boolean simplification $Y = A \cdot B$ collapses MUX to single 2-input AND gate | **1** | **$6.26$** |
| **`picorv32a`** | **32-Bit RISC-V CPU Core** | Complete `sky130_fd_sc_hd` standard cell library | **RV32IMC scalar CPU:** 1,596 DFFs (Flop Ratio 16.58%), 1,891 MUXes, 2,101 buffers. Sized to $546\,\mu\text{m} \times 544\,\mu\text{m}$ core ($35.16\%$ util), placed with $+12.89\,\text{ns}$ setup slack. | **9,624** | **$104,443.92$** (Post-resizer: $110,268$) |

---

## ⚡ 1-Click Master Regression & Reproducibility

Every simulation waveform, gate-level netlist, and synthesis statistic across all modules can be fully verified with a single regression run:

```bash
# Clone the repository
git clone https://github.com/AitharajuSriCharan/sky130_physical_design.git
cd sky130_physical_design

# Execute the complete 5-stage master verification, synthesis, and GLS regression suite
./scripts/run_all.sh
```

### Modular Execution Shortcuts:
```bash
# Simulate Module 01 (2:1 Multiplexer)
./01_RTL_Design_and_Verification/scripts/run_sim.sh

# Synthesize Module 02 (Technology Mapping)
./02_Logic_Synthesis_and_Technology_Mapping/scripts/run_synth.sh

# Run Module 03 Sequential Simulations & Syntheses
./03_Sequential_Logic_and_Clocking/scripts/run_all_sim.sh
./03_Sequential_Logic_and_Clocking/scripts/run_all_synth.sh

# Run Module 04 Gate-Level Simulation (GLS) Suite
./04_Gate_Level_Simulation_and_Synthesis_Mismatches/scripts/run_all_gls.sh
```

---

## 📂 Repository Hierarchy

```text
sky130_physical_design/
├── scripts/
│   └── run_all.sh                               # 1-Click Master 5-Stage Regression Suite
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
├── 04_Gate_Level_Simulation_and_Synthesis_Mismatches/
│   ├── src/                                    # bad_mux, blocking_caveat, incomp_if, incomp_case
│   ├── tb/                                     # RTL & GLS verification testbenches
│   ├── sim/                                    # RTL vs GLS VCD waveform databases
│   ├── netlist/                                # Synthesized gate-level netlists (Sky130)
│   ├── reports/                                # Yosys synthesis & GLS logs
│   ├── docs/images/                            # Comparative waveform traces & gate schematics
│   ├── scripts/run_all_gls.sh                  # Automated Module 04 regression suite
│   └── README.md                               # Complete Module 04 documentation
└── README.md                                   # Root project documentation
```

---

## 🛠 EDA Toolchain Stack

| Layer | Tool | Version | Purpose |
| :--- | :--- | :--- | :--- |
| **HDL Simulation** | [Icarus Verilog](http://iverilog.icarus.com/) | v11.0 | IEEE 1364-2005 Verilog simulation & VCD generation |
| **Gate-Level Simulation**| [Icarus Verilog](http://iverilog.icarus.com/) | v11.0 | Post-synthesis GLS with Sky130 standard-cell models |
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
