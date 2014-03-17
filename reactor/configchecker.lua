
assert(reactorOff and reactorOff())
assert(reactorOn)
assert(reactor and reactor.getInventoryName() == "Nuclear Reactor")
assert(supplier and supplier.getInventorySize and supplierside)
assert(puller and puller.getInventorySize and supplierside)
-- todo: the above sides should be verified to be valid sides, rather than just being set
assert(io.open(logfile,"a")):close()
assert(reactor_min < reactor_max)
assert(type(reactortable)=="table")
