function _init()
	-- poke(0x5F36, 0x8) -- draw sprite 0 
    -- poke(0x5f36,1) -- multidisplay
    poke(0x5f36,9)
	poke(24365,1) -- mouse
    
    camera_all(0,0)
end

function _update()
    controls()
end

function _draw()
	for i=0,3,1 do
        _map_display(i)
        camera(128*(i%2) + camx,128*(i\2)+camy)
        draw_all()
    end
    draw_picker()
end

function draw_all()
    cls(1)
    palt(0)
    map()
    circfill(mx,my,2)
    palt()
end

function camera_all(x,y)
    camx = x
    camy = y
end

function controls()
    move_speed = 4
    -- ESDF for camera
    if (btn(0,1)) camx += -move_speed
    if (btn(1,1)) camx += move_speed
    if (btn(2,1)) camy += -move_speed
    if (btn(3,1)) camy += move_speed

    -- mouse
    mxraw = stat(32)
    myraw = stat(33)
    mx = stat(32) + camx
	my = stat(33) + camy
end

function save_local()
    cstore(0,0,0X3000)
end

function draw_picker()
    _map_display(2)
    camera()
    line(0,63,128,63,6)
    palt(0)
    spr(0,0,64,16,8)
    palt()
    if (myraw > 128+64) circfill(mxraw,myraw-128,2)
end