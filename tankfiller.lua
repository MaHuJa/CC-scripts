--[[
	Version 1: 
	On mining turtle, above inventory has "tank" items whose properties are assumed to mirror openblocks tanks.
	When placed in front, they will be filled.
	When full, harvest and (later) dump them to inventory below.
]]

local t = turtle

--function dt(t) local k,v for k,v in pairs(t) do print(k,"   ",v) end end
function print_tank_status(t) print (t.amount .. '/' .. t.capacity) end

function wait_done()
  local tank
  repeat
    io.write "."
    sleep(0.2)
    tank = peripheral.call("front","getTankInfo","bottom")[1]
    print_tank_status(tank)
  until tank.amount == tank.capacity;
  io.write "+"
end

function dropall()
  local i
  for i = 1,16 do
    t.select(i)
    t.dropDown()
  end
  t.select(1)
end

function getItem()	-- rather, makeSureToHaveItem
  if t.getItemCount(1)>0 then return end
  dropall()
  t.suckUp()
end

t.select(1)
while true do
-- We may have been restarted while we had a tank out.
  if not t.detect() then	
    getItem()
    t.place()
  end
  assert(t.detect(),"Failed to place tank?")--Ran out of empty tanks?
  wait_done()
  t.select(2)
  t.dig()
  t.select(1)
end  

