# FPGA UART Communication Subsystem

A Universal Asynchronous Receiver-Transmitter (UART) communication subsystem implemented in Verilog. This project features custom Finite State Machines (FSMs), debouncers, metastability synchronizers, and a 7-segment LED display driver. The design was deployed and tested on a Spartan-7 FPGA development board.

## Features

* **Configurable Baud Rate:** A custom baud controller supporting dynamic rate selection for synchronized sampling.
* **UART Transmitter (Tx):** FSM-based controller handling parallel-to-serial conversion.
* **UART Receiver (Rx):** Features a dedicated Datapath and FSM, employing metastability synchronizers and a mid-bit oversampling technique for safe asynchronous signal reception.
* **Error Detection:** Hardware-level parity checking (Parity Error) and Stop-bit validation (Framing Error).
* **Hardware Integrations:** Custom debouncers for physical board inputs.
* **Real-time Display Subsystem:** A custom 2-digit 7-segment LED driver that dynamically decodes and visualizes the transmitted/received bytes in hexadecimal format.

## System Architecture

The system is highly modular, ensuring a clean separation between the datapath, control logic (FSMs), and peripheral drivers.

### Transmitter Block Diagram
The transmitter takes an 8-bit parallel input and shifts it out serially, appending the appropriate Start, Parity, and Stop bits.
![Transmitter Architecture](docs/tx_block_diagram.png)

### Receiver FSM
The receiver uses an oversampling technique triggered by the baud controller to accurately sample the middle of each incoming bit, ensuring data integrity.
![Receiver FSM](docs/rx_fsm.png)

### UART Channel (Top-Level)
The integration of the Tx and Rx modules into a single communication channel for hardware validation.
![UART Channel](docs/uart_channel_block_diagram.png)

## Repository Structure

```text
fpga-uart-subsystem/
├── rtl/
│   ├── top/       # Top-level integration (UART channel and Display subsystem)
│   ├── tx/        # Transmitter FSM and datapath logic
│   ├── rx/        # Receiver FSM and datapath logic
│   ├── display/   # Seven-segment LED display drivers and decoders
│   └── common/    # Shared utility modules (Baud controller, Synchronizer, Debouncer)
├── tb/            # Behavioral testbenches
├── constraints/   # FPGA pin and timing constraints (.xdc)
└── docs/          # Block diagrams and state machine figures
```

## Verification & Hardware Validation

### Behavioral Simulation
The repository includes dedicated behavioral testbenches for each major subsystem. Each module (Tx, Rx, Baud Controller) includes its own testbench (`tb/`) to ensure correct isolated functionality before top-level integration.

### Hardware Execution
The complete `uart_channel_display` top module was synthesized and programmed onto a Spartan-7 FPGA development board:
* **Transmitter Control:** `baud_select` and `Tx_DATA` were mapped to board switches, while `Tx_EN` was mapped to a debounced push-button. A dedicated LED successfully indicated the `Tx_BUSY` state during transmission.
* **Receiver Outputs:** Received bytes were outputted to 8 onboard LEDs. Additional LEDs accurately reflected the `Rx_VALID`, `Rx_PERROR` (Parity Error), and `Rx_FERROR` (Framing Error) flags.
* **7-Segment Display:** The received byte was seamlessly routed to the onboard 7-segment display, rendering the hexadecimal value in real time.
* **Serial Communication:** The FPGA was interfaced with a PC via a USB-to-UART bridge. PuTTY was utilized as the primary serial terminal. Two-way communication between the FPGA hardware and the PC terminal was established flawlessly.

## Tools

* **HDL:** Verilog
* **Synthesis & Simulation:** AMD/Xilinx Vivado
* **Testing:** PuTTY / Serial Terminal

## Academic Context

This project was developed as part of the Digital Systems Design laboratory course at the Department of Electrical and Computer Engineering, University of Thessaly, during the Winter Semester 2025–2026. The RTL included in this repository represents the final implementation submitted for the course.
