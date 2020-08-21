# DigitalClock-HardwareDescription

This is a project of Hardware Description made in SystemVerilog. This is a Digital Clock with the following features:
	 
	 - Clock (Hour : Minutes)
	 
	 - Stopwatch (Minutes: Seconds) (Increasing)
	 
	 - Timer (Minutes: Seconds) (Decreasing)
	 
	 - Alarm
	 
This has the following buttons (Inputs):
	 
	 - Reset (press for three seconds to redefines the clock)
	 
	 - Mode (Select the features of clock)
	 
	 - Cancel (Cancel operations)
	 
	 - Up Button (Increase counters)
	 
	 - Down Button (Decrease counters) 
	 
	 - Ok (Confirm operations)
	 
To use this project, select "relogio.sv" file as top-level and import all files "*.sv"
The default clock is 50MHz, but this can be changed only setting the parameter in "relogio.sv" file.

