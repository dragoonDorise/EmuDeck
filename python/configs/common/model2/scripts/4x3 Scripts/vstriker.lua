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

function goals_1p_cheat_f(value)
        I960_WriteWord(RAMBASE+0x1540,99); -- 1P 99 goals
        I960_WriteWord(RAMBASE+0x1544,0); -- 2P 0 goals
end

function goals_2p_cheat_f(value)
        I960_WriteWord(RAMBASE+0x1544,99); -- 2P 99 goals
        I960_WriteWord(RAMBASE+0x1540,0); -- 1P 0 goals
end

function fcsega_cheat_f(value)
        I960_WriteWord(RAMBASE+0xD4090,1); -- enable fc sega
end

Options =
{
	goals_1p_cheat={name="1P Wins",values={"Off","On"},runfunc=goals_1p_cheat_f},
	goals_2p_cheat={name="2P Wins",values={"Off","On"},runfunc=goals_2p_cheat_f},
	fcsega_cheat={name="Enable FC Sega",values={"Off","On"},runfunc=fcsega_cheat_f},
	scanlines={name="Scanlines (50%)",values={"Off","On"}}
}
