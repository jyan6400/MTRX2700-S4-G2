# 🛠️ MTRX2700 ASM Lab Project: STM32 Embedded System (Weeks 2–5)

## 👥 Team Members & Roles

| Name             | Role                     | Responsibilities                                                                 |
|------------------|--------------------------|-----------------------------------------------------------------------------------|
| Oscar         | Systems & Communication Lead | UART drivers, inter-board messaging, palindrome checker, Caesar cipher, integration logic |
| Jiaze         | I/O & Control Lead           | LED patterns, vowel/consonant counters, timers/delays, PWM behavior              |
| Jason         | Architecture & DevOps Lead   | Assembly foundations, repository structure, build configuration, documentation, testing & QA, Meeting Minutes |



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
