

-- import("/lua/lazyvar.lua").ExtendedErrorMessages = true

local baseCreateUI = CreateUI;
function CreateUI(isReplay) 
	baseCreateUI(isReplay) 
	
	local parent = import('/lua/ui/game/borders.lua').GetMapGroup()
	ForkThread(
		function()
			local path = "King of the Hill";
			import('/mods/' .. path .. '/modules/interface.lua').CreateModUI(isReplay, parent)
		end
	);


end