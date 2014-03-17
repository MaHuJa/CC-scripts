-- This file provides the entrypoint for the program

if peripheral then -- CC
  dofile "logger_cc.lua"
  dofile "config"
else
  component = assert(require "component")
  dofile "logger_ncom.lua"
end



