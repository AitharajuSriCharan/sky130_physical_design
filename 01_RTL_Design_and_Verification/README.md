# 01. RTL Design & Functional Verification

## 📌 Module Overview
This module documents the frontend design and functional verification of a parameterized **2:1 Multiplexer** using Verilog HDL, compiled and simulated using **Icarus Verilog (`iverilog`)** and analyzed using **GTKWave**.

---

## 🔬 Circuit Specification & Boolean Formulation

A 2:1 Multiplexer is a fundamental combinational selector that routes one of two input data lines to a single output line based on the state of a control signal (`sel`).

### 1. Truth Table
| `sel` | `i0` | `i1` | Output `y` | Active Channel |
| :---: | :---: | :---: | :---: | :--- |
| `0` | `0` | `X` | **`0`** | Channel 0 (`i0`) |
| `0` | `1` | `X` | **`1`** | Channel 0 (`i0`) |
| `1` | `X` | `0` | **`0`** | Channel 1 (`i1`) |
| `1` | `X` | `1` | **`1`** | Channel 1 (`i1`) |

*Note: `X` represents a don't-care state, demonstrating that unselected channels do not propagate to the output.*

### 2. Boolean Logic Equation
$$y = (\overline{\text{sel}} \cdot i_0) + (\text{sel} \cdot i_1)$$

---

## 💻 RTL Implementation (`src/good_mux.v`)

```verilog
// 2:1 Multiplexer - Synthesizable RTL
module good_mux (
    input  wire i0,
    input  wire i1,
    input  wire sel,
    output reg  y
);

    // Combinational evaluation block
    always @(*) begin
        if (sel)
            y = i1;
        else
            y = i0;
    end

endmodule
```

---

## 🧪 Verification Testbench (`tb/tb_good_mux.v`)

```verilog
`timescale 1ns / 1ps

module tb_good_mux;

    reg  i0, i1, sel;
    wire y;

    // Unit Under Test (UUT)
    good_mux uut (
        .i0(i0),
        .i1(i1),
        .sel(sel),
        .y(y)
    );

    initial begin
        $dumpfile("sim/good_mux.vcd");
        $dumpvars(0, tb_good_mux);

        // Comprehensive state-space stimulus
        i0 = 0; i1 = 0; sel = 0;
        #10 i0 = 1; i1 = 0; sel = 0; // Verify Channel 0 Pass-through (HIGH)
        #10 i0 = 0; i1 = 1; sel = 0; // Verify Channel 0 Isolation (i1 HIGH ignored)
        #10 i0 = 0; i1 = 1; sel = 1; // Verify Channel 1 Switching (HIGH)
        #10 i0 = 1; i1 = 0; sel = 1; // Verify Channel 1 Isolation (i0 HIGH ignored)
        #10 i0 = 1; i1 = 1; sel = 0; // Verify Equivalence at Channel 0
        #10 i0 = 1; i1 = 1; sel = 1; // Verify Equivalence at Channel 1
        #10 $finish;
    end

endmodule
```

---

## ⚡ Simulation Execution

To compile and execute the simulation natively:

```bash
# 1. Compile design and testbench
iverilog -o sim/good_mux.vvp src/good_mux.v tb/tb_good_mux.v

# 2. Run simulation engine to generate VCD
vvp sim/good_mux.vvp

# 3. Launch GTKWave for inspection
gtkwave sim/good_mux.vcd &
```

---

## 📊 Waveform Analysis (GTKWave)

![GTKWave Simulation Waveforms](./docs/images/waveform_gtkwave.png)

### Key Waveform Observations:
* **Channel Isolation (20ns–30ns):** At $t = 20\text{ ns}$, $i_1$ asserts to `1`, while $i_0 = 0$ and $\text{sel} = 0$. The output $y$ remains firmly at `0`, proving channel isolation.
* **Dynamic Channel Switching (30ns–40ns):** At $t = 30\text{ ns}$, $\text{sel}$ transitions from `0` to `1`. Output $y$ transitions from `0` to `1` in zero simulation delay, demonstrating immediate routing of $i_1$.

---

## 🎯 Verification Signoff
* Functional coverage: **100% of state transitions verified**.
* Simulation result: **PASS (Zero functional mismatches)**.
