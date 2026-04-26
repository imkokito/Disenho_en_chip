# SoC Practice: Timer System with Keypad, LCD and TPM0  
## Andre - Santi - Jared - Joshua  

This project implements a configurable timer system using a keypad for user input, an LCD for real-time visualization, and the TPM0 module for accurate time counting. The system allows the user to enter a desired number of seconds and then performs a countdown, indicating completion with an LED.

---

## Materials Used

To replicate this project, the following hardware is required:

* **Microcontroller:** KL25Z  
* **Display:** LCD (16x2) operating in **8-bit mode**  
* **Input:** 4x4 Matrix Keypad  
* **Output:** Onboard RGB LED (used as indicator)  
* **Extra Components:** Breadboard, jumper wires, resistor 

---

## System Features

* **User Input via Keypad:** Allows entering either 1 or 2 digit values (seconds).  
* **Dynamic Display:** LCD shows prompts, user input, and real-time countdown.  
* **Hardware Timer:** Uses TPM0 interrupts for accurate time tracking (1 second resolution).  
* **State Control:** System switches between input mode, counting mode, and finished state.  
* **Visual Indicator:** LED turns ON when countdown finishes.  
* **Debounced Input:** Prevents multiple detections of the same key press.  

---

## Architecture and Pin Mapping

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

### RGB LED - Ports B and D

* **Red:** `PTB18`  
* **Green:** `PTB19`  
* **Blue:** `PTD1`  

> Note: LED operates with inverse logic (LOW = ON).

---

### Timer Module

* **TPM0:** Generates periodic interrupts (~0.1 seconds per overflow)  

---

## Execution Flow

1. **Initialization:**
   * Initialize keypad, LCD, LED, and TPM0  
   * Turn off LED  
   * Display welcome message `"Hello"`  
   * Prompt user with `"Cuantos seg:"`  

2. **User Input:**
   * User enters digits via keypad  
   * Input is stored in a buffer (either 1 or 2 digits)  
   * LCD updates dynamically to show entered value  

3. **Start Countdown:**
   * User presses `'*'` to confirm  
   * Input is converted to integer (`atoi`)  
   * Counter resets and system enters **running mode**  
   * LCD displays `"Counting..."`  

4. **Counting Process:**
   * TPM0 interrupt increments a tick counter  
   * Every 10 ticks → 1 second  
   * `contador` increases until it reaches the target  

5. **Display Update:**
   * LCD shows progress:
     ```
     t = current / total
     ```
   * Example:
     ```
     t=3/10
     ```

6. **Finish Condition:**
   * When `contador >= segundos`:
     * Stop counting  
     * Display `"FIN!"`  
     * Turn ON LED  

---

## System Behavior

* User inputs desired time using keypad  
* LCD reflects input and countdown status  
* Timer runs independently using interrupts  
* System provides visual feedback when finished  

---

## System Flowchart

Below is the flowchart illustrating the system behavior:

![System Flowchart](Diagram.png)

![System Flowchart](Diagram2.png)

---

