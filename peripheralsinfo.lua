--Imported from class
-- From http://lua-users.org/wiki/SimpleLuaClasses

-- class.lua
-- Compatible with Lua 5.1 (not 5.0).
local class = { }
function class.class(base, init)
  local c = {}    -- a new class instance
  if not init and type(base) == 'function' then
    init = base
    base = nil
  elseif type(base) == 'table' then
    -- our new class is a shallow copy of the base class!
    for i,v in pairs(base) do
      c[i] = v
    end
    c._base = base
  end
  -- the class will be the metatable for all its objects,
  -- and they will look up their methods in it.
  c.__index = c

  -- expose a constructor which can be called by <classname>(<args>)
  local mt = {}
  mt.__call =
    function(class_tbl, ...)
      local obj = {}
      setmetatable(obj,c)
      --if init then
      --  init(obj,...)
if class_tbl.init then
  class_tbl.init(obj, ...)
      else 
        -- make sure that any stuff from the base class is initialized!
        if base and base.init then
          base.init(obj, ...)
        end
      end
      return obj
    end

  c.init = init
  c.is_a =
    function(self, klass)
      local m = getmetatable(self)
      while m do 
        if m == klass then return true end
        m = m._base
      end
      return false
    end
  setmetatable(c, mt)
  return c
end


--Imported from Logger
local Logger = { }

local debugMon
local logServerId
local logFile
local logger = screenLogger
local filteredEvents = {}

local function nopLogger(text)
end

local function monitorLogger(text)
  debugMon.write(text)
  debugMon.scroll(-1)
  debugMon.setCursorPos(1, 1)
end

local function screenLogger(text)
  local x, y = term.getCursorPos()
  if x ~= 1 then
    local sx, sy = term.getSize()
    term.setCursorPos(1, sy)
    --term.scroll(1)
  end
  print(text)
end

local function wirelessLogger(text)
  if logServerId then
    rednet.send(logServerId, {
      type = 'log',
      contents = text
    })
  end
end

local function fileLogger(text)
  local mode = 'w'
  if fs.exists(logFile) then
    mode = 'a'
  end
  local file = io.open(logFile, mode)
  if file then
    file:write(text)
    file:write('\n')
    file:close()
  end
end

local function setLogger(ilogger)
  logger = ilogger
end


function Logger.disableLogging()
  setLogger(nopLogger)
end

function Logger.setMonitorLogging(logServer)
  debugMon = Util.wrap('monitor')
  debugMon.setTextScale(.5)
  debugMon.clear()
  debugMon.setCursorPos(1, 1)
  setLogger(monitorLogger)
end

function Logger.setScreenLogging()
  setLogger(screenLogger)
end

function Logger.setWirelessLogging(id)
  if id then
    logServerId = id
  end
  setLogger(wirelessLogger)
end

function Logger.setFileLogging(fileName)
  logFile = fileName
  fs.delete(fileName)
  setLogger(fileLogger)
end

function Logger.log(value)
  if type(value) == 'table' then
    for k,v in pairs(value) do
      logger(k .. '=' .. tostring(v))
    end 
  else
    logger(tostring(value))
  end
end

function Logger.logNestedTable(t, indent)
  for _,v in ipairs(t) do
    if type(v) == 'table' then
      log('table')
      logNestedTable(v) --, indent+1)
    else
      log(v)
    end
  end
end

function Logger.filterEvent(event)
  table.insert(filteredEvents, event)
end

function Logger.logEvent(event, p1, p2, p3, p4, p5)
  local function param(p)
    if p then
      return ', ' .. tostring(p)
    end
    return ''
  end
  for _,v in pairs(filteredEvents) do
    if event == v then
      return
    end
  end
  if event == 'rednet_message' then
    local msg = p2
    logger(param(event) ..  param(p1) ..  param(msg.type) ..  param(msg.contents))
  elseif event ~= 'modem_message' then
    logger(param(event) ..  param(p1) ..  param(p2) ..  param(p3) ..  param(p4) ..  param(p5))
  end
end


--Imported from Util
local Util = { }

function Util.loadAPI(name)
  local dir = shell.dir()
  if fs.exists(dir .. '/' .. name) then
    os.loadAPI(dir .. '/' .. name)
  elseif shell.resolveProgram(name) then
    os.loadAPI(shell.resolveProgram(name))
  elseif fs.exists('/rom/apis/' .. name) then
    os.loadAPI('/rom/apis/' .. name)
  else
    os.loadAPI(name)
  end
end

function Util.wrap(inP)

  local wrapped
  
  for k,side in pairs(redstone.getSides()) do
    sideType = peripheral.getType(side)
    if sideType then
      --Logger.log(sideType .. " on " .. side)
      if sideType == inP then
        if sideType == "modem" then
          rednet.open(side)
          return
        else
          wrapped = peripheral.wrap(side)
        end
      end
    end
  end
  
  if not wrapped then
    error(inP .. " is not connected")
  end
  
  return wrapped
end

function Util.getSide(device)
  for k,side in pairs(rs.getSides()) do
    if peripheral.getType(side) == device then
      return side
    end
  end
  error(device .. " is not connected")
end

function Util.hasDevice(device)
  for k,side in pairs(rs.getSides()) do
    if peripheral.getType(side) == device then
      return true
    end
  end
  return false
end

function Util.tryTimed(timeout, f, ...)
  local c = os.clock()
  while not f(...) do
    if os.clock()-c >= timeout then
      return false
    end
  end
  return true
end

function Util.trace(x)
  if not x or not x.is_a then
    error('Incorrect syntax', 3)
  end
end

function Util.printTable(t)
  if not t then
    error('printTable: nil passed', 2)
  end
  for k,v in pairs(t) do
    print(k .. '=' .. tostring(v))
  end
end

function Util.tableSize(t)
  local c = 0
  for _,_ in pairs(t)
    do c = c+1
  end
  return c
end

--https://github.com/jtarchie/underscore-lua
function Util.each(list, func)
  local pairing = pairs
  if Util.isArray(list) then pairing = ipairs end

  for index, value in pairing(list) do
    func(value, index, list)
  end
end

function Util.size(list, ...)
  local args = {...}

  if Util.isArray(list) then
    return #list
  elseif Util.isObject(list) then
    local length = 0
    Util.each(list, function() length = length + 1 end)
    return length
  end

  return 0
end

function Util.isObject(value)
  return type(value) == "table"
end

function Util.isArray(value)
  return type(value) == "table" and (value[1] or next(value) == nil)
end
-- end https://github.com/jtarchie/underscore-lua

function Util.readFile(fname)
  local f = fs.open(fname, "r")
  if f then
    local t = f.readAll()
    f.close()
    return t
  end
end

function Util.readTable(fname)
  local t = Util.readFile(fname)
  if t then
    return textutils.unserialize(t)
  end
  Logger.log('Util:readTable: ' .. fname .. ' does not exist')
  return { }
end

function Util.writeTable(fname, data)
  writeFile(fname, textutils.serialize(data))
end

function Util.writeFile(fname, data)
  local file = io.open(fname, "w")
  if file then
    file:write(data)
    file:close()
  end
end

function Util.shallowCopy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v 
  end 
  return t2
end

function Util.split(str)
  local t = {}
  local function helper(line) table.insert(t, line) return "" end
  helper((str:gsub("(.-)\n", helper))) 
  return t
end

string.lpad = function(str, len, char)
    if char == nil then char = ' ' end
    return str .. string.rep(char, len - #str)
end

-- http://stackoverflow.com/questions/15706270/sort-a-table-in-lua
function Util.spairs(t, order)
  if not t then
    error('spairs: nil passed')
  end

  -- collect the keys
  local keys = {}
  for k in pairs(t) do keys[#keys+1] = k end

  -- if order function given, sort by it by passing the table and keys a, b,
  -- otherwise just sort the keys 
  if order then
    table.sort(keys, function(a,b) return order(t[a], t[b]) end)
  else
    table.sort(keys)
  end

  -- return the iterator function
  local i = 0
  return function()
    i = i + 1
    if keys[i] then
      return keys[i], t[keys[i]]
    end
  end
end

function Util.first(t, order)
  -- collect the keys
  local keys = {}
  for k in pairs(t) do keys[#keys+1] = k end

  -- if order function given, sort by it by passing the table and keys a, b,
  -- otherwise just sort the keys 
  if order then
    table.sort(keys, function(a,b) return order(t[a], t[b]) end)
  else
    table.sort(keys)
  end
  return keys[1], t[keys[1]]
end

--[[
pbInfo - Libs/lib.WordWrap.lua
	v0.41
	by p.b. a.k.a. novayuna
	released under the Creative Commons License By-Nc-Sa: http://creativecommons.org/licenses/by-nc-sa/3.0/
	
	original code by Tomi H.: http://shadow.vs-hs.org/library/index.php?page=2&id=48
]]
function Util.WordWrap(strText, intMaxLength)
	local tblOutput = {};
	local intIndex;
	local strBuffer = "";
	local tblLines = Util.Explode(strText, "\n");
	for k, strLine in pairs(tblLines) do
		local tblWords = Util.Explode(strLine, " ");
		if (#tblWords > 0) then
			intIndex = 1;
			while tblWords[intIndex] do
				local strWord = " " .. tblWords[intIndex];
				if (strBuffer:len() >= intMaxLength) then
					table.insert(tblOutput, strBuffer:sub(1, intMaxLength));
					strBuffer = strBuffer:sub(intMaxLength + 1);
				else
					if (strWord:len() > intMaxLength) then
						strBuffer = strBuffer .. strWord;
					elseif (strBuffer:len() + strWord:len() >= intMaxLength) then
						table.insert(tblOutput, strBuffer);
						strBuffer = ""
					else
						if (strBuffer == "") then
							strBuffer = strWord:sub(2);
						else
							strBuffer = strBuffer .. strWord;
						end;
						intIndex = intIndex + 1;
					end;
				end;
			end;
			if strBuffer ~= "" then
				table.insert(tblOutput, strBuffer);
				strBuffer = ""
			end;
		end;
	end;
	return tblOutput;
end

function Util.Explode(strText, strDelimiter)
	local strTemp = "";
	local tblOutput = {};
if not strText then
  error('no strText', 4)
end
	for intIndex = 1, strText:len(), 1 do
		if (strText:sub(intIndex, intIndex + strDelimiter:len() - 1) == strDelimiter) then
			table.insert(tblOutput, strTemp);
			strTemp = "";
		else
			strTemp = strTemp .. strText:sub(intIndex, intIndex);
		end;
	end;
	if (strTemp ~= "") then
		table.insert(tblOutput, strTemp)
	end;
	return tblOutput;
end

-- http://lua-users.org/wiki/AlternativeGetOpt
local function getopt( arg, options )
  local tab = {}
  for k, v in ipairs(arg) do
    if string.sub( v, 1, 2) == "--" then
      local x = string.find( v, "=", 1, true )
      if x then tab[ string.sub( v, 3, x-1 ) ] = string.sub( v, x+1 )
      else      tab[ string.sub( v, 3 ) ] = true
      end
    elseif string.sub( v, 1, 1 ) == "-" then
      local y = 2
      local l = string.len(v)
      local jopt
      while ( y <= l ) do
        jopt = string.sub( v, y, y )
        if string.find( options, jopt, 1, true ) then
          if y < l then
            tab[ jopt ] = string.sub( v, y+1 )
            y = l
          else
            tab[ jopt ] = arg[ k + 1 ]
          end
        else
          tab[ jopt ] = true
        end
        y = y + 1
      end
    end
  end
  return tab
end
-- end http://lua-users.org/wiki/AlternativeGetOpt

function Util.showOptions(options)
  for k, v in pairs(options) do
    print(string.format('-%s  %s', v.arg, v.desc))
  end
end

function Util.getOptions(options, args, syntaxMessage)
  local argLetters = ''
  for _,o in pairs(options) do
    argLetters = argLetters .. o.arg
  end
  local rawOptions = getopt(args, argLetters)

  for _,o in pairs(options) do
    if rawOptions[o.arg] then
      o.value = rawOptions[o.arg]
      if o.value and tonumber(o.value) then
        o.value = tonumber(o.value)
      end
    end
  end

--[[
for k,v in pairs(options) do
  print(k)
  Util.printTable(v)
end
read()
--]]

end


--Imported from Event
local Event = { }

local eventHandlers = {
  namedTimers = {}
}
local enableQueue = {}
local removeQueue = {}

local function deleteHandler(h)
  for k,v in pairs(eventHandlers[h.event].handlers) do
    if v == h then
      table.remove(eventHandlers[h.event].handlers, k)
      break
    end
  end
  --table.remove(eventHandlers[h.event].handlers, h.key)
end

function Event.addHandler(type, f)
  local event = eventHandlers[type]
  if not event then
    event = {}
    event.handlers = {}
    eventHandlers[type] = event
  end

  local handler = {}
  handler.event = type
  handler.f = f
  handler.enabled = true
  table.insert(event.handlers, handler)
  -- any way to retrieve key here for removeHandler ?
  
  return handler
end

function Event.removeHandler(h)
  h.deleted = true
  h.enabled = false
  table.insert(removeQueue, h)
end

function Event.queueTimedEvent(name, timeout, event, args)
  Event.addNamedTimer(name, timeout, false,
    function()
      os.queueEvent(event, args)
    end
  )
end

function Event.addNamedTimer(name, interval, recurring, f)
  Event.cancelNamedTimer(name)
  eventHandlers.namedTimers[name] = Event.addTimer(interval, recurring, f)
end

function Event.getNamedTimer(name)
  return eventHandlers.namedTimers[name]
end

function Event.cancelNamedTimer(name)
  local timer = Event.getNamedTimer(name)

  if timer then
    timer.enabled = false
    timer.recurring = false
  end
end

function Event.addTimer(interval, recurring, f)
  local timer = Event.addHandler('timer',
    function(t, id)
      if t.timerId ~= id then
        return
      end
      if t.enabled then
        t.cf(t, id)
      end
      if t.recurring then
        t.timerId = os.startTimer(t.interval)
      else
        removeHandler(t)
      end
    end
  )
  timer.cf = f
  timer.interval = interval
  timer.recurring = recurring
  timer.timerId = os.startTimer(interval)

  return timer
end

function Event.removeTimer(h)
  Event.removeEventHandler(h)
end

function Event.waitForEvent(event, timeout)
  local c = os.clock()
  while true do
    os.queueEvent('dummyEvent')
    local e, p1, p2, p3, p4 = Event.pullEvent()
    if e == event then
      return e, p1, p2, p3, p4
    end 
    if os.clock()-c > timeout then
      return
    end 
  end 
end

function Event.pullEvents()
  while true do
    local e = Event.pullEvent()
    if e == 'exitPullEvents' then
      break
    end
  end
end

function Event.exitPullEvents()
  os.queueEvent('exitPullEvents')
end

function Event.enableHandler(h)
  table.insert(enableQueue, h)
end

function Event.pullEvent(type)
  local e, p1, p2, p3, p4, p5 = os.pullEvent(type)

  Logger.logEvent(e, p1, p2, p3, p4, p5)

  local event = eventHandlers[e]
  if event then
    for k,v in pairs(event.handlers) do
      if v.enabled then
        v.f(v, p1, p2, p3, p4, p5)
      end
    end
    while #enableQueue > 0 do
      table.remove(handlerQueue).enabled = true
    end
    while #removeQueue > 0 do
      Event.deleteHandler(table.remove(removeQueue))
    end
  end
  
  return e, p1, p2, p3, p4, p5
end

--Imported from UI
local function widthify(s, len)
  if not s then
    s = ' '
  end
  return string.lpad(string.sub(s, 1, len) , len, ' ')
end

local console

UI = { }

function UI.setProperties(obj, argTable)
  if argTable then
    for k,v in pairs(argTable) do
      obj[k] = v
    end
  end
end

-- there can be only one
function UI.getConsole()
  if not console then
    console = UI.Console()
  end
  return console
end

--[[-- Console (wrapped term) --]]--
UI.Console = class.class()

function UI.Console:init(args)
  self.clear = term.clear
  self.width, self.height = term.getSize()
  UI.setProperties(self, args)
  self.isColor = term.isColor()
  if not self.isColor then
    term.setBackgroundColor = function(...) end
    term.setTextColor = function(...) end
  end
end

function UI.Console:reset()
  term.setCursorPos(1, 1)
  term.setBackgroundColor(colors.black)
  self:clear()
end

function UI.Console:advanceCursorY(offset)
  local x, y = term.getCursorPos()
  term.setCursorPos(1, y+offset)
end

function UI.Console:clearArea(x, y, width, height, bg)
  if bg then
    term.setBackgroundColor(bg)
  end
  local filler = string.rep(' ', width+1)
  for i = y, y+height-1 do
    term.setCursorPos(x, i)
    term.write(filler)
  end
end

function UI.Console:write(x, y, text, bg)
  if bg then
    term.setBackgroundColor(bg)
  end
  term.setCursorPos(x, y)
  term.write(tostring(text))
end

function UI.Console:wrappedWrite(x, y, text, len, bg)
  for k,v in pairs(Util.WordWrap(text, len)) do
    console:write(x, y, v, bg)
    y = y + 1
  end
  return y
end

function UI.Console:prompt(text)
  term.write(text)
  term.setCursorBlink(true)
  local response = read()
  term.setCursorBlink(false)
  if string.len(response) > 0 then
    return response
  end
end

--[[-- StringBuffer --]]--
UI.StringBuffer = class.class()
function UI.StringBuffer:init(bufSize)
  self.bufSize = bufSize
  self.buffer = {}
end

function UI.StringBuffer:insert(s, index)
  table.insert(self.buffer, { index = index, str = s })
end

function UI.StringBuffer:append(s)
  local str = self:get()
  self:insert(s, #str)
end

function UI.StringBuffer:get()
  local str = ''
  for k,v in Util.spairs(self.buffer, function(a, b) return a.index < b.index end) do
    str = str .. string.rep(' ', v.index - string.len(str)) .. v.str
  end
  local len = string.len(str)
  if len < self.bufSize then
    str = str .. string.rep(' ', self.bufSize - len)
  end
  return str
end

function UI.StringBuffer:clear()
  self.buffer = {}
end

--[[-- Pager --]]--
UI.Pager = class.class()

function UI.Pager:init(args)
  local defaults = {
    pages = { }
  }
  UI.setProperties(self, defaults)
  UI.setProperties(self, args)

  self.keyHandler = Event.addHandler('mouse_scroll',
    function(h, direction)
      if direction == 1 then
        self.currentPage:keyHandler('down')
      else
        self.currentPage:keyHandler('up')
      end
    end
  )
  self.keyHandler = Event.addHandler('char',
    function(h, ch)
      if self.currentPage then
        self.currentPage:keyHandler(ch)
      end
    end
  )
  self.keyHandler = Event.addHandler('key',
    function(h, code)
      local ch = keys.getName(code)
      -- filter out a through z as they will be get picked up
      -- as char events
      if string.len(ch) > 1 then
        if self.currentPage then
          self.currentPage:keyHandler(ch)
        end
      end
    end
  )
end

function UI.Pager:addPage(name, page)
  self.pages[name] = page
end

function UI.Pager:setPages(pages)
  self.pages = pages
end

function UI.Pager:getPage(pageName, ...)
  local page = self.pages[pageName]
  
  if not page then
    error('Pager:getPage: Invalid page: ' .. tostring(pageName), 2)
  end

  return page
end

-- changing to setNamedPage
function UI.Pager:setPage(pageName)
  local page = self:getPage(pageName)
  
  self:setPageRaw(page)
end

-- changing to setPage
function UI.Pager:setPageRaw(page)
  if page == self.currentPage then
    page:draw()
  else
    if self.currentPage then
      self.currentPage:disable()
      self.currentPage.enabled = false
      page.previousPage = self.currentPage
    end
    self.currentPage = page
    console:reset()
    page.enabled = true
    page:enable()
    page:draw()
  end
end

function UI.Pager:getCurrentPage()
  return self.currentPage
end

function UI.Pager:setDefaultPage()
  if not self.defaultPage then
    error('No default page defined', 2)
  end
  self:setPage(self.defaultPage)
end

function UI.Pager:setPreviousPage()
  if self.currentPage.previousPage then
    local previousPage = self.currentPage.previousPage.previousPage
    self:setPageRaw(self.currentPage.previousPage)
    self.currentPage.previousPage = previousPage
  end
end

--[[-- Page --]]--
UI.Page = class.class()

function UI.Page:init(args)
  self.defaultPage = 'menu'
  UI.setProperties(self, args)
end

function UI.Page:draw()
end

function UI.Page:enable()
end

function UI.Page:disable()
end

function UI.Page:keyHandler(ch)
end

--[[-- Grid  --]]--
UI.Grid = class.class()

function UI.Grid:init(args)
  local defaults = {
    sep = ' ',
    sepLen = 1,
    x = 1,
    y = 1,
    pageSize = 16,
    pageNo = 1,
    index = 1,
    inverseSort = false,
    disableHeader = false,
    selectable = true,
    textColor = colors.white,
    textSelectedColor = colors.white,
    backgroundColor = colors.black,
    backgroundSelectedColor = colors.gray,
    t = {},
    columns = {}
  }
  UI.setProperties(self, defaults)
  UI.setProperties(self, args)
  if not self.width then
    self.width = self:calculateWidth()
  end
  if self.autospace then
    local colswidth = 0
    for _,c in pairs(self.columns) do
      colswidth = colswidth + c[3] + 1
    end
    local spacing = (self.width - colswidth - 1) 
    spacing = math.floor(spacing / (#self.columns - 1) )
    for _,c in pairs(self.columns) do
      c[3] = c[3] + spacing
    end
  end
end

function UI.Grid:setPosition(x, y)
  self.x = x
  self.y = y
end

function UI.Grid:setPageSize(pageSize)
  self.pageSize = pageSize
end

function UI.Grid:setColumns(columns)
  self.columns = columns
end

function UI.Grid:getTable()
  return self.t
end

function UI.Grid:setTable(t)
  self.t = t
end

function UI.Grid:setInverseSort(inverseSort)
  self.inverseSort = inverseSort
  self:drawRows()
end

function UI.Grid:setSortColumn(column)
  self.sortColumn = column
  for _,col in pairs(self.columns) do
    if col[2] == column then
      return
    end
  end
  error('Grid:setSortColumn: invalid column', 2)
end

function UI.Grid:setSeparator(sep)
  self.sep = sep
  self.sepLen = string.len(sep)
end

function UI.Grid:setSelected(row)
  self.selected = row
end

function UI.Grid:getSelected()
  return self.selected
end

function UI.Grid:draw()
  if not self.disableHeader then
    self:drawHeadings()
  end
  self:drawRows()
end

function UI.Grid:drawHeadings()

  local sb = UI.StringBuffer(self.width)
  local x = 1
  for k,col in ipairs(self.columns) do
    local width = col[3] + 1
    sb:insert(col[1], x)
    x = x + width
  end
  console:write(self.x, self.y, sb:get(), colors.blue)
end

function UI.Grid:calculateWidth()
  -- gutters on each side
  local width = 2
  for _,col in pairs(self.columns) do
    width = width + col[3] + 1
  end
  return width - 1
end

function UI.Grid:drawRows()

  local function sortM(a, b)
    return a[self.sortColumn] < b[self.sortColumn]
  end

  local function inverseSortM(a, b)
    return a[self.sortColumn] > b[self.sortColumn]
  end

  local sortMethod
  if self.sortColumn then
    sortMethod = sortM
    if self.inverseSort then
      sortMethod = inverseSortM
    end
  end

  if self.index > Util.size(self.t) then
    local newIndex = Util.size(self.t)
    if newIndex <= 0 then
      newIndex = 1
    end
    self:setIndex(newIndex)
    return
  end

  local startRow = self:getStartRow()
  local y = self.y
  local rowCount = 0
  local sb = UI.StringBuffer(self.width)

  if not self.disableHeader then
    y = y + 1
  end

  local index = 1
  for _,row in Util.spairs(self.t, sortMethod) do
    if index >= startRow then
      sb:clear()
      if index >= startRow + self.pageSize then
        break
      end

      if not console.isColor then
        if index == self.index and self.selectable then
          sb:insert('>', 0)
        end
      end

      local x = 1
      for _,col in pairs(self.columns) do

        local value = row[col[2]]
        if value then
          sb:insert(string.sub(value, 1, col[3]), x)
        end

        x = x + col[3] + 1
      end

      local selected = index == self.index and self.selectable
      if selected then
        self:setSelected(row)
      end

      term.setTextColor(self:getRowTextColor(row, selected))
      console:write(self.x, y, sb:get(), self:getRowBackgroundColor(row, selected))

      y = y + 1
      rowCount = rowCount + 1
    end
    index = index + 1
  end

  if rowCount < self.pageSize then
    console:clearArea(self.x, y, self.width, self.pageSize-rowCount, self.backgroundColor)
  end
  term.setTextColor(colors.white)
end

function UI.Grid:getRowTextColor(row, selected)
  if selected then
    return self.textSelectedColor
  end
  return self.textColor
end

function UI.Grid:getRowBackgroundColor(row, selected)
  if selected then
    return self.backgroundSelectedColor
  end
  return self.backgroundColor
end

function UI.Grid:getIndex(index)
  return self.index
end

function UI.Grid:setIndex(index)
  if self.index ~= index then
    if index < 1 then
      index = 1
    end
    self.index = index
    self:drawRows()
  end
end

function UI.Grid:getStartRow()
  return math.floor((self.index - 1)/ self.pageSize) * self.pageSize + 1
end

function UI.Grid:getPage()
  return math.floor(self.index / self.pageSize) + 1
end

function UI.Grid:getPageCount()
  local tableSize = Util.size(self.t)
  local pc = math.floor(tableSize / self.pageSize)
  if tableSize % self.pageSize > 0 then
    pc = pc + 1
  end
  return pc
end

function UI.Grid:setPage(pageNo)
  -- 1 based paging
  self:setIndex((pageNo-1) * self.pageSize + 1)
end

function UI.Grid:keyHandler(ch)

  if ch == 'j' or ch == 'down' then
    self:setIndex(self.index + 1)
  elseif ch == 'k' or ch == 'up' then
    self:setIndex(self.index - 1)
  elseif ch == 'h' then
    self:setIndex(self.index - self.pageSize)
  elseif ch == 'l' then
    self:setIndex(self.index + self.pageSize)
  elseif ch == 'home' then
    self:setIndex(1)
  elseif ch == 'end' then
    self:setIndex(Util.size(self.t))
  elseif ch == 'r' then
    self:draw()
  elseif ch == 's' then
    self:setInverseSort(not self.inverseSort)
  else
    return false
  end
  return true
end

--[[-- ScrollingGrid  --]]--
UI.ScrollingGrid = class.class(UI.Grid)
function UI.ScrollingGrid:init(args)
  local defaults = {
    scrollOffset = 1
  }
  UI.setProperties(self, defaults)
  UI.Grid.init(self, args)
end

function UI.ScrollingGrid:drawRows()
  UI.Grid.drawRows(self)
  self:drawScrollbar()
end

function UI.ScrollingGrid:drawScrollbar()
  local ts = Util.size(self.t)
  if ts > self.pageSize then
    term.setBackgroundColor(self.backgroundColor)
    local sbSize = self.pageSize - 2
    local sa = ts -- - self.pageSize
    sa = self.pageSize / sa
    sa = math.floor(sbSize * sa)
    if sa < 1 then
      sa = 1
    end
    if sa > sbSize then
      sa = sbSize
    end
    local sp = ts-self.pageSize
    sp = self.scrollOffset / sp
    sp = math.floor(sp * (sbSize-sa + 0.5))
--console:reset()
--print('sb: ' .. sbSize .. ' sa:' .. sa .. ' sp:' .. sp)
--read()

    local x = self.x + self.width-1
    if self.scrollOffset > 1 then
      console:write(x, self.y + 1, '^')
    else
      console:write(x, self.y + 1, ' ')
    end
    local row = 0
    for i = 0, sp - 1 do
      console:write(x, self.y + row+2, '|')
      row = row + 1
    end
    for i = 1, sa do
      console:write(x, self.y + row+2, '#')
      row = row + 1
    end
    for i = row, sbSize do
      console:write(x, self.y + row+2, '|')
      row = row + 1
    end
    if self.scrollOffset + self.pageSize - 1 < Util.size(self.t) then
      console:write(x, self.y + self.pageSize, 'v')
    else
      console:write(x, self.y + self.pageSize, ' ')
    end
  end
end

function UI.ScrollingGrid:getStartRow()
  local ts = Util.size(self.t)
  if ts < self.pageSize then
    self.scrollOffset = 1
  end
  return self.scrollOffset
end

function UI.ScrollingGrid:setIndex(index)
  if index < self.scrollOffset then
    self.scrollOffset = index
  elseif index - (self.scrollOffset - 1) > self.pageSize then
    self.scrollOffset = index - self.pageSize + 1
  end

  if self.scrollOffset < 1 then
    self.scrollOffset = 1
  else
    local ts = Util.size(self.t)
    if self.pageSize + self.scrollOffset > ts then
      self.scrollOffset = ts - self.pageSize + 1
    end
  end
  UI.Grid.setIndex(self, index)
end

--[[-- Menu  --]]--
UI.Menu = class.class(UI.Grid)

function UI.Menu:init(args)
  local defaults = {
    disableHeader = true,
    columns = { { 'Prompt', 'prompt', 20 } },
    t = args['menuItems'],
    width = 1
  }
  UI.Grid.init(self, defaults)
  UI.setProperties(self, args)
  self.pageSize = #self.menuItems
  for _,v in pairs(self.t) do
    if string.len(v.prompt) > self.width then
      self.width = string.len(v.prompt)
    end
  end
  self.width = self.width + 2
end

function UI.Menu:center()
  local width = 0
  for _,v in pairs(self.menuItems) do
    local len = string.len(v.prompt)
    if len > width then
      width = len
    end
  end
  self.x = (console.width - width) / 2
  self.y = (console.height - #self.menuItems) / 2
end

function UI.Menu:keyHandler(ch)
  if ch and self.menuItems[tonumber(ch)] then
    self.menuItems[tonumber(ch)].action()
  elseif ch == 'enter' then
    self.menuItems[self.index].action()
  else
    return UI.Grid.keyHandler(self, ch)
  end
  return true
end

--[[-- ViewportConsole  --]]--
UI.ViewportConsole = class.class()
function UI.ViewportConsole:init(args)
  local defaults = {
    x = 1,
    y = 1,
    width = console.width,
    height = console.height,
    offset = 0,
    vpx = 1,
    vpy = 1,
    vpHeight = console.height
  }
  UI.setProperties(self, defaults)
  UI.setProperties(self, args)
end

function UI.ViewportConsole:setCursorPos(x, y)
  self.vpx = x
  self.vpy = y
  if self.vpy > self.height then
    self.height = self.vpy
  end
end

function UI.ViewportConsole:reset(bg)
  console:clearArea(self.x, self.y, self.width, self.vpHeight, bg)
  self:setCursorPos(1, 1)
end

function UI.ViewportConsole:clearArea(x, y, width, height, bg)
  if bg then
    term.setBackgroundColor(bg)
  end
  y = y - self.offset
  for i = 1, height do
    if y > 0 and y <= self.vpHeight then
      term.setCursorPos(x, self.y + y - 1)
      term.clearLine()
    end
    y = y + 1
  end
end

function UI.ViewportConsole:pr(text, bg)
  self:write(self.vpx, self.vpy, text, bg)
  self:setCursorPos(1, self.vpy + 1)
end

function UI.ViewportConsole:write(x, y, text, bg)
  y = y - self.offset
  if y > 0 and y <= self.vpHeight then
    console:write(self.x + x - 1, self.y + y - 1, text, bg)
  end
end

function UI.ViewportConsole:wrappedPrint(text, indent, len, bg)
  indent = indent or 1
  len = len or self.width - indent
  for k,v in pairs(Util.WordWrap(text, len+1)) do
    self:write(indent, self.vpy, v, bg)
    self.vpy = self.vpy + 1
  end
end

function UI.ViewportConsole:wrappedWrite(x, y, text, len, bg)
  for k,v in pairs(Util.WordWrap(text, len)) do
    self:write(x, y, v, bg)
    y = y + 1
  end
  return y
end

function UI.ViewportConsole:setPage(pageNo)
  self:setOffset((pageNo-1) * self.vpHeight + 1)
end

function UI.ViewportConsole:setOffset(offset)
  self.offset = math.max(0, math.min(math.max(0, offset), self.height-self.vpHeight))
  self:draw()
end

function UI.ViewportConsole:draw()
end

function UI.ViewportConsole:keyHandler(ch)

  if ch == 'j' or ch == 'down' then
    self:setOffset(self.offset + 1)
  elseif ch == 'k' or ch == 'up' then
    self:setOffset(self.offset - 1)
  elseif ch == 'home' then
    self:setOffset(0)
  elseif ch == 'end' then
    self:setOffset(self.height-self.vpHeight)
  elseif ch == 'h' then
    self:setPage(
      math.floor((self.offset - self.vpHeight) / self.vpHeight))
  elseif ch == 'l' then
    self:setPage(
      math.floor((self.offset + self.vpHeight) / self.vpHeight) + 1)
  else
    return false
  end
  return true
end
  
--[[-- ScrollingText  --]]--
UI.ScrollingText = class.class()
function UI.ScrollingText:init(args)
  local defaults = {
    x = 1,
    y = 1,
    height = console.height,
    backgroundColor = colors.black,
    width = console.width,
    buffer = { }
  }
  UI.setProperties(self, defaults)
  UI.setProperties(self, args)
end

function UI.ScrollingText:write(text)
  if #self.buffer+1 >= self.height then
    table.remove(self.buffer, 1)
  end
  table.insert(self.buffer, text)
  self:draw()
end

function UI.ScrollingText:clear()
  self.buffer = { }
  console:clearArea(self.x, self.y, self.width, self.height, self.backgroundColor)
end

function UI.ScrollingText:draw()
  for k,text in ipairs(self.buffer) do
    console:write(self.x, self.y + k, widthify(text, self.width), self.backgroundColor)
  end
end

--[[-- TitleBar  --]]--
UI.TitleBar = class.class()
function UI.TitleBar:init(args)
  local defaults = {
    x = 1,
    y = 1,
    backgroundColor = colors.brown,
    width = console.width,
    title = ''
  }
  UI.setProperties(self, defaults)
  UI.setProperties(self, args)
end

function UI.TitleBar:draw()
  console:clearArea(self.x, self.y, self.width, 1, self.backgroundColor)
  local centered = (self.width -#self.title) / 2
  console:write(self.x + centered, self.y, self.title)
  term.setBackgroundColor(colors.black)
end

--[[-- StatusBar  --]]--
UI.StatusBar = class.class(UI.Grid)
function UI.StatusBar:init(args)
  local defaults = {
    selectable = false,
    disableHeader = true,
    y = console.height,
    backgroundColor = colors.gray,
    width = console.width,
    t = {{}}
  }
  UI.setProperties(defaults, args)
  UI.Grid.init(self, defaults)
  if self.values then
    self:setValues(self.values)
  end
end

function UI.StatusBar:setValues(values)
  self.t[1] = values
end

function UI.StatusBar:setValue(name, value)
  self.t[1][name] = value
end

function UI.StatusBar:getValue(name)
  return self.t[1][name]
end

function UI.StatusBar:getColumnWidth(name)
  for _,v in pairs(self.columns) do
    if v[2] == name then
      return v[3]
    end
  end
end

function UI.StatusBar:setColumnWidth(name, width)
  for _,v in pairs(self.columns) do
    if v[2] == name then
      v[3] = width
      break
    end
  end
end

--[[-- Form  --]]--
UI.Form = class.class()
UI.Form.D = { -- display

  static = {
    draw = function(field)
      console:write(field.x, field.y, widthify(field.value, field.width), colors.black)
    end
  },

  entry = {

    draw = function(field)
      console:write(field.x, field.y, widthify(field.value, field.width), colors.gray)
    end,

    updateCursor = function(field)
      term.setCursorPos(field.x + field.pos, field.y)
    end,

    focus = function(field)
      term.setCursorBlink(true)
      if not field.pos then
        field.pos = #field.value
      end
      field.display.updateCursor(field)
    end,

    loseFocus = function(field)
      term.setCursorBlink(false)
    end,
--[[
  A few lines below from theoriginalbit
  http://www.computercraft.info/forums2/index.php?/topic/16070-read-and-limit-length-of-the-input-field/
--]]
    keyHandler = function(form, field, ch)
      if ch == 'enter' then
        form:selectNextField()
        -- self.accept(self)
      elseif ch == 'left' then
        if field.pos > 0 then
          field.pos = math.max(field.pos-1, 0)
          field.display.updateCursor(field)
        end
      elseif ch == 'right' then
        local input = field.value
        if field.pos < #input then
          field.pos = math.min(field.pos+1, #input)
          field.display.updateCursor(field)
        end
      elseif ch == 'home' then
        field.pos = 0
        field.display.updateCursor(field)
      elseif ch == 'end' then
        field.pos = #field.value
        field.display.updateCursor(field)
      elseif ch == 'backspace' then
        if field.pos > 0 then
          local input = field.value
          field.value = input:sub(1, field.pos-1) .. input:sub(field.pos+1)
          field.pos = field.pos - 1
          field.display.draw(field)
          field.display.updateCursor(field)
        end
      elseif ch == 'delete' then
        local input = field.value
        if field.pos < #input then
          field.value = input:sub(1, field.pos)..input:sub(field.pos+2)
          field.display.draw(field)
          field.display.updateCursor(field)
        end
      elseif #ch == 1 then
        local input = field.value

        if #input < field.width then
          field.value = input:sub(1, field.pos) .. ch .. input:sub(field.pos+1)
          field.pos = field.pos + 1
          field.display.draw(field)
          field.display.updateCursor(field)
        end
      else
        return false
      end
      return true
    end
  },
  button = {
    draw = function(field, focused)
      local bg = colors.brown
      if focused then
        bg = colors.green
      end
      console:clearArea(field.x, field.y, field.width, 1, bg)
      console:write(
              field.x + math.ceil(field.width/2) - math.ceil(#field.text/2),
              field.y,
              tostring(field.text))
    end,
    focus = function(field)
      field.display.draw(field, true)
    end,
    loseFocus = function(field)
      field.display.draw(field, false)
    end,
    keyHandler = function(form, field, ch)
      if ch == 'enter' then
        form.cancel(form)
      else
        return false
      end
      return true
    end
  }
}

UI.Form.V = { -- validation
  number = function(value)
    return type(value) == 'number'
  end
}

UI.Form.T = { -- data types
  number = function(value)
    return tonumber(value)
  end
}

function UI.Form:init(args)
  local defaults = {
    values = {},
    fields = {},
    columns = {
      { 'Name', 'name', 20 },
      { 'Values', 'value', 20 }
    },
    x = 1,
    y = 1,
    nameWidth = 20,
    valueWidth = 20,
    accept = function() end,
    cancel = function() end
  }
  UI.setProperties(self, defaults)
  UI.setProperties(self, args)

end

function UI.Form:setValues(values)
  self.values = values

  -- store the value in the field in case the user cancels entry
  for k,field in pairs(self.fields) do
    if field.key then
      field.value = self.values[field.key]
      if not field.value then
        field.value = ''
      end
    end
  end
end

function UI.Form:draw()

  local y = self.y
  for k,field in ipairs(self.fields) do

    console:write(self.x, y, field.name, colors.black)

    field.x = self.x + 1 + self.nameWidth
    field.y = y
    field.width = self.valueWidth

    if not self.fieldNo and field.display.focus then
      self.fieldNo = k
    end

    field.display.draw(field, k == self.fieldNo)

    y = y + 1
  end

  local field = self:getCurrentField() 
  field.display.focus(field)
end

function UI.Form:getCurrentField()
  if self.fieldNo then
    return self.fields[self.fieldNo]
  end
end

function UI.Form:selectField(index)
  local field = self:getCurrentField()
  if field then
    field.display.loseFocus(field)
  end

  self.fieldNo = index

  field = self:getCurrentField()
  field.display.focus(field)
end

function UI.Form:selectFirstField()
  for k,field in ipairs(self.fields) do
    if field.display.focus then
      self:selectField(k)
      break
    end
  end
end

function UI.Form:selectPreviousField()
  for k = self.fieldNo - 1, 1, -1 do
    local field = self.fields[k]
    if field.display.focus then
      self:selectField(k)
      break
    end
  end
end

function UI.Form:selectNextField()
  for k = self.fieldNo + 1, #self.fields do
    local field = self.fields[k]
    if field.display.focus then
      self:selectField(k)
      break
    end
  end
end

function UI.Form:keyHandler(ch)

  local field = self:getCurrentField()
  if field.display.keyHandler(self, field, ch) then
    return true
  end

  if ch == 'down' then
    self:selectNextField()
  elseif ch == 'up' then
    self:selectPreviousField()
  else
    return false
  end

  return true
end

--[[-- Spinner  --]]--
UI.Spinner = class.class()
function UI.Spinner:init(args)
  local defaults = {
    timeout = .095,
    x = 1,
    y = 1,
    c = os.clock(),
    spinIndex = 0,
    spinSymbols = { '-', '/', '|', '\\' }
  }
  UI.setProperties(self, defaults)
  UI.setProperties(self, args)
end

function UI.Spinner:spin()
  local cc = os.clock()
  if cc > self.c + self.timeout then
    term.setCursorPos(self.x, self.y)
    term.write(self.spinSymbols[self.spinIndex % #self.spinSymbols + 1])
    self.spinIndex = self.spinIndex + 1
    self.c = cc
    os.sleep(0)
  end
end

function UI.Spinner:getCursorPos()
  self.x, self.y = term.getCursorPos()
end

-----------------------------------------------
-- UIL2 ?

function UI.messageBox(text)
  local w = console.width - 4
  local h = console.height - 4
  local x = 3
  local y = 3
  console:clearArea(x, y, w-1, h, colors.red)

  console:wrappedWrite(x+2, y+2, text, w-4, colors.red)
  console:write(x+1, y, string.rep('oh', w/2), colors.orange)
  console:write(x+1, y+h-1, string.rep('no', w/2), colors.orange)
  for i = y, y + h - 1 do
    console:write(x, i, 'O', colors.orange)
    console:write(x+w-1, i, 'H', colors.orange)
  end
  console:wrappedWrite(x+2, y+h-3, 'Press enter to continue', w-4, colors.red)
  read()
  term.setBackgroundColor(colors.black)
end



local console = UI.getConsole()

--[[ -- MethodsPage  -- ]] --
peripheralsPage = UI.Page({
  titleBar = UI.TitleBar({
    title = 'Peripheral Viewer v0.0001'
  }),
  grid = UI.ScrollingGrid({
    columns = { 
      { 'Type', 'type', console.width-10 },
      { 'Side', 'side', 8 }
    },  
    sortColumn = 'type',
    pageSize = console.height-3,
    width = console.width,
    y = 2,
    x = 1 
  }),
  statusBar = UI.StatusBar({
    columns = { 
      { '', 'msg', console.width },
    },  
    x = 1,
    backgroundColor = colors.blue
  })
})

function peripheralsPage:draw()
  local sides = peripheral.getNames()
  local t = { }
  for _,side in pairs(sides) do
    table.insert(t, {
      type = peripheral.getType(side),
      side = side
    })
  end

  self.titleBar:draw()
  self.grid:setTable(t)
  self.grid:draw()
  self.statusBar:setValue('msg', 'Select peripheral')
  self.statusBar:draw()
end

function peripheralsPage:keyHandler(ch)
  if ch == 'q' then
    Event.exitPullEvents()
  elseif ch == 'enter' then
    methodsPage.selected = self.grid:getSelected()
    methodsPage.grid.index = 1
    methodsPage.grid.scrollOffset = 1
    pager:setPageRaw(methodsPage)
  else
    return  self.grid:keyHandler(ch)
  end
  return false
end

--[[ -- MethodsPage  -- ]] --
methodsPage = UI.Page({
  titleBar = UI.TitleBar(),
  grid = UI.ScrollingGrid({
    columns = { 
      { 'Name', 'name', console.width }
    },  
    sortColumn = 'name',
    pageSize = 5,
    width = console.width,
    y = 2,
    x = 1 
  }), 
  viewportConsole = UI.ViewportConsole({
    y = 8,
    vpHeight = console.height-8
  }),
  statusBar = UI.StatusBar({
    columns = { 
      { '', 'msg', console.width },
    },  
    x = 1,
    backgroundColor = colors.blue
  })
})

function methodsPage:enable()
  self.extendedInfo = false
  local p = peripheral.wrap(self.selected.side)
  if not p.getAdvancedMethodsData then
    local t = { }
    for name,f in pairs(p) do
      table.insert(t, { name = name })
    end
    self.grid.pageSize = console.height - 3
    self.grid.t = t
  else
	local t = { }
	adv = p.getAdvancedMethodsData()
    for name,func_details in pairs(adv) do
	  func_details.name = name
      table.insert(t, func_details)
    end
    self.grid.t = t
    self.grid.pageSize = 5
    self.extendedInfo = true
  end

  if self.extendedInfo then
    self.titleBar.title = self.selected.type
  else
    self.titleBar.title = self.selected.type .. ' (no ext info)'
  end

  self.statusBar:setValue('msg', 'q to return')
end

function methodsPage:draw()
  self.titleBar:draw()
  self.grid:draw()
  if self.extendedInfo then
	if self.grid:getSelected() then
	  drawMethodInfo(self.viewportConsole, self.grid:getSelected())
	end
  end
  self.statusBar:draw()
end

function methodsPage:keyHandler(ch)
  if ch == 'q' then
    pager:setPageRaw(peripheralsPage)
  elseif ch == 'enter' then
    if self.extendedInfo then
      pager:setPageRaw(methodDetailsPage)
    end
  elseif self.grid:keyHandler(ch) then
    if self.extendedInfo then
      drawMethodInfo(self.viewportConsole, self.grid:getSelected())
    end
  end
end

--[[ -- MethodDetailsPage  -- ]] --
methodDetailsPage = UI.Page({
  viewportConsole = UI.ViewportConsole({
    y = 1,
    height = console.height-1,
    vpHeight = console.height-1
  }),
  statusBar = UI.StatusBar({
    columns = { 
      { '', 'msg', console.width }
    },  
    x = 1,
    backgroundColor = colors.blue
  })
})

function methodDetailsPage:enable()
  self.viewportConsole.offset = 0
  self.viewportConsole.height = console.height-1
  self.statusBar:setValue('msg', 'enter to return')
end

function methodDetailsPage:draw()
  drawMethodInfo(self.viewportConsole, methodsPage.grid:getSelected())
  self.statusBar:draw()
end

function methodDetailsPage:keyHandler(ch)
  if ch == 'enter' or ch == 'q' then
    pager:setPreviousPage()
  elseif self.viewportConsole:keyHandler(ch) then
    drawMethodInfo(self.viewportConsole, methodsPage.grid:getSelected())
  end
end

--[[ -- Common logic  -- ]] --
function drawMethodInfo(c, method)

  c:reset(colors.brown)

  if method.description then
    c:wrappedPrint(method.description)
    c:pr('')
  end

  local str = method.name .. '('
  for k,arg in ipairs(method.args) do
    str = str .. arg.name
    if k < #method.args then
      str = str .. ', '
    end
  end
  c:wrappedPrint(str .. ')')

  local sb = UI.StringBuffer(0)
  if #method.returnTypes > 0 then
    sb:clear()
    sb:append('Returns: ')
    for k,ret in ipairs(method.returnTypes) do
      sb:append(ret)
      if k < #method.returnTypes then
        sb:append(', ')
      end
    end
    c:pr(sb:get())
  end

  if #method.args > 0 then
    for _,arg in ipairs(method.args) do
      c:pr('')
      c:wrappedPrint(arg.name .. ': ' .. arg.description)
      c:pr('')
      c:pr('optional nullable type    vararg')
      c:pr('-------- -------- ----    ------')
      sb:clear()
      sb:insert(tostring(arg.optional), 0)
      sb:insert(tostring(arg.nullable), 9)
      sb:insert(arg.type, 18)
      sb:insert(tostring(arg.vararg), 26)
      c:pr(sb:get())
    end
  end

  term.setBackgroundColor(colors.black)
  return y
end

--[[ -- Startup logic  -- ]] --
pager = UI.Pager()
pager:setPageRaw(peripheralsPage)

Logger.disableLogging()
Event.pullEvents()
console:reset()
