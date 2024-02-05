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
	 	Model2_SetStretchBLow(1)
		Model2_SetWideScreen(1)
		Model2_SetStretchALow(1)
		Model2_SetStretchAHigh(1)
		Model2_SetStretchBHigh(1)
		I960_WriteDWord(TMAPGFXBASE+0x5060,0);
        I960_WriteDWord(TMAPGFXBASE+0x5064,0);
        I960_WriteDWord(TMAPGFXBASE+0x5068,0);
        I960_WriteDWord(TMAPGFXBASE+0x506C,0);
        I960_WriteDWord(TMAPGFXBASE+0x5070,0);
        I960_WriteDWord(TMAPGFXBASE+0x5074,0);
        I960_WriteDWord(TMAPGFXBASE+0x5078,0);
        I960_WriteDWord(TMAPGFXBASE+0x507C,0);

	else
	 	Model2_SetStretchBLow(0)
		Model2_SetWideScreen(0)
		Model2_SetStretchALow(0)
		Model2_SetStretchAHigh(0)
		Model2_SetStretchBHigh(0)
	end
	

end



function PostDraw()
		if Options.scanlines.value==1 then
		Video_DrawSurface(TestSurface,0,0);
	end

end


function health_1p_cheat_f(value)
        I960_WriteWord(RAMBASE+0xEE70,9); -- 1P 9 health
end

function ammo_1p_cheat_f(value)
        I960_WriteWord(RAMBASE+0xEE38,6); -- 1P 6 ammo
end

Options =
{
	health_1p_cheat={name="1P Infinite Health",values={"Off","On"},runfunc=health_1p_cheat_f},
	ammo_1p_cheat={name="1P Infinite Ammo",values={"Off","On"},runfunc=ammo_1p_cheat_f},
	scanlines={name="Scanlines (50%)",values={"Off","On"}}
}
