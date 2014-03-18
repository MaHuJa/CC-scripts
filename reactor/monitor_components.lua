--[[
The reactor is now running (or about to run) and we need to check that the components are up to it.


]]
assert (reactortable)
assert (componentcheck)

local all = reactor.getAllStacks();
local k,v;
local result;

for k,v in pairs(all) do
	if (not v and reactortable[k])	--missing
	or (v and objname ~= reactortable[k]) --wrong
	then 
		automaintain();
		return false;
	end
	if (v and componentcheck[v.name) then
		result = result and componentcheck[v.name](k,v,true)
	end
	return result;
end

