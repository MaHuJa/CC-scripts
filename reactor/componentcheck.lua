--[[

]]

componentcheck = {}

componentcheck['ic2.reactorVentGold'] = function (index, data, running)
	assert (data)
	if data.dmg > 4000 then
		if running then return automaintain() end
		removeItem(index)
		addItem('ic2.reactorVentGold',index)
	end
end

