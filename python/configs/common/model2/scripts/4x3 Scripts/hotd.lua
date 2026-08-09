require("model2")

function Init()

	TestSurface = Video_CreateSurfaceFromFile("scripts\\scanlines_default.png");
	wide=true
	press=0
end

function Frame() -- (Nuexzz's values)
	Romset_PatchDWord(ROMBASE,0x18610,0xa000000)--no flash screen (by_egregiousguy)
		if Input_IsKeyPressed(0x3F)==1 and press==0 then wide=not wide press=1
		elseif Input_IsKeyPressed(0x3F)==0 and press==1 then press=0
		end
		
	if wide==true then
		local gameState = I960_ReadByte(0x51EE14)
		 if gameState==0x2
		 then
		Model2_SetWideScreen(0)
		Model2_SetStretchBLow(0)
		Model2_SetStretchBHigh(0)
		else
		Model2_SetWideScreen(0)
		Model2_SetStretchBLow(0)
		Model2_SetStretchBHigh(0)
		end
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

function health_1p_cheat_f(value)
        I960_WriteWord(RAMBASE+0x1EC10,5); -- 1P 5 health
end

function ammo_1p_cheat_f(value)
        I960_WriteWord(RAMBASE+0x1EC41,6); -- 1P 6 ammo
end

Options =
{
	health_1p_cheat={name="1P Infinite Health",values={"Off","On"},runfunc=health_1p_cheat_f},
	ammo_1p_cheat={name="1P Infinite Ammo",values={"Off","On"},runfunc=ammo_1p_cheat_f},
	scanlines={name="Scanlines (50%)",values={"Off","On"}}
}
