version = "2.0.0"

-- some terminal functions with extra short names
t = {}
t.cp = function(x,y) -- setCursorPos
  term.setCursorPos(x,y)
end
t.cb = function(c) -- color Background
  if not term.isColor() then c = colors.black end
  term.setBackgroundColor(c)
end
t.cf = function(c) -- color Foreground
  if not term.isColor() then c = colors.white end
  term.setTextColor(c)
end
t.w = function(s) -- write
  term.write(s)
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

function welcomeScreen()
  s1 = "CC Stripmine v"..version
  s2 = "Copyright (c)  2015"
  s3 = "by Tim Taubitz (Yggdrasil128)"
  t.c()
  x,y = term.getSize()
  t.watc(s1, math.floor((x-string.len(s1))/2), math.floor((y-2)/2), colors.orange)
  t.watc(s2, math.floor((x-string.len(s2))/2), math.floor((y-2)/2)+2, colors.lightGray)
  t.wat(s3, math.floor((x-string.len(s3))/2), math.floor((y-2)/2)+3)
  os.sleep(2)
  t.c()
end

welcomeScreen()
