-- Common helper functions

-- Convert a 4-bit value to hex char (0-9,A-F)
HEX2CHAR="0123456789ABCDEF";
function HEX4(value)
	return string.sub(HEX2CHAR,value+1,value+1);
end

-- Convert a 8-bit value to hex string
function HEX8(value)
	local ret="";

	for i=1,0,-1 do

		ret=ret..HEX4(AND(SHR(value,i*4),0xF));

	end		

	return ret;
end

-- Convert a 16-bit value to hex string
function HEX16(value)
	local ret="";

	for i=3,0,-1 do

		ret=ret..HEX4(AND(SHR(value,i*4),0xF));

	end		

	return ret;
end

-- Convert a 32-bit value to hex string
function HEX32(value)
	local ret="";

	for i=7,0,-1 do

		ret=ret..HEX4(AND(SHR(value,i*4),0xF));

	end	
	
	return ret;
end

--Input keys access. Add one of the JOYx values with the button/axis value: JOY1+JOY_LEFT  or JOY1+JOY_BUTTON1

JOY1=0x100;
JOY2=0x200;
JOY3=0x300;
JOY4=0x400;

JOY_LEFT=0x0;		-- Axis 1, usually dpad
JOY_RIGHT=0x1;
JOY_UP=0x2;
JOY_DOWN=0x3;

JOY_LEFT2=0x4;		-- Axis 2, usually left stick
JOY_RIGHT2=0x5;
JOY_UP2=0x6;
JOY_DOWN2=0x7;

JOY_LEFT3=0x8;		-- Axis 3, usually right stick
JOY_RIGHT3=0x9;
JOY_UP3=0xa;
JOY_DOWN3=0xb;

JOY_BUTTON1=0x10;
JOY_BUTTON2=0x20;
JOY_BUTTON3=0x30;
JOY_BUTTON4=0x40;
JOY_BUTTON5=0x50;
JOY_BUTTON6=0x60;
JOY_BUTTON7=0x70;
JOY_BUTTON8=0x80;
