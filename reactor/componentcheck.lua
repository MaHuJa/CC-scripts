--[[
	I'm not happy with how this part turned out.
	todo: Call it only from the monitor, have it give a return value indicating what needs to be done with it.
]]

componentcheck = {}

componentcheck['ic2.reactorVentGold'] = function (index, data, running)
	assert (data)
	if data.dmg > 4000 then
		if running then return automaintain() end
		--if running then return cooldown() end
		removeItem(index)
		addItem('ic2.reactorVentGold',index)
		return false
	end
	return true
end

