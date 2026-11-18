require("model2");

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
		local gameState = I960_ReadByte(0x5010A4)

	if   	   gameState==0x16	-- Ingame
	 	or gameState==0x03	-- Attract ini
		or gameState==0x04	-- Attract Higscore ini
		or gameState==0x05	-- Attract Highscore
		or gameState==0x06	-- Attract VR Ini
		or gameState==0x07	-- Attract VR
	then
	 	Model2_SetStretchBLow(0)
		Model2_SetWideScreen(0)

	else
	 	Model2_SetStretchBLow(0)
		Model2_SetWideScreen(0)
	end
	
else
		Model2_SetStretchBLow(0)
		Model2_SetWideScreen(0)
	end
end


function heliviewfunc(value)
	I960_WriteWord(RAMBASE+0x1710,4); -- helicopter view
end


function PostDraw()
	if Options.scanlines.value==1 then
	Video_DrawSurface(TestSurface,0,0);
	end
end


function timecheatfunc(value)
	I960_WriteWord(RAMBASE+0x10D0,61*64);	--60 seconds always
end


Options =
{
	timecheat={name="Infinite Time",values={"Off","On"},runfunc=timecheatfunc},
	heliview={name="Helicopter View",values={"Off","On"},runfunc=heliviewfunc},
	scanlines={name="Scanlines (50%)",values={"Off","On"}}
}
