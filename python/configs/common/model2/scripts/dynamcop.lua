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
		Model2_SetStretchAHigh(1)
	 	Model2_SetStretchALow(1)
		Model2_SetStretchBHigh(1)
	 	Model2_SetStretchBLow(1)
		Model2_SetWideScreen(1)
	else
		Model2_SetStretchAHigh(0)
	 	Model2_SetStretchALow(0)
		Model2_SetStretchBHigh(0)
	 	Model2_SetStretchBLow(0)
		Model2_SetWideScreen(0)
	end
end

function PostDraw()
		if Options.scanlines.value==1 then
		Video_DrawSurface(TestSurface,0,0);
	end

end

function health_1p_cheat_f(value)
        I960_WriteWord(RAMBASE+0x10F74,104); -- 1P full health
end

Options =
{
	health_1p_cheat={name="1P Infinite Health",values={"Off","On"},runfunc=health_1p_cheat_f},
	scanlines={name="Scanlines (50%)",values={"Off","On"}}
}
