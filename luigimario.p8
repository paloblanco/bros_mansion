pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
function _init()
		
	-- game variables
	start_health = 3
	bro_speed = .75 -- higher is faster!
	ghost_speed = .5
	ghost_rate = 90 --higher means less ghosts
	vacuum_range = 16
	vacuum_width = 11
	vacuum_speed = 0.5 --slowdown while using vacuum
	
	make_globals() -- dont play with this
	make_luigi()
	-- play music
	music(0)
end


function _update60()
	if gamestart and not gamend then
		update_gameplay()
	else
		if btnp(4) or btnp(5) then
			gamestart = true
			music(-1)
		end
	end
	if gamend then
		_draw()
		if btnp(4) or btnp(5) then
			run()
		end
	elseif not mario then
		check_p2()
	end
end

function update_gameplay()
	if rnd(ghost_rate) < 1 then
		make_random_boo()
	end
 
	for bro in all(bros) do
		if (bro.alive) move_bro(bro)
	end
	
	move_boos()
	
	local vac_stop=true
	for bro in all(bros) do
		if bro.alive then
			check_vacuum(bro)
			collide_boos(bro)
			collide_items(bro)
			if (bro.vacuum) vac_stop = false
		end
	end
	if (vac_stop) sfx(1,-2)
	
	-- make ghosts happen more often
	if timer_sec%5==0 and timer==0 then
		ghost_rate = ghost_rate - 2
		ghost_speed = ghost_speed + .02
	end 
 
 -- gamend?
 gamend=true
 for bro in all(bros) do
 	if (bro.alive) gamend = false
 end
 if (trophy) gamend = true
 
	update_globals() -- don't play with this
	
end

function _draw()
	-- draw the room
	update_cam(luigi)
	cls()
	map()
	
	-- draw characters and stuff
	for bro in all(bros) do
		if (bro.alive) draw_bro(bro)
	end
	
	draw_boos()
	draw_items()
	-- status bar
	camera()
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
		local ys = 40
		coprint("luigi & mario's",ys,3,7)
		coprint("mini mansion",ys+8,1,7)
	end
	
	-- end game
	if gamend then
		local ys = 40
		if (not trophy) coprint("game over",ys,0,7)
		if (trophy) coprint("you win!",ys,0,7)
		fscore = coin_count+timer_sec
		coprint("final score: "..fscore,ys+12,10,0)
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
		if not (b.hurt and timer%4<2) then
			if b.big then
				local yy = b.y-8+2*sin(timer/59)
				sspr(32,16,8,8,b.x-8,yy,24,24)
				if b.health < 200 then
					oprint(b.health,b.x-2,yy,8,0)
				end
			else
				spr(b.s,b.x,b.y-2)
			end
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
			if i.name=="coin" then
				coin_count += 1
				sfx(2)
			end
			if i.name=="bigcoin" then
				coin_count += 10
				sfx(3)
			end
			if i.name=="heart" then
				bro.health += 1
				sfx(4)
			end
			if i.name=="1up" then
				sfx(5)
				for bro in all(bros) do
					if (not bro.alive) then
						bro.alive=true
						bro.health=1
						bro.timer=50
					end
				end
 		end
 		if i.name=="trophy" then
				trophy = true
				sfx(5)
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
  		del(boos,b)
  		hurt_bro(bro)
  	end
 end
end

function hurt_bro(bro)
	bro.health = bro.health-1
	bro.timer = 60
	if bro.health < 1 then
		bro.alive=false
		sfx(7)
	else
		sfx(6)
	end
end

function kill_boo(b)
	del(boos,b)
	random_item(b.x,b.y)
	sfx(8)
	if b.big then
		for xx=(b.x\8)-1,(b.x\8)+1,1 do
			for yy=(b.y\8)-1,(b.y\8)+1,1 do
				mset(xx,yy,97)
			end
		end
	end
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
		if b.wallbump then
			if (dx > 0 and bump_right(b)) b.dx=-b.dx
			if (dx < 0 and bump_left(b)) b.dx=-b.dx
			if (dy < 0 and bump_up(b)) b.dy=-b.dy
			if (dy > 0 and bump_down(b)) b.dy=-b.dy
		elseif b.x < camx-12 or b.x > camx+130 or
			b.y < camy-12 or b.y > camy+130 then
			del(boos,b)
		end
	end
end

function setup_items()
	item_list = {}
	item_list[48]="coin"
	item_list[49]="heart"
	item_list[50]="bigcoin"
	item_list[51]="1up"
	item_list[52]="trophy"
	item_indices = {}
	for k,_ in pairs(item_list) do
		add(item_indices,k)
	end
end

function random_item(x,y)
	local sp=48
	local chance = rnd()
	if chance < 0.9 then
		sp = 48
	elseif chance < .95 then
		sp = 50
		for bro in all(bros) do
			if not bro.alive then
				if rnd() < 0.75 then
					sp = 51
				end
			end
		end
	else
		sp = 49
	end
	make_item(x,y,sp)
end

function make_item(x,y,sp)
	local item = {}
	item.x=x
	item.y=y
	item.sprite = sp
	item.name = item_list[sp]
	add(items,item)
end

function return_boo()
	local boo = {}
	boo.s = 33 -- sprite no.
	boo.health=20
	boo.hurt=false
	boo.wallbump=false
	boo.big=false
	boo.dx=0
	boo.dy=0
	boo.x=0
	boo.y=0
	return boo
end

function make_big_boo(x,y)
	local boo = return_boo()
	boo.x=x
	boo.y=y
	boo.s=36
	boo.big=true
	boo.health=200
	add(boos,boo)
	for xx=(x\8)-1,(x\8)+1,1 do
		for yy=(y\8)-1,(y\8)+1,1 do
			mset(xx,yy,86)
		end
	end
end

function make_bounce_boo(x,y,dx,dy)
	local boo = return_boo()
	boo.x=x
	boo.y=y
	boo.dy=dy
	boo.dx=dx
	boo.wallbump=true
	add(boos,boo)
end

function make_random_boo()
	local boo = return_boo()
	local speed = ghost_speed * (1.1-rnd(0.2))
	if rnd() < 0.5 then
		boo.dx = 0
		boo.dy = speed * sgn(rnd()-.5)
		if boo.dy>0 then
			boo.y = camy-8
		else
			boo.y= camy+128
		end
		boo.x = camx+ 8 + rnd(104)
	else
		boo.dy = 0
		boo.dx = speed * sgn(rnd()-.5)
		if boo.dx>0 then
			boo.x = camx-8
		else
			boo.x= camx+128
		end
		boo.y = camy+24 + rnd(80)	
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
	trophy = false
	poke(0x5f5c, 255)
	camx=0
	camy=0
	setup_items()
	setup_map()		
end

function setup_map()
	for xx=0,127,1 do
		for yy=0,63,1 do
			local t = mget(xx,yy)
			if t==1 then
				luigi_start_x = xx*8
				luigi_start_y = yy*8
				mset(xx,yy,97)
			end
		end
	end
	camxmin=127*8
	camxmax=0
	camymin=63*8
	camymax=0
	for xx=0,127,1 do
		for yy=0,63,1 do
			local t = mget(xx,yy)
			if t != 0 then
				camxmin=min(camxmin,8*xx)
				camxmax=max(camxmax,8*(xx-15))
				camymin=min(camymin,8*yy)
				camymax=max(camymax,8*(yy-13))
			end
			if t==33 then
				make_bounce_boo(xx*8,yy*8,ghost_speed,0)
				mset(xx,yy,97)
			elseif t==34 then
				make_bounce_boo(xx*8,yy*8,0,ghost_speed)
				mset(xx,yy,97)
			elseif t==36 then
				make_big_boo(xx*8,yy*8)
				mset(xx,yy,97)
			elseif contains(item_indices,t) then
				make_item(xx*8,yy*8,t)
				mset(xx,yy,97)
			end
		end
	end
end

function contains(t,v)
	for vv in all(t) do
		if (v==vv) return true
	end
	return false
end

function update_cam(bro)
	camx = max(camxmin,bro.x-64)
	camy = max(camymin,bro.y-64)
	camx = min(camxmax,camx)
	camy = min(camymax,camy)
	camera(camx,camy)
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
	bro.health = start_health
	
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
	luigi.x = luigi_start_x
	luigi.y = luigi_start_y
	add(bros,luigi)
end

function make_mario()
	mario = return_bro()
	mario.sprite = 3
	mario.player = 1
	mario.name = 'mario'
	mario.color = 8
	mario.x = luigi.x + 10
	mario.y = luigi.y
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
		sfx(1,-2)
		sfx(1)
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
--	if (bro.x < 8) bro.x = 8
--	if (bro.x > 112) bro.x = 112
--	if (bro.y < 24) bro.y = 24
--	if (bro.y > 96) bro.y = 96
	
	if (dx > 0 and bump_right(bro)) snap_left(bro)
	if (dx < 0 and bump_left(bro)) snap_right(bro)
	if (dy < 0 and bump_up(bro)) snap_down(bro)
	if (dy > 0 and bump_down(bro)) snap_up(bro)
	
	-- timer
	bro.timer = max(0,bro.timer-1)
	
	-- sounds
	if bro.moved and timer%10==5 then
		sfx(0)
	end
		
end

function snap_down(bro)
	snap(bro,-1,(1+(bro.y\8)),0,-1)
end

function snap_up(bro)
	snap(bro,-1,(bro.y\8),0,1)
end

function snap_right(bro)
	snap(bro,(1+(bro.x\8)),-1,-1,0)
end

function snap_left(bro)
	snap(bro,(bro.x\8),-1,1,0)
end

function snap(bro,mx,my,xoff,yoff)
	local newx = bro.x
	if (mx != -1) newx = 8*mx + xoff
	local newy = bro.y
	if (my != -1) newy = 8*my + yoff
	bro.x = newx
	bro.y = newy
end

function bump(mx0,my0,mx1,my1)
	return fget(mget(mx0,my0),0) or fget(mget(mx1,my1),0)
end

function bump_vert(bro,yoff)
	local mx0 = (bro.x+2)\8
	local mx1 = (bro.x+6)\8
	local my = (bro.y+yoff)\8
	return bump(mx0,my,mx1,my)
end

function bump_down(bro)
	return bump_vert(bro,7)
end

function bump_up(bro)
	return bump_vert(bro,1)
end

function bump_side(bro,xoff)
	local mx = (bro.x+xoff)\8
	local my0= (bro.y+2)\8
	local my1= (bro.y+6)\8
	return bump(mx,my0,mx,my1)
end

function bump_left(bro)
	return bump_side(bro,1)
end

function bump_right(bro)
	return bump_side(bro,7)
end

function check_vacuum(bro)
	if (not bro.vacuum) return
	local cx = bro.vacx*vacuum_range+bro.x
	local cy = bro.vacy*vacuum_range+bro.y
	local d = vacuum_width
	for b in all(boos) do
		local dplus=0
		if (b.big) dplus=8
  if cx+d > b.x-dplus and
  	cx < b.x+8+dplus and
  	cy+d > b.y-dplus and
  	cy < b.y+8+dplus then
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

function coprint(str,y,c,c0)
	local xx = 64 - #str*2
	oprint(str,xx,y,c,c0)
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
ffffffff006666000066660000011110006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff0000ff0677776006117760001cccc1061111600006600000000000000000000000000000000000000000000000000000000000000000000000000000000000
f000000f6777171667777886101c1c116111c1c60061160000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000067717166711788611ccccc10611c1c60611116000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000006777776677777761cccccc1061111160611116000000000000000000000000000000000000000000000000000000000000000000000000000000000
f000000f677788766777777601cccc10611188160061160000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff0000ff0677886006766760001cc100061188600006600000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff006666000060060000011000006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000008e008e00099990000333300009aa7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000990008888888e09aaaa9003377330009aa7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009aa9008888888e9aa9aaa973377337999aaaa70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09aaaa902888888e9aa99aa973333337909aaa0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09aaaa902888888e9aa99aa933333333999aaa9a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009aa900028888809aa9aaa907177170009999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000990000028880009aaaa90071771700009a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000002800000999900007777000099a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e6dee6dee6dee6dee6dee622e6dee6dee6dee6dee6dee622e6dee622e6dee620000000000000000000000000000000000000000000000000000000000000000
2e6dee6dee6dee6dee6dee62e26dee6dee6dee6dee6dee2ee200002de26dee2d0000000000000000000000000000000000000000000000000000000000000000
d26dee6dee6dee6dee6dee2d6d2dee6dee6dee6dee6de2d6ee00006dee00006d0000000000000000000000000000000000000000000000000000000000000000
626dee6dee6dee6dee6dee266de2ee6dee6dee6dee6d2ed6ee00006dee00006d0000000000000000000000000000000000000000000000000000000000000000
6d2dee6dee6dee6dee6de2d66d6d2e6dee6dee6dee62d6d6ee00006dee00006d0000000000000000000000000000000000000000000000000000000000000000
6d2dee6dee6dee6dee6de2d6de6d626dee6dee6dee2ed6edee00006dee00006d0000000000000000000000000000000000000000000000000000000000000000
e6d2ee6dee6dee6dee6d2d6ede6d6d2dee6dee6de2d6d6ede26dee2dee00006d0000000000000000000000000000000000000000000000000000000000000000
e6d2ee6dee6dee6dee6d2d6ed6de6de2ee6dee6d2ed6ed6d2e6dee62ee00006d0000000000000000000000000000000000000000000000000000000000000000
d6de2e6dee6dee6dee62ed6d00000000444544450000000011111110ee00006d0000000000000000000000000000000000000000000000000000000000000000
de6d2e6dee6dee6dee62d6ed00000000444544450000000011111101ee00006d0000000000000000000000000000000000000000000000000000000000000000
de6de26dee6dee6dee2ed6ed00000000444544450000000011111011ee00006d0000000000000000000000000000000000000000000000000000000000000000
6d6de26dee6dee6dee2ed6d600000000444544550000000000000000ee00006d0000000000000000000000000000000000000000000000000000000000000000
6de6d62dee6dee6de26d6ed600000000444544450000000011101111ee00006d0000000000000000000000000000000000000000000000000000000000000000
6de6de2dee6dee6de2ed6ed600000000444544450000000011011111ee00006d0000000000000000000000000000000000000000000000000000000000000000
e6d6de622222222226ed6d6e00000000444544450000000010111111ee00006d0000000000000000000000000000000000000000000000000000000000000000
e6de6d622222222226d6ed6e00000000445544450000000000000000ee00006d0000000000000000000000000000000000000000000000000000000000000000
d6de6de2111111102ed6ed6d00000000000000000000000000000000ee00006d0000000000000000000000000000000000000000000000000000000000000000
de6d6de2111111012ed6d6ed00000000000000000000000000000000ee00006d0000000000000000000000000000000000000000000000000000000000000000
de6de6d2111110112d6ed6ed00000000000000000000000000000000ee00006d0000000000000000000000000000000000000000000000000000000000000000
6d6de6d2000000002d6ed6d600000000000000000000000000000000ee00006d0000000000000000000000000000000000000000000000000000000000000000
6de6d6d2111011112d6d6ed600000000000000000000000000000000ee00006d0000000000000000000000000000000000000000000000000000000000000000
6de6de621101111126ed6ed600000000000000000000000000000000ee00006d0000000000000000000000000000000000000000000000000000000000000000
e6d6de621011111126ed6d6e00000000000000000000000000000000e26dee2d0000000000000000000000000000000000000000000000000000000000000000
e6de6d620000000026d6ed6e000000000000000000000000000000002e6dee620000000000000000000000000000000000000000000000000000000000000000
d6de6de2222222222ed6ed6d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
de6d6d2dee6dee6de2d6d6ed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
de6d626dee6dee6dee2ed6ed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d6d2e6dee6dee6dee62d6d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6de2ee6dee6dee6dee6d2ed600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d2dee6dee6dee6dee6de2d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e26dee6dee6dee6dee6dee2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e6dee6dee6dee6dee6dee6200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000454545454545454545454545454545450000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000451616161616161616161616431616450000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000451616161616161616161616161616450000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000045454545454516161616161616161645450000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004545451616454545454545450000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000451616450000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000451616450000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000141414141414161616161414141414140000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000041414141414161616161414141414240000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000051515151515164216161515151515250000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000061616161616161616161616161616260000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000061616161616161616161616161616260000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000061616121616161616161616221616260000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000061616161616161616161616161616260000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000061603031616161616161616161616260000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000061613131616161616161616161616260000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000061623161616161610161616161616260000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000061616161616161616161616161616260000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000061616161616161616161616161616260000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000061616161616161616161616161616260000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000071717171717171717171717171717270000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000010100000000000000000000000000000101000000000001000000000000000001010001010101010101010000000000000000010101000100010100000000000000000100010000000001000000000000000001010100000000000000000000000000
0000010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100001803418035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800040e72611726177260e72600700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002934533345000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002934533347373473334737347000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001b0432e043000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000130361b0361b0361d0361b036270362703629036270363003630036330360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001f35316353163530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002b35322353223531f3531b353183531635300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600002725327253000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001018000c344000000f34411342003000c3440f34200000000001334400000000040c3440f0000f344113420c0000c34400000000000000000000000000c0000c00000000000000000000000000000000000000
011018000c344000000f34411342003000c3440f34200000000001334400000000040c3440f0000f304113020c0000c34400000000000000000000000000c0000c00000000000000000000000000000000000000
011018001305300000000000662500000086251305300000000000662500000086251305300000000000662500000086251305300000000000662500000086250000000000000000000000000000000000000000
__music__
01 090b4344
02 0a0b4344

