
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
	assert(puller.pullItem(pullerside,index)==1)
end

function emergencyStop()
	-- When this function is called, we're not seeing the reactor stop despite cutting the redstone signal. There may be another source of rs keeping it going.
	logmessage "Emergency stop activated!";
	local k,v, t = reactor.getAllStacks()
	foreach k,v in pairs(t) do 
		if string.match(v.name,".*[Ff]uel.*") then
			removeItem(k)
		end
	end
	logmessage "Emergency stop completed!";
	manualmaintenance()	
end
function reactorOff()
	reactorStop()
	sleep(1.2)
	if reactor.isActive() then emergencyStop() end
end
