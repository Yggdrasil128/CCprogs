version = "2.0.0 (WIP)"
--[[
CC Stripmine by Yggdrasil128

See 'https://github.com/Yggdrasil128/CCprogs/tree/master/stripmine'
for more information

Copyright (C) 2015-2016  Tim Taubitz (aka Yggdrasil128)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]

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

function checkModem(wired,wireless)
  local dirs = nil

  if turtle
  then dirs = {"left","right"}
  else dirs = {"left","right","top","bottom","front","back"} end

  local r = {}
  for i=1,#dirs do
    if peripheral.getType(dirs[i]) == "modem" then
      local isWireless = peripheral.call(dirs[i],"isWireless")
      if wireless and isWireless then
        r[#r+1] = dirs[i]
      elseif wired and not isWireless then
        r[#r+1] = dirs[i]
      end
    end
  end

  if #r > 0
  then return r
  else return false end
end

-- displays a simple welcome screen, waiting 25 ticks
function welcomeScreen()
  local s1 = "CC Stripmine v"..version
  local s2 = "Copyright (c)  2015 - 2016"
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
  t.watc("Main menu", 2, 3, colors.lime)

  local y = 5
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
    t.watc("[T]weaks...", 4, y, colors.white)
    term.setTextColor(colors.gray)
    t.wat("[", 4, y)
    t.wat("]", 6, y)
    y = y +1
    maxIndex = maxIndex +1
    actionList[maxIndex] = "tweaks"
    actionListRev["tweaks"] = maxIndex
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
    t.wat(">", 2, index+4)
    event, key = os.pullEvent("key")
    t.wat(" ", 2, index+4)

    if key == keys.enter then fin = true
    elseif (key == keys.up) and (index>1) then index = index - 1
    elseif (key == keys.down) and (index<maxIndex) then index = index + 1
    elseif key == keys.s then
      action = "settings"
      fin = true
    elseif key == keys.e then
      action = "exit"
      fin = true
    elseif key == keys.t then
      action = "tweaks"
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
    if action == "tweaks" then tweaksMenu(1)
    elseif action == "mine" then singleturtle()
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

  if checkModem(true,true) then
    mainOptions.rep = true
    mainOptions.host = true
    _cfgReturnIndex = 4
    if checkTurtle() then
      mainOptions.mine = true
      mainOptions.join = true
      _cfgReturnIndex = 6
    end
  elseif checkTurtle() then
    mainOptions.mine = true
    _cfgReturnIndex = 3
  else _cfgReturnIndex = 2 end
end

function cfgMenu(workingCFG, startIndex)
  t.c()
  t.watc("CC Stripmine v"..version, 1, 1, colors.orange)
  t.wc(" by Yggdrasil128", colors.lightGray)
  t.watc("Settings", 2, 3, colors.lime)

  t.cf(colors.white)
  t.wat("antiLagSleep", 4, 5)
  t.wat("fuelCheck", 4, 6)
  t.wat("startDist", 4, 7)
  t.wat("endDist", 4, 8)
  t.wat("depth", 4, 9)
  t.wat("[O]res ...", 4, 10) -- adjust returning index, too
  t.wat("[A]bort ...", 4, 11)
  t.wat("[S]ave ...", 4, 12)

  term.setTextColor(colors.gray)
  for i=10,12,1 do
    t.wat("[", 4, i)
    t.wat("]", 6, i)
  end

  t.cf(colors.lightGray)
  for i=5,9,1 do t.wat("=", 17, i) end

  t.cf(colors.yellow)
  t.wat(workingCFG.antiLagSleep, 19, 5)
  t.wat(workingCFG.fuelCheck and "true" or "false", 19, 6)
  t.wat(workingCFG.startDist, 19, 7)
  t.wat(workingCFG.endDist, 19, 8)
  t.wat(workingCFG.depth, 19, 9)

  local maxIndex = 8
  local index = startIndex
  loop = function()
    fin = false
    while not fin do
      t.watc(">", 2, index+4, colors.cyan)
      event, key = os.pullEvent("key")
      t.wat(" ", 2, index+4)
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
      t.cat(19,5)
      t.cf(colors.yellow)
      local v = tonumber(read())
      if v then if v >= 0 then workingCFG.antiLagSleep = v end end
      t.cat(19,5)
      t.w(workingCFG.antiLagSleep)
      loop()
    elseif index == 2 then
      workingCFG.fuelCheck = not workingCFG.fuelCheck
      t.watc(workingCFG.fuelCheck and "true " or "false", 19, 6, colors.yellow)
      loop()
    elseif index == 3 then
      t.cat(19,7)
      t.cf(colors.yellow)
      local v = tonumber(read())
      if v then if (v >= 0) and (v <= workingCFG.endDist) then workingCFG.startDist = v end end
      t.cat(19,7)
      t.w(workingCFG.startDist)
      loop()
    elseif index == 4 then
      t.cat(19,8)
      t.cf(colors.yellow)
      local v = tonumber(read())
      if v then if v >= workingCFG.startDist then workingCFG.endDist = v end end
      t.cat(19,8)
      t.w(workingCFG.endDist)
      loop()
    elseif index == 5 then
      t.cat(19,9)
      t.cf(colors.yellow)
      local v = tonumber(read())
      if v then if v >= 0 then workingCFG.depth = v end end
      t.cat(19,9)
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

function tweaksMenu(startIndex)
  t.c()
  t.watc("CC Stripmine v"..version, 1, 1, colors.orange)
  t.wc(" by Yggdrasil128", colors.lightGray)
  t.watc("Tweaks", 2, 3, colors.lime)

  local y = 5
  local maxIndex = 0
  local actionList = {}
  local actionListRev = {}
  if turtle then
    t.watc("[A]dd ore to config...", 4, y, colors.white)
    term.setTextColor(colors.gray)
    t.wat("[", 4, y)
    t.wat("]", 6, y)
    y = y +1
    maxIndex = maxIndex +1
    actionList[maxIndex] = "add"
    actionListRev["add"] = maxIndex
  end
  local hasModem = checkModem(true,true)
  if hasModem then
    t.watc("Ping: [P]ing", 4, y, colors.white)
    term.setTextColor(colors.gray)
    t.wat("[", 10, y)
    t.wat("]", 12, y)
    y = y +1
    maxIndex = maxIndex +1
    actionList[maxIndex] = "pingp"
    actionListRev["pingp"] = maxIndex

    t.watc("Ping: [H]ost", 4, y, colors.white)
    term.setTextColor(colors.gray)
    t.wat("[", 10, y)
    t.wat("]", 12, y)
    y = y +1
    maxIndex = maxIndex +1
    actionList[maxIndex] = "pingh"
    actionListRev["pingh"] = maxIndex
  end
  do
    t.watc("[B]ack to main menu", 4, y, colors.white)
    term.setTextColor(colors.gray)
    t.wat("[", 4, y)
    t.wat("]", 6, y)
    y = y +1
    maxIndex = maxIndex +1
    actionList[maxIndex] = "back"
    actionListRev["back"] = maxIndex
  end

  t.cf(colors.cyan)
  local index = startIndex
  local fin = false
  local action = ""
  local event, key = "", 0
  while not fin do
    t.wat(">", 2, index+4)
    event, key = os.pullEvent("key")
    t.wat(" ", 2, index+4)

    if key == keys.enter then fin = true
    elseif (key == keys.up) and (index>1) then index = index - 1
    elseif (key == keys.down) and (index<maxIndex) then index = index + 1
    elseif key == keys.b then
      action = "back"
      fin = true
    elseif key == keys.a and turtle then
      action = "add"
      fin = true
    elseif key == keys.p and hasModem then
      action = "pingp"
      fin = true
    elseif key == keys.h and hasModem then
      action = "pingh"
      fin = true
    end
  end
  os.pullEvent("key_up")
  if action == "" then action = actionList[index] end
  index = actionListRev[action]

  if action == "back" then return nil
  else
    if action == "add" then tweakAddOre()
    elseif action == "pingp" then tweakPingClient()
    elseif action == "pingh" then tweakPingHost()
    end
    tweaksMenu(index)
  end
end

tm = {} -- turtle movement
td = {} -- turtle dig
ti = {} -- turtle inspect
if turtle then
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

  td.front = turtle.dig
  td.up = turtle.digUp
  td.down = turtle.digDown

  ti.front = turtle.inspect
  ti.up = turtle.inspectUp
  ti.down = turtle.inspectDown
end

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

function tweakAddOre()
  t.c()
  t.watc("CC Stripmine v"..version, 1, 1, colors.orange)
  t.wc(" by Yggdrasil128", colors.lightGray)
  t.watc("Add ore to config", 2, 3, colors.lime)

  local b,v = ti.front()

  if not b then
    t.watc("No ore found.", 2, 5, colors.yellow)
    t.watc("This turtle needs to be", 2, 7, colors.white)
    t.wat("facing an ore directly", 2, 8)
    t.wat("to add it to the config.", 2, 9)
    term.setTextColor(colors.lightGray)
    t.wat("Press [Enter] to continue...", 2, 11)
    read()
  else
    local ore = v.name..":"..tostring(v.metadata)
    local snippets = {}
    snippets[1] = ore
    for i=#ore,1,-1 do
      if ore:sub(i,i) == ":" then
        snippets[#snippets+1] = ore:sub(1,i-1)
      end
    end
    t.watc("Press [Left]/[Right] to switch rules", 2, 6, colors.lightGray)
    t.watc("Select a value for this rule:", 2, 8, colors.white)
    t.watc("[T]rue", 4, 10, colors.lime)
    t.watc("[F]alse", 4, 11, colors.red)
    t.watc("[A]bort", 4, 12, colors.brown)
    t.cf(colors.gray)
    for i=10,12 do
      t.wat("[", 4, i)
      t.wat("]", 6, i)
    end
    local indexM, indexS = 1, 1
    local fin, event, key = false, nil, 0
    while not fin do
      t.cat(2, 5)
      t.wc(snippets[indexS], colors.lightBlue)
      t.watc(">", 2, indexM+9, colors.cyan)
      event, key = os.pullEvent("key")
      t.wat(" ", 2, indexM+9)

      if key == keys.up and indexM > 1 then indexM = indexM -1
      elseif key == keys.down and indexM < 3 then indexM = indexM +1
      elseif key == keys.left and indexS > 1 then indexS = indexS -1
      elseif key == keys.right and indexS < #snippets then indexS = indexS +1
      elseif key == keys.enter then fin = true
      elseif key == keys.t then
        indexM = 1
        fin = true
      elseif key == keys.f then
        indexM = 2
        fin = true
      elseif key == keys.a then
        indexM = 3
        fin = true
      end
    end
    os.pullEvent("key_up")
    if indexM == 3 then return nil end
    cfg.ores.count = cfg.ores.count +1
    cfg.ores.names[tostring(cfg.ores.count)] = snippets[indexS]
    cfg.ores.values[tostring(cfg.ores.count)] = (indexM == 1)
    saveCFG()
    osc = {}
  end
  return nil
end

function tweakPingClient()
  t.c()
  t.watc("CC Stripmine v"..version, 1, 1, colors.orange)
  t.wc(" by Yggdrasil128", colors.lightGray)
  t.watc("Ping: Client", 2, 3, colors.lime)

  local modems = checkModem(true,true)
  if modems then
    for i=1,#modems do
      rednet.open(modems[i])
    end
    t.watc("Scanning for servers...", 2, 5, colors.lightBlue)
    local serverListRaw = {rednet.lookup("CSMping")}
    local serverList = {}
    for i=1,#serverListRaw do
      if tonumber(serverListRaw[i]) then
        serverList[#serverList+1] = tonumber(serverListRaw[i])
      end
    end

    if #serverList > 0 then
      t.watc("Select server: ", 2, 5, colors.lightBlue)
      t.wc("Abort with [A]", colors.lightGray)

      selectServer = function(list, startIndex)
        if startIndex < 1 then startIndex = 1 end
        if startIndex > #list then startIndex = #list end
        local maxLines = t.sizeY-6
        local pageCount = math.ceil(#list / maxLines)
        local currentPage = math.ceil(#list / maxLines)
        local indexDelta = maxLines * (currentPage-1)
        local linesOnThisPage = 0
        if currentPage < pageCount then
          linesOnThisPage = maxLines
        else
          linesOnThisPage = #list - maxLines * (pageCount-1)
        end
        local indexOnThisPage = (startIndex-1) % maxLines + 1

        t.cf(colors.white)
        for I=6,5+linesOnThisPage do
          local i = I+indexDelta-5
          t.cat(4,I)
          t.w(tostring(list[i]))
        end

        term.setTextColor(colors.lightGray)
        t.cw("Page "..tostring(currentPage).." of "..tostring(pageCount), t.sizeY)

        local fin, event, key = false, nil, 0
        while not fin do
          t.watc(">", 2, indexOnThisPage+5, colors.cyan)
          event, key = os.pullEvent("key")
          t.wat(" ", 2, indexOnThisPage+5)

          if (key == keys.up) and (indexOnThisPage > 1)
          then indexOnThisPage = indexOnThisPage -1
          elseif (key == keys.down) and (indexOnThisPage < linesOnThisPage)
          then indexOnThisPage = indexOnThisPage +1
          elseif (key == keys.left) and (currentPage > 1) then fin = true
          elseif (key == keys.right) and (currentPage < pageCount) then fin = true
          elseif key == keys.enter then fin = true
          elseif key == keys.a then fin = true end
        end
        os.pullEvent("key_up")

        if key == keys.left then
          return selectServer(list, indexOnThisPage+indexDelta-maxLines)
        elseif key == keys.right then
          return selectServer(list, indexOnThisPage+indexDelta+maxLines)
        elseif key == keys.enter then
          return list[indexOnThisPage+indexDelta]
        elseif key == keys.a then
          return false
        else
          return selectServer(list, indexOnThisPage+indexDelta)
        end
      end

      local server = selectServer(serverList,1)
      if not server then return nil end

      t.c()
      t.watc("CC Stripmine v"..version, 1, 1, colors.orange)
      t.wc(" by Yggdrasil128", colors.lightGray)
      t.watc("Ping: Client", 2, 3, colors.lime)
      t.watc("Pinging "..tostring(server).."...", 2, 5, colors.lightBlue)

      rednet.send(server, "ping", "CSMping")
      local p1, p2, p3 = rednet.receive("CSMping",5)
      sleep(0.5)

      if p1
      then t.watc("Pong received.", 2, 6, colors.lime)
      else t.watc("Timeout.", 2, 6, colors.red) end

      t.watc("Press [Enter] to continue...", 2, 8, colors.lightGray)
      read()
    else -- no servers
      t.watc("No servers found.", 2, 7, colors.red)
      t.watc("Press [Enter] to continue...", 2, 8, colors.lightGray)
      read()
    end

    for i=1,#modems do
      rednet.close(modems[i])
    end
  else -- no modem
    t.watc("No modem connected.", 2, 5, colors.red)
    t.watc("Press [Enter] to continue...", 2, 6, colors.lightGray)
    read()
  end
end

function tweakPingHost()
  t.c()
  t.watc("CC Stripmine v"..version, 1, 1, colors.orange)
  t.wc(" by Yggdrasil128", colors.lightGray)
  t.watc("Ping: Server", 2, 3, colors.lime)
  t.watc("Modem status:", 2, 5, colors.lightBlue)
  t.watc("Wired:", 4, 6, colors.white) -- 14
  t.watc("Offline", 14, 6, colors.red)
  t.watc("Wireless:", 4, 7, colors.white) -- 14
  t.watc("Offline", 14, 7, colors.red)
  t.watc("Server:", 2, 9, colors.lightBlue) -- 18
  t.watc("Status:", 4, 10, colors.white)
  t.watc("Offline", 12, 10, colors.red)
  t.watc("Received pings:", 4, 11, colors.white)
  t.watc("n/a", 20, 11, colors.lightGray)
  t.watc("Press [Enter] to stop and quit...", 1, 13, colors.lightGray)

  local modems, modems_count = {}, 0
  modems = checkModem(true,false) -- wired
  if modems then
    t.watc("Starting", 14, 6, colors.yellow)
    for i=1,#modems do
      parallel.waitForAll(function() rednet.open(modems[i]) end, function() sleep(0.5) end )
    end
    t.watc("Online  ", 14, 6, colors.lime)
    modems_count = modems_count + #modems
  end
  modems = checkModem(false,true) -- wireless
  if modems then
    t.watc("Starting", 14, 7, colors.yellow)
    for i=1,#modems do
      parallel.waitForAll(function() rednet.open(modems[i]) end, function() sleep(0.5) end )
    end
    t.watc("Online  ", 14, 7, colors.lime)
    modems_count = modems_count + #modems
  end

  if modems_count > 0 then
    t.watc("Starting", 12, 10, colors.yellow)
    parallel.waitForAll(function() rednet.host("CSMping",tostring(os.getComputerID())) end, function() sleep(0.5) end )
    t.watc("Online", 12, 10, colors.lime)
    t.watc(", ID: ", 18, 10, colors.white)
    t.wc(tostring(os.getComputerID()), colors.cyan)

    t.watc("0  ", 20, 11, colors.green)

    local ping_count = 0
    local event, p1, p2, p3, p4, p5
    while true do
      event, p1, p2, p3, p4, p5 = os.pullEvent()

      if event == "key_up" and p1 == keys.enter then break
      elseif event == "rednet_message" and p3 == "CSMping" then
        rednet.send(p1, "pong", "CSMping")
        ping_count = ping_count +1
        t.watc(tostring(ping_count), 20, 11, colors.green)
      end
    end

    rednet.unhost("CSMping",tostring(os.getComputerID()))

    modems = checkModem(true,true)
    for i=1,#modems do
      rednet.close(modems[i])
    end
  end
end

vanilla_ores = {}
vanilla_ores["minecraft:coal_ore"] = true
vanilla_ores["minecraft:iron_ore"] = true
vanilla_ores["minecraft:lapis_ore"] = true
vanilla_ores["minecraft:redstone_ore"] = true
vanilla_ores["minecraft:gold_ore"] = true
vanilla_ores["minecraft:diamond_ore"] = true
vanilla_ores["minecraft:emerald_ore"] = true
vanilla_ores["minecraft:quartz_ore"] = true
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
  if snippets[#snippets] == "minecraft" and not vanilla_ores[snippets[2]] then
    snippets[#snippets] = nil
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
  add("Never dig straight up!")
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
    t.watc(s, t.sizeX-#s+1, 5, colors.cyan)
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
    if cfg.antiLagSleep > 0 then os.sleep(cfg.antiLagSleep) end
  end
  singleturtleHome(cfg.depth,false)
end

--[[
prototype for a csmnet message:
table  msg
number msg.sender
number msg.seqNo
number msg.receiver
any    msg.data
]]
csmnet = {}
csmnet.thisClient = os.getComputerID()
csmnet.host = 0
csmnet.turtles = {} -- only for the host
csmnet.repeater = {}
csmnet.msgSeqNo = 0
csmnet.msgSeqs = {}
csmnet.init = function(host)
  csmnet.host = host
  csmnet.turtles = {}
  csmnet.repeater = {}
  csmnet.msgSeqNo = 0
  csmnet.msgSeqs = {}
end
csmnet.addTurtle = function(id)
  local found = 0
  for i=1, #csmnet.turtles do
    if csmnet.turtles[i].name == id and csmnet.turtles[i].connected then
      found = i
      break
    end
  end
  if found == 0 then
    local t = {}
    t.name = id
    t.connected = true
    csmnet.turtles[#csmnet.turtles+1] = t
    csmnet.msgSeqs[id] = 0
    found = #csmnet.turtles
  end
  return found
end
csmnet.addRepeater = function(id)
  local found = 0
  for i=1, #csmnet.repeater do
    if csmnet.repeater[i].name == id and csmnet.repeater[i].connected then
      found = i
      break
    end
  end
  if found == 0 then
    local t = {}
    t.name = id
    t.connected = true
    csmnet.repeater[#csmnet.repeater+1] = t
    csmnet.msgSeqs[id] = 0
    found = #csmnet.repeater
  end
  return found
end
csmnet.removeTurtleByID = function(id)
  for i=1, #csmnet.turtles do
    if csmnet.turtles[i].name == id and csmnet.turtles[i].connected then
      csmnet.turtles[i].connected = false
      break
    end
  end
  csmnet.msgSeqs[id] = nil
end
csmnet.removeRepeaterByID = function(id)
  for i=1, #csmnet.repeater do
    if csmnet.repeater[i].name == id and csmnet.repeater[i].connected then
      csmnet.repeater[i].connected = false
      break
    end
  end
  csmnet.msgSeqs[id] = nil
end
csmnet.removeTurtleByNO = function(no)
  csmnet.turtles[no].connected = false
  csmnet.msgSeqs[csmnet.turtles[no].name] = nil
end
csmnet.removeRepeaterByNO = function(no)
  csmnet.repeater[no].connected = false
  csmnet.msgSeqs[csmnet.repeater[no].name] = nil
end
csmnet.isTurtle = function(id)
  local r = false
  for i=1, #csmnet.turtles do
    if csmnet.turtles[i].name == id and csmnet.turtles[i].connected then
      r = true
      break
    end
  end
  return r
end
csmnet.isRepeater = function(id)
  local r = false
  for i=1, #csmnet.repeater do
    if csmnet.repeater[i].name == id and csmnet.repeater[i].connected then
      r = true
      break
    end
  end
  return r
end
csmnet.isValidMsg = function(msg)
  if  type(msg) == "table"
  and type(msg.sender) == "number"
  and type(msg.seqNo) == "number"
  and type(msg.receiver) == "number"
  then return true
  else return false end
end
csmnet.isNewMsg = function(msg)
  if msg.sender == csmnet.thisClient then return false end
  if csmnet.msgSeqs[msg.sender] == nil then
    csmnet.msgSeqs[msg.sender] = msg.seqNo
    return true
  end
  if csmnet.msgSeqs[msg.sender] < msg.seqNo then
    csmnet.msgSeqs[msg.sender] = msg.seqNo
    return true
  end
  return false
end
csmnet.send = function(rec, data)
  csmnet.msgSeqNo = csmnet.msgSeqNo +1
  -- craft the message
  msg = {}
  msg.sender = csmnet.thisClient
  msg.seqNo = csmnet.msgSeqNo
  msg.receiver = tonumber(rec)
  msg.data = data
  -- send msg to rec
  rednet.send(rec, msg, "CSMnet")
  -- send msg to all rep
  for i=1, #csmnet.repeater do
    if csmnet.repeater[i].connected then
      rednet.send(csmnet.repeater[i].name, msg, "CSMnet")
    end
  end
end
-- #############################################################################################################################################################
function multiturtleJoin()
  t.c()
  t.watc("CC Stripmine v"..version, 1, 1, colors.orange)
  t.wc(" by Yggdrasil128", colors.lightGray)
  t.watc("MultiTurtle: Join", 2, 3, colors.lime)

  local modems = checkModem(true,true)
  for i=1,#modems do
    rednet.open(modems[i])
  end
  t.watc("Scanning for hosts...", 2, 5, colors.lightBlue)
  local serverListRaw = {rednet.lookup("CSMhost")}
  local serverList = {}
  for i=1,#serverListRaw do
    if tonumber(serverListRaw[i]) then
      serverList[#serverList+1] = tonumber(serverListRaw[i])
    end
  end

  local repeaterListRaw = {rednet.lookup("CSMrepeat")}
  for i=1,#repeaterListRaw do
    if tonumber(repeaterListRaw[i]) then
      serverList[#serverList+1] = tonumber(repeaterListRaw[i])
    end
  end

  --[[
  network info table (nit) structure:
  table    nit
  number   nit.host
  [number] nit.repeater
  ]]
  hosts = {}
  repeater = {}
  local hasHost = function(s)
    local r = false
    for j=1, #hosts do
      if s == hosts[j] then
        r = true
        break
      end
    end
    return r
  end
  for i=1, #serverList do
    rednet.send(serverList[i], "info", "CSMinfo")
    local _, nit, __ = rednet.receive("CSMinfo", 5)
    if type(nit) == "table" and not hasHost(nit.host) then
      hosts[#hosts+1] = nit.host
      repeater[nit.host] = nit.repeater
    end
  end

  if #hosts == 0 then
    t.watc("No hosts found.", 2, 7, colors.red)
    t.watc("Press [Enter] to continue...", 2, 8, colors.lightGray)
    read()
    return nil
  end
  t.watc("Select host: ", 2, 5, colors.lightBlue)
  t.wc("Abort with [A]", colors.lightGray)
  selectServer = function(list, startIndex)
    if startIndex < 1 then startIndex = 1 end
    if startIndex > #list then startIndex = #list end
    local maxLines = t.sizeY-6
    local pageCount = math.ceil(#list / maxLines)
    local currentPage = math.ceil(#list / maxLines)
    local indexDelta = maxLines * (currentPage-1)
    local linesOnThisPage = 0
    if currentPage < pageCount then
      linesOnThisPage = maxLines
    else
      linesOnThisPage = #list - maxLines * (pageCount-1)
    end
    local indexOnThisPage = (startIndex-1) % maxLines + 1
      t.cf(colors.white)
    for I=6,5+linesOnThisPage do
      local i = I+indexDelta-5
      t.cat(4,I)
      t.w(tostring(list[i]))
    end
    term.setTextColor(colors.lightGray)
    t.cw("Page "..tostring(currentPage).." of "..tostring(pageCount), t.sizeY)
    local fin, event, key = false, nil, 0
    while not fin do
      t.watc(">", 2, indexOnThisPage+5, colors.cyan)
      event, key = os.pullEvent("key")
      t.wat(" ", 2, indexOnThisPage+5)

      if (key == keys.up) and (indexOnThisPage > 1)
      then indexOnThisPage = indexOnThisPage -1
      elseif (key == keys.down) and (indexOnThisPage < linesOnThisPage)
      then indexOnThisPage = indexOnThisPage +1
      elseif (key == keys.left) and (currentPage > 1) then fin = true
      elseif (key == keys.right) and (currentPage < pageCount) then fin = true
      elseif key == keys.enter then fin = true
      elseif key == keys.a then fin = true end
    end
    os.pullEvent("key_up")

    if key == keys.left then
      return selectServer(list, indexOnThisPage+indexDelta-maxLines)
    elseif key == keys.right then
      return selectServer(list, indexOnThisPage+indexDelta+maxLines)
    elseif key == keys.enter then
      return list[indexOnThisPage+indexDelta]
    elseif key == keys.a then
      return false
    else
      return selectServer(list, indexOnThisPage+indexDelta)
    end
  end

  local host = selectServer(hosts,1)
  if not host then return nil end

  t.c()
  t.watc("CC Stripmine v"..version, 1, 1, colors.orange)
  t.wc(" by Yggdrasil128", colors.lightGray)
  t.watc("MultiTurtle: Join", 2, 3, colors.lime)

  t.watc("Connecting to host "..tostring(host).."...", 1, 5, colors.lightGray)
  sleep(1)

  -- try to connect to the network
  local connected = false
  -- try connecting directly to the host
  rednet.send(host, "join", "CSMhost")
  local _, turtleID, __ = rednet.receive("CSMhost", 2)
  if type(turtleID) == "number" then
    connected = true
  else
    -- try connecting to one of the repeater
    for i=1, #repeater[host] do
      local rep = repeater[host][i]
      rednet.send(rep, "join", "CSMrepeat")
      _, turtleID, __ = rednet.receive("CSMrepeat", 2)
      if type(turtleID) == "number" then
        connected = true
        break
      end
    end
  end
  if not connected then
    t.watc("Unable to connect.", 1, 6, colors.red)
    t.watc("Press [Enter] to continue...", 1, 7, colors.cyan)
    read()
    return nil
  end

  csmnet.init(host)
  for i=1, #repeater[host] do
    csmnet.addRepeater(repeater[host][i])
  end

  local announceSeqNo = 0

  t.watc("Connected.", 1, 6, colors.green)
  t.watc("Assigned turtle ID is "..tostring(turtleID)..".", 1, 7, colors.green)
  t.watc("Press [D] at any time to disconnect.", 1, 8, colors.cyan)
  t.watc("Waiting for network...", 1, 9, colors.lightGray)

  local fin = false
  repeat
    local e, p1, p2, p3, p4, p5 = os.pullEvent()

    if e == "key_up" and p1 == keys.d then -- disconnect
      turtleID = nil
      csmnet.send(csmnet.host, "unjoin")
      fin = true
    elseif e == "rednet_message" then
      if p3 == "CSMannounce" and type(p2) == "table" and p2.seqNo > announceSeqNo then
        announceSeqNo = p2.seqNo
        if p2.type == "repeat" then
          csmnet.addRepeater(p2.value)
        elseif p2.type == "unrepeat" then
          csmnet.removeRepeaterByID(p2.value)
        end
      end
    end
  until fin
  if not turtleID then return nil end

  for i=1,#modems do
    rednet.close(modems[i])
  end
end
-- #############################################################################################################################################################
function multiturtleRepeat()
  t.c()
  t.watc("CC Stripmine v"..version, 1, 1, colors.orange)
  t.wc(" by Yggdrasil128", colors.lightGray)
  t.watc("MultiTurtle: Repeat", 2, 3, colors.lime)

  local modems = checkModem(true,true)
  for i=1,#modems do
    rednet.open(modems[i])
  end
  t.watc("Scanning for hosts...", 2, 5, colors.lightBlue)
  local serverListRaw = {rednet.lookup("CSMhost")}
  local serverList = {}
  for i=1,#serverListRaw do
    if tonumber(serverListRaw[i]) then
      serverList[#serverList+1] = tonumber(serverListRaw[i])
    end
  end

  local repeaterListRaw = {rednet.lookup("CSMrepeat")}
  for i=1,#repeaterListRaw do
    if tonumber(repeaterListRaw[i]) then
      serverList[#serverList+1] = tonumber(repeaterListRaw[i])
    end
  end

  --[[
  network info table (nit) structure:
  table    nit
  number   nit.host
  [number] nit.repeater
  ]]
  hosts = {}
  repeater = {}
  local hasHost = function(s)
    local r = false
    for j=1, #hosts do
      if s == hosts[j] then
        r = true
        break
      end
    end
    return r
  end
  for i=1, #serverList do
    rednet.send(serverList[i], "info", "CSMinfo")
    local _, nit, __ = rednet.receive("CSMinfo", 5)
    if type(nit) == "table" and not hasHost(nit.host) then
      hosts[#hosts+1] = nit.host
      repeater[nit.host] = nit.repeater
    end
  end

  if #hosts == 0 then
    t.watc("No hosts found.", 2, 7, colors.red)
    t.watc("Press [Enter] to continue...", 2, 8, colors.lightGray)
    read()
    return nil
  end
  t.watc("Select host: ", 2, 5, colors.lightBlue)
  t.wc("Abort with [A]", colors.lightGray)
  selectServer = function(list, startIndex)
    if startIndex < 1 then startIndex = 1 end
    if startIndex > #list then startIndex = #list end
    local maxLines = t.sizeY-6
    local pageCount = math.ceil(#list / maxLines)
    local currentPage = math.ceil(#list / maxLines)
    local indexDelta = maxLines * (currentPage-1)
    local linesOnThisPage = 0
    if currentPage < pageCount then
      linesOnThisPage = maxLines
    else
      linesOnThisPage = #list - maxLines * (pageCount-1)
    end
    local indexOnThisPage = (startIndex-1) % maxLines + 1
      t.cf(colors.white)
    for I=6,5+linesOnThisPage do
      local i = I+indexDelta-5
      t.cat(4,I)
      t.w(tostring(list[i]))
    end
    term.setTextColor(colors.lightGray)
    t.cw("Page "..tostring(currentPage).." of "..tostring(pageCount), t.sizeY)
    local fin, event, key = false, nil, 0
    while not fin do
      t.watc(">", 2, indexOnThisPage+5, colors.cyan)
      event, key = os.pullEvent("key")
      t.wat(" ", 2, indexOnThisPage+5)

      if (key == keys.up) and (indexOnThisPage > 1)
      then indexOnThisPage = indexOnThisPage -1
      elseif (key == keys.down) and (indexOnThisPage < linesOnThisPage)
      then indexOnThisPage = indexOnThisPage +1
      elseif (key == keys.left) and (currentPage > 1) then fin = true
      elseif (key == keys.right) and (currentPage < pageCount) then fin = true
      elseif key == keys.enter then fin = true
      elseif key == keys.a then fin = true end
    end
    os.pullEvent("key_up")

    if key == keys.left then
      return selectServer(list, indexOnThisPage+indexDelta-maxLines)
    elseif key == keys.right then
      return selectServer(list, indexOnThisPage+indexDelta+maxLines)
    elseif key == keys.enter then
      return list[indexOnThisPage+indexDelta]
    elseif key == keys.a then
      return false
    else
      return selectServer(list, indexOnThisPage+indexDelta)
    end
  end

  local host = selectServer(hosts,1)
  if not host then return nil end

  t.c()
  t.watc("CC Stripmine v"..version, 1, 1, colors.orange)
  t.wc(" by Yggdrasil128", colors.lightGray)
  t.watc("MultiTurtle: Repeat", 2, 3, colors.lime)

  t.watc("Connecting to host "..tostring(host).."...", 1, 5, colors.lightGray)
  sleep(1)

  -- try to connect to the network
  local connected = false
  -- try connecting directly to the host
  rednet.send(host, "repeat", "CSMhost")
  local _, repeaterID, __ = rednet.receive("CSMhost", 2)
  if type(repeaterID) == "number" then
    connected = true
  else
    -- try connecting to one of the repeater
    for i=1, #repeater[host] do
      local rep = repeater[host][i]
      rednet.send(rep, "repeat", "CSMrepeat")
      _, repeaterID, __ = rednet.receive("CSMrepeat", 2)
      if type(repeaterID) == "number" then
        connected = true
        break
      end
    end
  end
  if not connected then
    t.watc("Unable to connect.", 1, 6, colors.red)
    t.watc("Press [Enter] to continue...", 1, 7, colors.cyan)
    read()
    return nil
  end

  csmnet.init(host)
  for i=1, #repeater[host] do
    csmnet.addRepeater(repeater[host][i])
  end

  rednet.host("CSMrepeat", tostring(csmnet.thisClient))

  t.watc("Connected.", 1, 6, colors.green)
  t.watc("Assigned repeater ID is "..tostring(repeaterID)..".", 1, 7, colors.green)
  t.watc("Press [D] at any time to disconnect,", 1, 8, colors.cyan)
  t.watc("but this may causes your network", 1, 9, colors.cyan)
  t.watc("to stop working.", 1, 10, colors.cyan)
  t.watc("Repeating network messages...", 1, 11, colors.white)
  t.watc("Message count:", 1, 12, colors.lightGray)

  msgCount = 0
  updateStatusScreen = function()
    t.watc(tostring(msgCount), 16, 12, colors.white)
  end
  local incMsgCount = function()
    msgCount = msgCount +1
    updateStatusScreen()
  end
  updateStatusScreen()

  local announceSeqNo = 0

  local networkOpen = true

  local fin = false
  repeat
    local e, p1, p2, p3, p4, p5 = os.pullEvent()

    if e == "key_up" and p1 == keys.d then -- disconnect
      repeaterID = nil
      csmnet.send(csmnet.host, "unrepeat")
      fin = true
    elseif e == "rednet_message" then
      if p3 == "CSMinfo" then
        local nit = {}
        nit.host = csmnet.host
        nit.repeater = {}
        nit.repeater[1] = csmnet.thisClient
        for i=1, #csmnet.repeater do
          if csmnet.repeater[i].connected then
            nit.repeater[#nit.repeater+1] = csmnet.repeater[i].name
          end
        end
        rednet.send(p1, nit, "CSMinfo")
        incMsgCount()
      elseif p3 == "CSMannounce" and type(p2) == "table" and p2.seqNo > announceSeqNo then
        announceSeqNo = p2.seqNo
        rednet.broadcast(p2, "CSMannounce")
        incMsgCount()
        if p2.type == "repeat" then
          csmnet.addRepeater(p2.value)
        elseif p2.type == "unrepeat" then
          csmnet.removeRepeaterByID(p2.value)
        elseif p2.type == "close" then
          networkOpen = false
          rednet.unhost("CSMrepeat", tostring(csmnet.thisClient))
        end
      elseif p3 == "CSMrepeat" and networkOpen then
        if p2 == "join" then -- new turtle
          local client = p1
          local msg = {}
          msg.text = "join"
          msg.value = client
          csmnet.send(csmnet.host, msg)
          local _, reply, __
          repeat
            _, reply, __ = rednet.receive("CSMnet", 2)
          until reply == nil or (csmnet.isValidMsg(reply) and csmnet.isNewMsg(reply) and reply.receiver == csmnet.thisClient)
          incMsgCount()
          if type(reply) == "table" and type(reply.data) == "number" then
            rednet.send(client, reply.data, "CSMrepeat")
            incMsgCount()
          end
        elseif p2 == "repeat" then -- new repeater
          local client = p1
          local msg = {}
          msg.text = "repeat"
          msg.value = client
          csmnet.send(csmnet.host, msg)
          local _, reply, __
          repeat
            _, reply, __ = rednet.receive("CSMnet", 2)
          until reply == nil or (csmnet.isValidMsg(reply) and csmnet.isNewMsg(reply) and reply.receiver == csmnet.thisClient)
          incMsgCount()
          if type(reply) == "table" and type(reply.data) == "number" then
            rednet.send(client, reply.data, "CSMrepeat")
            incMsgCount()
          end
        end
      elseif p3 == "CSMnet" and csmnet.isValidMsg(p2) and csmnet.isNewMsg(p2) then
        rednet.send(p2.receiver, p2, "CSMnet")
        for i=1, #csmnet.repeater do
          if csmnet.repeater[i].connected then
            rednet.send(csmnet.repeater[i].name, p2, "CSMnet")
          end
        end
        incMsgCount()
      end
    end
  until fin
  if networkOpen then
    rednet.host("CSMrepeat", tostring(csmnet.thisClient))
    networkOpen = false
  end
  if not repeaterID then return nil end

  for i=1,#modems do
    rednet.close(modems[i])
  end
end
-- #############################################################################################################################################################
function multiturtleHost()
  t.c()
  t.watc("CC Stripmine v"..version, 1, 1, colors.orange)
  t.wc(" by Yggdrasil128", colors.lightGray)
  t.watc("MultiTurtle: Host", 2, 3, colors.lime)
  sleep(1)

  t.watc("Preparing MultiTurtle network host...", 1, 5, colors.lightGray)
  sleep(1)

  csmnet.init(csmnet.thisClient)
  announceSeqNo = 0

  t.watc("Opening modems...", 1, 6, colors.lightGray)
  local modems, modems_count = {}, 0
  modems = checkModem(true,true) -- both wiredand wireless
  for i=1,#modems do
      parallel.waitForAll(function() rednet.open(modems[i]) end, function() sleep(0.5) end )
  end

  t.watc("Registering and opening host service...", 1, 7, colors.lightGray)
  parallel.waitForAll(function() rednet.host("CSMhost",tostring(os.getComputerID())) end, function() sleep(2) end )

  t.watc("Ready. ", 1, 8, colors.green)
  t.wc("Hostname: "..tostring(os.getComputerID()), colors.lime)
  t.watc("Waiting for incoming connections...", 1, 9, colors.white)
  t.watc("Status: ", 1, 10, colors.orange)
  t.wc("Turtles: ", colors.lightGray)
  t.wc("0   ", colors.white) -- x=18
  t.wc("Repeater: ", colors.lightGray)
  t.wc("0  ", colors.white)  -- x=32
  t.watc("Press [Enter] once finished.", 1, 11, colors.cyan)

  local updateStatusScreen = function()
    local n = 0
    for i=1, #csmnet.turtles do
      if csmnet.turtles[i].connected then
        n = n +1
      end
    end
    t.watc(tostring(n), 18, 10, colors.white)
    while term.getCursorPos() < 21 do
      t.w(" ")
    end
    n = 0
    for i=1, #csmnet.repeater do
      if csmnet.repeater[i].connected then
        n = n +1
      end
    end
    t.watc(tostring(n), 32, 10, colors.white)
    while term.getCursorPos() < 35 do
      t.w(" ")
    end
  end

  local fin = false
  repeat
    local e, p1, p2, p3, p4, p5 = os.pullEvent()

    if e == "key_up" and p1 == keys.enter then fin = true
    elseif e == "rednet_message" then
      if p2 == "info" and p3 == "CSMinfo" then
        local nit = {}
        nit.host = csmnet.host
        nit.repeater = {}
        for i=1, #csmnet.repeater do
          if csmnet.repeater[i].connected then
            nit.repeater[#nit.repeater+1] = csmnet.repeater[i].name
          end
        end
        rednet.send(p1, nit, "CSMinfo")
      elseif p2 == "join" and p3 == "CSMhost" then
        local seqNo = csmnet.addTurtle(p1)
        rednet.send(p1, seqNo, "CSMhost")
        updateStatusScreen()
      elseif p2 == "repeat" and p3 == "CSMhost" then
        -- announce the new repeater to the network
        announceSeqNo = announceSeqNo +1
        local amsg = {}
        amsg.type = "repeat"
        amsg.value = p1
        amsg.seqNo = announceSeqNo
        rednet.broadcast(amsg, "CSMannounce")
        -- accept the new repeater
        local seqNo = csmnet.addRepeater(p1)
        rednet.send(p1, seqNo, "CSMhost")
        updateStatusScreen()
      elseif p3 == "CSMnet" and csmnet.isValidMsg(p2) and csmnet.isNewMsg(p2) then
        if p2.data == "unjoin" and csmnet.isTurtle(p2.sender) then
          csmnet.removeTurtleByID(p2.sender)
          updateStatusScreen()
        elseif p2.data == "unrepeat" and csmnet.isRepeater(p2.sender) then
          csmnet.removeRepeaterByID(p2.sender)
          -- announce the disconnecting repeater to the network
          announceSeqNo = announceSeqNo +1
          local amsg = {}
          amsg.type = "unrepeat"
          amsg.value = p2.sender
          amsg.seqNo = announceSeqNo
          rednet.broadcast(amsg, "CSMannounce")
          updateStatusScreen()
        elseif type(p2.data) == "table" and p2.data.text == "join" then
          local seqNo = csmnet.addTurtle(p2.data.value)
          csmnet.send(p2.sender, seqNo)
          updateStatusScreen()
        elseif type(p2.data) == "table" and p2.data.text == "repeat" then
          -- accept the new repeater
          local seqNo = csmnet.addRepeater(p2.data.value)
          csmnet.send(p2.sender, seqNo)
          -- announce the new repeater to the network
          sleep(0.1)
          announceSeqNo = announceSeqNo +1
          local amsg = {}
          amsg.type = "repeat"
          amsg.value = p2.data.value
          amsg.seqNo = announceSeqNo
          rednet.broadcast(amsg, "CSMannounce")
          updateStatusScreen()
        end
      end
    end
  until fin

  t.watc("Closing host service...", 1, 12, colors.lightGray)
  parallel.waitForAll(function() rednet.unhost("CSMhost",tostring(os.getComputerID())) end, function() sleep(1) end )
  announceSeqNo = announceSeqNo +1
  local amsg = {}
  amsg.type = "close"
  amsg.seqNo = announceSeqNo
  rednet.broadcast(amsg, "CSMannounce")

  t.watc("Network established and ready.", 1, 13, colors.green)
  sleep(2)

  read()
  for i=1,#modems do
    rednet.close(modems[i])
  end
end
-- #############################################################################################################################################################
function init()
  math.randomseed(os.time()*1000)
  loadCFG()
  setMainOptions()
end

function exit()
  t.c()
  local x,y = term.getSize()
  x = math.ceil(x/2 -4)
  y = math.ceil(y/2)
  t.cp(x,y)
  textutils.slowPrint("Goodbye.",10)
  sleep(0.2)
  t.c()
end

function main()
  if not checkCCVersion() then
    t.errorScreen("CC out of date!", {"ComputerCraft is out of date.", "", "You need at least version 1.74", "to run CC Stripmine."})
  end
  parallel.waitForAll(welcomeScreen, function() updateStatus = checkForUpdate() end, init)
  mainMenu(1)
  exit()
end

main()
