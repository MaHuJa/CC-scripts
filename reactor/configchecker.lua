
assert(reactorOff and reactorOff())
assert(reactorOn)
assert(reactor and reactor.inventoryName = "") -- todo
assert(supplier and supplier.getInventorySize)
assert(io.open(logfile,"a")):close()
assert(reactor_min < reactor_max)

