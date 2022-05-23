pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
function _init()
	make_globals() -- dont play with this
	make_luigi()
	
	-- game variables
	
	bro_speed = .75 -- higher is faster!
	ghost_speed = .5
	ghost_rate = 120 --higher means less ghosts
	vacuum_range = 16
	vacuum_width = 11
	vacuum_speed = 0.5 --slowdown while using vacuum
end


function _update60()
	if gamestart then
		update_gameplay()
	else
		if btnp(4) or btnp(5) then
			gamestart = true
		end
	end
	if gamend then
		_draw()
	 	stop()
	elseif not mario then
		check_p2()
	end
end

function update_gameplay()
	if rnd(ghost_rate) < 1 then
		make_boo()
	end
 
	for bro in all(bros) do
		if (bro.alive) move_bro(bro)
	end
	
	move_boos()
	
	for bro in all(bros) do
		if bro.alive then
			check_vacuum(bro)
			collide_boos(bro)
			collide_items(bro)
		end
	end
	
	-- make ghosts happen more often
	if timer_sec%5==0 and timer==0 then
		ghost_rate = ghost_rate - 2
		ghost_speed = ghost_speed + .025
	end 
 
 -- gamend?
 gamend=true
 for bro in all(bros) do
 	if (bro.alive) gamend = false
 end
 
	update_globals() -- don't play with this
	
end

function _draw()
	-- draw the room
	cls()
	map()
	
	-- draw characters and stuff
	for bro in all(bros) do
		if (bro.alive) draw_bro(bro)
	end
	
	draw_boos()
	draw_items()
	-- status bar
	rectfill(0,112,128,128,0)
	rect(0,112,127,127,6)
	
	for bro in all(bros) do
		brohearts = bro.name..": "
		for i=1,bro.health,1 do
			brohearts = brohearts.."♥"
		end
		print(brohearts,2,114+6*bro.player,bro.color)
	end

	print("⧗: "..timer_sec,94,114,7)
	print("coins: "..coin_count,82,120,10)
	
	-- draw title if starting up
	if not gamestart then
		xs = 34
		ys = 40
		oprint("luigi",xs,ys,3,7)
		oprint("&",xs+26,ys,1,7)
		oprint("mario's",xs+36,ys,8,7)
		oprint("mini mansion",xs+8,ys+8,1,7)
	end
	
	-- end game
	if gamend then
	 xs = 40
		ys = 40
		oprint("game over",xs,ys,0,7)
		fscore = coin_count+timer_sec
		oprint("final score: "..fscore,xs-10,ys+12,10,0)
	end
end

function check_p2()
	for ix=0,5,1 do
		if btnp(ix,1) then
			make_mario()
			return
		end 
	end
end

function draw_boos()
	for b in all(boos) do
		draw_shadow(b.x,b.y)
		
		if b.hurt then
			if timer%4>1 then
				spr(b.s,b.x,b.y-2)
			end
		else
			spr(b.s,b.x,b.y-2)
		end
	end
end

function draw_items()
	for i in all(items) do
		draw_shadow(i.x,i.y)
		spr(i.sprite,i.x,i.y-2)
	end
end

function collide_items(bro)
	for i in all(items) do
		if bro.x+6 > i.x+1 and
  	bro.x+1 < i.x+6 and
  	bro.y+6 > i.y+1 and
  	bro.y+1 < i.y+6 then
  	if (i.name=="coin") coin_count += 1
  	if (i.name=="bigcoin") coin_count += 10
  	if (i.name=="heart") bro.health += 1
  	if i.name=="1up" then
  	 for bro in all(bros) do
  	 	if (not bro.alive) then
  	 		bro.alive=true
  	 		bro.health=1
  	 		bro.timer=50
  	 	end
  	 end
  	end
  	del(items,i)
  end
	end
end

function collide_boos(bro)
 if (bro.timer > 0) return
 for b in all(boos) do
  if bro.x+6 > b.x+1 and
  	bro.x+1 < b.x+6 and
  	bro.y+6 > b.y+1 and
  	bro.y+1 < b.y+6 then
  		kill_boo(b)
  		hurt_bro(bro)
  	end
 end
end

function hurt_bro(bro)
	bro.health = bro.health-1
	bro.timer = 60
	if (bro.health < 1) bro.alive=false
end

function kill_boo(b)
	del(boos,b)
	make_item(b.x,b.y)
end

function move_boos()
	for b in all(boos) do
		local dx = b.dx
		local dy = b.dy
		if b.hurt then
			dx = dx * 0.5
			dy = dy * 0.5
		end
		b.hurt = false
		b.x = b.x + dx
		b.y = b.y + dy
		if b.x < -12 or b.x > 130 or
			b.y < -12 or b.y > 130 then
			del(boos,b)
		end
	end
end

function make_item(x,y)
	local item = {}
	local chance = rnd()
	item.x=x
	item.y=y
	if chance < 0.9 then
		item.name = "coin"
		item.sprite = 48
	elseif chance < .95 then
		item.name = "bigcoin"
		item.sprite = 50
	else
		item.name = "heart"
		item.sprite = 49
		for bro in all(bros) do
			if not bro.alive then
				if rnd() < 0.4 then
					item.name = "1up"
					item.sprite = 51
				end
			end
		end
	end
	add(items,item)
end

function make_boo()
	local boo = {}
	boo.s = 33 -- sprite no.
	boo.health=20
	boo.hurt=false
	local speed = ghost_speed * (1.1-rnd(0.2))
	if rnd() < 0.5 then
		boo.dx = 0
		boo.dy = speed * sgn(rnd()-.5)
		if boo.dy>0 then
			boo.y = -8
		else
			boo.y= 128
		end
		boo.x = 8 + rnd(104)
	else
		boo.dy = 0
		boo.dx = speed * sgn(rnd()-.5)
		if boo.dx>0 then
			boo.x = -8
		else
			boo.x= 128
		end
		boo.y = 24 + rnd(80)	
	end
	add(boos,boo)
end

function make_globals()
	timer = 0
	timer_sec = 0
	coins = {}
	coin_count = 0
	gamestart = false
	gameend = false
	boos = {}
	bros = {}
	items = {}
	poke(0x5f5c, 255)
end

function update_globals()
	timer = (timer + 1)%60
	if (timer == 0) timer_sec  = timer_sec + 1
end

function return_bro()
	local bro = {}
	bro.name = 'luigi'
	bro.color = 3
	bro.alive = true
	bro.x = 50
	bro.y = 76
	bro.sprite = 1
	bro.health = 3
	
	-- dont edit these ones
	bro.moved = false
	bro.faceleft = false
	bro.frame = 0 
	bro.framenow = 0
	bro.timer = 32
	bro.vacuum = false
	bro.vacx = 1
	bro.vacy = 0
	bro.player = 0 --  player index, for multiplayer
	return bro
end

function make_luigi()
	luigi = return_bro()
	luigi.sprite = 1
	luigi.name = 'luigi'
	luigi.color = 3
	add(bros,luigi)
end

function make_mario()
	mario = return_bro()
	mario.sprite = 3
	mario.player = 1
	mario.name = 'mario'
	mario.color = 8
	mario.x = mario.x + 10
	add(bros,mario)
end

function move_bro(bro)
	local dx = 0
	local dy = 0
	bro.moved = false
	bro.vacuum = false

	if (btn(0,bro.player)) dx = -1
	if (btn(1,bro.player)) dx = 1
	if (btn(2,bro.player)) dy = -1
	if (btn(3,bro.player)) dy = 1
	if (btn(4,bro.player)) bro.vacuum = true
	
	if (dx!=0 or dy!=0) bro.moved=true
	if (dx > 0 and not bro.vacuum) bro.faceleft = false
	if (dx < 0 and not bro.vacuum) bro.faceleft = true
		
	if abs(dx) + abs(dy) > 1 then
		dx = dx * .707
		dy = dy * .707
	end
	
	if btnp(4,bro.player) then
		bro.vacx=dx
		bro.vacy=dy
		if dx==0 and dy==0 then
			if bro.faceleft then
				bro.vacx = -1
			else
				bro.vacx = 1
			end
		end
	end
	
	if bro.vacuum then
		dx = dx * vacuum_speed
		dy = dy * vacuum_speed
	end
	
	dx = dx * bro_speed
	dy = dy * bro_speed
	
	bro.x = bro.x + dx
	bro.y = bro.y + dy
	
	-- out of bounds code
	if (bro.x < 8) bro.x = 8
	if (bro.x > 112) bro.x = 112
	if (bro.y < 24) bro.y = 24
	if (bro.y > 96) bro.y = 96
	
	-- timer
	bro.timer = max(0,bro.timer-1)
	
	-- sounds
	if bro.moved and timer%10==5 then
		sfx(0)
	end
		
end

function check_vacuum(bro)
	if (not bro.vacuum) return
	local cx = bro.vacx*vacuum_range+bro.x
	local cy = bro.vacy*vacuum_range+bro.y
	local d = vacuum_width
	for b in all(boos) do
  if cx+d > b.x and
  	cx < b.x+8 and
  	cy+d > b.y and
  	cy < b.y+8 then
  		hurt_boo(b)
  	end
 end
end

function hurt_boo(b)
	b.health = b.health-1
	if (b.health < 1) kill_boo(b)
	b.hurt = true
end

function draw_vacuum(bro)
	local ccount=4
	for i=0,ccount-1,1 do
		local cycle = ((timer+i*15/ccount)%15) 
		local dist = vacuum_range*(1-(cycle/15))
		local cx = bro.x + 4 + bro.vacx*dist
		local cy = bro.y + 2 + bro.vacy*dist
		local cr = (1+vacuum_width/2)*(1-(cycle/15))
		if (timer+i)%2>0 then
			circ(cx,cy,cr,6)
		end
	end
end

function draw_bro(bro)
	--shadow
	draw_shadow(bro.x,bro.y+1)
	
	--vacuum particles
	if (bro.vacuum) draw_vacuum(bro)
	
	--if hurt, flash
	if (bro.timer%8>3) return
	
	--animate
	local yup = 0
	if bro.moved or bro.vacuum then
		if timer%10 > 4 then
			yup=1
		end
	end

	spr(bro.sprite+yup,bro.x,bro.y-2-8,1,2,bro.faceleft)
	
	--vacuum
	if bro.vacuum then
		spr(16,bro.x,bro.y-2-yup,1,1,bro.faceleft)
	end
end

function draw_shadow(x,y)
	palt(0,false)
	palt(15,true)
	spr(32,x,y)
	palt()
end

function oprint(str,x,y,c,co)
	for xx=-1,1,1 do
		for yy=-1,1,1 do
			print(str,x+xx,y+yy,co)
		end
	end
	print(str,x,y,c)
end

__gfx__
00000000000000000033373000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003337300333333300000000008887800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700033333333331f1f000888780088888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770003331f1f044f1f1f00888888888f1f1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700044f1f1f04fffffff88f1f1f04ff1f1ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007004fffffffffff1fff4ff1f1ff4f1fffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffff1fff0ffff1114f1fffff0ff111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ffff11100fffff00ff1111100fffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000fffff00331313000fffff0088c8c800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000050031331300377317008c88c8008778c700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000550331331330177117388c88c880c77cc740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555560771111773311113377cccc7744cccc440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666560771111773310113377cccc7744c0cc440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000055001100110300000000cc00cc0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000050033003300000000004400440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000033303330000000004440444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff006666000001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff0000ff06777760001cccc100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f000000f67771716101c1c1100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000677171611ccccc100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000067777761cccccc100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f000000f6777887601cccc1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff0000ff06778860001cc10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff006666000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000008e008e00099990000333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000990008888888e09aaaa9003377330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009aa9008888888e9aa9aaa973377337000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09aaaa902888888e9aa99aa973333337000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09aaaa902888888e9aa99aa933333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009aa900028888809aa9aaa907177170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000990000028880009aaaa9007177170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000280000099990000777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e6dee6dee6dee6dee6dee6200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e6dee6dee6dee6dee6dee6200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d26dee6dee6dee6dee6dee2d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
626dee6dee6dee6dee6dee2600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d2dee6dee6dee6dee6de2d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d2dee6dee6dee6dee6de2d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e6d2ee6dee6dee6dee6d2d6e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e6d2ee6dee6dee6dee6d2d6e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d6de2e6dee6dee6dee62ed6d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
de6d2e6dee6dee6dee62d6ed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
de6de26dee6dee6dee2ed6ed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d6de26dee6dee6dee2ed6d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6de6d62dee6dee6de26d6ed600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6de6de2dee6dee6de2ed6ed600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e6d6de622222222226ed6d6e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e6de6d622222222226d6ed6e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d6de6de2111111102ed6ed6d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
de6d6de2111111012ed6d6ed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
de6de6d2111110112d6ed6ed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d6de6d2000000002d6ed6d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6de6d6d2111011112d6d6ed600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6de6de621101111126ed6ed600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e6d6de621011111126ed6d6e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e6de6d620000000026d6ed6e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d6de6de2222222222ed6ed6d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
de6d6d2dee6dee6de2d6d6ed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
de6d626dee6dee6dee2ed6ed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d6d2e6dee6dee6dee62d6d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6de2ee6dee6dee6dee6d2ed600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d2dee6dee6dee6dee6de2d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e26dee6dee6dee6dee6dee2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e6dee6dee6dee6dee6dee6200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000010100000000000100000000000000000101000000000001000000000000000001010001010100000000000000000000000000010101000000000000000000000000000101010000000000000000000000000001010100000000000000000000000000
0000010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4141414141414141414141414141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4041414141414141414141414141414200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151515151515151515151515200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061616161616161616161616161616200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061616161616161616161616161616200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061616161616161616161616161616200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061616161616161616161616161616200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061616161616161616161616161616200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061616161616161616161616161616200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061616161616161616161616161616200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061616161616161616161616161616200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061616161616161616161616161616200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061616161616161616161616161616200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071717171717171717171717171717200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100001803418035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001a1561d156231562615600700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
