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

function infinitetime_f(value)
        I960_WriteWord(RAMBASE+0x95CDF,99*256); -- 99 seconds always
end

function firstplace_f(value)
        I960_WriteWord(RAMBASE+0x95CEA,16256); -- first place
        I960_WriteWord(RAMBASE+0xA1772,16256); -- display
end

Options =
{
	infinitetime={name="Infinite Time",values={"Off","On"},runfunc=infinitetime_f},
	firstplace={name="1st Place",values={"Off","On"},runfunc=firstplace_f},
	scanlines={name="Scanlines (50%)",values={"Off","On"}}
}
