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
		Model2_SetWideScreen(1)
		Model2_SetStretchBLow(1)
		Model2_SetStretchBHigh(1)
	else	
		Model2_SetWideScreen(0)
		Model2_SetStretchBLow(0)
		Model2_SetStretchBHigh(0)
	end
end

function PostDraw()
	if Options.scanlines.value==1 then
	Video_DrawSurface(TestSurface,0,0);
	end
end

function health_cheat_f(value)
	I960_WriteWord(RAMBASE+0x0494,400); -- full health
end

function time_cheat_f(value)
	I960_WriteWord(RAMBASE+0x21040,99*33.3); -- 99 time
end

Options =
{
	health_cheat={name="Infinite Health",values={"Off","On"},runfunc=health_cheat_f},
	time_cheat={name="Infinite Time",values={"Off","On"},runfunc=time_cheat_f},
	scanlines={name="Scanlines (50%)",values={"Off","On"}}

}