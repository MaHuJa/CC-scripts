--[[
  Automaintain
  
  We're here because something detected there are components in need of replacing.
]]

assert (reactortable)
reactorOff()
logmessage "Automaintenance activated"
sleep(1)

assert (componentcheck)

local i,obj
for i = 1,reactor.getInventorySize() do
	obj = reactor.getStackInSlot(i);
	-- missing
	if not obj and reactortable[i] then
		addItem(reactortable[i])
	-- wrong object
	elseif obj and obj.name ~= reactortable[i] then
		removeItem(i)
		addItem(reactortable[i],i)
	-- has checking routine
	elseif obj and reactortable[i] then
		componentcheck[obj.name](i,obj,false)
	end
end

logmessage "Automaintenance completed"

