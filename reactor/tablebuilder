dofile("/disk/config")
file = assert(io.open("reactortable","w"))
reac = assert(peripheral.wrap(reactorname))

reactor = reac.getAllStacks()

file:write(textutils.serialize(reactor))
file:close()



