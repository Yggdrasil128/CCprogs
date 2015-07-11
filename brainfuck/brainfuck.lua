-- ComputerCraft Brainfuck Interpreter
-- by Yggdrasil128
version = "1.2.2"

-- See 'https://github.com/Yggdrasil128/CCprogs/tree/master/brainfuck'
-- for more information


-- begin of user defined settings
cfg = {}

-- number of elements in the stack
cfg.stackSize = 256

-- width of every stack element in bit
cfg.stackWidth = 8

-- output data as ascii char?
-- stackWidth has to be set to 8 to allow this
cfg.asciiOut = true

-- allow stack element value overflow/underflow?
cfg.stackElementOverflow = false

-- allow stack index overflow/underflow?
cfg.stackIndexOverflow = false

-- do fuel checks?
-- disable this if you have disabled fuel usage
-- in the ComputerCraft configs
cfg.fuelCheck = true

-- end of user defined settings


-- begin of program code

print("Computercraft Brainfuck Interpreter v"..version)
print("by Yggdrasil128")
print("")

if cfg.stackWidth ~= 8 then cfg.asciiOut = false end

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

stack = {}
for i=1,cfg.stackSize do stack[i] = 0 end
index = 1

loopWidth = 0

stopped = false

firstWrite = true

function doInc()
  stack[index] = stack[index] + 1
  if (stack[index] == math.pow(2,cfg.stackWidth)) then
    if cfg.stackElementOverflow
    then stack[index] = 0
    else
      if term.isColor()
      then term.setTextColor(colors.red) end
      print("")
      print("Stack element overflow at index "..index.."!")
      print("Set cfg.stackElementOverflow to true")
      print("to disable this error.")
      print("")
      error("program canceled")
    end
  end
end

function doDec()
  stack[index] = stack[index] - 1
  if (stack[index] == -1) then
    if cfg.stackElementOverflow
    then stack[index] = math.pow(2,cfg.stackWidth) - 1
    else
      if term.isColor()
      then term.setTextColor(colors.red) end
      print("")
      print("Stack element underflow at index "..index.."!")
      print("Set cfg.stackElementOverflow to true")
      print("to disable this error.")
      print("")
      error("program canceled")
    end
  end
end

function doIncIndex()
  if index == cfg.stackSize then
    if cfg.stackIndexOverflow then index = 1 else
      if term.isColor() then term.setTextColor(colors.red) end
      print("")
      print("Stack index overflow!")
      print("Set cfg.stackIndexOverflow to true")
      print("to disable this error")
      print("")
      error("program canceled")
    end
  else index = index + 1 end
end

function doDecIndex()
  if index == 1 then
    if cfg.stackIndexOverflow then index = cfg.stackSize else
      if term.isColor() then term.setTextColor(colors.red) end
      print("")
      print("Stack index underflow!")
      print("Set cfg.stackIndexOverflow to true")
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
  if stack[index] ~= 0 then
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
    write(string.char(stack[index]))
  else
    if not firstWrite then write(",") end
    write(tostring(stack[index]))
  end
end

function doRead()
  local x,y = term.getCursorPos()
  if x > 1 then print("") end
  write("input: ")
  local input = read()
  if input:sub(1,1) == ":" then
    local int = tonumber(input:sub(2))
    if int == nil then
      print("Invalid input, try again:")
      doRead()
    elseif int >= math.pow(2,cfg.stackWidth) then
      print("Input too big, try again:")
      doRead()
    else stack[index] = int end
  else
    local int = input:byte()
    if int == nil then
      print("Invalid input, try again:")
      doRead()
    else stack[index] = int end
  end
end

function doStop()
  stopped = true
end

function doIt()
  b,fp = turtle.inspectDown()
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

function main()
  if cfg.fuelCheck then
    local fuel = turtle.getFuelLevel()
    print("Starting with "..fuel.." fuel.")
    print("")
  end
  doIt()
  while not stopped do
    if cfg.fuelCheck then while fuel == 0 do
      print("")
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

main()