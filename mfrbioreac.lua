--[[
	MFR bioreactor controller
	Emit a redstone signal when there isn't "enough" spare items.
]]
side = "back"
stackcount = 3

local br = peripheral.wrap(side)
while true do
  if #br.getAllStacks() < stackcount then
    rs.setOutput(side,true)
    io.write("+")
  else
    rs.setOutput(side,false)
    io.write("-")
  end
  sleep(1)
end

