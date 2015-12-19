version = "2.0.0 (WIP)"

-- default configuration, do not change
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
t.w = term.write
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
  local x = math.ceil( (t.sizeX-#s) / 2)
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
t.errorScreen = function(title, lines)
  t.c()
  local sX,sY = term.getSize()
  local startY = math.ceil((sY-2-#lines)/2)
  t.cwc(title, startY, colors.red)
  t.cf(colors.white)
  for i=1,#lines,1 do
    t.cw(lines[i],startY+i+1)
  end
  t.cp(1,sY)
  error()
end

function checkCCVersion()
  if _CC_VERSION == nil then return false end
  if tonumber(_CC_VERSION) == nil then return false end
  return tonumber(_CC_VERSION) >= 1.74
end

--[[ error codes
0: all ok
1: no turtle
2: inv full
3: no pickaxe
--]]
function checkTurtle()
  if turtle == nil then return false, 1 end

  local i = 1
  while i < 17 do
    if i == 17 then break end
    if turtle.getItemCount(i) == 0 then break end
    i = i +1
  end
  if i == 17 then return false, 2 end
  turtle.select(i)

  local checkR = function()
    turtle.equipRight()
    local item = turtle.getItemDetail()
    turtle.equipRight()
    if item == nil then return false end
    if item.name ~= "minecraft:diamond_pickaxe" then return false end
    return true
  end

  local checkL = function()
    turtle.equipLeft()
    local item = turtle.getItemDetail()
    turtle.equipLeft()
    if item == nil then return false end
    if item.name ~= "minecraft:diamond_pickaxe" then return false end
    return true
  end

  if checkL() then
    return true, 0
  elseif checkR() then
    return true, 0
  else
    return false, 3
  end
end

function checkWireless()
  local dirs = nil

  if turtle
  then dirs = {"left","right"}
  else dirs = {"left","right","top","bottom","front","back"} end

  local r = false
  for i=1,#dirs do
    if peripheral.getType(dirs[i]) == "modem" then
      if peripheral.call(dirs[i],"isWireless") then
        r = dirs[i]
        break
      end
    end
  end

  return r
end

-- displays a simple welcome screen, waiting 25 ticks
function welcomeScreen()
  local s1 = "CC Stripmine v"..version
  local s2 = "Copyright (c)  2015"
  local s3 = "by Tim Taubitz (Yggdrasil128)"
  t.c()
  local x,y = term.getSize()
  t.watc(s1, math.floor((x-#s1)/2), math.floor((y-2)/2), colors.orange)
  t.watc(s2, math.floor((x-#s2)/2), math.floor((y-2)/2)+2, colors.lightGray)
  t.wat(s3, math.floor((x-#s3)/2), math.floor((y-2)/2)+3)
  term.setTextColor(colors.gray)
  t.cp(1,y)
  if x == 26 then
    for i = 1, x, 1 do
      term.write(".")
      os.sleep(0.05)
    end
  else
    for i = 1, x, 2 do
      term.write("..")
      os.sleep(0.05)
    end
  end
end

updateStatus = nil
update = nil
function checkForUpdate()
  if http == nil then return nil end
  local pastebinURL = "http://pastebin.com/raw/"
  local updateURL = "https://rawgit.com/Yggdrasil128/CCprogs/stripmine2wip/stripmine/versiontracker"
  if not http.checkURL(updateURL) then return nil end
  local get = http.get(updateURL)
  if get == nil then return nil end
  update = textutils.unserialize(get.readAll())
  get.close()
  if type(update) ~= "table" then return nil end
  if type(update.version) ~= "string" then return nil end
  if type(update.pastebinID) ~= "string" then return nil end
  if not http.checkURL(pastebinURL..update.pastebinID) then return nil end

  local parseVersion = function(s)
    r = {}
    r[1] = 0
    p = 1
    for i=1,#s,1 do
      local c = s:sub(i,i)
      if c == " " then break
      elseif c == "." then
        p = p +1
        r[p] = 0
      elseif type(tonumber(c)) == "number" then
        r[p] = 10*r[p] + tonumber(c)
      end
    end
    return r
  end

  local isNewer = function(v)
    local v0 = parseVersion(version)
    if #v ~= #v0 then
      for i=1,math.max(#v, #v0) do
        if v[i] == nil then v[i] = 0 end
        if v0[i] == nil then v0[i] = 0 end
      end
    end
    r = false
    for i=1,#v do
      if v[i] > v0[i] then
        r = true
        break
      elseif v[i] < v0[i] then
        r = false
        break
      end
    end
    return r
  end

  return isNewer(parseVersion(update.version))
end

-- a navigatable main menu
_cfgReturnIndex = 1
mainOptions = {}
function mainMenu(startIndex)
  t.c()
  t.watc("CC Stripmine v"..version, 1, 1, colors.orange)
  t.wc(" by Yggdrasil128", colors.lightGray)
  t.watc("Main menu", 1, 3, colors.lime)
  t.watc("Scroll with up/down, select with enter", 1, 4, colors.gray)

  local y = 6
  local maxIndex = 0
  local actionList = {}
  local actionListRev = {}
  if mainOptions.mine then
    t.watc("SingleTurtle: [M]ine", 4, y, colors.white)
    term.setTextColor(colors.gray)
    t.wat("[", 18, y)
    t.wat("]", 20, y)
    y = y +1
    maxIndex = maxIndex +1
    actionList[maxIndex] = "mine"
    actionListRev["mine"] = maxIndex
  end
  if mainOptions.join then
    t.watc("MultiTurtle:  [J]oin", 4, y, colors.white)
    term.setTextColor(colors.gray)
    t.wat("[", 18, y)
    t.wat("]", 20, y)
    y = y +1
    maxIndex = maxIndex +1
    actionList[maxIndex] = "join"
    actionListRev["join"] = maxIndex
  end
  if mainOptions.rep then
    t.watc("MultiTurtle:  [R]epeat", 4, y, colors.white)
    term.setTextColor(colors.gray)
    t.wat("[", 18, y)
    t.wat("]", 20, y)
    y = y +1
    maxIndex = maxIndex +1
    actionList[maxIndex] = "repeat"
    actionListRev["repeat"] = maxIndex
  end
  if mainOptions.host then
    t.watc("MultiTurtle:  [H]ost", 4, y, colors.white)
    term.setTextColor(colors.gray)
    t.wat("[", 18, y)
    t.wat("]", 20, y)
    y = y +1
    maxIndex = maxIndex +1
    actionList[maxIndex] = "host"
    actionListRev["host"] = maxIndex
  end
  do
    t.watc("[S]ettings...", 4, y, colors.white)
    term.setTextColor(colors.gray)
    t.wat("[", 4, y)
    t.wat("]", 6, y)
    y = y +1
    maxIndex = maxIndex +1
    actionList[maxIndex] = "settings"
    actionListRev["settings"] = maxIndex
  end
  do
    t.watc("[E]xit", 4, y, colors.white)
    term.setTextColor(colors.gray)
    t.wat("[", 4, y)
    t.wat("]", 6, y)
    y = y +1
    maxIndex = maxIndex +1
    actionList[maxIndex] = "exit"
    actionListRev["exit"] = maxIndex
  end

  if updateStatus == nil then
    t.watc("Can't check for updates.", 1, t.sizeY, colors.brown)
  elseif updateStatus == false then
    t.watc("No update available.", 1, t.sizeY, colors.green)
  else
    t.watc("Update available: "..update.version, 1, t.sizeY, colors.orange)
  end

  t.cf(colors.cyan)
  local index = startIndex
  local fin = false
  local action = ""
  local event, key = "", 0
  while not fin do
    t.wat(">", 2, index+5)
    event, key = os.pullEvent("key")
    t.wat(" ", 2, index+5)

    if key == keys.enter then fin = true
    elseif (key == keys.up) and (index>1) then index = index - 1
    elseif (key == keys.down) and (index<maxIndex) then index = index + 1
    elseif key == keys.s then
      action = "settings"
      fin = true
    elseif key == keys.e then
      action = "exit"
      fin = true
    elseif (key == keys.m) and mainOptions.mine then
      action = "mine"
      fin = true
    elseif (key == keys.j) and mainOptions.join then
      action = "join"
      fin = true
    elseif (key == keys.r) and mainOptions.rep then
      action = "repeat"
      fin = true
    elseif (key == keys.h) and mainOptions.host then
      action = "host"
      fin = true
    end
  end
  os.pullEvent("key_up")
  if action == "" then action = actionList[index] end
  index = actionListRev[action]

  if action == "settings" then cfgMenu(copyCFG(), 1)
  elseif action == "exit" then return nil
  else
    if action == "mine" then singleturtle()
    elseif action == "join" then multiturtleJoin()
    elseif action == "repeat" then multiturtleRepeat()
    elseif action == "host" then multiturtleHost() end
    mainMenu(index)
  end
end

function setMainOptions()
  mainOptions.mine = false
  mainOptions.join = false
  mainOptions.rep  = false
  mainOptions.host = false

  if checkWireless() then
    mainOptions.rep = true
    mainOptions.host = true
    _cfgReturnIndex = 3
    if checkTurtle() then
      mainOptions.mine = true
      mainOptions.join = true
      _cfgReturnIndex = 5
    end
  elseif checkTurtle() then
    mainOptions.mine = true
    _cfgReturnIndex = 2
  else _cfgReturnIndex = 1 end
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

  local maxIndex = 8
  local index = startIndex
  loop = function()
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
      local temp = oreMenu(workingCFG.ores, 1)
      if temp then workingCFG.ores = temp end
      cfgMenu(workingCFG, 6)
    elseif index == 7 then
      os.pullEvent("key_up")
      mainMenu(_cfgReturnIndex)
    elseif index == 8 then
      os.pullEvent("key_up")
      cfg = workingCFG
      saveCFG()
      osc = {}
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

tm = {} -- turtle movement
tm.move = function()
  while not turtle.forward() do
    turtle.dig()
  end
end
tm.left = turtle.turnLeft
tm.right = turtle.turnRight
tm.turnAround = function()
  tm.right()
  tm.right()
end
tm.back = function()
  if not turtle.back() then
    tm.turnAround()
    tm.move()
    tm.turnAround()
  end
end
tm.up = function()
  while not turtle.up() do
    turtle.digUp()
  end
end
tm.down = function()
  while not turtle.down() do
    turtle.digDown()
  end
end
tm.moveX = function(x)
  for i=1,x,1 do
    tm.move()
  end
end
tm.backX = function(x)
  tm.turnAround()
  tm.moveX(x)
  tm.turnAround()
end

td = {} -- turtle dig
td.front = turtle.dig
td.up = turtle.digUp
td.down = turtle.digDown

ti = {} -- turtle inspect
ti.front = turtle.inspect
ti.up = turtle.inspectUp
ti.down = turtle.inspectDown

isOre = {}
isOre.front = function()
  return checkOre(ti.front())
end
isOre.up = function()
  return checkOre(ti.up())
end
isOre.down = function()
  return checkOre(ti.down())
end

osc = {} -- ore search cache
function checkOre(b, d)
  if not b then return false end
  local ore = d.name..":"..tostring(d.metadata)
  if osc[ore] ~= nil then return osc[ore] end
  -- cache miss, now do a full cfg search for the ore
  local snippets = {}
  snippets[1] = ore
  for i=#ore,1,-1 do
    if ore:sub(i,i) == ":" then
      snippets[#snippets+1] = ore:sub(1,i-1)
    end
  end
  local r = nil;
  for i=1,#snippets do
    for j=1,cfg.ores.count do
      if cfg.ores.names[tostring(j)] == snippets[i] then
        r = cfg.ores.values[tostring(j)]
        break
      end
    end
    if r ~= nil then break end
  end
  if r == nil then r = false end
  -- add result to cache and return result
  osc[ore] = r
  return r
end

function processVein()
  if isOre.up() then
    td.up()
    tm.up()
    processVein()
    tm.down()
  end
  if isOre.down() then
    td.down()
    tm.down()
    processVein()
    tm.up()
  end
  if isOre.front() then
    td.front()
    tm.move()
    processVeinIgnoreBack()
    tm.back()
  end
  tm.left() -- left
  if isOre.front() then
    td.front()
    tm.move()
    processVeinIgnoreBack()
    tm.back()
  end
  tm.left() -- back
  if isOre.front() then
    td.front()
    tm.move()
    processVeinIgnoreBack()
    tm.back()
  end
  tm.left() -- right
  if isOre.front() then
    td.front()
    tm.move()
    processVeinIgnoreBack()
    tm.back()
  end
  tm.left() -- front
end

function processVeinIgnoreBack()
  if isOre.up() then
    td.up()
    tm.up()
    processVein()
    tm.down()
  end
  if isOre.down() then
    td.down()
    tm.down()
    processVein()
    tm.up()
  end
  if isOre.front() then
    td.front()
    tm.move()
    processVeinIgnoreBack()
    tm.back()
  end
  tm.left()
  if isOre.front() then
    td.front()
    tm.move()
    processVeinIgnoreBack()
    tm.back()
  end
  tm.turnAround()
  if isOre.front() then
    td.front()
    tm.move()
    processVeinIgnoreBack()
    tm.back()
  end
  tm.left()
end

function dropInv()
  tm.right()
  for i=16,1,-1 do
    turtle.select(i)
    if turtle.getItemCount() > 0 then
      while not turtle.drop() do
        sleep(1)
      end
    end
  end
  tm.left()
end

function refuel(softCap)
  if turtle.getFuelLevel() >= math.min(turtle.getFuelLimit(), softCap) then return nil end
  tm.left()
  while turtle.getFuelLevel() < math.min(turtle.getFuelLimit(), softCap) do
    turtle.suck(1)
    turtle.refuel()
    if turtle.getItemCount() > 0 then
      tm.turnAround()
      while not turtle.drop() do
        sleep(1)
      end
      tm.turnAround()
    end
  end
  tm.right()
end

function singleturtleHome(s, continue)
  tm.backX(s)
  dropInv()
  if cfg.fuelCheck then refuel(cfg.depth*100) end
  if continue then tm.moveX(s) end
end

splashes = {} -- some splashes to display during mining
splashes_delimiter = "#"
splash = ""
do
  local add = function(s)
    splashes[#splashes+1] = s
  end
  --   ....!....1....!....2....!....3....!....4....!....5.
  --                                         #           #
  add("Time to mine!")
  add("Keep calm and mine ores.")
  add("Never waste your diamonds on a hoe.")
  add("Diggy, diggy...")
  add("Creepers gonna creep")
  add("Oink! ... No.")
  add("I came, I saw, I mined.")
  add("In the end,#you know it's all just blocks.")
  add("Mr. Steve,#pick down this cobblestone!")
  add("A creeper a day#keeps the diamonds away.")
  add("I mine, therefore, I craft.")
  add("Mining is the law of life.")
  add("Huh? Was that a 'shhhhh' behind you?")
  add("You will miss 100%#of the ores you don't mine.")
  add("Keep calm and#HOLY, A CREEPER, DONT KEEP CALM, RUN!")
  add("Creepers, they just want hugs.")
  add("In the End, it doesn't even matter.")
  add("What's redstone again?")
  add("One step closer to the diamonds...")
  add("The Dark Mine rises")
  add("Never dig straight down!")
  add("Never dig straight up, neither!")
  add("The thing is,#there's only six sides to a block!")
  add("Bacon and eggs!")
  add("Wait a second, creepers are dangerous?!")
  add("The pick, the ore and the player")
  add("They see me creepin', they freakin'.")
  add("They should make a Minecraft movie,#it'll become a blockbuster!")
  add("One does not simply#stop playing Minecraft.")
  add("If life gives you lemons,#you must have some sort#of fruit mod installed.")
  add("Keep calm and craft on.")
  add("If the Minecraft world is infinite,#then how can the sun rotate around it?")
  add("Keep calm and sshhhh BOOM!")
  add("Minecraft won't start? Dinkleberg!")
end

function getSplash()
  splash = splashes[math.random(#splashes)]
  local s,f = 1, nil
  local parts = {}
  repeat
    f = string.find(splash,splashes_delimiter,s)
    if f == nil then
      parts[#parts+1] = splash:sub(s)
    else
      parts[#parts+1] = splash:sub(s,f-1)
      s = f+1
    end
  until f == nil
  return parts
end

function occInvSlots() -- occupied inventory slots
  local r = 0
  for i=1,16 do
    if turtle.getItemCount(i) > 0 then
      r = r +1
    end
  end
  return r
end

function singleturtle()
  t.c()
  t.watc("CC Stripmine v"..version, 1, 1, colors.orange)
  t.wc(" by Yggdrasil128", colors.lightGray)
  t.watc("Mining strip...", 2, 3, colors.white)
  dropInv()
  refuel(cfg.depth*100)
  for i = 1, cfg.depth do
    t.watc(tostring(i).." of "..tostring(cfg.depth), 1, 5, colors.green)
    local s = tostring(math.floor(100*i/cfg.depth)) .. " %"
    t.watc(s, t.sizeX-#s+1, 5, colors.lime)
    local b = math.floor(t.sizeX*i/cfg.depth)
    t.cp(1,6)
    t.cb(colors.lime)
    for j=1,b do t.w(" ") end
    t.cb(colors.black)
    if (i%5) == 0 or i==1 then
      local parts = getSplash()
      t.cf(colors.lightGray)
      for j=10,13 do
        t.cat(1,j)
      end
      for j=1,#parts do
        t.wat(parts[j], 1, t.sizeY+j-#parts)
      end
    end
    if (occInvSlots() >= 14) or (turtle.getFuelLevel() < math.min(turtle.getFuelLimit(), cfg.depth*100)) then
      singleturtleHome(i-1,true)
    end
    td.front()
    tm.move()
    processVeinIgnoreBack()
  end
  singleturtleHome(cfg.depth,false)
end

function multiturtleJoin()
  t.m("j",colors.white)
  read()
end

function multiturtleRepeat()
  t.m("r",colors.white)
  read()
end

function multiturtleHost()
  t.m("h",colors.white)
  read()
end

function init()
  loadCFG()
  setMainOptions()
end

function main()
  math.randomseed(os.time()*1000)
  if not checkCCVersion() then
    t.errorScreen("CC out of date!", {"ComputerCraft is out of date.", "", "You need at least version 1.74", "to run CC Stripmine."})
  end
  parallel.waitForAll(welcomeScreen, function() updateStatus = checkForUpdate() end, init)
  mainMenu(1)
  t.c()
end

main()
