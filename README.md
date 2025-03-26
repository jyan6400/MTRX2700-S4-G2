# 🛠️ MTRX2700 ASM Lab Project – Group G2

## 👥 Group Information

**Team Number:** [S4-G2]  
**Unit:** MTRX2700 – Mechatronics 2  
**Semester:** S1 2025  

### 👤 Group Members & Roles

| Name           | Role                         | Responsibilities                                                                 |
|----------------|------------------------------|----------------------------------------------------------------------------------|
| Oscar          | Systems & Comms Lead         | String manipulation, UART communication, integration of input/output logic      |
| Jiaze          | I/O & Control Lead           | LED bitmasking, button interfacing, timer configuration, PWM and delays         |
| Jason          | DevOps & Architecture Lead   | Repository structure, documentation, Git integration, assembly debugging support|

---

## 🔧 Project Description

This project is a series of embedded system modules programmed in **ARM Assembly** for the **STM32F3 Discovery Board**. It was completed over Weeks 1–5 as part of the MTRX2700 ASM Lab Series.

The goal is to demonstrate modular, low-level embedded development using:
- Manual memory management and pointer logic
- LED and button I/O interaction
- Serial communication (UART)
- Hardware timers and delay functions
- Integration of all components into a working system

---

## 📦 Project Structure

The repo is structured by **lab week and exercise number**, as per the official lab manual.

/Weekly Labs/
├── 1.3.2/           # String manipulation functions
│   └── 1.3.2a.s     # Uppercase/lowercase conversion
│   └── 1.3.2b.s     # Palindrome checker
│   └── 1.3.2c.s     # Caesar cipher
│
├── 1.4.2/           # LED control with bitmasking and button input
│   └── 1.4.2a.s     # Bitmask LED pattern
│   └── 1.4.2b.s     # Button-driven LED toggle
│   └── 1.4.2c.s     # Vowel/consonant LED display
│
├── 1.5.2/           # UART communication modules
│   └── uart_send.s
│   └── uart_receive.s
│   └── uart_bridge.s
│
├── 1.6.2/           # Timer-based delay functions and PWM
│   └── delay_timer.s
│   └── pwm_loop.s
│   └── initialise.s
│
├── 1.7.2/           # Final integration project
│   └── integration_main.s   # Combines UART, logic, LEDs, timers
│
├── Week 1 Code/     # Introductory assembly examples
│   └── assembly.s
│   └── first_timer_test.s



---

## 🚀 Program Overview

### 🔹 Functionality:
The project processes a user-provided string and:
1. Checks if it is a **palindrome**
2. If it is, applies a **Caesar cipher**
3. Sends the result to another STM32 board via **UART**
4. The second board decodes the message and:
   - Counts the **vowels and consonants**
   - Blinks **LEDs accordingly** with a 500ms delay between each character group

### 🔹 Modules:
| Module        | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| `string_utils`| Handles character case conversion, palindrome check, and Caesar encryption |
| `uart_comm`   | UART send/receive drivers with polling                                      |
| `led_control` | Controls GPIOE output based on character counts                             |
| `timer_util`  | Implements delays and PWM control using TIM2                               |
| `integration_main` | Combines all modules in a final working system                        |

---

## 📥 Instructions for Use

### 🔧 Requirements:
- STM32CubeIDE (v1.12+)
- STM32F3 Discovery Board
- Micro-USB cable
- Jumper wires (for UART connection between boards)

### 🔄 Build & Flash:
1. Clone the repo and open with STM32CubeIDE:
   ```bash
   git clone https://github.com/[your-org]/MTRX2700-S4-G2.git


