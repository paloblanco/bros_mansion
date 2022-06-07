pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
-- main loop

-- bros mini mansion
-- palo blanco games, 2022
-- rocco panella

function _init()
	-- game variables
	make_game_variables()
	make_globals() -- dont play with this
	make_player(0)
	start_title()
end

function make_game_variables()
	-- game variables
	-- things like speed and freq.
	start_health = 10
	regen_health = 10 -- how much you come back with
	bro_speed = 0.75 --.75 -- higher is faster!
	ghost_speed = .5
	ghost_dvel = 0--.02 -- how much ghosts get faster by
	ghost_rate = 12000--90 --higher means less ghosts
	ghost_dr = 0--2 -- how much freq increase by
	vacuum_range = 18--16
	vacuum_width = 11
	vacuum_speed = 0.5 --slowdown while using vacuum
	damage = 1 -- vacuum damage
	camera_speed = 10 --lower is faster!
end

function update_gameplay()
	
	if rnd(ghost_rate) < 1 then
		make_random_boo()
	end
 
	update_bros()
	update_boos()
	update_all_coins()
	update_collisions()
	try_increase_ghosts()
	check_cameras()
	update_alarms()
 
 -- gamend?
 gamend=true
 for _,bro in pairs(bros) do
 	if (bro.alive) gamend = false
 end
 if (trophy) gamend = true
 if (gamend) start_end()
 
	update_globals() -- don't play with this
	check_players()	
end


function draw_gameplay()
	-- draw the room
	update_cam()
	cls()
	map()
	
	-- draw characters and stuff
	for _,bro in pairs(bros) do
		if (bro.alive) draw_bro(bro)
	end
	draw_all_boos()
	draw_all_items()
	draw_furniture()
	draw_all_coins()
	
	-- status bar
	camera()
	draw_status_bar()
	
	-- alarm ring
	draw_alarm()
end

function draw_alarm()
	for k,b in pairs(bros) do
		if b.alarm then
			rect(2,2,125,110,7)
			return
		end
	end
end

function draw_status_bar()
	rectfill(0,112,128,128,0)
	rect(0,112,127,127,6)
	for _,bro in pairs(bros) do
		brohearts = bro.name.." "
		if bro.health < 4 then
			for i=1,bro.health,1 do
				brohearts = brohearts.."♥"
			end
		else
			brohearts = brohearts.."♥X"..bro.health
		end
		print(brohearts,2,114+6*bro.player,bro.color)
	end

	print("⧗: "..timer_sec,94,114,7)
	print("coins: "..coin_count,82,120,10)
	if (redkey) spr(53,70,113)
	if (bluekey) spr(54,71,116)
	if (orangekey) spr(55,72,119)
end

function try_increase_ghosts()
	if timer_sec%5==0 and timer==0 then
		ghost_rate = ghost_rate - ghost_dr
		ghost_speed = ghost_speed + ghost_dvel
	end 
end

function update_collisions()
	local vac_stop=true
	for _,bro in pairs(bros) do
		if bro.alive then
			check_vacuum(bro)
			collide_boos(bro)
			collide_items(bro)
			collide_alarms(bro)
			if (bro.vacuum) vac_stop = false
		end
	end
	if (vac_stop) sfx(1,-2)
end

function check_players()
	for ixp=0,3,1 do
		if not bros[ixp] then
			for ix=0,5,1 do
				if btnp(ix,ixp) then
					make_player(ixp)
				end
			end
		end 
	end
end

function draw_all_boos()
	for b in all(boos) do
		b.draw_me(b)
	end
end

function draw_all_items()
	for i in all(items) do
		draw_shadow(i.x,i.y)
		spr(i.sprite,i.x,i.y-2)
	end
end

function make_globals()
	timer = 0
	timer_sec = 0
	coin_count = 0
	gamestart = false
	gameend = false
	
	boos = {}
	bros = {}
	items = {}
	cameras = {}
	furniture = {}
	coins = {}
	booalarms = {}
	softwalls = {}
	
	trophy = false
	redkey = false
	bluekey = false
	orangekey = false
	
	poke(0x5f5c, 255) -- no key repeat
	
	camx=0
	camy=0
	camtargx=0
	camtargy=0
	camtarget=nil
	
	setup_characters()
	setup_items()
	setup_boos()
	setup_map()		
end

function setup_map()
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
			if t==1 then
				start_x = xx*8
				start_y = yy*8
				mset(xx,yy,97)
			elseif t==39 then
				make_camera(xx*8,yy*8)
				mset(xx,yy,97)
			elseif t==44 then
				make_boo_alarm(xx*8,yy*8)
				make_camera(xx*8,yy*8)
				mset(xx,yy,97)
			elseif contains(boo_indices,t) then
				boo_list[t](xx*8,yy*8)
				mset(xx,yy,97)
			elseif contains(item_indices,t) then
				make_item(xx*8,yy*8,t)
				mset(xx,yy,97)
			elseif fget(t,3) then
				make_furn(xx*8,yy*8,t)
			elseif fget(t,2) then
				make_wall(xx,yy)
			end
		end
	end
end

function update_cam()
	if camtarget then
		set_cam(camtarget)
		return
	end
	for ix=0,3,1 do
		local bro = bros[ix]
		if bro and bro.alive then
			set_cam(bro)
			return
		end
	end
end

function set_cam(targ)
	camtargx = max(camxmin,targ.x-60)
	camtargy = max(camymin,targ.y-56)
	camtargx = min(camxmax,camtargx)
	camtargy = min(camymax,camtargy)
	local deltax = camtargx-camx
	local deltay = camtargy-camy
	if abs(deltax)>4 or abs(deltay)>4 then
		camx = camx + (deltax)/camera_speed
		camy = camy + (deltay)/camera_speed
	else
		camx=camtargx
		camy=camtargy
	end
	camera(camx,camy)
end

function update_globals()
	timer = (timer + 1)%60
	if (timer == 0) timer_sec  = timer_sec + 1
end
-->8
-- bros

function setup_characters()
	bro_types={}
	local bb = make_bro_type("luigi",3,1)
	add(bro_types,bb)
	local bb = make_bro_type("mario",8,3)
	add(bro_types,bb)
end

function make_bro_type(name,colix,sprite)
	local b = {}
	b.name=name or "luigi"
	b.color=colix or 3
	b.sprite= sprite or 1
	return b
end

function update_bros()
	for _,bro in pairs(bros) do
		if (bro.alive) update_bro(bro)
	end
end

function return_bro()
	local bro = {}
	bro.name = 'luigi'
	bro.color = 3
	bro.alive = true
	bro.x = 0
	bro.y = 0
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
	bro.alarm=nil
	return bro
end

function make_player(ix)
	pl = return_bro()
	bt = bro_types[ix+1]
	pl.sprite = bt.sprite or 1
	pl.name = bt.name or 'luigi'
	pl.player = ix
	pl.color = bt.color or 3
	if ix==0 then
		pl.x = start_x
		pl.y = start_y
	else
		pl.x = bros[0].x + 10*ix 
		pl.y = bros[0].y 
	end
	--add(bros,pl)
	bros[ix]=pl
end


function update_bro(bro)
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
		
	if (dx > 0 and bump_right(bro)) snap_left(bro)
	if (dx < 0 and bump_left(bro)) snap_right(bro)
	if (dy < 0 and bump_up(bro)) snap_down(bro)
	if (dy > 0 and bump_down(bro)) snap_up(bro)
	
	-- see if trapped by alarm
	check_alarm(bro)
	
	-- timer
	bro.timer = max(0,bro.timer-1)
	
	-- sounds
	if bro.moved and timer%10==5 then
		sfx(0)
	end
		
end

function check_vacuum(bro)
	if (not bro.vacuum) return
	local v={}
	v.x = bro.vacx*vacuum_range+bro.x
	v.y = bro.vacy*vacuum_range+bro.y
	v.d = vacuum_width
	v.dx = bro.vacx
	v.dy = bro.vacy
	v.dplus = 0
	_vacuum_boos(v)
	_vacuum_furniture(v)
	_vacuum_items(v)
	_vacuum_walls(v)
end

function _vacuum_walls(v)
	for w in all(softwalls) do
		if collide(v,w,v.d) then
			hurt_wall(w)
		end
	end
end

function _vacuum_boos(v)
	for b in all(boos) do
		if not b.ball then
			local dp=0
			if (b.big or b.king) dp=8
	  if collide(v,b,v.d+dp) then
	  	if (not b.stomp) hurt_boo(b)
	  	if (b.stomp and b.z < 2) hurt_boo(b)
	  end
  end
 end
end

function _vacuum_furniture(v)
	for f in all(furniture) do
		local ff = {}
		ff.x = f.x+8
		ff.y = f.y
 	if collide(v,ff,v.d+4) then
 	 hurt_furn(f)
 	end
 end
end

function _vacuum_items(v)
	for i in all(items) do
 	if collide(v,i,v.d) then
 	 i.x += -v.dx*.25
 	 i.y += -v.dy*.25
 	end
 end
end

function draw_vacuum(bro)
	local ccount=6
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
		if blink(5) then
			yup=1
		end
	end

	spr(bro.sprite+yup,bro.x,bro.y-2-8,1,2,bro.faceleft)
	
	--vacuum
	if bro.vacuum then
		spr(16,bro.x,bro.y-2-yup,1,1,bro.faceleft)
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


function collide_items(bro)
	for i in all(items) do
		if collide(bro,i,8) then
			i.get_me(i,bro)
			del(items,i)
		end
	end
end

function collide_boos(bro)
 if (bro.timer > 0) return
 for b in all(boos) do
  if collide(bro,b,6) then
  		if ((not b.king) and (not b.stomp)) del(boos,b)
  		if (not b.stomp) hurt_bro(bro)
  		if (b.stomp and b.z < 2) hurt_bro(bro)
  	end
 end
end

function collide_alarms(bro)
	for ba in all(booalarms) do
		if collide(bro,ba,60) then
			start_booalarm(ba)
			bro.alarm=ba
		end
	end
end

function check_alarm(bro)
	if (not bro.alarm) return
	local ba = bro.alarm
	if not ba.active then
		bro.alarm=nil
	else
		while (bro.x > ba.x+52) bro.x += -1
		while (bro.x < ba.x-52) bro.x += 1
		while (bro.y > ba.y+48) bro.y += -1
		while (bro.y < ba.y-48) bro.y += 1	
	end
end


-->8
-- boos

function setup_boos()
	boo_list={}
	boo_list[33]=make_horz_boo
	boo_list[34]=make_vert_boo
	boo_list[36]=make_big_boo
	boo_list[37]=make_ball_boo
	boo_list[38]=make_stomp_boo
	boo_list[40]=make_king_boo
	boo_list[42]=make_easy_wall
	boo_indices = {}
	for k,_ in pairs(boo_list) do
		add(boo_indices,k)
	end
end

function hurt_boo(b)
	b.health = b.health-damage
	if (b.health < 1) kill_boo(b)
	b.hurt = true
end

function kill_boo(b)
	del(boos,b)
	if b.king then
		make_item(b.x,b.y,52)
	else
		--random_item(b.x,b.y)
		make_coin(b.x,b.y)
	end
	sfx(8)
	if b.big then
		set_map_around(b.x,b.y,97)
	end
end

function update_boos()
	for b in all(boos) do
		b.update_me(b)
	end
end


function return_boo(x,y,dx,dy,updater,s,drawer)
	local boo = {}
	boo.s = s or 33 -- sprite no.
	boo.health=20
	boo.hurt=false
	boo.wallbump=false
	boo.big=false
	boo.king=false
	boo.ball=false
	boo.stomp=false
	boo.easywall=false
	boo.dx= dx or 0
	boo.dy= dy or 0
	boo.x= x or 0
	boo.y= y or 0
	boo.update_me = updater or update_basic_boo
	boo.draw_me = drawer or draw_boo
	return boo
end

function _move_boo(b)
	local dx = b.dx
	local dy = b.dy
	if b.hurt then
		dx = dx * 0.5
		dy = dy * 0.5
	end
	b.hurt = false
	b.x = b.x + dx
	b.y = b.y + dy
end

function _bounce_boo(b)
	if b.dx > 0 and bump_right(b) then
		b.dx=-b.dx
		snap_left(b)
	elseif b.dx < 0 and bump_left(b) then
		b.dx=-b.dx
		snap_right(b)
	end
	
	if b.dy < 0 and bump_up(b) then
		b.dy=-b.dy
		snap_down(b)
	elseif b.dy > 0 and bump_down(b) then
		b.dy=-b.dy
		snap_up(b)
	end
end

function update_basic_boo(b)
	_move_boo(b)
	if b.x < camx-12 or 
		b.x > camx+130 or
		b.y < camy-12 or 
		b.y > camy+130 then
	 del(boos,b)
	end
end

function update_stomp_boo(b)
	b.hurt = false
	if (b.z <= 0) b.dz=.6
	b.z += b.dz
	b.dz += -.01
end

function draw_stomp_boo(b)
	draw_shadow(b.x,b.y)
	if not (b.hurt and blink(2)) then
		spr(b.s,b.x,b.y-2-b.z)
		if (b.health<20) oprint(b.health,b.x-1,b.y-4-b.z,6,0)			
	end
end

function make_stomp_boo(x,y)
	local boo = return_boo(x,y,0,0,
	update_stomp_boo,38,
	draw_stomp_boo)
	boo.z=0
	boo.dz=0
	boo.stomp=true
	add(boos,boo)
end


function make_ball_boo(x,y,dx,dy)
	local dx = dx or .5
	local dy = dy or .5
	local boo = return_boo(x,y,dx,dy,
	update_basic_boo,37,draw_boo)
	boo.ball=true
	add(boos,boo)
end

function update_king_boo(b)
	_move_boo(b)
	_bounce_boo(b)
end

function draw_king_boo(b)
	if not (b.hurt and blink(2)) then
		local yy = b.y-8+2*sin(timer/59)
		sspr(64,16,16,16,b.x-8,yy,24,24)
		if b.health < 500 then
			oprint(b.health,b.x-2,yy,8,0)
		end
	end
end

function make_king_boo(x,y)
	local boo = return_boo(x,y,.5,
	.5,update_king_boo,40,
	draw_king_boo)
	boo.king=true
	boo.health=500
	add(boos,boo)
end

function update_wall(b)
	_move_boo(b)
end

function draw_wall(b)
	if not (b.hurt and blink(2)) then
		local yy = b.y-8+2*sin(timer/59)
		sspr(80,16,16,16,b.x-8,yy,24,24)
		if b.health < 500 then
			oprint(b.health,b.x-2,yy,8,0)
		end
	end
end

function make_easy_wall(x,y)
	local boo = return_boo(x,y,0,0,
	update_wall,42,draw_wall)
	boo.big=true
	boo.easywall=true
	boo.health=500
	add(boos,boo)
	set_map_around(x,y,86)
end

function update_big_boo(b)
	_move_boo(b)
	if timer%30==0 and timer_sec%3==0 then
		if b.x > camx-6 and 
			b.x < camx+130 and
			b.y > camy-6 and 
			b.y < camy+120 then
			for i=0,15,1 do
				local dbx=.35*cos(i/15)
				local dby=.35*sin(i/15)
				make_ball_boo(b.x,b.y,dbx,dby)
			end
			sfx(12)		
		end
	end
end

function draw_big_boo(b)
	if not (b.hurt and blink(2)) then
		local yy = b.y-8+2*sin(timer/59)
		sspr(32,16,8,8,b.x-8,yy,24,24)
		if b.health < 200 then
			oprint(b.health,b.x-2,yy,8,0)
		end
	end
end

function make_big_boo(x,y)
	local boo = return_boo(x,y,0,0,
	update_big_boo,36,draw_big_boo)
	boo.big=true
	boo.health=200
	add(boos,boo)
	set_map_around(x,y,86)
end

function make_bounce_boo(x,y,dx,dy)
	local boo = return_boo(x,y,dx,dy,update_bounce_boo,33,draw_boo)
	boo.wallbump=true
	add(boos,boo)
end

function make_vert_boo(x,y)
	make_bounce_boo(x,y,0,ghost_speed)
end

function make_horz_boo(x,y)
	make_bounce_boo(x,y,ghost_speed,0)
end

function update_bounce_boo(b)
	_move_boo(b)
	_bounce_boo(b)
end

function draw_boo(b)
	draw_shadow(b.x,b.y)
	if not (b.hurt and blink(2)) then
		spr(b.s,b.x,b.y-2)
		if (b.health<20) oprint(b.health,b.x-1,b.y-4,6,0)
	end
end

function make_random_boo()
	local speed = ghost_speed * (1.1-rnd(0.2))
	local dx, dy, x, y
	if rnd() < 0.5 then
		dx = 0
		dy = speed * sgn(rnd()-.5)
		if dy>0 then
			y = camy-8
		else
			y= camy+128
		end
		x = camx + 8 + rnd(104)
	else
		dy = 0
		dx = speed * sgn(rnd()-.5)
		if dx>0 then
			x = camx-8
		else
			x= camx+128
		end
		y = camy+24 + rnd(80)	
	end
	local boo = return_boo(x,y,
		dx,dy,update_basic_boo,33,draw_boo)
	add(boos,boo)
end
-->8
--items

function setup_items()
	item_list = {}
	item_list[48]={"coin",get_coin}
	item_list[49]={"heart",get_heart}
	item_list[50]={"bigcoin",get_bigcoin}
	item_list[51]={"1up",get_1up}
	item_list[52]={"trophy",get_trophy}
	item_list[53]={"redkey",get_redkey}
	item_list[54]={"bluekey",get_bluekey}
	item_list[55]={"orangekey",get_orangekey}
	item_indices = {}
	for k,_ in pairs(item_list) do
		add(item_indices,k)
	end
end

function get_item_name(sp)
	return item_list[sp][1]
end

function get_item_func(sp)
	return item_list[sp][2]
end

function random_item(x,y)
	local sp=48 --coin
	local chance = rnd()
	if chance < 0.9 then
		sp = 48
	elseif chance < .95 then
		sp = 50 --bigcoin
		for bro in all(bros) do
			if not bro.alive then
				if rnd() < 0.75 then
					sp = 51 --mushroom
				end
			end
		end
	else
		sp = 49 --heart
	end
	make_item(x,y,sp)
end

function get_coin(item,bro)
	coin_count += 1
	sfx(2)
end

function get_bigcoin(item,bro)
	coin_count += 10
	sfx(3)
end

function get_heart(item,bro)
	bro.health += 1
	sfx(4)
end

function get_1up(item,bro)
	sfx(5)
	for bbro in all(bros) do
		if (not bbro.alive) then
			bbro.alive=true
			bbro.health=regen_health
			bbro.timer=50
			bbro.x=bro.x+8+2*bbro.player
			bbro.y=bro.y
		end
	end
end

function get_trophy(item,bro)
	trophy = true
	sfx(5)
end
			
function get_redkey(item,bro)
	redkey = true
	sfx(2)
end

function get_bluekey(item,bro)
	bluekey = true
	sfx(2)
end

function get_orangekey(item,bro)
	orangekey = true
	sfx(2)
end
			

function make_item(x,y,sp)
	local item = {}
	item.x=x
	item.y=y
	item.sprite = sp
	item.name = get_item_name(sp)
	item.get_me = get_item_func(sp)
	add(items,item)
end

function make_camera(x,y)
	local cam = {}
	cam.x=x+4
	cam.y=y
	add(cameras,cam)
end

function check_cameras()
	for c in all(cameras) do
		for ix=0,3,1 do
			local b = bros[ix]
			if b then
				if collide(c,b,60) then
					camtarget=c
					return
				end
			end
		end
	end
	camtarget=nil
end

function make_furn(x,y,sp)
	local furn = {}
	furn.x=x
	furn.y=y
	furn.sp=sp
	furn.health=60
	furn.hurt=false
	mset(x\8,y\8,86)
	mset(1+(x\8),y\8,86)
	add(furniture,furn)
end

function draw_furn(f)
	draw_shadow(f.x,f.y)
	if (f.hurt and blink(2)) return
	draw_shadow(8+f.x,f.y)
	spr(f.sp,f.x,f.y-2-8,2,2)
	f.hurt=false
end

function draw_furniture()
	for f in all(furniture) do
		draw_furn(f)
	end
end

function hurt_furn(f)
	f.hurt = true
	f.health = max(0,f.health-1)
	if (f.health <= 0) return
	if f.health%5 == 0 then
		make_coin(f.x+7,f.y)
	end
end

function make_coin(x,y)
	local coin = {}
	coin.x=x
	coin.y=y
	coin.z=0
	coin.sp=48
	coin.dx=.5-rnd()
	coin.dy=.5-rnd()
	coin.dz=1+rnd()
	add(coins,coin)
end

function update_coin(c)
	c.x += c.dx
	c.y += c.dy
	_bounce_boo(c)
	c.dz += -.08
	c.z += c.dz
	if c.z <= 0 then
		make_item(c.x,c.y,48)
		del(coins,c)
	end
end

function draw_coin(c)
	draw_shadow(c.x,c.y)
	spr(c.sp,c.x,c.y-2-c.z)
end

function update_all_coins()
	for c in all(coins) do
		update_coin(c)
	end
end

function draw_all_coins()
	for c in all(coins) do
		draw_coin(c)
	end
end

function make_boo_alarm(x,y)
	local ba = {}
	ba.x=x+4
	ba.y=y
	ba.active=false
	add(booalarms,ba)
end

function start_booalarm(ba)
	ba.active=true
end

function update_boo_alarm(ba)
	if (not ba.active) return
	local haveboo=false
	for b in all(boos) do
		if collide(ba,b,60) then
			haveboo=true
		end
	end
	if not haveboo then
		ba.active=false
		del(booalarms,ba)
	end
end

function update_alarms()
	for ba in all(booalarms) do
		update_boo_alarm(ba)
	end
end

function make_wall(xx,yy)
	local wall = {}
	wall.x = xx*8
	wall.y=yy*8
	wall.health=60
	add(softwalls,wall)
end

function hurt_wall(w)
	w.health += -damage
	if w.health <= 0 then
		breakwall(w.x\8,w.y\8)
		del(softwalls,w)
	end
end

function breakwall(xx,yy)
	if fget(mget(xx,yy),4) then
		mset(xx,yy,115)
		_draw()
		flip()
		breakwall(xx-1,yy)
		breakwall(xx+1,yy)
		breakwall(xx,yy-1)
		breakwall(xx,yy+1)
	end
end
-->8
-- all entities

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

function unlock(mx,my)
	local tt = mget(mx,my)
	if (tt==99 and redkey) or
	 (tt==100 and bluekey) or
	 (tt==101 and orangekey) then
	 mset(mx,my,97)
		unlock(mx-1,my)
		unlock(mx+1,my)
		unlock(mx,my-1)
		unlock(mx,my+1)
		sfx(13,-2)
		sfx(13)
	end	
end

function bump(mx0,my0,mx1,my1)
	if fget(mget(mx0,my0),1) then
		unlock(mx0,my0)
	elseif fget(mget(mx1,my1),1) then
		unlock(mx1,my1)
	end	
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

function draw_shadow(x,y)
	palt(0,false)
	palt(15,true)
	spr(32,x,y)
	palt()
end

function collide(a,b,r)
	-- a and b both must have x and y
	-- r is radius
	local r = r or 8
	if a.x+r > b.x and
		b.x+r > a.x and
		a.y+r > b.y and
		b.y+r > a.y then
		return true
	else 
		return false
	end
end
-->8
-- utils

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

function contains(t,v)
	for vv in all(t) do
		if (v==vv) return true
	end
	return false
end

function set_map_around(x,y,sp)
	for xx=(x\8)-1,(x\8)+1,1 do
		for yy=(y\8)-1,(y\8)+1,1 do
			mset(xx,yy,sp)
		end
	end
end


function blink(n)
	if timer%(n*2) < n then
		return true
	else
		return false
	end
end
-->8
-- transitions

function start_title()
	_update60  = update_title
	_draw = draw_title
	-- play music
	music(0)
end

function update_title()
	if btnp(4) or btnp(5) then
		gamestart = true
		music(-1)
		start_gameloop()
	end
end

function draw_title()
	cls()
	local ys = 40
	coprint("mario bros",ys,3,7)
	coprint("mini mansion",ys+8,1,7)
end

function start_gameloop()
	fade_out()
	_update60 = update_gameplay
	_draw = draw_gameplay
	for i=1,20*camera_speed,1 do
		update_cam()
	end
	fade_in()
end

function start_end()
	_update60 = update_end
	_draw = draw_end
	music(0)
end

function update_end()
	if btnp(4) or btnp(5) then
		run()
	end
end

function draw_end()
	cls()
	local ys = 40
	if (not trophy) coprint("game over",ys,0,7)
	if (trophy) coprint("you win!",ys,0,7)
	fscore = coin_count+timer_sec
	coprint("final score: "..fscore,ys+12,10,0)
end

function fade_in()
	local imax=45
	for i=0,imax,1 do
		_draw()
		local y = 127*(i/imax)
		rectfill(0,y,127,127,1)
		flip()
	end
end

function fade_out()
	local imax=45
	for i=0,imax,1 do
		_draw()
		local y = 127*(i/imax)
		rectfill(0,0,127,y,1)
		flip()
	end
end
__gfx__
00000000000000000033373000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003337300333333300000000008887800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700033333333331f1f000888780088888880aaaa7a000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770003331f1f044f1f1f00888888888f1f1f0aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700044f1f1f04fffffff88f1f1f04ff1f1ffaaaffff000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007004fffffffffff1fff4ff1f1ff4f1fffff44ff1f1f00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffff1fff0ffff1114f1fffff0ff111114f1ffeef00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ffff11100fffff00ff1111100fffff0fff11ee100000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000fffff00331313000fffff0088c8c800ffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000050031331300377317008c88c8008778c70aadaadaa00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000550331331330177117388c88c880c77cc74ffdddddf00000000000000000000000000000000000000000000000000000000000000000000000000000000
05555560771111773311113377cccc7744cccc4477dddd7700000000000000000000000000000000000000000000000000000000000000000000000000000000
06666560771111773310113377cccc7744c0cc4477dddd7700000000000000000000000000000000000000000000000000000000000000000000000000000000
0000055001100110300000000cc00cc0400000000dddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000050033003300000000004400440000000000440044000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000033303330000000004440444000000000444044400000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff0066660000666600000111100066660000000000777777770066660000000009000a0000999998880989bbbb06666000000000000000000000000000
ff0000ff0677776006117760001cccc10611116000066000770707776666667700000669aaaa0000999b98889989bbb566556600000000000000000000000000
f000000f6777171667777886101c1c116111c1c600611600770707776660067700006779999960009999b895859999bb65665600000000000000000000000000
00000000067717166711788611ccccc10611c1c60611116077777777660660660006777777777600999999955555b9bb65665600000000000000000000000000
0000000006777776677777761cccccc106111116061111607700007766066066006777777777776099b90995555559bb66556660000000000000000000000000
f000000f677788766777777601cccc106111881600611600770770776660066600677770777770608bb9899555bbb55506666006000000000000000000000000
ff0000ff0677886006766760001cc100061188600006600077777777666666660677777707770776bbb9999955bbbb5500000006000000000000000000000000
ffffffff006666000060060000011000006666000000000077777777000000000677777707770776bbb9899955b5bb5500000660000000000000000000000000
0000000008e008e00099990000333300009aa70000aaaa0000aaaa0000aaaa000676777777777776bb9b888995b5bb5500000000000000000000000000000000
000990008888888e09aaaa9003377330009aa7000a8888a00acccca00a9999a00676778777778776bbbb888895bb5b5500000000000000000000000000000000
009aa9008888888e9aa9aaa973377337999aaaa70a8888a00acccca00a9999a006767688888887768bb8888985bbbb9500000000000000000000000000000000
09aaaa902888888e9aa99aa973333337909aaa0a00a8aaa000acaaa000a9aaa067776778888877608898888888bbb99500000000000000000000000000000000
09aaaa902888888e9aa99aa933333333999aaa9a00a888a000accca000a999a0677777778887776088800888889bb99500000000000000000000000000000000
009aa900028888809aa9aaa9071771700099990000a8aaa000acaaa000a9aaa06767777777777600808888888989999500000000000000000000000000000000
000990000028880009aaaa90071771700009a00000a888a000accca000a999a00606677777766000808088888880090000000000000000000000000000000000
000000000002800000999900007777000099a700000aaa00000aaa00000aaa000000066666600000808988888080000000000000000000000000000000000000
2e6dee6dee6dee6dee6dee622e6dee6dee6dee6dee6dee622e6dee622e6dee62ee6dee6dee6dee6d222522220555555000444444444444000000000000000000
2e6dee6dee6dee6dee6dee62e26dee6dee6dee6dee6dee2ee200002de26dee2dee5de56de66dee6d22225222051e815000441111111144000000000000000000
d26dee6dee6dee6dee6dee2d6d2dee6dee6dee6dee6de2d6ee00006dee00006dee5d5e6de666ee6dee6de56d05be825000441881522144000000000000000000
626dee6dee6dee6dee6dee266de2ee6dee6dee6dee6d2ed6ee00006dee00006dee65ee6dee666e6dee6d5e6d0555555000441889522144000000000000000000
6d2dee6dee6dee6dee6de2d66d6d2e6dee6dee6dee62d6d6ee00006dee00006dee6d5e6dee6d666dee65ee6d0581615000441889522144000000000000000000
6d2dee6dee6dee6dee6de2d6de6d626dee6dee6dee2ed6edee00006dee00006dee6de56dee6de66dee5d5e6d0589615000444444444444000000000000000000
e6d2ee6dee6dee6dee6d2d6ede6d6d2dee6dee6de2d6d6ede26dee2dee00006d22225222ee6dee66ee5de56d0555555000441111111144000000000000000000
e6d2ee6dee6dee6dee6d2d6ed6de6de2ee6dee6d2ed6ed6d2e6dee62ee00006d22252222ee6dee6dee6dee6d0500005000441111111144000000000000000000
d6de2e6dee6dee6dee62ed6d00000000444544450000000000000001ee00006dd6de6de2444544452ed6ed6d0000000000441111111144000000000000000000
de6d2e6dee6dee6dee62d6ed00000000444544450000000000000010ee00006dde6d6de2466544452ed6d6ed0000000000441111111144000000000000000000
de6de26dee6dee6dee2ed6ed00000000444544450000030000000100ee00006dd56de6d2446644452d6e55ed0000000000444444444444000000000000000000
6d6de26dee6dee6dee2ed6d600000000444544550000303011111111ee00006d6d5de552444664552d55d6d60000000000441111111144000000000000000000
6de6d62dee6dee6de26d6ed600000000444544450000000000010000ee00006d6de556d544456645556d5ed60000000000441111111144000000000000000000
6de6de2dee6dee6de2ed6ed600000000444544450000000000100000ee00006d6556de624445464526ed65d60000000000444444444444000000000000000000
e6d6de622222222226ed6d6e00000000444544450300000001000000ee00006de6d6de624445444526ed6d6e0000000000445500005544000000000000000000
e6de6d622222222226d6ed6e00000000445544453030000011111111ee00006de6de6d624455444526d6ed6e0000000000440000000044000000000000000000
d6de6de2000000012ed6ed6d55555555555555555555555500670067ee00006d0000000000000000000000000000000000000000000000000000000000000000
de6d6de2000000102ed6d6ed588888855cccccc55999999566566656ee00006d0000000000000000000000000000000000000000000000000000000000000000
de6de6d2000001002d6ed6ed580000855c0000c55900009500560056ee00006d0000000000000000000000000000000000000000000000000000000000000000
6d6de6d2111111112d6ed6d6580000855c0000c55900009500560056ee00006d0000000000000000000000000000000000000000000000000000000000000000
6de6d6d2000100002d6d6ed6588008855cc00cc55990099500560056ee00006d0000000000000000000000000000000000000000000000000000000000000000
6de6de620010000026ed6ed6588008855cc00cc55990099500560056ee00006d0000000000000000000000000000000000000000000000000000000000000000
e6d6de620100000026ed6d6e588888855cccccc55999999500560056e26dee2d0000000000000000000000000000000000000000000000000000000000000000
e6de6d621111111126d6ed6e555555555555555555555555005600562e6dee620000000000000000000000000000000000000000000000000000000000000000
d6de6de2222222222ed6ed6d00000001444544450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
de6d6d2dee6dee6de2d6d6ed00000010444544450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
de6d626dee6dee6dee2ed6ed00000100444544450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d6d2e6dee6dee6dee62d6d610101010444544550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6de2ee6dee6dee6dee6d2ed600010000444544450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d2dee6dee6dee6dee6de2d600100000444544450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e26dee6dee6dee6dee6dee2e01000000444544450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e6dee6dee6dee6dee6dee6210101010445544450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545000000000000000000000000000000
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545000000000000000000000000000000
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545000000000000000000000000000000
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545454595959595959545454545454545454545454545
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545000000000000000000000000000000
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545454595959595959545454545454545454545454545
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545000000000000000000000000000000
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545454595959595959545454545454545454545454545
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545000000000000000000000000000000
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545959595954545454545454545454545454545
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545000000000000000000000000000000
45454545454545454545454545454545454545454545454545454545454545454545454545454545141414141414949494941414141414144545454545454545
45454545141414141414141414141414141445454545454545451414141414141414141414141414454545454545454545000000000000000000000000000000
45454545454545454545454545453415151515151515151515544545454545454545454545454545041414141414949494941414141414244545454545454545
45454545341515151515151515151515155445454545454545453415151515151515151515151554454545454545454545000000000000000000000000000000
454545454545454545454545454506161616161616c416c416264545454545454545454545454545051515151515848484841515151515254534151515151554
45454545061616161616161616161616162645454545454545450616161616161616161616161626454545454545454500000000000000000000000000000000
45454545454545454545454545450616161616161616161616264545454545454545454545454545061616161616161616167416131316264506161622161626
45454545061616161616161616a21616162645454545454545450616161616161616161616161626454545454545454500000000000000000000000000000000
45454545454545454545454545450616161616161616161616264545454545454545454545454545061616161616161616167516161216264506162216161626
45454545061616161616161616161616162645454545454545450616161616161616161616161626454545454545454500000000000000000000000000000000
45454545454545454534151515151516161616161616161616151515151515151515151515151515061616161616161616167516161616261515221616232326
15151515156464646464161216641616162645454545454545450616161616161616161616161626454545454545454500000000000000000000000000000000
45454545454545454506131616161616161616161616161616161616161616161616161616161616461616167416161216167516161616361616161622232316
16161616161616161664161616641616161515151515151515151516161616161616161616161626454545454545454500000000000000000000000000000000
4545454545454545450633165316164216161616161622161616161616a216161316161616161616461616167516161616167516161616361616161616232316
16161616161616161664161616641616161616621616161616161616161616161616161616161626454545454545454500000000000000000000000000000000
45454545454545454506161616161616161616c21616161616161616161616161616161616161616461616167516163712167516161616361616221616232316
16161616161616161664161616641616161616621616161616161616161616161616821616161626454545454545454500000000000000000000000000000000
45454545454545454507171717171716161616161616161616171717171717171717171717171717061616167516161616167512161616261717162216161626
17171717171612161664161216641616161616621616161616161616161616161616161616161626454545454545454500000000000000000000000000000000
45454545454545454545454545450616161616221616161616264545454545454545454545454545061616167516161616127616161612264506161616161626
45454545061616161664161616641616161717171717171717171716161616161616161616161626454545454545454500000000000000000000000000000000
45454545454545454545454545450616161616161616161616264545454545454545454545454545061623167516161616161616161616264507171717171727
45454545061616161616626262641616162645454545454545450616161616161616161616161626454545454545454500000000000000000000000000000000
45454545454545454545454545450616161616161616161616264545454545454545454545454545061616167616161616161616161616264545454545454545
45454545061616161616161616641616162645454545454545450616161616161616161616161626454545454545454545450000000000000000000000000000
45454545454545454545454545450616161616161616c41616264545454545454545454545454545071717171717161616161717171717274545454545454545
45454545071717171717171717171717172745454545454545450616161616161616161616161626454545454545454545450000000000000000000000000000
45454545454545454545454545450717171717171717171717274545454545454545454545454545454545454506161616162645454545454545454545454545
45454545454545454545454545454545454545454545454545450717171717171717171717171727454545454545454545450000000000000000000000000000
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545454506161616162645454545454545454545454545
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545450000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555666666666666464646466666666666665555555555555555
55555555555555555555555555555555555555555555555545454545454545454545454545454545454545454545454545450000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555665555555555161616165555555555665555555555555555
55555555555555555555555555555555555555555555555545454545454545454545454545454545454545454545454545450000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555665555555555161616165555555555665555555555555555
55555555555555555555555555555555555555555555555545454545454545454545454545454545454545454545454545450000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555665555555555101616165555555555665555555555555555
55555555555555555555555555555555555555555555555545454545454545454545454545454545454545454545454545450000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555665555555555161616165555555555665555555555555555
55555555555555555555555555555555555555555555555545454545454545454545454545454545454545454545454545450000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555665555555555161616165555555555665555555555555555
55555555555555555555555555555555555555555555555545454545454545454545454500000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555665555135555555555555555556355665555555555555555
55555555555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555665555555555555555555555555555665555555555555555
55555555555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555666666666666666666666666666666665555555555555555
55555555555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
444544454445d6de6de2000000019aa9aaa900000001ee00006d0000000100000001000000010000000100000001000000010000000100000001000000010000
444544454445de6d6de2000000109aa99aa900000010ee00006d0000001000000010000000100000001000000010000000100000001000000010000000100000
444544454445de6de6d2000001009aa99aa900000100ee00006d0000010000000100000001000000010000000100000001000000010000000100000001000000
4455444544556d6de6d2111111119aa9aaa911111111ee00006d1111111111111111111111111111111111111111111111111111111111111111111111111111
4445444544456de6d6d20001000009aaaa9000010000ee00006d0001000000010000000100000001000000010000000100000001000000010000000100000001
4445444544456de6de62001000000099990000100000ee00006d0010000000100000001000000010000000100000001000000010000000100000001000000010
444544454445e6d6de62010000000100000001000000ee00006d0100000001000000010000000100000001000000010000000100000001000000010000000100
444544554445e6de6d62111111111111111111111111ee00006d1111111111111111111111111111111111111111111111111111111111111111111111111111
444544454445d6de6de2000000010000000100000001ee00006d0000000100000001000000010000000100000001000000010000000100000001000000010000
444544454445de6d6de2000000100000001000000010ee00006d0000001000000010000000100000001000000010000000100000001000000010000000100000
444544454445de6de6d2000001000000010000000100ee00006d0000010000000100000001000000010000000100000001000000010000000100000001000000
4455444544556d6de6d2111111111111111111111111ee00006d1111111111111111111111111111111111111111111111111111111111111111111111111111
4445444544456de6d6d2000100000001000000010000ee00006d0001000000010000000100000001000000010000000100000001000000010000000100000001
4445444544456de6de62001000000010000000100000ee00006d0010000000100000001000000010000000100000001000000010000000100000001000000010
444544454445e6d6de62010000000100000001000000e26dee2d0100000001000000010000000100000001000000010000000100000001000000010000000100
444544554445e6de6d621111111111111111111111112e6dee621111111111111111111111111111111111111111111111111111111111111111111111111111
444544454445d6de6de2222222222222222222222222222222222222222200000001000000010000000100000001222222222222222222222222222222222222
444544454445de6d6d2dee6dee6dee6dee6dee6dee6dee6dee6dee6dee6d00000010000000100000001000000010ee6dee6dee6dee6dee6dee6dee6dee6dee6d
444544454445de6d626dee6dee6dee6dee6dee6dee6dee6dee6dee6dee6d00000100000001000000010000000100ee6dee6dee6dee6dee6dee6dee6dee6dee6d
4455444544556d6d2e6dee6dee6dee6dee6dee6dee6dee6dee6dee6dee6d11111111111111111111111111111111ee6dee6dee6dee6dee6dee6dee6dee6dee6d
4445444544456de2ee6dee6dee6dee6dee6dee6dee6dee6dee6dee6dee6d00010000000100000001000000010000ee6dee6dee6dee6dee6dee6dee6dee6dee6d
4445444544456d2dee6dee6dee6dee6dee6dee6dee6dee6dee6dee6dee6d00100000001000000010000000100000ee6dee6dee6dee6dee6dee6dee6dee6dee6d
444544454445e26dee6dee6dee6dee6dee6dee6dee6dee6dee6dee6dee6d01000000010000000100000001000000ee6dee6dee6dee6dee6dee6dee6dee6dee6d
4445445544452e6dee6dee6dee6dee6dee6dee6dee6dee6dee6dee6dee6d11111111111111111111111111111111ee6dee6dee6dee6dee6dee6dee6dee6dee6d
4445444544454445444544454445444544454445444544454445d6de6de2000000010000000100000001000000012ed6ed6d4445444544454445444544454445
4445444544454445444544454445444544454445444544454445de6d6de2000000100000001000000010000000102ed6d6ed4445444544454445444544454445
4445444544454445444544454445444544454445444544454445de6de6d2000001000000010000000100000001002d6ed6ed4445444544454445444544454445
44554445445544454455444544554445445544454455444544556d6de6d2111111111111111111111111111111112d6ed6d64445445544454455444544554445
44454445444544454445444544454445444544454445444544456de6d6d2000100000001000000010000000100002d6d6ed64445444544454445444544454445
44454445444544454445444544454445444544454445444544456de6de620010000000100000001000000010000026ed6ed64445444544454445444544454445
4445444544454445444544454445444544454445444544454445e6d6de620100000001000000010000000100000026ed6d6e4445444544454445444544454445
4445445544454455444544554445445544454455444544554445e6de6d621111111111111111111111111111111126d6ed6e4455444544554445445544454455
4445444544454445444544454445444544454445444544454445d6de6de2000000010000000100000001000000012ed6ed6d4445444544454445444544454445
4445444544454445444544454445444544454445444544454445de6d6de2000000100000001000000010000000102ed6d6ed4445444544454445444544454445
4445444544454445444544454445444544454445444544454445de6de6d2000001000000010000000100000001002d6ed6ed4445444544454445444544454445
44554445445544454455444544554445445544454455444544556d6de6d2111111111111111111111111111111112d6ed6d64445445544454455444544554445
44454445444544454445444544454445444544454445444544456de6d6d2000100000001000000010000000100002d6d6ed64445444544454445444544454445
44454445444544454445444544454445444544454445444544456de6de620010000000100000001000000010000026ed6ed64445444544454445444544454445
4445444544454445444544454445444544454445444544454445e6d6de620100000001000000010000000100000026ed6d6e4445444544454445444544454445
4445445544454455444544554445445544454455444777777777777777777777111777777777777777771111111126d6ed6e4455444544554445445544454455
00000000000000670067006700670067006700670067333733373337333773375557333733377337733755555555006700670067006700670067006700670067
0000000000006656665666566656665666566656665733373737373773773737ccc737373737373737775cccccc5665666566656665666566656665666566656
030000000300005600560056005600560056005600573737333733777377373700c733773377373733375c0000c5005600560056005600560056005600560056
303000003030005600560056005600560056005600573737373737377377373700c737373737373777375c0000c5005600560056005600560056005600560056
00000000000000560056005600560056005600560057373737373737333733770cc733373737337733775cc00cc5005600560056005600560056005600560056
00000000000000560056005600560056005600560057777777777777777777700cc777777777777777755cc00cc5005600560056005600560056005600560056
0000030000000056005600560056005600560056005600560056005600565cccccc55cccccc55cccccc55cccccc5005600560056005600560056005600560056
00003030000000560056005600560056005600577777777777777777005777777777777577777777777777755555005600560056005600560056005600560056
00000000000000670067000000000000000000071117111711771117000711171117117771171117711711770001000000000000000000000000000000000000
00000000000066566656000000000000000000071117717717177177000711171717171717777177171717170010000000000000000000000000000000000000
03000000030000560056000003000000030000071717717717177170030717171117171711177177171717170100000003000000030000000300000003000000
30300000303000560056000030300000303000071717717717177177303717171717171777177177171717171111000030300000303000003030000030300000
00000000000000560056000000000000000000071717111717171117000717171717171711771117117717170000000000000000000000000000000000000000
00000000000000560056000000000000000000077777777777777777000777777777777777777777777777770000000000000000000000000000000000000000
00000300000000560056030000000300000003000000030000000300000001000000010000000100000001000000030000000300000003000000030000000300
00003030000000560056303000003030000030300000303000003030000011333731111111111111111111111111303000003030000030300000303000003030
00000000000000670067000000000000000000000000000000000000000003333333000088878000000100000001000000000000000000000000000000000000
0000000000006656665600000000000000000000000000000000000000003331f1f0000888888800001000000010000000000000000000000000000000000000
03000000030000560056000003000000030000000300000003000000030044f1f1f00088f1f1f000010000000100000003000000030000000300000003000000
3030000030300056005600003030000030300000303000003030000030304fffffff114ff1f1ff11111111111111000030300000303000003030000030300000
000000000000005600560000000000000000000000000000000000000000ffff1fff004f1fffff01000000010000000000000000000000000000000000000000
0000000000000056005600000000000000000000000000000000000000000ffff111001ff1111110000000100000000000000000000000000000000000000000
00000300000000560056030000000300000003000000030000000300000001fffff00100fffff100000001000000030000000300000003000000030000000300
000030300000005600563030000030300000303000003030000030300000131331311118c88c8111111111111111303000003030000030300000303000003030
000000000000006700670000000000000000000000000000000000000000331331330088c88c8800000100000001000000000000000000000000000000000000
000000000000665666560000000000000000000000000000000000000000771111770077cccc7700001000000010000000000000000000000000000000000000
030000000300005600560000030000000300000003000000030000000300771111770077cccc7700010000000100000003000000030000000300000003000000
30300000303000560056000030300000303000003030000030300000303011100111111cc00cc111111111111111000030300000303000003030000030300000
00000000000000560056000000000000000000000000000000000000000003300330000440044001000000010000000000000000000000000000000000000000
00000000000000560056000000000000000000000000000000000000000003330333000444044410000000100000000000000000000000000000000000000000
00000300000000560056030000000300000003000000030000000300000000000000010000000100000001000000030000000300000003000000030000000300
00003030000000560056303000003030000030300000303000003030000011000011111100001111111111111111303000003030000030300000303000003030
00000000000000670067000000000000000000000000000000000000000000000001000000010000000100000001000000000000000000000000000000000000
00000000000066566656000000000000000000000000000000000000000000000010000000100000001000000010000000000000000000000000000000000000
03000000030000560056000003000000030000000300000003000000030000000100000001000000010000000100000003000000030000000300000003000000
30300000303000560056000030300000303000003030000030300000303011111111111111111111111111111111000030300000303000003030000030300000
00000000000000560056000000000000000000000000000000000000000000010000000100000001000000010000000000000000000000000000000000000000
00000000000000560056000000000000000000000000000000000000000000100000001000000010000000100000000000000000000000000000000000000000
00000300000000560056030000000300000003000000030000000300000001000000010000000100000001000000030000000300000003000000030000000300
00003030000000560056303000003030000030300000303000003030000011111111111111111111111111111111303000003030000030300000303000003030
00000000000000670067000000000000000000000000000000000000000000000001000000010000000100000001000000000000000000000000000000000000
00000000000066566656000000000000000000000000000000000000000000000010000000100000001000000010000000000000000000000000000000000000
03000000030000560056000003000000030000000300000003000000030000000100000001000000010000000100000003000000030000000300000003000000
30300000303000560056000030300000303000003030000030300000303011111111111111111111111111111111000030300000303000003030000030300000
00000000000000560056000000000000000000000000000000000000000000010000000100000001000000010000000000000000000000000000000000000000
00000000000000560056000000000000000000000000000000000000000000100000001000000010000000100000000000000000000000000000000000000000
00000300000000560056030000000300000008e008e003000000030000000100000001000000010000000100000003000000030000000300000003aaaa000300
0000303000000056005630300000303000008888888e3030000030300000111111111111111111111111111111113030000030300000303000003acccca03030
0000000000000067006700000000000000008888888e0000000000000000000000000000000000000000000000000000000000000000000000000acccca10000
0000000000006656665600000000000000002888888e00000000000000000000000000000000000000000000000000000000000000000000000000acaaa00000
0300000003000056005600000300000003002888888e00000300000003000000030000000300000003000000030000000300000003000000030000accca00000
3030000030300056005600003030000030300288888000003030000030300000303000003030000030300000303000003030000030300000303000acaaa00000
0000000000000056005600000000000000000028880000000000000000000000000000000000000000000000000000000000000000000000000000accca00000
00000000000000560056000000000000000000028000000000000000000000000000000000000000000000000000000000000000000000000000000aaa000000
00000300000000560056030000000300000001000000030000000300000003000000030000000300000003000000030000000300000003000000010000000300
00003030000000560056303000003030000011111111303000003030000030300000303000003030000030300000303000003030000030300000111111113030
00000000000000670067000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000066566656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03000000030000560056000003000000030000000300000003000000030000000300000003000000030000000300000003000000030000000300000003000000
30300000303000560056000030300000303000003030000030300000303000003030000030300000303000003030000030300000303000003030000030300000
00000000000000560056000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000560056000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000300000000560056030000000300000003000000030000000300000003000000030000000300000003000000030000000300000003000000030000000300
00003030000000560056303000003030000030300000303000003030000030300000303000003030000030300000303000003030000030300000303000003030
00000000000000670067006700670067006700670067006700670067006700670067006700670067006700670067006700670067006700670067006700670067
00000000000066566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656665666566656
03000000030000560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056
30300000303000560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056
00000000000000560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056
00000000000000560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056
00000300000000560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056
00003030000000560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056005600560056
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006
60300030303330033033300000000003303300033033000330330003303300033033000000000000000000000000000777770000000000777000000000000006
60300030300300300003000300000003333300033333000333330003333300033333000000000000000000000000000077700007000000707000000000000006
60300030300300300003000000000003333300033333000333330003333300033333000000000000000000000000000007000000000000707000000000000006
60300030300300303003000300000000333000003330000033300000333000003330000000000000000000000000000077700007000000707000000000000006
60333003303330333033300000000000030000000300000003000000030000000300000000000000000000000000000777770000000000777000000000000006
60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006
60888088808880888008800000000008808800088088000880880008808800088088000000000000000aa00aa0aaa0aa000aa000000000aaa000000000000006
6088808080808008008080080000000888880008888800088888000888880008888800000000000000a000a0a00a00a0a0a0000a000000a0a000000000000006
6080808880880008008080000000000888880008888800088888000888880008888800000000000000a000a0a00a00a0a0aaa000000000a0a000000000000006
6080808080808008008080080000000088800000888000008880000088800000888000000000000000a000a0a00a00a0a000a00a000000a0a000000000000006
60808080808080888088000000000000080000000800000008000000080000000800000000000000000aa0aa00aaa0a0a0aa0000000000aaa000000000000006
60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006
60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666

__gff__
0000000000000000000000000000000000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010001010101010101011511150808080808010101000100010115111500080808080100010303030101000000000000000001010100040000000000000000000000
0000010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454000000000000000000000000000000000000000000000000000000000000000000000000000000
5454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454000000000000000000000000000000000000000000000000000000000000000000000000000000
5454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454000000000000000000000000000000000000000000000000000000000000000000000000000000
5454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454000000000000000000000000000000000000000000000000000000000000000000000000000000
5454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454000000000000000000000000000000000000000000000000000000000000000000000000000000
5454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454000000000000000000000000000000000000000000000000000000000000000000000000000000
5454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0003000026053280531335110351153511335118351163511d3511c35126351233510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
070a00000a355073501f3552235022351000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 090b4344
02 0a0b4344

