--[[
This code will be run when the system decides it needs manual intervention.

Possible alternative implementations is to occasionally check if it can continue, or provide a menu that offers to try restarting, etc. I deemed this good enough at least for now.
]]

reactorOff();
logmessage "MANUAL INTERVENTION NEEDED!";
os.exit();
