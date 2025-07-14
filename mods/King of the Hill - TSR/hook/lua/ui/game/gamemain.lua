

-- import("/lua/lazyvar.lua").ExtendedErrorMessages = true
import("/mods/king of the hill - tsr/modules/constants.lua")

local baseCreateUI = CreateUI
function CreateUI(isReplay) 
	baseCreateUI(isReplay) 
	
	local parent = import('/lua/ui/game/borders.lua').GetMapGroup()
	ForkThread(
		function()
			import('/mods/' .. kothConstants.path .. '/modules/interface.lua').CreateModUI(isReplay, parent)
		end
	);


end
