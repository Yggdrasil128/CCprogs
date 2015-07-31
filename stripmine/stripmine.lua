version = "1.2.1"
--[[
CC Stripmine by Yggdrasil128

See 'https://github.com/Yggdrasil128/CCprogs/tree/master/stripmine'
for more information

Copyright (C) 2015  Tim Taubitz (Yggdrasil128)

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

-----------------------------------------
-- begin of user defined settings
cfg = {}

-- maximum distance to stripmine
cfg.maxDist = 100

-- do fuel checks?
-- disable this if you have disabled fuel usage
-- in the ComputerCraft configs
cfg.fuelCheck = true


-----
ores = {}
add = function(s)
  ores[s] = true
end

-- define the ores you want to mine for here
add("minecraft:coal_ore")
add("minecraft:iron_ore")
add("minecraft:lapis_ore")
add("minecraft:redstone_ore")
add("minecraft:gold_ore")
add("minecraft:diamond_ore")
add("denseores")
add("BigReactors:YelloriteOre")
add("IC2:nlockOreUran")
add("ThermalFoundation:Ore:2") -- silver
add("ThermalFoundation:Ore:3") -- lead
add("ThermalFoundation:Ore:4") -- ferrous ore

-- end of user defined settings
-----------------------------------------

-- begin of program code

if term.isColor() then
  term.setTextColor(colors.orange)
  write("CC Stripmine ")
    term.setTextColor(colors.lightGray)
  print("v"..version)
  term.setTextColor(colors.gray)
  print("Copyright (c) 2015")
  print("Tim Taubitz (Yggdrasil128)")
  print("")
  term.setTextColor(colors.white)
else
  print("CC Stripmine v"..version)
  print("Copyright (c) 2015")
  print("Tim Taubitz (Yggdrasil128)")
  print("")
end


function exception(...)
  local args = {...}
  if term.isColor() then term.setTextColor(colors.red) end
  for i=1,#args do print(args[i]) end
  print("")
  error("program canceled")
end

function warning(...)
  local args = {...}
  if term.isColor() then term.setTextColor(colors.yellow) end
  for i=2,#args do print(args[i]) end
  print("")
  term.setTextColor(colors.white)
  local input = ""
  while input == "" do
    if args[1]
    then write("(c)ontinue, (a)bort, (t)erminate: ")
    else write("(c)ontinue, (t)erminate: ") end
    input = read()
    if (input ~= "c") and (input ~= "t") and ((input ~= "c") or not args[1]) then input = "" end
  end
  if input == "t" then exception()
  elseif input == "a" then
    pos.goto(0,0)
    pos.turn(pos.startF)
    exception()
  end
  los = nil
end

function checkCCVersion()
  if (function()
    local s = os.version()
    return tonumber(s:sub(9))
  end)() < 1.64 then exception("ComputerCraft out of date!","","To run CC Befunge","CraftOS 1.64 or higher is needed.","You are running "..os.version()) end
end

function checkTurtle()
  if not turtle then exception("This is not a turtle!","","Please run this program on a mining turtle.") end
end

function checkMiningTurtle()
  if (function ()
    local b,s = turtle.dig()
    return (s == "No tool to dig with")
  end)() then exception("This is not a mining turtle!","","Please equip this turtle with a pickaxe.") end
end

posX = 0

function checkFuel()
  if cfg.fuelCheck
  then return (turtle.getFuelLevel() > (posX+100))
  else return true end
end

function checkInventory()
  local b = false
  for i=1,16 do
    if turtle.getItemCount(i) == 0 then
      b = true
      break
    end
  end
  return b
end

function checkStatus()
  return (checkFuel() and checkInventory())
end

function move()
  while not turtle.forward() do
    turtle.dig()
    sleep(0.1)
  end
end

function moveBack()
  if not turtle.back() then
    turtle.turnRight()
    turtle.turnRight()
    move()
    turtle.turnRight()
    turtle.turnRight()
  end
end

function moveUp()
  while not turtle.up() do
    turtle.digUp()
    sleep(0.1)
  end
end

function moveDown()
  while not turtle.down() do
    turtle.digDown()
    sleep(0.1)
  end
end

function isOre(b,fp)
  if not b then return false end
  if ores[fp.name] then return true end
  if ores[fp.name..":"..tostring(fp.metadata)] then return true end
  i = string.find(fp.name,":")
  if not i then return false end
  if ores[fp.name:sub(1,i-1)] then return true end
  return false
end

function vein()
  if isOre(turtle.inspectUp()) then
    turtle.digUp()
    moveUp()
    veinBack()
    moveDown()
  end
  if isOre(turtle.inspectDown()) then
    turtle.digDown()
    moveDown()
    veinBack()
    moveUp()
  end
  if isOre(turtle.inspect()) then
    turtle.dig()
    move()
    vein()
    moveBack()
  end
  turtle.turnLeft()
  if isOre(turtle.inspect()) then
    turtle.dig()
    move()
    vein()
    moveBack()
  end
  turtle.turnRight()
  turtle.turnRight()
  if isOre(turtle.inspect()) then
    turtle.dig()
    move()
    vein()
    moveBack()
  end
  turtle.turnLeft()
end

function veinBack()
  if isOre(turtle.inspectUp()) then
    turtle.digUp()
    moveUp()
    veinBack()
    moveDown()
  end
  if isOre(turtle.inspectDown()) then
    turtle.digDown()
    moveDown()
    veinBack()
    moveUp()
  end
  if isOre(turtle.inspect()) then
    turtle.dig()
    move()
    vein()
    moveBack()
  end
  turtle.turnLeft()
  if isOre(turtle.inspect()) then
    turtle.dig()
    move()
    vein()
    moveBack()
  end
  turtle.turnLeft()
  if isOre(turtle.inspect()) then
    turtle.dig()
    move()
    vein()
    moveBack()
  end
  turtle.turnLeft()
  if isOre(turtle.inspect()) then
    turtle.dig()
    move()
    vein()
    moveBack()
  end
  turtle.turnLeft()
end

function returnToBase(stay)
  for i=1,posX do moveBack() end
  turtle.turnRight()
  for i=1,16 do
    turtle.select(i)
    if turtle.getItemCount() > 0 then
      while not turtle.drop() do
        print("Target inventory is full.")
        write("Please clear...")
        read()
      end
    end
  end
  turtle.turnLeft()
  if cfg.fuelCheck then
    turtle.turnLeft()
    turtle.select(1)
    while turtle.getFuelLevel() < turtle.getFuelLimit() do
      while not turtle.suck() do
        print("No more fuel in chest.")
        write("Please refill...")
        read()
      end
      local f = turtle.getFuelLevel()
      while not turtle.refuel(1) do
        turtle.turnRight()
        turtle.turnRight()
        while not turtle.drop() do
          print("Target inventory is full.")
          write("Please clear...")
          read()
        end
        turtle.turnLeft()
        turtle.turnLeft()
        while not turtle.suck() do
          print("No more fuel in chest.")
          write("Please refill...")
          read()
        end
      end
      f = math.floor((turtle.getFuelLimit() - turtle.getFuelLevel()) / (turtle.getFuelLevel() - f))
      while turtle.getFuelLevel() < turtle.getFuelLimit() do
        if not turtle.refuel(f > 64 and 64 or f) then break end
      end
      if turtle.refuel(0) then
        turtle.drop()
      else
        turtle.turnRight()
        turtle.turnRight()
        while not turtle.drop() do
          print("Target inventory is full.")
          write("Please clear...")
          read()
        end
        turtle.turnLeft()
        turtle.turnLeft()
      end
    end
    turtle.turnRight()
  end

  if not stay then
    for i=1,posX do move() end
  end
end

function main()
  checkCCVersion()
  checkTurtle()
  checkMiningTurtle()
  while posX < cfg.maxDist do
    if not checkStatus() then returnToBase(false) end
    turtle.dig()
    move()
    posX = posX + 1
    vein()
  end
  returnToBase(true)
end

main()
