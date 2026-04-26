# SoC Practice: LCD-Keyboard-Timers-Interrupts  
## Andre - Santi - Jared - Joshua  

This project implements an embedded system that combines interrupts, timers, a keypad interface, and an LCD display to control system states in real time. The system operates in two modes: **RUNNING** and **PAUSED**, switching between them using external interrupts and keypad input.

---

## Materials Used

To replicate this project, the following hardware is required:

* **Microcontroller:** KL25Z  
* **Display:** LCD (16x2) operating in **8-bit mode**  
* **Input Devices:**  
  * Push button (connected to PTA1)  
  * 4x4 Matrix Keypad  
* **Extra Components:** Breadboard, jumper wires, resistor  

---

## System Features

* **Interrupt-Based Control:** Uses PORTA interrupt to immediately change system state.  
* **State Machine:** Implements two states:
  * `RUNNING`
  * `PAUSED`  
* **Keypad Interaction:** Allows user to resume system operation using a specific key (`*`).  
* **LCD Feedback:** Displays current system state in real time.  
* **Timer Integration:** TPM0 generates periodic interrupts (100 ms base timing).  
* **Low Power Efficiency:** Uses `__WFI()` to wait for interrupts.  

---

## Architecture and Pin Mapping

### Push Button - Port A
* **Input Pin:** `PTA1`  
  * Configured with pull-up resistor  
  * Interrupt on falling edge  

---

### Keypad - Port C

* **Rows (Outputs):** `PTC0` – `PTC3`  
* **Columns (Inputs):** `PTC4` – `PTC7`  
* Configured with pull-up resistors for scanning  

---

### LCD Screen - Ports A and D (8-Bit Mode)

* **Data Bus (8 bits):** `PTD0` – `PTD7`  
* **Control Pins:**
  * **RS:** `PTA2`  
  * **R/W:** `PTA4`  
  * **EN:** `PTA5`  

---

### Timer Module

* **TPM0:** Generates periodic interrupts (~100 ms base timing)  

---

## Execution Flow

1. **Initialization:**
   * Configure TPM0 timer with interrupt  
   * Configure PTA1 as interrupt input  
   * Initialize keypad scanning system  
   * Initialize LCD  
   * Display initial state `"RUNNING"`  

2. **Main Loop:**
   * Continuously scan keypad  
   * If `'*'` key is pressed:
     * Apply debounce delay  
     * Change state to `RUNNING`  
     * Reset counter  
     * Update LCD  

3. **Interrupt Handling (PORTA):**
   * Triggered when button is pressed  
   * Change state to `PAUSED`  
   * Update LCD to show `"PAUSED"`  

4. **Timer Interrupt (TPM0):**
   * Executes periodically  
   * If system is `RUNNING`, increments internal counter  
   * If `PAUSED`, no action is taken  

5. **Low Power Mode:**
   * CPU waits using `__WFI()` until an interrupt occurs  

---

## System Behavior

* System starts in **RUNNING** mode  
* Pressing the button (PTA1):
  * Immediately switches system to **PAUSED**  
  * LCD updates accordingly  
* Pressing `'*'` on keypad:
  * Returns system to **RUNNING**  
  * LCD updates again  
* Timer continues running in background for time tracking  

---

## System Flowchart

Below is the flowchart illustrating the system behavior:

![System Flowchart](Diagram.png)

---
