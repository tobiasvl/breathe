pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- breathe
-- by tobiasvl
function _init()
  fps_60 = false

  a_side = false

  gondola_x = -21
  gondola_y = 71
  gondola_a = 0

  if fps_60 then
    _update60 = gondola_update
  else
    _update = gondola_update
  end
  _draw = gondola_draw

  frame = 0
  turbulence = false
  box_appeared = false
  debug = true
  focus_rate = 0.01
  focus_win = 1
  breath = -1
  up = false
  focus = 0
  lasttime = time()
  dt = 0

  local object = {
    easeprop = 0,
    distance = 50,
    duration = 1,
    timeelapsed = 0,
    down = function(self, v)
      return ease(v, 0, self.distance, self.duration)
    end,
    up = function(self, v)
      return ease(v, self.distance, -self.distance, self.duration)
    end,
    still = function(self) end,
    new = function(self, o)
      o = o or {}
      setmetatable(o, self)
      self.__index = self
      return o
    end,
    bounce = function(self)
      if self.timeelapsed > self.duration then
        self.timeelapsed = 0
        if self.currentfunc == self.up then
          self.currentfunc = self.down
        elseif self.currentfunc == self.down then
          self.currentfunc = self.up
        end
      end
      self.easeprop = self:currentfunc(self.timeelapsed)
    end
  }

  particles = {}
  for _=1,32 do
    add(particles,{x=rnd(128),y=rnd(256),z=flr(rnd(3))})
  end

  feather = object:new{distance=50,duration=1}
  feather.currentfunc = feather.still

  box = object:new{distance=87,duration=3}
  box.currentfunc = box.down

  feather.y = feather.easeprop
  feather.v = 0

  feather_a = 0
  feather_d = false
end

function gondola_draw()
  if a_side then
    pal(9,14)
    pal(4,13)
    pal(1,4)
    pal(13,9)
  end

  cls(2)
  palt(0,false)
  palt(11,true)
  line(gondola_x+9,gondola_y-6,gondola_x+9,gondola_y,9)
  line(-19,68,121,-2,9)
  line(-20,68,120,-2,0)
  line(gondola_x+8,gondola_y-5,gondola_x+8,gondola_y,0)
  pset(gondola_x+7,gondola_y-5,0)

  if gondola_x < 52 then
    spr(7,gondola_x,gondola_y,3,2)
  else
    spr_r(7,gondola_x,gondola_y,gondola_a,3,2)
  end

  palt()
  spr(10,0,0,4,2)
  spr(32,0,128-12,4,2)
  spr(36,128-19,128-19,3,3)
--     print("breathe", 64 - (7*4)/2, 80,6)
--     print("press x", 64 - (7*4)/2, 100,6)
  if (debug) print(stat(1),0,0,stat(1) > 1 and 8 or 7)
end

function gondola_update()
  if gondola_x >= 52 then
    if not gondola_d then
      gondola_a-=1
    else
      gondola_a+=1
    end
    if gondola_a == -4 then
      gondola_d = true
    elseif gondola_a == 4 then
      gondola_d = false
    end
  else
    gondola_x += 2 / 15-- / 30
    gondola_y -= 1 / 15-- / 30
  end
 
  if btnp(5) then
    if fps_60 then
      _update60 = game_update
    else
      _update = game_update
    end
    _draw = game_draw
    pal()
  elseif btnp(4) then
    a_side = true
  end
end

function game_draw()
  --cls(focus >= 2 and 0 or 13)
  cls()

  for p in all(particles) do
    if (p.z < 2) circfill(p.x,p.y-64,p.z,6)
  end

  if debug then
    print(test1,0,106)
    print(test2,0,112)
    print(test3,0,116)
    print(test4,0,122)
  end
  if box_appeared and not win then
    local focus = min(focus, focus_win)
    local box_x = 31
    local box_y = box.easeprop+1+flr(focus)
    local box_xx = 100
    local box_xy = box.easeprop+40-1-flr(focus)
    fillp(0b0101010110101010.1)
    clip(box_x,box_y,box_xx-box_x,box_xy-box_y)
    spr(not win and not collide and turbulence and 80 or 0,64-(51/2),64-(14/2)+feather.y-5,7,2)
    rectfill(box_x,box_y,box_xx,box_xy,1)--collide and 7 or 14)
    fillp()
    clip()
    --rect(30,box.easeprop+flr(focus),30+70,box.easeprop+40-flr(focus),collide and 7 or 6)
    palt()
    if (not collide) pal(7,6)
    spr(39,box_x,box_y,4,3)
    --spr(39,30+1,box.easeprop+1+flr(focus),4,3)--collide and 7 or 14)
    spr(39,box_xx-31,box_xy-24,4,3,true,true)
    --spr(39,30+71-32,box.easeprop+40-flr(focus)-24,4,3,true,true)--collide and 7 or 14)
    pal()
  end
  palt(0,false)
  palt(11,true)
  --spr(not win and not collide and turbulence and 80 or 0,64-(51/2),64-(14/2)+feather.y,7,2)
  spr_r(not win and not collide and turbulence and 40 or 0,64-(51/2),64-(14/2)+feather.y,feather_a,7,2)
  if debug then
    print(stat(1),0,0,stat(1) > 1 and 8 or 7)
    print(focus,0,6)
    print(box.distance,0,12)
    print(collide,0,18)
  end

  for p in all(particles) do
    if (p.z >= 2) circfill(p.x,p.y-64,p.z,6)
  end
end

function game_update()
  if not feather_d then
    feather_a-=1
  else
    feather_a+=1
  end
  if feather_a == -4 then
    feather_d = true
  elseif feather_a == 4 then
    feather_d = false
  end

  if not box_appeared and feather.y <= -45 then
    box_appeared = true
  end

  if box_appeared then
    box.distance = 87-(focus*1.5)
    box.duration = mid(2.5, 2.5+(focus/10), 4)
  end

  up = btn(5)

  if win then
    particles = {}
  else
    frame += 1
    if frame % 7 == 0 and box_appeared then
      if turbulence then
        frame = 0
      end
      turbulence = not turbulence
    end

    if up then
      breath = mid(-1, breath + 0.1, 1)
      feather.y = mid(55, feather.y - breath, -57)
    else
      breath = mid(-1.5, breath - 0.1, 1)
      feather.y = mid(-57, feather.y - breath, 55)
    end
  end


  for p in all(particles) do
    local pd = fps_60 and 0.6 or 1.2
    if up then
      p.y-=pd * (p.z+1) / 3
    else
      p.y+=pd * (p.z+1) / 3
    end
    if (p.y >= 128 + 64) p.y -= 256
    if (p.y <= -64) p.y += 256
  end

--  if up and feather.currentfunc == feather.still then
--    feather.currentfunc = feather.up
--  end

  fy = 64-(14/2)+feather.y
  local by = box.easeprop+1
  local bxy = box.easeprop+40-1
  collide = box_appeared and fy > by and fy + 14 < bxy

  if collide then
    focus = min(focus_win, focus + focus_rate)
  else
    focus = max(0, focus - focus_rate)
  end

  if focus >= focus_win and collide and (fy > 54 and fy < 56) then
    win = true
  end

  t = time()
  dt = t - lasttime
  lasttime = t
  feather.timeelapsed += dt
  if (box_appeared) box.timeelapsed += dt

  --feather:bounce()
  if (box_appeared) box:bounce()
end
-->8
-- tweening
function spr_r(s,x,y,a,w,h)
  local colors={[0]=0}
  local transparent={}
  local addr=0x5f00
  for a=0,15 do
    local new_color=peek(addr+a)
    colors[a]=band(new_color,0x0f)
    if (band(new_color,0xf0)!=0) transparent[a]=true
  end

 sw=(w or 1)*8
 sh=(h or 1)*8
 sx=(s%8)*8
 sy=flr(s/8)*8
 x0=flr(0.5*sw)
 y0=flr(0.5*sh)
 a=a/360
 sa=sin(a)
 ca=cos(a)
 for ix=0,sw-1 do
  for iy=0,sh-1 do
   dx=ix-x0
   dy=iy-y0
   xx=flr(dx*ca-dy*sa+x0)
   yy=flr(dx*sa+dy*ca+y0)
   if (xx>=0 and xx<sw and yy>=0 and yy<=sh) then
     local color=colors[sget(sx+xx,sy+yy)]
     if (not transparent[color]) pset(x+ix,y+iy,color)
   end
  end
 end
end

function pow(x,a)
  if (a==0) return 1
  if (a<0) x,a=1/x,-a
  local ret,a0,xn=1,flr(a),x
  a-=a0
  while a0>=1 do
      if (a0%2>=1) ret*=xn
      xn,a0=xn*xn,shr(a0,1)
  end
  while a>0 do
      while a<1 do x,a=sqrt(x),a+a end
      ret,a=ret*x,a-1
  end
  return ret
end

function inoutquint(t, b, c, d)
  t = t / d * 2
  if (t < 1) return c / 2 * pow(t, 5) + b
  return c / 2 * (pow(t - 2, 5) + 2) + b
end

pi = 3.14
cos1 = cos function cos(angle) return cos1(angle/(3.1415*2)) end

function inoutsine(t, b, c, d)
  return -c / 2 * (cos(pi * t / d) - 1) + b
end

function inoutcubic(t, b, c, d)
  if debug then
    test1=t
    test2=b
    test3=c
    test4=d
  end
  t = t / d * 2
  if (t < 1) return c / 2 * t * t * t + b
  t = t - 2
  return c / 2 * (t * t * t + 2) + b
end

ease=inoutcubic
__gfx__
bbbbbbbbbbbbbbb0000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00bbbbb0000bbbb0099bbbbb444444444444444444444444444444400000000000000000
bbbbbbbbbbbb0005499449000000000bbbbbbbbbbbbbbbb0000bbbbb000bbb000000bb00099bbbbb444444444444444444444994449944000000000088888880
bbbbbbbbbb005449944994999944994000000bbbbbb00004aa0bbbbb990000000000000999bbbbbb444444444444999444499449999000000000000888888888
b0000bb000544499499949999449999499944000000499aaa0bbbbbbbb000000000000099bbbbbbb4444444444499994444444999900000000000008888ffff8
0aa9900005449944999499994499944999449944999aaaa90bbbbbbbbb000000000000099bbbbbbb444449994499944444449400000000000000000888f1ff18
b0000999905444444444444449994499449994499aaaa940bbbbbbbbbb000000000000099bbbbbbb444999944444444949990000000000000000000088fffff0
bbbbb00009999999a9aaaa9944444444999aaaaaaaa9400bbbbbbbbbbb000000000000099bbbbbbb449999444444449999900000000000000000000008333300
bbbbbbb000055554444449aaaaa9aaaaaaa4444aa9400bbbbbbbbbbbbb000000000000099bbbbbbb499999444444499900000000000000000000000000700700
bbbbbbbbb0449944999455555544444444444999900bbbbbbbbbbbbbbb000000000000099bbbbbbb449444440444999000000000000000000000000008888880
bbbbbbbbb05444a94a9949944999449a449aa4400bbbbbbbbbbbbbbbbb000000000000099bbbbbbb444444490099990000000000000000000000000088888888
bbbbbbbbbb00544aa4aa94a944a99449aa44900bbbbbbbbbbbbbbbbbb000000000000000099bbbbb4444449900000000000000000000000000000008888ffff8
bbbbbbbbbbbb0004aa4aa94aa44aa9949aa00bbbbbbbbbbbbbbbbbbbb000000000000000099bbbbb444449900000000000000000000000000000000888f1ff18
bbbbbbbbbbbbbbb000000044aa44aa40000bbbbbbbbbbbbbbbbbbbbbb90000990099000099bbbbbb499999000000000000000000000000000000000888fffff8
bbbbbbbbbbbbbbbbbbbbbb000000000bbbbbbbbbbbbbbbbbbbbbbbbbbb9999bb99bb9999bbbbbbbb449990000000000000000000000000000000000088ff55f0
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000008333300
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000700700
00000000000011000000000000000000000000000000000000100000077007700777777007777700077000770000000000000000000000000000000000000000
0000000000011d100000000000000000000000000000000000100000777700770000000077000007777770000000000000000000000000000000000000000000
1100000000111dd10000000000000000000000000000000000100000700770077777777770007777000077700000000000000000000000000000000000000000
1d11000001111dd11000000000000000000000000000000001100000007070007777777000077000000000000000000000000000000000000000000000000000
1ddd1100011111dd1100000000000000000000000000000001100000070000000000000000000000000000000000000000000000000000000000000000000000
11ddd111111111ddd110000000000000000000000000000001100000770000000000000000000000000000000000000000000000000000000000000000000000
111ddddd111111dddd11000000000000000000000000000001100000770000000000000000000000000000000000000000000000000000000000000000000000
1111dddddd11111d11dd100000000000000000000000000011100000077000000000000000000000000000000000000000000000000000000000000000000000
11111dd11111111dd111111000000000000000001100000011100000077000000000000000000000000000000000000000000000000000000000000000000000
1111111d111111111111111100000000000000011d11000111100000007700000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111110000000000000011dd1111111100000700700000000000000000000000000000000000000000000000000000000000000000000
111111111111111111111111111000000000001111ddddd111100000070700000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000111111dddddd1100000700700000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000011111d11d11ddd100000007700000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000011111dd11d111d100000077000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000001111111ddd11111100000770000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000001111111111111111100000700700000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000011111111111111111100000707000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000111111111111111111100000700700000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbb000000000bbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbb00000004499449940000bbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbb0004994999499449999499900bbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbb00544994999499449994499944900bbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbb05444994999499449994499449994400bbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbb0449944999455555544444444444999900bbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbb000055554444449aaaaa9aaaaaaa4444aa9400bbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
bbbbb00009999999a9aaaa9944444444999aaaaaaaa9400bbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
b000099990544444444444444999449a449994499aaaa940bbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
0aa9900005449944aa94aa9944a99449aa44aa44999aaaa90bbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
b0000bb0005444a94aa94aaa944aa9949aa44000000499aaa0bbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbb00544aa44aa4aaa944aa4000000bbbbbb00004aa0bbbbb000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbb00054aa44a000000000bbbbbbbbbbbbbbbb0000bbbbb000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbb0000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
