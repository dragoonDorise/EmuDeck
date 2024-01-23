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
		Model2_SetStretchAHigh(0)
	 	Model2_SetStretchALow(0)
		Model2_SetStretchBHigh(0)
	 	Model2_SetStretchBLow(0)
		Model2_SetWideScreen(0)
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

function health1p(value)
	I960_WriteWord(RAMBASE+0x10DAC,220); -- 1P full health
end

function health2p(value)
	I960_WriteWord(RAMBASE+0x12DAC,220); -- 2P full health
end

function mahler(value)
	I960_WriteWord(RAMBASE+0x15DC7,2048); -- 1P mahler
	I960_WriteWord(RAMBASE+0x15DC9,8); -- 2P mahler
end

Options =
{
	health1p={name="1P Infinite Health",values={"Off","On"},runfunc=health1p},
	health2p={name="2P Infinite Health",values={"Off","On"},runfunc=health2p},
--	mahler={name="Mahler Enabled",values={"Off","On"},runfunc=mahler},
	scanlines={name="Scanlines (50%)",values={"Off","On"}}
}
