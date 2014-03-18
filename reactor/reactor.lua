-- This file provides the entrypoint for the program
dofile "config"
dofile "configchecker"

if peripheral then -- CC
  dofile "logger_cc.lua"
else
  dofile "logger_ncom.lua"
end
logmessage ("Config seems ok.");
sleep = sleep or os.sleep

dofile "utilities.lua"
dofile "componentcheck.lua"

manualmaintenance = assert(loadfile("manualmaintenance.lua"))
automaintain = assert(loadfile("automaintain.lua"))

function mainloop() 
	
end




do
	status, error = pcall (mainloop);
	-- All code paths that can happen in here are to be marked CRITICAL in comments
	logmessage (error);
	reactorOff();
	manualmaintenance();
end



