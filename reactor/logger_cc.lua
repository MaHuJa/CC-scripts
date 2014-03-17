rednet.open "right"
local monitor = peripheral.wrap "monitor_0"

-- CRITICAL
function logmessage (msg)
	-- Todo: timestamping
	print (msg)
	
	local netstr = "Reactor control: " .. msg;
	rednet.broadcast (netstr);
	
	monitor.write(msg);
	monitor.write("\n");
	
	local file = io.open ("reactorlog","a");
	if file then
		file:write (msg)
		file:write '\n'
	end
	file:close()	-- CC needs the file to be closed immediately.
	

end


