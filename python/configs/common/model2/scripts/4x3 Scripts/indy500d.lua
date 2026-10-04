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
		Model2_SetWideScreen(0)
		Model2_SetStretchBLow(0)
		Model2_SetStretchBHigh(0)
		local gameState = I960_ReadByte(0x54C224)
 	if 	gameState==0x5
		or gameState==0x6
	then
		Model2_SetStretchAHigh(0)
		Model2_SetStretchALow(0)
	else
		Model2_SetStretchAHigh(0)
		Model2_SetStretchALow(0)
	end
else	
		Model2_SetWideScreen(0)
		Model2_SetStretchAHigh(0)
		Model2_SetStretchALow(0)
		Model2_SetStretchBLow(0)
		Model2_SetStretchBHigh(0)
	end

end

function PostDraw()
	if Options.scanlines.value==1 then
	Video_DrawSurface(TestSurface,0,0);
	end
end

function timecheatfunc(value)
	I960_WriteWord(RAMBASE+0x0446E0,99*60); -- 99 seconds always
end

function firstplacefunc(value)
        I960_WriteWord(RAMBASE+0xEBF58,1); -- position
end

Options =
{
	timecheat={name="Infinite Time",values={"Off","On"},runfunc=timecheatfunc},
	firstplace={name="First Place",values={"Off","On"},runfunc=firstplacefunc},
	scanlines={name="Scanlines (50%)",values={"Off","On"}}
}