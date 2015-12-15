version = "2.0.0 (WIP)"

cfg = {}
cfg.antiLagSleep = 0
cfg.fuelCheck = true
cfg.startDist = 0
cfg.endDist = 100
cfg.depth = 100
cfg.ores = {}

function loadCFG()
  if fs.exists("cfg.smc") then
    local f = fs.open("cfg.smc","r")
    local data = f.readAll()
    f.close()
    data = textutils.unserialize(data)
    if data == nil then return saveCFG()
    elseif type(data.antiLagSleep) ~= "number" then return saveCFG()
    elseif type(data.fuelCheck) ~= "boolean" then return saveCFG()
    elseif type(data.startDist) ~= "number" then return saveCFG()
    elseif type(data.endDist) ~= "number" then return saveCFG()
    elseif type(data.depth) ~= "number" then return saveCFG()
    elseif type(data.ores) ~= "table" then return saveCFG()
    else
      cfg.antiLagSleep = data.antiLagSleep
      cfg.fuelCheck = data.fuelCheck
      cfg.startDist = data.startDist
      cfg.endDist = data.endDist
      cfg.depth = data.depth
      cfg.ores = {}
      for k,v in pairs(data.ores) do
        if (type(k) == "string") and ( (type(v) == "boolean") or (type(v) == "nil") ) then cfg.ores[k] = v end
      end
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
  for k,v in pairs(cfg.ores) do
    ccfg.ores[k] = v
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
  t.wat("Settings", 4, 6) -- adjust _cfgReturnIndex, too
  t.wat("Exit", 4, 7)

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
    elseif (key == keys.down) and (index<maxIndex) then index = index + 1 end
  end
  os.pullEvent("key_up")

  if index == 1 then return cfgMenu(copyCFG(), 1)
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
  t.wat("[O]res ...", 4, 11) -- please change returning index, too
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
      workingCFG.ores = oreMenu(workingCFG.ores)
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

function oreMenu(workingOres)
  return workingOres
end

function main()
  loadCFG()
  welcomeScreen()
  mainMenu(1)
  t.c()
end

main()
