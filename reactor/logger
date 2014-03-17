rednet.open "right"

function logmessage (msg)
	local file = io.open ("reactorlog","a");
	local str = "Reactor control: " .. msg;
	rednet.broadcast (str)
	if file then
		file:write (msg)
		file:write '\n'
	end
	file:close()	
	-- CC needs it to be closed - and this is the only opportunity to do it properly.
end


