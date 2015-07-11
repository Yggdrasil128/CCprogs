-- CC Brainfuck
-- by Yggdrasil128
version = "1.3"

-- See 'https://github.com/Yggdrasil128/CCprogs/tree/master/brainfuck'
-- for more information

-- ######################################
-- begin of user defined settings
cfg = {}

-- number of cells
cfg.cellCount = 256

-- width of every cell in bit
cfg.cellWidth = 8

-- output data as ascii char?
-- cellWidth has to be set to 8 to allow this
cfg.asciiOut = true

-- allow cell value overflow/underflow?
cfg.cellValueOverflow = false

-- allow cell index overflow/underflow?
cfg.cellIndexOverflow = false

-- do fuel checks?
-- disable this if you have disabled fuel usage
-- in the ComputerCraft configs
cfg.fuelCheck = true

-- end of user defined settings
-- ######################################

-- begin of program code

local args = { ... }

print("CC Brainfuck v"..version)
print("by Yggdrasil128")
print("")

function getOSVersionFloat()
  local s = os.version()
  return tonumber(s:sub(9))
end

if getOSVersionFloat() < 1.64 then
  if term.isColor() then term.setTextColor(colors.red) end
  print("ComputerCraft out of date!")
  print("")
  print("To run CC Brainfuck")
  print("CraftOS 1.64 or higher is needed.")
  print("You are running "..os.version())
  print("")
  error("program canceled")
end

if type(cfg.cellCount) ~= "number" then
  if term.isColor() then term.setTextColor(colors.red) end
  print("Config error!")
  print("Invalid value for cfg.cellCount:")
  print("Expected number, but got "..type(cfg.cellCount))
  print("")
  error("program canceled")
elseif cfg.cellCount < 1 then
  print("Config error!")
  print("Invalid value for cfg.cellCount:")
  print("Value must be at least 1, but got "..tostring(cfg.cellCount))
  print("")
  error("program canceled")
else cfg.cellCount = math.floor(cfg.cellCount) end

if type(cfg.cellWidth) ~= "number" then
  if term.isColor() then term.setTextColor(colors.red) end
  print("Config error!")
  print("Invalid value for cfg.cellWidth:")
  print("Expected number, but got "..type(cfg.cellWidth))
  print("")
  error("program canceled")
elseif cfg.cellWidth < 1 then
  print("Config error!")
  print("Invalid value for cfg.cellWidth:")
  print("Value must be at least 1, but got "..tostring(cfg.cellWidth))
  print("")
  error("program canceled")
else cfg.cellWidth = math.floor(cfg.cellWidth) end

if type(cfg.asciiOut) ~= "boolean" then
  if term.isColor() then term.setTextColor(colors.red) end
  print("Config error!")
  print("Invalid value for cfg.asciiOut:")
  print("Expected boolean, but got "..type(cfg.asciiOut))
  print("")
  error("program canceled")
end

if type(cfg.cellValueOverflow) ~= "boolean" then
  if term.isColor() then term.setTextColor(colors.red) end
  print("Config error!")
  print("Invalid value for cfg.cellValueOverflow:")
  print("Expected boolean, but got "..type(cfg.cellValueOverflow))
  print("")
  error("program canceled")
end

if type(cfg.cellIndexOverflow) ~= "boolean" then
  if term.isColor() then term.setTextColor(colors.red) end
  print("Config error!")
  print("Invalid value for cfg.cellIndexOverflow:")
  print("Expected boolean, but got "..type(cfg.cellIndexOverflow))
  print("")
  error("program canceled")
end

if type(cfg.fuelCheck) ~= "boolean" then
  if term.isColor() then term.setTextColor(colors.red) end
  print("Config error!")
  print("Invalid value for cfg.fuelCheck:")
  print("Expected boolean, but got "..type(cfg.fuelCheck))
  print("")
  error("program canceled")
end

if cfg.cellWidth ~= 8 then cfg.asciiOut = false end

id = {}
id.wool = "minecraft:wool"
id.stairs = "minecraft:oak_stairs"
id.inc = 5
id.dec = 14
id.incIndex = 0
id.decIndex = 15
id.loopSet = false
id.loopStart = 0
id.loopEnd = 0
id.write = "minecraft:torch"
id.read = "minecraft:standing_sign"
id.stop = "minecraft:obsidian"

function setLoop(startDir)
  if startDir == 0 then
    id.loopStart = 0
    id.loopEnd = 1
    return true
  end
  if startDir == 1 then
    id.loopStart = 1
    id.loopEnd = 0
    return true
  end
  if startDir == 2 then
    id.loopStart = 2
    id.loopEnd = 3
    return true
  end
  if startDir == 3 then
    id.loopStart = 3
    id.loopEnd = 2
    return true
  end
  return false
end

cells = {}
for i=1,cfg.cellCount do cells[i] = 0 end
index = 1

loopWidth = 0

stopped = false

function doInc()
  cells[index] = cells[index] + 1
  if (cells[index] == math.pow(2,cfg.cellWidth)) then
    if cfg.cellValueOverflow
    then cells[index] = 0
    else
      if term.isColor()
      then term.setTextColor(colors.red) end
      print("")
      print("cells element overflow at index "..index.."!")
      print("Set cfg.cellValueOverflow to true")
      print("to disable this error.")
      print("")
      error("program canceled")
    end
  end
end

function doDec()
  cells[index] = cells[index] - 1
  if (cells[index] == -1) then
    if cfg.cellValueOverflow
    then cells[index] = math.pow(2,cfg.cellWidth) - 1
    else
      if term.isColor()
      then term.setTextColor(colors.red) end
      print("")
      print("cells element underflow at index "..index.."!")
      print("Set cfg.cellValueOverflow to true")
      print("to disable this error.")
      print("")
      error("program canceled")
    end
  end
end

function doIncIndex()
  if index == cfg.cellCount then
    if cfg.cellIndexOverflow then index = 1 else
      if term.isColor() then term.setTextColor(colors.red) end
      print("")
      print("cells index overflow!")
      print("Set cfg.cellIndexOverflow to true")
      print("to disable this error")
      print("")
      error("program canceled")
    end
  else index = index + 1 end
end

function doDecIndex()
  if index == 1 then
    if cfg.cellIndexOverflow then index = cfg.cellCount else
      if term.isColor() then term.setTextColor(colors.red) end
      print("")
      print("cells index underflow!")
      print("Set cfg.cellIndexOverflow to true")
      print("to disable this error")
      print("")
      error("program canceled")
    end
  else index = index - 1 end
end

function doLoopStart()
  if not id.loopSet then
    local b,fp = turtle.inspectDown()
    id.loopSet = setLoop(fp.metadata)
    if id.loopSet then loopWidth = loopWidth + 1 end
  else loopWidth = loopWidth + 1 end
end

function doLoopEnd()
  if loopWidth == 0 then
    if term.isColor() then term.setTextColor(colors.red) end
    print("")
    print("Syntax error: unexpected loop end!")
    print("")
    error("program canceled")
  end
  if cells[index] ~= 0 then
    local l = 0
    while l >= 0 do
      while not turtle.back() do sleep(0.05) end
      local b,fp = turtle.inspectDown()
      if b then
        if fp.name == id.stairs then
          if fp.metadata == id.loopEnd then l = l + 1
          elseif fp.metadata == id.loopStart then l = l - 1 end
        end
      end
    end
  else loopWidth = loopWidth - 1 end
end

function doWrite()
  if cfg.asciiOut then
    write(string.char(cells[index]))
  else
    if term.getCursorPos() > 1 then write(",") end
    write(tostring(cells[index]))
  end
end

function doRead()
  if term.getCursorPos() > 1 then print("") end
  write("input: ")
  local input = read()
  if (input:sub(1,1) == ":") and (#input > 1) then
    local int = tonumber(input:sub(2))
    if int == nil then
      print("Invalid input, try again:")
      doRead()
    elseif int >= math.pow(2,cfg.cellWidth) then
      print("Input too big, try again:")
      doRead()
    elseif int < 0 then
      print("No negative numbers allowed, try again:")
      doRead()
    else cells[index] = int end
  else
    local int = input:byte()
    if int == nil then
      print("Invalid input, try again:")
      doRead()
    elseif int >= math.pow(2,cfg.cellWidth) then
      print("Input too big, try again:")
      doRead()
    else cells[index] = int end
  end
end

function doStop()
  stopped = true
end

function doIt()
  local b,fp = turtle.inspectDown()
  if b then
    if fp.name == id.wool then
      if fp.metadata == id.inc then doInc()
      elseif fp.metadata == id.dec then doDec()
      elseif fp.metadata == id.incIndex then doIncIndex()
      elseif fp.metadata == id.decIndex then doDecIndex() end
    elseif fp.name == id.stairs then
      if not id.loopSet then doLoopStart()
      elseif fp.metadata == id.loopStart then doLoopStart()
      elseif fp.metadata == id.loopEnd then doLoopEnd() end
    elseif fp.name == id.write then doWrite()
    elseif fp.name == id.read then doRead()
    elseif fp.name == id.stop then doStop() end
  end
end

function bf_standalone()
  local fuel = 0
  if cfg.fuelCheck then
    fuel = turtle.getFuelLevel()
    print("Starting with "..fuel.." fuel.")
    print("")
  end
  doIt()
  while not stopped do
    if cfg.fuelCheck then while fuel == 0 do
      if term.getCursorPos() > 1 then print("") end
      print("Turtle out of fuel.")
      write("Please put some fuel into the active slot, then press enter.")
      read()
      print("")
      turtle.refuel()
      fuel = turtle.getFuelLevel()
    end end
    if turtle.forward() then doIt() end
  end
end

function sub_return()
  print("Returning to program start...")
  turtle.turnRight()
  turtle.turnRight()
  while not turtle.detect() do turtle.forward() end
  turtle.turnRight()
  turtle.turnRight()
end

function sub_refuel()
  print("Refueling turtle...")
  local old = turtle.getSelectedSlot()
  local i = 1
  while (i <= 16) and (turtle.getFuelLevel() < turtle.getFuelLimit()) do
    turtle.select(i)
    turtle.refuel()
  end
  turtle.select(old)
  print("Turtle now has "..turtle.getFuelLevel().." fuel.")
end

function main()
  if type(args[1]) == "nil" then bf_standalone()
  elseif args[1] == "return" then sub_return()
  elseif args[1] == "refuel" then sub_refuel()
  elseif args[1] == "42" then print("The answer to life, the universe and everything")
  else
    if term.isColor() then term.setTextColor(colors.red) end
    print("Invalid program parameter!")
    print("See the wiki at GitHub for more information.")
    print("A link to the GitHub page is at the beginning of this program's file.")
  end
  if term.getCursorPos() > 1 then print("") end
end

main()
