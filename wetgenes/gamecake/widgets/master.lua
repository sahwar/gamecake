-- copy all globals into locals
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


-- widget class master
-- the master widget




--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

function M.bake(oven,wmaster)
wmaster=wmaster or {}

local gl=oven.gl
local cake=oven.cake
local canvas=oven.canvas

local framebuffers=oven.rebake("wetgenes.gamecake.framebuffers")


--
-- add meta functions
--
function wmaster.setup(widget,def)

	local master=widget
	local meta=widget.meta
--	local win=def.win


	master.throb=0
--	master.fbo=_G.win.fbo(0,0,0) -- use an fbo
--	master.fbo=framebuffers.create(0,0,0)
	master.dirty=true

-- the master gets some special overloaded functions to do a few more things
	function master.update(widget)
	
		local throb=(widget.throb<128)
		
		widget.throb=widget.throb-4
		if widget.throb<0 then widget.throb=255 end
		
		if throb ~= (widget.throb<128) then -- dirty throb...
			if widget.focus then
				if widget.focus.class=="textedit" then
					widget.focus:set_dirty()
				end
			end
		end

		meta.update(widget)
	end
	
	function master.layout(widget)
		meta.layout(widget)
		master.remouse(widget)
	end

	local dirty_fbos={}
	local find_dirty_fbos -- to recurse is defined...
	find_dirty_fbos=function(widget)
		if widget.fbo and widget.dirty then
			dirty_fbos[ #dirty_fbos+1 ]=widget
		end
		for i,v in ipairs(widget) do
			find_dirty_fbos(v)
		end
	end

	function master.draw(widget)

		dirty_fbos={}
		find_dirty_fbos(widget)

		gl.Disable(gl.CULL_FACE)
		gl.Disable(gl.DEPTH_TEST)

		gl.PushMatrix()
		
		if #dirty_fbos>0 then
			for i=#dirty_fbos,1,-1 do -- call in reverse so sub fbos can work
				meta.draw(dirty_fbos[i]) -- dirty, so this only builds the fbo
			end
		end

		meta.draw(widget)
		
		gl.PopMatrix()
	end
	
	function master.msg(widget,m)
		if m.class=="key" then
			widget:key(m.ascii,m.keyname,m.action)
		elseif m.class=="mouse" then
			widget:mouse(m.action,m.x,m.y,m.keycode)
		end
	end
--
-- handle key input
--
	function master.key(widget,ascii,key,act)

		if master.focus then -- key focus, steals all the key presses until we press enter again
		
			master.focus:key(ascii,key,act)
			
		else
		
			if act==1 then
				if key=="space" or key=="return" then
					if master.over then
						master.over:call_hook("click")
					end
					return
				end
			
--print(1,master.over)
			
				local vx=0
				local vy=0
				if key=="left"  then vx=-1 end
				if key=="right" then vx= 1 end
				if key=="up"    then vy=-1 end
				if key=="down"  then vy= 1 end
				
				if vx~=0 or vy~=0 then -- move hover selection
				
					if master.over then
						local over=master.over
						local best={}
						local ox=over.pxd+(over.hx/2)
						local oy=over.pyd+(over.hy/2)

--print("over",ox,oy)

						master:call_descendents(function(w)
							if w.solid and w.hooks then
								local wx=w.pxd+(w.hx/2)
								local wy=w.pyd+(w.hy/2)
								local dx=wx-ox
								local dy=wy-oy
								local dd=0
								if vx==0 then dd=dd+dx*dx*16 else dd=dd+dx*dx end
								if vy==0 then dd=dd+dy*dy*16 else dd=dd+dy*dy end
--print(w,wx,wy,dx,dy,by,by)
								if	( dx<0 and vx<0 ) or
									( dx>0 and vx>0 ) or
									( dy<0 and vy<0 ) or
									( dy>0 and vy>0 ) then -- right direction
									
									if best.over then
										if best.dd>dd then -- closer
											best.over=w
											best.dd=dd
										end
									else
										best.over=w
										best.dd=dd
									end
								end
							end
						end)
						if best.over then
							over:set_dirty()
							best.over:set_dirty()
							master.over=best.over
						end
					end
					if not master.over then
						master:call_descendents(function(v)
							if not master.over then
								if v.solid and v.hooks then
									master.over=v
									v:set_dirty()
								end
							end
						end)
					end
					
				end
--print(2,master.over)
			end
		end

	end

--
-- set the mouse position to its last position
-- call this after adding/removing widgets to make sure they highlight properly
--	
	function master.remouse(widget)
		local p=widget.last_mouse_position or {0,0}
		widget.mouse(widget,nil,p[1],p[2],nil)
	end
--
-- handle mouse input
--	
	function master.mouse(widget,act,x,y,key)
--print(act,x,y,key)	
		master.last_mouse_position={x,y}
	
--		if widget.state=="ready" then
		
			if master.active and (master.active.parent.class=="slide" or master.active.parent.class=="oldslide") then -- slide :)
			
				local w=master.active
				local p=master.active.parent
				
				local minx=p.pxd
				local miny=p.pyd+p.hy-w.hy
				local maxx=p.pxd+p.hx-w.hx
				local maxy=p.pyd
				
				w.pxd=x-master.active_x
				w.pyd=y-master.active_y
				
				if w.pxd<minx then w.pxd=minx end
				if w.pxd>maxx then w.pxd=maxx end
				if w.pyd<miny then w.pyd=miny end
				if w.pyd>maxy then w.pyd=maxy end
				
				w.px=w.pxd-p.pxd
				w.py=w.pyd-p.pyd
			
				w:call_hook("slide")
				
				w:set_dirty()

			end
			
			local old_active=master.active
			local old_over=master.over
			for i,v in ipairs(widget) do
				meta.mouse(v,act,x,y,key)
			end
			
			if act== 1 then
				master.press=true
			end
			if act==-1 then
				master.press=false
				master.active=nil
			end
			
--mark as dirty
			if master.active~=old_active then
				if master.active then master.active:set_dirty() end
				if old_active then old_active:set_dirty() end
			end
			if master.over~=old_over then
				if master.over then master.over:set_dirty() end
				if old_over then old_over:set_dirty() end
			end
			
--		end
	end
--

	function master.clean_all(m)
		meta.clean_all(m)
		master.over=nil
		master.active=nil
		master.focus=nil
	end
end

return wmaster
end
