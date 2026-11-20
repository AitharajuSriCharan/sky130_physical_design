# 📖 Day 3 Complete Lecture Notes: OpenLane Physical Design Inception, Floorplanning, and Placement

**Course:** Digital ASIC & Physical Design (From RTL to GDSII)  
**Process Technology:** SkyWater 130nm CMOS (`sky130_fd_sc_hd`)  
**Design Under Test:** Claire Wolf's PicoRV32 32-bit RISC-V CPU Core (`picorv32a`)  
**Student & Author:** Sri Charan Aitharaju  
**Repository:** [`AitharajuSriCharan/sky130_physical_design`](https://github.com/AitharajuSriCharan/sky130_physical_design)

---

## 📑 Table of Contents
1. [Engineering Motivation: Transitioning from Frontend RTL to Backend Physical Design](#1-engineering-motivation-transitioning-from-frontend-rtl-to-backend-physical-design)
2. [OpenLane Architecture & The Containerized EDA Stack](#2-openlane-architecture--the-containerized-eda-stack)
3. [Design Preparation & Workspace Inception (`prep`)](#3-design-preparation--workspace-inception-prep)
4. [Logic Synthesis of PicoRV32a & The Flop Ratio Derivation](#4-logic-synthesis-of-picorv32a--the-flop-ratio-derivation)
5. [Floorplanning Mechanics: Physics, Dimensions & Power Planning](#5-floorplanning-mechanics-physics-dimensions--power-planning)
6. [Global and Detailed Placement (`run_placement`)](#6-global-and-detailed-placement-run_placement)
7. [Physical Verification in Magic VLSI: From Core Boundary to Pin Abstracts](#7-physical-verification-in-magic-vlsi-from-core-boundary-to-pin-abstracts)
8. [⭐ Chronological Command Master Reference (Copy-Paste Ready)](#8--chronological-command-master-reference-copy-paste-ready)

---

## 1. Engineering Motivation: Transitioning from Frontend RTL to Backend Physical Design

In Modules 01 through 04, our verification focus was logical correctness:
* Writing synthesizable Verilog.
* Running cycle-accurate event-driven testbenches in Icarus Verilog (`iverilog`).
* Mapping Boolean logic into SkyWater 130nm standard cells with Yosys.
* Proving that Gate-Level Simulation (GLS) catches simulator-synthesis mismatches.

However, a digital netlist is not hardware—it is merely a text file containing names of standard cells and virtual wires. To fabricate a physical integrated circuit, we must translate gates into geometric planar polygons across multiple physical masks (diffusion, polysilicon, contacts, and metal routing layers Metal 1 through Metal 5). This journey is called **Physical Design (Backend Implementation)**.

---

## 2. OpenLane Architecture & The Containerized EDA Stack

### Why OpenLane?
Traditional commercial EDA flows (Synopsys, Cadence) cost hundreds of thousands of dollars per seat and require rigid site licensing. **OpenLane** is an automated RTL-to-GDSII flow developed by Efabless that harnesses open-source tools:
* **Logic Synthesis:** Yosys & Berkeley ABC
* **Static Timing Analysis (STA):** OpenSTA
* **Floorplanning, Placement & Routing:** OpenROAD (RePLace, OpenDP, TritonCTS, FastRoute, TritonRoute)
* **Power Planning:** OpenROAD PDN generator
* **Physical Verification:** Magic VLSI (DRC/GDSII extraction) and Netgen (LVS)
* **Design Rule Checking & Mask Export:** KLayout & Magic

### The Docker Container Sandbox
Because these tools require diverse C++, Python, Boost, and Tcl library dependencies, OpenLane packages the entire stack inside a hardened Docker container.
* Host Path: `/home/aravi/OpenLane` is mounted to `/openlane`.
* PDK Path: `/home/aravi/.ciel` is mounted to `/home/aravi/.ciel` and bound to `$PDK_ROOT`.
* Display Socket: Host `/tmp/.X11-unix` is mapped into the container, enabling interactive GUI applications (Magic VLSI, GTKWave) to render transparently on Windows via WSLg.

---

## 3. Design Preparation & Workspace Inception (`prep`)

In OpenLane, designs reside under `designs/<design_name>/`.
For the benchmark 32-bit RISC-V CPU core (`picorv32a`):
* `src/picorv32a.v`: Synthesizable Verilog RTL for the RV32IMC processor.
* `config.tcl` / `config.json`: Floorplan utilization, clock constraints, and target metal layers.
* `sky130A_sky130_fd_sc_hd_config.tcl`: Highest-priority library override file.

### What Happens During `prep -design picorv32a`:
1. OpenLane ingests the configuration files.
2. It sets up environment variables (`$::env(DESIGN_NAME)`, `$::env(CLOCK_PERIOD)`, etc.).
3. It prepares multi-corner LEF files (`nom`, `min`, `max`) from `$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/lef/`.
4. It creates an isolated, timestamped run directory:
   ```text
   designs/picorv32a/runs/RUN_2026.11.20_06.07.38/
   ├── config.tcl
   ├── logs/
   ├── reports/
   ├── results/
   └── tmp/
   ```

---

## 4. Logic Synthesis of PicoRV32a & The Flop Ratio Derivation

Running `run_synthesis` triggers Yosys and ABC to elaborate the RTL and bind logic to `sky130_fd_sc_hd` cells.

### Post-Synthesis Statistics (`1-synthesis.DELAY_0.stat.rpt`):
* **Total Number of Cells ($N_{\text{Total}}$):** `9,624`
* **Sequential D-Flip-Flops ($N_{\text{DFF}}$):** `1,596` (`sky130_fd_sc_hd__dfxtp_2`)
* **Combinational Multiplexers:** `1,891` (`mux2_2`: 1,528, `mux4_2`: 363)
* **High-Drive Buffers:** `2,101` (`buf_1`, `buf_2`)
* **Total Cell Silicon Area:** `104,443.92 µm²`

### 🧮 Mathematical Derivation of the Flop Ratio:
$$\text{Flop Ratio} = \frac{N_{\text{DFF}}}{N_{\text{Total Cells}}} \times 100\% = \frac{1,596}{9,624} \times 100\% = \mathbf{16.58\%}$$

**Physical Significance:** In a 32-bit scalar RISC CPU, approximately 1 in every 6 cells is a memory/pipeline state element. The remaining $83.42\%$ constitutes combinational logic (ALU addition, branching, register selection, and clock routing buffers).

---

## 5. Floorplanning Mechanics: Physics, Dimensions & Power Planning

Floorplanning establishes the outer boundary of the silicon die, the inner core placement region, and the power grid.

### 1. Die vs. Core Geometry:
In `results/floorplan/picorv32a.def`:
* **Distance Units:** `UNITS DISTANCE MICRONS 1000 ;` (1 DBU = 1 nm).
* **Die Area:** `(0, 0)` to `(557310, 568030)`
  $$\text{Die Width} = 557.31\,\mu\text{m}, \quad \text{Die Height} = 568.03\,\mu\text{m}$$
  $$\text{Total Die Area} = 557.31 \times 568.03 = \mathbf{316,568.7\,\mu\text{m}^2} \quad (0.317\,\text{mm}^2)$$
* **Core Dimensions:**
  $$\text{Core Width} = 546.02\,\mu\text{m}, \quad \text{Core Height} = 544.00\,\mu\text{m}$$
  $$\text{Aspect Ratio} = \frac{544.00}{546.02} = \mathbf{0.996} \approx \mathbf{1.0} \quad (\text{Square Core})$$
* **Core Utilization:**
  $$\text{Utilization} = \frac{\text{Cell Area}}{\text{Core Area}} = \frac{104,443.92\,\mu\text{m}^2}{297,034.88\,\mu\text{m}^2} \times 100\% = \mathbf{35.16\%}$$
  *(Target was $35\%$; met with $0.16\%$ error!)*

### 2. Standard Cell Row Orientation (Alternating N and FS):
Adjacent standard cell rows alternate between `N` (Normal) and `FS` (Flipped South). This allows adjacent rows to share a single continuous $V_{DD}$ or $GND$ power rail, reducing overall interconnect overhead by $\sim 30\%$.

### 3. Decoupling Capacitors (Decaps):
Transient current surges during simultaneous switching cause inductive voltage drops:
$$V_{\text{drop}} = L \frac{di}{dt}$$
Decaps (`sky130_fd_sc_hd__decap_*`) act as local charge reservoirs connected between $V_{DD}$ and $GND$ to clamp voltage fluctuations and suppress ground bounce.

### 4. Well-Tap Cells (Latchup Prevention):
To prevent parasitic NPN-PNP SCR thyristors from turning on and causing catastrophic CMOS latchup, Well-Tap cells (`sky130_fd_sc_hd__tapvpwrvgnd_1`) tie the N-well to $V_{DD}$ and the P-substrate to $GND$ at regular intervals $\le 14\,\mu\text{m}$.

---

## 6. Global and Detailed Placement (`run_placement`)

1. **Global Placement (RePLace):**
   * Uses an **electrostatic force-directed analogy**: nets are modeled as attractive springs, while overlapping cell densities create repulsive forces.
   * Minimizes Half-Perimeter Wirelength (HPWL) while tolerating small temporary overlaps.
2. **Placement Resizer Optimization:**
   * Sizes up under-driven gates and inserts buffers on long nets to meet transition slews.
   * Cell area slightly increases from $104,443\,\mu\text{m}^2$ to **$110,268\,\mu\text{m}^2$** ($37\%$ utilization).
3. **Detailed Placement (OpenDP):**
   * Snaps every single cell legally into site rows with **zero overlaps**.
4. **Post-Placement Static Timing Analysis (OpenSTA):**
   * **Worst Negative Slack (WNS):** `0.00 ns` (Zero violations!)
   * **Setup Slack ($T_{\text{clk}} = 24\,\text{ns}$):** `+12.89 ns` (Positive Slack)
   * **Hold Slack:** `+0.21 ns` (Positive Slack)
   * **DRC Violations:** `0 Errors`

---

## 7. Physical Verification in Magic VLSI: From Core Boundary to Pin Abstracts

### Why LEF Abstracts?
Full transistor layouts contain millions of polygons. Loading all polygons into memory during physical design would crash EDA tools.
* **LEF (Library Exchange Format):** Contains only the cell bounding box, pin ports (`VPWR`, `VGND`, `A`, `X`), and routing metal blockages.
* **GDSII Stream-Out:** In the final signoff stage, OpenLane substitutes LEF abstracts with the true full-mask foundry polygons from the PDK.

### Magic Commands Reference:
* **`v`**: View all (fits the entire silicon chip to screen).
* **`z` / `Z`**: Zoom in / Zoom out.
* **`s`**: Select the standard cell beneath the cursor.
* **`what`**: Print cell instance name and library definition to console.
* **`expand`**: Unroll the cell to reveal internal pins (`VPWR`, `VGND`, `VNB`, input/output ports).
* **`unexpand`**: Collapse the cell back to its abstract bounding box.

---

## 8. ⭐ Chronological Command Master Reference (Copy-Paste Ready)

```bash
# ------------------------------------------------------------------------------
# STEP 1: Launch OpenLane Container
# ------------------------------------------------------------------------------
cd /home/aravi/OpenLane
make mount

# ------------------------------------------------------------------------------
# STEP 2: Interactive Tcl Inception & Design Prep (Inside Container)
# ------------------------------------------------------------------------------
./flow.tcl -interactive
package require openlane
prep -design picorv32a

# ------------------------------------------------------------------------------
# STEP 3: Run Logic Synthesis & Technology Mapping
# ------------------------------------------------------------------------------
run_synthesis

# ------------------------------------------------------------------------------
# STEP 4: Run Floorplanning & Power Distribution Network (PDN)
# ------------------------------------------------------------------------------
run_floorplan

# ------------------------------------------------------------------------------
# STEP 5: Run Global & Detailed Placement
# ------------------------------------------------------------------------------
run_placement

# ------------------------------------------------------------------------------
# STEP 6: Inspect Layout in Magic VLSI (From a Second Ubuntu Host Terminal)
# ------------------------------------------------------------------------------
cd /home/aravi/OpenLane/designs/picorv32a/runs/RUN_2026.11.20_06.07.38/results/placement/
magic -T /home/aravi/.ciel/sky130A/libs.tech/magic/sky130A.tech lef read ../../tmp/merged.nom.lef def read picorv32a.def &
```
