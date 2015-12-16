version = "2.0.0 (WIP)"

cfg = {}
cfg.antiLagSleep = 0
cfg.fuelCheck = true
cfg.startDist = 0
cfg.endDist = 100
cfg.depth = 100
cfg.ores = {}
cfg.ores.count = 0
cfg.ores.names = {}
cfg.ores.values = {}

function loadCFG()
  if fs.exists("cfg.smc") then
    local f = fs.open("cfg.smc","r")
    local data = f.readAll()
    f.close()
    data = textutils.unserialize(data)
    if data == nil then return saveCFG()
    elseif type(data) ~= "table" then return saveCFG()
    elseif type(data.antiLagSleep) ~= "number" then return saveCFG()
    elseif type(data.fuelCheck) ~= "boolean" then return saveCFG()
    elseif type(data.startDist) ~= "number" then return saveCFG()
    elseif type(data.endDist) ~= "number" then return saveCFG()
    elseif type(data.depth) ~= "number" then return saveCFG()
    elseif type(data.ores) ~= "table" then return saveCFG()
    elseif type(data.ores.count) ~= "number" then return saveCFG()
    elseif type(data.ores.names) ~= "table" then return saveCFG()
    elseif type(data.ores.values) ~= "table" then return saveCFG()
    elseif data.antiLagSleep < 0 then return saveCFG()
    elseif data.startDist < 0 then return saveCFG()
    elseif data.endDist < data.startDist then return saveCFG()
    elseif data.depth < 0 then return saveCFG()
    elseif data.ores.count < 0 then return saveCFG()
    else
      ccfg = {}
      ccfg.antiLagSleep = math.floor(data.antiLagSleep)
      ccfg.fuelCheck = data.fuelCheck
      ccfg.startDist = math.floor(data.startDist)
      ccfg.endDist = math.floor(data.endDist)
      ccfg.depth = math.floor(data.depth)
      ccfg.ores = {}
      ccfg.ores.count = math.floor(data.ores.count)
      ccfg.ores.names = {}
      ccfg.ores.values = {}
      local fail = false
      for I=1,ccfg.ores.count,1 do
        local i = tostring(I)
        if type(data.ores.names[i]) ~= "string" then fail = true
        elseif type(data.ores.values[i]) ~= "boolean" then fail = true
        elseif data.ores.names[i] == "" then fail = true end
        if fail then break end
        ccfg.ores.names[i] = data.ores.names[i]
        ccfg.ores.values[i] = data.ores.values[i]
      end
      if fail then return saveCFG()
      else cfg = ccfg end
    end
  else return saveCFG() end
end

function saveCFG()
  local data = textutils.serialize(cfg)
  local f = fs.open("cfg.smc","w")
  f.write(data)
  f.close()
end

function copyCFG()
  ccfg = {}
  ccfg.antiLagSleep = cfg.antiLagSleep
  ccfg.fuelCheck = cfg.fuelCheck
  ccfg.startDist = cfg.startDist
  ccfg.endDist = cfg.endDist
  ccfg.depth = cfg.depth
  ccfg.ores = {}
  ccfg.ores.count = cfg.ores.count
  ccfg.ores.names = {}
  ccfg.ores.values = {}
  for I=1,ccfg.ores.count,1 do
    local i = tostring(I)
    ccfg.ores.names[i] = cfg.ores.names[i]
    ccfg.ores.values[i] = cfg.ores.values[i]
  end
  return ccfg
end

-- some terminal functions with extra short names
t = {}
t.colFG = colors.white
t.colBG = colors.black
t.sizeX, t.sizeY = term.getSize()
t.cp = function(x,y) -- setCursorPos
  term.setCursorPos(x,y)
end
t.cb = function(c) -- color Background
  if not term.isColor() then c = colors.black end
  term.setBackgroundColor(c)
  t.colBG = c
end
t.cf = function(c) -- color Foreground
  if not term.isColor() then c = colors.white end
  term.setTextColor(c)
  t.colFG = c
end
t.crol = function() -- clear rest of line
  t.w("                                                   ")
end
t.cat = function(x,y) -- clear (rest of line) at
  t.cp(x,y)
  t.crol()
  t.cp(x,y)
end
t.w = function(s) -- write
  term.write(s)
end
t.wc = function(s,c) -- write (color)
  t.cf(c)
  t.w(s)
end
t.wat = function(s,x,y) -- write at
  t.cp(x,y)
  t.w(s)
end
t.watc = function(s,x,y,c) -- write at (color)
  t.cf(c)
  t.wat(s,x,y)
end
t.cw = function(s,y) -- center write
  local x = math.floor( (t.sizeX-#s) / 2)
  t.wat(s,x,y)
end
t.cwc = function(s,y,c) -- center write (color)
  t.cf(c)
  t.cw(s,y)
end
t.c = function() -- clear
  term.clear()
  t.cp(1,1)
  t.cf(colors.white)
  t.cb(colors.black)
end
t.m = function(s,c) -- a mark at the right bottom of the screen, for debugging
-- safe to call from anywhere, since it restores cursor position and color
  x0,y0 = term.getCursorPos()
  cf0 = t.colFG
  t.watc(s, t.sizeX-#s+1, t.sizeY, c)
  t.cp(x0,y0)
  t.cf(cf0)
end

-- displays a simple welcome screen, waiting about 25 ticks
function welcomeScreen()
  s1 = "CC Stripmine v"..version
  s2 = "Copyright (c)  2015"
  s3 = "by Tim Taubitz (Yggdrasil128)"
  t.c()
  x,y = term.getSize()
  t.watc(s1, math.floor((x-#s1)/2), math.floor((y-2)/2), colors.orange)
  t.watc(s2, math.floor((x-#s2)/2), math.floor((y-2)/2)+2, colors.lightGray)
  t.wat(s3, math.floor((x-#s3)/2), math.floor((y-2)/2)+3)
  term.setTextColor(colors.gray)
  t.cp(1,y)
  if x == 26 then
    for i = 1, x, 1 do
      term.write(".1", i, y)
      os.sleep(0.05)
    end
  else
    for i = 1, x, 2 do
      term.write("..", i, y)
      os.sleep(0.05)
    end
  end
  t.c()
end

-- a navigatable main menu
--[[
Settings
Exit
--]]
_cfgReturnIndex = 1
function mainMenu(startIndex)
  t.c()
  t.watc("CC Stripmine v"..version, 1, 1, colors.orange)
  t.wc(" by Yggdrasil128", colors.lightGray)
  t.watc("Main menu", 1, 3, colors.lime)
  t.watc("Scroll with up/down, select with enter", 1, 4, colors.gray)

  t.cf(colors.white)
  t.wat("[S]ettings...", 4, 6) -- adjust _cfgReturnIndex, too
  t.wat("[E]xit", 4, 7)

  term.setTextColor(colors.gray)
  for i=6,7,1 do
    t.wat("[", 4, i)
    t.wat("]", 6, i)
  end

  t.cf(colors.cyan)
  maxIndex = 2
  index = startIndex
  fin = false
  while not fin do
    t.wat(">", 2, index+5)
    event, key = os.pullEvent("key")
    t.wat(" ", 2, index+5)

    if key == keys.enter then fin = true
    elseif (key == keys.up) and (index>1) then index = index - 1
    elseif (key == keys.down) and (index<maxIndex) then index = index + 1
    elseif key == keys.s then
      index = 1
      fin = true
    elseif key == keys.e then
      index = 2
      fin = true
    end
  end
  os.pullEvent("key_up")

  if index == 1 then cfgMenu(copyCFG(), 1)
  elseif index == 2 then return end
end

function cfgMenu(workingCFG, startIndex)
  t.c()
  t.watc("CC Stripmine v"..version, 1, 1, colors.orange)
  t.wc(" by Yggdrasil128", colors.lightGray)
  t.watc("Settings", 1, 3, colors.lime)
  t.watc("Scroll with up/down, change with enter", 1, 4, colors.gray)

  t.cf(colors.white)
  t.wat("antiLagSleep", 4, 6)
  t.wat("fuelCheck", 4, 7)
  t.wat("startDist", 4, 8)
  t.wat("endDist", 4, 9)
  t.wat("depth", 4, 10)
  t.wat("[O]res ...", 4, 11) -- adjust returning index, too
  t.wat("[A]bort ...", 4, 12)
  t.wat("[S]ave ...", 4, 13)

  term.setTextColor(colors.gray)
  for i=11,13,1 do
    t.wat("[", 4, i)
    t.wat("]", 6, i)
  end

  t.cf(colors.lightGray)
  for i=6,10,1 do t.wat("=", 17, i) end

  t.cf(colors.yellow)
  t.wat(workingCFG.antiLagSleep, 19, 6)
  t.wat(workingCFG.fuelCheck and "true" or "false", 19, 7)
  t.wat(workingCFG.startDist, 19, 8)
  t.wat(workingCFG.endDist, 19, 9)
  t.wat(workingCFG.depth, 19, 10)

  maxIndex = 8
  index = startIndex
  function loop()
    fin = false
    while not fin do
      t.watc(">", 2, index+5, colors.cyan)
      event, key = os.pullEvent("key")
      t.wat(" ", 2, index+5)
      --
      if key == keys.enter then fin = true
      elseif (key == keys.up) and (index>1) then index = index - 1
      elseif (key == keys.down) and (index<maxIndex) then index = index + 1
      elseif key == keys.o then
        index = 6
        fin = true
      elseif key == keys.a then
        index = 7
        fin = true
      elseif key == keys.s then
        index = 8
        fin = true
      end
    end

    if index == 1 then
      t.cat(19,6)
      t.cf(colors.yellow)
      local v = tonumber(read())
      if v then if v >= 0 then workingCFG.antiLagSleep = v end end
      t.cat(19,6)
      t.w(workingCFG.antiLagSleep)
      loop()
    elseif index == 2 then
      workingCFG.fuelCheck = not workingCFG.fuelCheck
      t.watc(workingCFG.fuelCheck and "true " or "false", 19, 7, colors.yellow)
      loop()
    elseif index == 3 then
      t.cat(19,8)
      t.cf(colors.yellow)
      local v = tonumber(read())
      if v then if (v >= 0) and (v <= workingCFG.endDist) then workingCFG.startDist = v end end
      t.cat(19,8)
      t.w(workingCFG.startDist)
      loop()
    elseif index == 4 then
      t.cat(19,9)
      t.cf(colors.yellow)
      local v = tonumber(read())
      if v then if v >= workingCFG.startDist then workingCFG.endDist = v end end
      t.cat(19,9)
      t.w(workingCFG.endDist)
      loop()
    elseif index == 5 then
      t.cat(19,10)
      t.cf(colors.yellow)
      local v = tonumber(read())
      if v then if v >= 0 then workingCFG.depth = v end end
      t.cat(19,10)
      t.w(workingCFG.depth)
      loop()
    elseif index == 6 then
      os.pullEvent("key_up")
      temp = oreMenu(workingCFG.ores, 1)
      if temp then workingCFG.ores = temp end
      cfgMenu(workingCFG, 6)
    elseif index == 7 then
      os.pullEvent("key_up")
      mainMenu(_cfgReturnIndex)
    elseif index == 8 then
      os.pullEvent("key_up")
      cfg = workingCFG
      saveCFG()
      mainMenu(_cfgReturnIndex)
    else -- just to be sure...
      index = 1
      loop()
    end
  end
  loop()
end

function oreMenuHelp()
  t.c()
  t.watc("Ore configuration help", 1, 1, colors.orange)
  t.cf(colors.white)
  t.wat("Navigate with up/down", 2, 3)
  t.wat("Switch page with left/right", 2, 4)
  t.wat("[Enter] to toggle a rule", 2, 5)
  t.wat("[A] to add a rule", 2, 6)
  t.wat("[R] to remove a rule", 2, 7)
  t.wat("[LShift] to move rule up", 2, 8)
  t.wat("[LCtrl] to move rule down", 2, 9)
  t.wat("[Q] to quit without saving", 2, 10)
  t.wat("[S] to save and quit", 2, 11)
  t.wat("Press [Enter] to continue ...", 2, 13)
  read()
end

function oreMenuAdd()
  t.c()
  t.watc("Ore configuration", 1, 1, colors.orange)
  t.watc("Add a new rule:", 2, 3, colors.white)
  t.cf(colors.yellow)
  s = ""
  while s == "" do
    t.cat(2,4)
    s = read()
  end
  return s
end

function shortOreName(s)
  return s
end

function oreMenu(workingOres, startIndex)
  t.c()
  t.watc("Ore configuration, 'h' for help", 1, 1, colors.orange)
  if workingOres.count == 0 then
    t.watc("No ores defined yet.", 1, 3, colors.yellow)
    local fin, event, key = false, nil, 0
    while not fin do
      event, key = os.pullEvent("key")
      if key == keys.h then fin = true
      elseif key == keys.a then fin = true
      elseif key == keys.q then fin = true
      elseif key == keys.s then fin = true end
    end
    os.pullEvent("key_up")
    if key == keys.h then
      oreMenuHelp()
      return oreMenu(workingOres, 1)
    elseif key == keys.a then
      local n,v,i = oreMenuAdd(), true, "1"
      workingOres.count = 1
      workingOres.names[i] = n
      workingOres.values[i] = v
      return oreMenu(workingOres, 1)
    else return false end
  else -- workingOres.count > 0
    if startIndex<1 then startIndex = 1
    elseif startIndex>workingOres.count then startIndex = workingOres.count end
    local maxLines = t.sizeY-3
    local pageCount = math.ceil(workingOres.count / maxLines)
    local currentPage = math.ceil(startIndex / maxLines)
    local indexDelta = maxLines * (currentPage-1)
    local linesOnThisPage = 0
    if currentPage < pageCount then
      linesOnThisPage = maxLines
    else
      linesOnThisPage = workingOres.count - maxLines * (pageCount-1)
    end
    local indexOnThisPage = (startIndex-1) % maxLines + 1

    for I=3,2+linesOnThisPage do
      local i = tostring(I+indexDelta-2)
      t.watc(shortOreName(workingOres.names[i]), 4, I, workingOres.values[i] and colors.lime or colors.red)
      if not term.isColor() then t.w(workingOres.values[i] and " T" or " F") end
    end

    term.setTextColor(colors.lightGray)
    t.cw("Page "..tostring(currentPage).." of "..tostring(pageCount), t.sizeY)

    local fin, event, key = false, nil, 0
    while not fin do
      t.watc(">", 2, indexOnThisPage+2, colors.cyan)
      event, key = os.pullEvent("key")
      t.wat(" ", 2, indexOnThisPage+2)

      if (key == keys.up) and (indexOnThisPage > 1)
      then indexOnThisPage = indexOnThisPage -1
      elseif (key == keys.down) and (indexOnThisPage < linesOnThisPage)
      then indexOnThisPage = indexOnThisPage +1
      elseif (key == keys.left) and (currentPage > 1) then fin = true
      elseif (key == keys.right) and (currentPage < pageCount) then fin = true
      elseif key == keys.enter then fin = true
      elseif key == keys.h then fin = true
      elseif key == keys.a then fin = true
      elseif key == keys.r then fin = true
      elseif (key == keys.leftShift) and (indexOnThisPage+indexDelta > 1) then fin = true
      elseif (key == keys.leftCtrl) and (indexOnThisPage+indexDelta < workingOres.count) then fin = true
      elseif key == keys.q then fin = true
      elseif key == keys.s then fin = true end
    end
    os.pullEvent("key_up")

    if key == keys.left then
      return oreMenu(workingOres, indexOnThisPage + indexDelta - maxLines)
    elseif key == keys.right then
      return oreMenu(workingOres, indexOnThisPage + indexDelta + maxLines)
    elseif key == keys.enter then
      local i = tostring(indexOnThisPage+indexDelta)
      workingOres.values[i] = not workingOres.values[i]
      return oreMenu(workingOres, indexOnThisPage + indexDelta)
    elseif key == keys.h then
      oreMenuHelp()
      return oreMenu(workingOres, indexOnThisPage + indexDelta)
    elseif key == keys.a then
      local n,v,i = oreMenuAdd(), true, tostring(workingOres.count+1)
      workingOres.count = workingOres.count +1
      workingOres.names[i] = n
      workingOres.values[i] = v
      return oreMenu(workingOres, workingOres.count)
    elseif key == keys.r then
      for i=indexOnThisPage+indexDelta, workingOres.count-1, 1 do
        workingOres.names[tostring(i)] = workingOres.names[tostring(i+1)]
        workingOres.values[tostring(i)] = workingOres.values[tostring(i+1)]
      end
      workingOres.names[tostring(workingOres.count)] = nil
      workingOres.values[tostring(workingOres.count)] = nil
      workingOres.count = workingOres.count -1
      return oreMenu(workingOres, indexOnThisPage+indexDelta)
    elseif key == keys.leftShift then
      local i = indexOnThisPage+indexDelta
      local n,v = workingOres.names[tostring(i)], workingOres.values[tostring(i)]
      workingOres.names[tostring(i)] = workingOres.names[tostring(i-1)]
      workingOres.values[tostring(i)] = workingOres.values[tostring(i-1)]
      workingOres.names[tostring(i-1)] = n
      workingOres.values[tostring(i-1)] = v
      return oreMenu(workingOres, indexOnThisPage+indexDelta-1)
    elseif key == keys.leftCtrl then
      local i = indexOnThisPage+indexDelta
      local n,v = workingOres.names[tostring(i)], workingOres.values[tostring(i)]
      workingOres.names[tostring(i)] = workingOres.names[tostring(i+1)]
      workingOres.values[tostring(i)] = workingOres.values[tostring(i+1)]
      workingOres.names[tostring(i+1)] = n
      workingOres.values[tostring(i+1)] = v
      return oreMenu(workingOres, indexOnThisPage+indexDelta+1)
    elseif key == keys.q then return false
    else return workingOres end
  end
end

function main()
  loadCFG()
  welcomeScreen()
  mainMenu(1)
  t.c()
end

main()
