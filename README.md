# 🚀 Open-Silicon ASIC Design & Physical Design Hub (SkyWater 130nm)

[![PDK](https://img.shields.io/badge/PDK-SkyWater%20130nm%20(sky130A)-blue.svg)](https://github.com/google/skywater-pdk)
[![Simulation](https://img.shields.io/badge/Simulation-Icarus%20Verilog%20%7C%20GTKWave-brightgreen.svg)](https://github.com/steveicarus/iverilog)
[![Synthesis](https://img.shields.io/badge/Synthesis-Yosys%20%7C%20ABC-orange.svg)](https://github.com/YosysHQ/yosys)
[![Status](https://img.shields.io/badge/Status-Active%20Engineering%20Development-success.svg)](#)

A comprehensive, production-grade repository documenting the end-to-end digital ASIC implementation flow from **RTL specification to tapeout-ready GDSII**, utilizing the open-source **SkyWater 130nm Process Design Kit (PDK)**.

---

## 🏛 Completed ASIC Flow Milestones

```text
  [ 01. RTL Design & Verification ]
        ├── Verilog HDL Modeling
        ├── Testbench & Stimulus Generation
        └── Waveform Verification (iverilog + GTKWave)
                │
                ▼
  [ 02. Logic Synthesis & Technology Mapping ]
        ├── Elaboration & Process Decomposition (Yosys)
        ├── Boolean Optimization & Decomposition (techmap)
        ├── Standard Cell Mapping (ABC + Sky130 HD Library)
        └── Silicon Gate-Level Netlist Generation
```

---

## 📂 Active Modules & Achievements

| Directory | Scope & Completed Milestones | Status |
| :--- | :--- | :--- |
| [`01_RTL_Design_and_Verification/`](./01_RTL_Design_and_Verification/) | RTL design, testbenches, cycle-accurate VCD waveforms, 100% truth table verification. | ✅ Verified & Complete |
| [`02_Logic_Synthesis_and_Technology_Mapping/`](./02_Logic_Synthesis_and_Technology_Mapping/) | Yosys elaboration, `techmap` Boolean factorization, ABC mapping to `sky130_fd_sc_hd__mux2_1`. | ✅ Verified & Complete |

---

## 🛠 EDA Toolchain Stack

* **RTL Simulator:** Icarus Verilog (`iverilog` v11.0)
* **Waveform Viewer:** GTKWave (v3.3.104)
* **Logic Synthesizer:** Yosys (v0.9+) with Berkeley ABC
* **PDK:** SkyWater 130nm High-Density Standard Cells (`sky130_fd_sc_hd`)
* **Operating Environment:** WSL 2 (Ubuntu 22.04 LTS)

---

## 👨‍💻 Author

**Aravind**  
*Aspiring VLSI & ASIC Physical Design Engineer*  
Open-Source Silicon Contributor
