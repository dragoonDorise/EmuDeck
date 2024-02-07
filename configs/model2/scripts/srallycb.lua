require("model2")

function Init()

	TestSurface = Video_CreateSurfaceFromFile("scripts\\scanlines_default.png");
	wide=true
	press=0
end

function Frame()
		if Input_IsKeyPressed(0x3F)==1 and press==0 then wide=not wide press=1
		elseif Input_IsKeyPressed(0x3F)==0 and press==1 then press=0
		end
		
	if wide==true then
		local state = I960_ReadByte(0x202098);
		local state2 = I960_ReadByte(0x20209C);
		local state3 = I960_ReadByte(0x2020AC);

		if state==3 and state2==5 and state3==1 then
	 	Model2_SetStretchBLow(0)
		Model2_SetWideScreen(0)
		else
	 	Model2_SetStretchBLow(1)
		Model2_SetWideScreen(1)
		end
	else	
	 	Model2_SetStretchBLow(0)
		Model2_SetWideScreen(0)
	end

end

function PostDraw()
	if Options.scanlines.value==1 then
	Video_DrawSurface(TestSurface,0,0);
	end
end

function timecheatfunc(value)
   I960_WriteWord(RAM2BASE+0xB0B0,60*60);   --60 seconds always
end

function firstplacefunc(value)
        I960_WriteWord(RAM2BASE+0x20C8,0); -- competitors in front
end

Options =
{
	timecheat={name="Infinite Time",values={"Off","On"},runfunc=timecheatfunc},
	firstplace={name="1st Place",values={"Off","On"},runfunc=firstplacefunc},
	scanlines={name="Scanlines (50%)",values={"Off","On"}}
}