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
		Model2_SetWideScreen(0)
		else
		Model2_SetWideScreen(0)
		end
	else	
		Model2_SetWideScreen(0)
		end

end

function PostDraw()
	if Options.scanlines.value==1 then
	Video_DrawSurface(TestSurface,0,0);
	end
end

function health_cheat_f(value)
        I960_WriteWord(RAMBASE+0x272EC,0); -- 0 damage
end

Options =
{
	health_cheat={name="1P Infinite Health",values={"Off","On"},runfunc=health_cheat_f},
	scanlines={name="Scanlines (50%)",values={"Off","On"}}
}