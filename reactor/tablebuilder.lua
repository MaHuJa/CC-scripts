dofile("/disk/config")
file = assert(io.open("reactortable","w"))
reac = assert(peripheral.wrap(reactorname))

reactor = reac.getAllStacks()
out = {}
local k,v
for k,v in pairs(reactor) do
	out[k] = v[name]
end

-- TODO: NCOM does not have serialize
file:write(textutils.serialize(reactor))
file:close()

