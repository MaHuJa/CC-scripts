-- List of files to pack
files = {
	"sha256.lua",
	"peripheralsinfo.lua",
	"luaide.lua",
	"tankfiller.lua",
	"mfrbioreac.lua"
}

-- Output table
outputs = {}
function wr(ite) 
	outputs[#outputs+1] = ite 
end

function packFile(name)
	--[[ ensure you can open file, write "header", write content, write footer ]]
	-- Check that file exists
	local file = assert(io.open(name,"r"))
	
	-- find cc name (i.e. strip .lua extension)
	local ccname = name:match("(.+)%.lua")
	print ("Adding file " .. ccname)
	
	-- write header
	wr ("writefile('")
	wr (ccname)
	wr ("', [=====[")
	
	-- write content
	local content
	repeat 
		content = file:read("*a")
		wr (content)
	until content == "";
	
	-- write footer
	wr("]=====]);\n\n")	
end

fileheader = [[
function writefile(name,content)
	file = io.open(name,"w")
	file:write(content)
	file:close()
end
]]
-- syntax check it
assert (load (fileheader, "fileheader"))

outfile = assert(io.open ("installer","w"))
outfile:write(fileheader)
local _,v
for _,v in ipairs(files) do
	packFile(v)
	outfile:write(table.concat(outputs))
	outputs={}
end

outfile:close()

