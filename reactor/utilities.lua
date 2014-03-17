
function addItem(name,index)
	local slot
	-- search through supplier inventory
	local k,v
	for k,v in pairs(supplier.getAllStacks()) do
		if v.name == name then
			slot = k
			break
		end
	end
	if not slot then 
		logmessage ("Out of "..name)
		manualmaintenance()	-- never returns
		return addItem(name,index) -- but if it does, it means try again
	end
	supplier.pushItem(supplierside,slot,1,index)
end

function removeItem (index)
	assert(supplier.pullItem(supplierside,index)==1)
end
