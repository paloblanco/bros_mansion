function _init()
	-- poke(0x5F36, 0x8) -- draw sprite 0 
    -- poke(0x5f36,1) -- multidisplay
    poke(0x5f36,9)
	poke(24365,1) -- mouse
    
    camera_all(0,0)
    
    -- mapping vars
    current_tile = 0

    -- control vars
    -- mouse
    m0 = false
    m0p = false
    m1 = false
    m1p = false
    m2 = false
    m2p = false
    ms = 0 --scroll
end

function _update()
    controls()
    if (m0) place_tile()
    if (m1) dropper_tile()
    if (check_key("5")) save_local()
end



function dropper_tile()
    local xx = mx\8
    local yy = my\8
    if xx>=0 and xx < 128 and yy>=0 and yy < 64 then
        current_tile = mget(xx,yy)
    end
end

function place_tile()
    local xx = mx\8
    local yy = my\8
    if xx>=0 and xx < 128 and yy>=0 and yy < 64 then
        mset(xx,yy,current_tile)
    end
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
    update_mouse()

    -- arrows for tile selection
    if (btnp(0,0)) current_tile += -1
    if (btnp(1,0)) current_tile += 1
    if (btnp(2,0)) current_tile += -16
    if (btnp(3,0)) current_tile += 16
    if (current_tile<0) current_tile = current_tile+8*16 
    if (current_tile>127) current_tile = current_tile-8*16

    

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
    
    ctilex = 8*(current_tile%16)
    ctiley = 64 + 8*(current_tile\16)
    rect(ctilex,ctiley,ctilex+7,ctiley+7,7)
    palt()
    if (myraw > 128+64) circfill(mxraw,myraw-128,2)
end

-- control stuff
function get_key()
    return(stat(31))
end

function check_key(key)
    return get_key()==key
end

function get_m0()
    return stat(34)&1
end

function update_mouse()
    local m0new = stat(34)&1
    local m1new = (stat(34)&2) >>> 1
    local m2new = (stat(34)&4) >>> 2

    m0new = m0new==1
    m1new = m1new==1
    m2new = m2new==1

    m0p = false
    m1p = false
    m2p = false

    if (m0new and not m0) m0p = true
    if (m1new and not m1) m1p = true
    if (m2new and not m2) m2p = true

    m0 = m0new
    m1 = m1new
    m2 = m2new

    ms = stat(36)

    mxraw = stat(32)
    myraw = stat(33)
    mx = stat(32) + camx
	my = stat(33) + camy
end
