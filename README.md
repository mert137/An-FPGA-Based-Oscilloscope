# An-FPGA-Based-Oscilloscope
METU EEE Digital Electronics Laboratory Project

This project aims to make a very simple oscilloscope by using FPGA. All the codes are written in Verilog. The oscilloscope's voltage range is 0-5V and maximum frequency which can measure is 20 kHz due to the limitations of FPGA. It has time/div, volt/div, autoscale and AC/DC mode buttons. The FPGA used in the project is DE1-SoC board, 5CSEMA5F31C6. To run code, you need Quartus 17.1 program. All the pin assignments are made in program. Also, there is a report.pdf file that explains working principle of project in the repo.
### Hardwares which must be used to run oscilloscope
* DE1-SoC equipment
* VGA connector
* Monitor (of course must have a VGA input)
* One female-to-female jumper 
* Signal generator to give a wave 

### Make hardware connections
1. Connect signal generator's positive leg to channel 0 of ADC.
2. Connect signal generator's negative leg to GND of ADC (or any GND pin of FPGA).
3. Connect GPIO_0 pin 0 to any GND pin of FPGA with female-to-female jumper.
4. Connect VGA connector to monitor and FPGA
5. Supply FPGA with its adaptor, connect it to laptop with its USB connector, click power button.
6. Now, you are ready for the run from Quartus.
