--
-- (C) 2013 Kriss@XIXs.com
--
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wzips=require("wetgenes.zips")
local wsbox=require("wetgenes.sandbox")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")

-- handle a simple oven for win programs,
-- all it does is call other ovens/mods functions.

local function print(...) return _G.print(...) end

local function assert_resume(co)

	local a,b=coroutine.resume(co)
	
	if a then return a,b end -- no error
	
	error( b.."\nin coroutine\n"..debug.traceback(co) ) -- error
end


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

function M.bake(opts)

	local oven={}

		oven.opts=opts or {}

--print(wwin.flavour)


-- check if we already have junk in our local dir, and if so then dont use the users HOME dir

oven.homedir="./"

local fp=io.open(wwin.files_prefix.."settings.lua","r")
if fp then -- stick with what we have
	fp:close()
else


	if ( wwin.flavour=="linux" or wwin.flavour=="raspi" or wwin.flavour=="osx" ) and wwin.posix then -- we need to store in the homedir

		local homedir=os.getenv("HOME")

		if homedir then
			wwin.files_prefix=homedir.."/.config/"..(opts.name or "gamecake").."/files/"
			wwin.cache_prefix=homedir.."/.config/"..(opts.name or "gamecake").."/cache/"

			local wbake=require("wetgenes.bake")
			wbake.create_dir_for_file(wwin.files_prefix.."t.txt")
			wbake.create_dir_for_file(wwin.cache_prefix.."t.txt")

			oven.homedir=homedir.."/"
		end
		
	end

	if wwin.flavour=="windows" then -- we need to store in the homedir

		local homedir=os.getenv("USERPROFILE")

		if homedir then
			wwin.files_prefix=homedir.."/gamecake/"..(opts.name or "gamecake").."/files/"
			wwin.cache_prefix=homedir.."/gamecake/"..(opts.name or "gamecake").."/cache/"

			local wbake=require("wetgenes.bake")
			wbake.create_dir_for_file(wwin.files_prefix.."t.txt")
			wbake.create_dir_for_file(wwin.cache_prefix.."t.txt")

			oven.homedir=homedir.."/"
		end

	end
	
end

--[[
print(wwin.files_prefix)
print(wwin.cache_prefix)
print(oven.homedir)
os.exit()
]]


-- pull in info about what art we baked		
		local lson=wzips.readfile("lua/init_bake.lua")
		if lson then
--print(lson)
			oven.opts.bake=wsbox.lson(lson)
			oven.opts.smell=oven.opts.bake.smell or oven.opts.smell -- smell overides
--print(oven.opts.bake.stamp)
		end

		
--opts.disable_sounds=true
		
		oven.baked={}
		oven.mods={}

--
-- preheat a normal oven
-- you may perform this yourself if you want more oven control
--
		function oven.preheat()

			oven.frame_rate=1/opts.fps -- how fast we want to run
			oven.frame_time=0

			local inf={width=opts.width,height=opts.height,title=opts.title,overscale=opts.overscale}
			local screen=wwin.screen()

			inf.x=(screen.width-inf.width)/2
			inf.y=(screen.height-inf.height)/2

			if wwin.flavour=="raspi" then -- do fullscreen on raspi
				inf.x=0
				inf.y=0
				inf.width=screen.width
				inf.height=screen.height
				inf.dest_width=screen.width
				inf.dest_height=screen.height
				if inf.height>=480*2 then -- ie a 1080 monitor, double the pixel size
					inf.width=inf.width/2
					inf.height=inf.height/2
				end
			end


			oven.win=wwin.create(inf)
			oven.win:context({})

require("gles").GetError()
require("gles").CheckError() -- uhm this fixes an error?

--wwin.hardcore.peek(oven.win[0])

			local doshow=opts.show
			for i,v in ipairs(opts) do -- check extra options
				if     v=="windowed" then
					doshow="win"
				elseif v=="fullscreen" then
					doshow="full"
				elseif v=="maximised" then
					doshow="max"
				end
			end
			if doshow then oven.win:show(doshow) end

--			oven.win:show("full")
--			oven.win:show("max")

			oven.rebake("wetgenes.gamecake.cake") -- bake the cake in the oven,

			-- the order these are added is important for priority, top of list is lowest priority, bottom is highest.
			oven.rebake_mod("wetgenes.gamecake.mods.escmenu") -- escmenu gives us a doom style escape menu
			oven.rebake_mod("wetgenes.gamecake.mods.console") -- console gives us a quake style tilda console
			oven.rebake_mod("wetgenes.gamecake.mods.keys") -- touchscreen keys and posix keymaping
			oven.rebake_mod("wetgenes.gamecake.mods.mouse") -- auto fake mouse on non windows builds
			oven.rebake_mod("wetgenes.gamecake.mods.layout") -- screen layout options
			oven.rebake_mod("wetgenes.gamecake.mods.snaps") -- builtin screen snapshot code

			if wzips.exists("data/wskins/soapbar.png") or wzips.exists("data/wskins/soapbar.00.lua")then -- we got us better skin to use :)
				oven.rebake("wetgenes.gamecake.widgets.skin").load("soapbar")
			end

			if opts.start then
				oven.next=oven.rebake(opts.start)
			end
			
			
			return oven
		end
		


-- require and bake oven.baked[modules] in such a way that it can have simple circular dependencies

		function oven.rebake(name)

			local ret=oven.baked[name]
			
			if not ret then
		
				if type(name)=="function" then -- allow bake function instead of a name
					return name(oven,{})
				end
			
				ret={modname=name}
				oven.baked[name]=ret
				ret=assert(require(name)).bake(oven,ret)
				
			end

			return ret
		end


-- this performs a rebake and adds the baked module into every update/draw function
-- so we may insert extra functionality without having to modify the running app
-- eg a console or an onscreen keyboard
		function oven.rebake_mod(name)
		
			if oven.mods[name] then return oven.mods[name] end -- already setup, nothing else to do
			local m=oven.rebake(name) -- rebake mod into this oven

			oven.mods[name]=m			-- store baked version by its name
			table.insert(oven.mods,m)		-- and put it at the end of the list for easy iteration
			
			m.setup() -- and call setup since it will always be running from now on until it is removed
			
			return m
		end
		

		if opts.times then
			oven.times={}
			function oven.times.create()
				local t={}
				t.time=0
				t.time_live=0
				
				t.hash=0
				t.hash_live=0
				
				t.started=0
				
				function t.start()
					t.started=oven.win and oven.win.time() or 0
				end
				
				function t.stop()
					local ended=oven.win and oven.win.time() or 0
					
					t.time_live=t.time_live + ended-t.started
					t.hash_live=t.hash_live + 1
				end
				
				function t.done()
					t.time=t.time_live
					t.hash=t.hash_live
					t.time_live=0
					t.hash_live=0
					
				end
				
				return t
			end
			oven.times.update=oven.times.create()
			oven.times.draw=oven.times.create()
		end

		function oven.change()

		-- handle oven changes

			if oven.next then
			
				oven.clean()
				
				if type(oven.next)=="string" then	 -- change by required name
				
					oven.next=oven.rebake(oven.next)
					
				elseif type(oven.next)=="boolean" then -- special exit oven
				
--					if wwin.hardcore.finish then
--						wwin.hardcore.finish() -- try a more serious quit?					
--						oven.next=nil
--					else
					if wwin.hardcore.task_to_back then -- on android there is no quit, only back
						wwin.hardcore.task_to_back()						
						if opts.start then
							oven.next=oven.rebake(opts.start) -- beter than staying on the menu
						else
							oven.next=nil
						end
					else
						oven.next=nil
						oven.finished=true		
					end
					
					oven.last=oven.now
					oven.now=oven.next
					
				end

				if oven.next then
					oven.last=oven.now
					oven.now=oven.next
					oven.next=nil
					
					oven.setup()
				end
				
			end
			
		end

		function oven.setup()	
			if oven.now and oven.now.setup then
				oven.now.setup() -- this will probably load data and call the preloader
			end
--print("setup preloader=off")
			oven.preloader_enabled=false -- disabled preloader after first setup completes
		end

		oven.started=false -- keep track of startstop state
		oven.do_start=false -- flag start
		function oven.start()	
			oven.do_start=false
			if oven.started then return end -- already started
			oven.started=true

			oven.win:start()
			oven.cake.start()
			oven.cake.canvas.start()
			if oven.now and oven.now.start then
				oven.now.start()
			end
--print("start preloader=off")
			if oven.preloader_enabled=="stop" then -- we turned on at stop so turn off at start
				oven.preloader_enabled=false
			end

		end

		function oven.stop()
			if not oven.started then return end
--print("stop preloader=on")
			oven.rebake(opts.preloader or "wetgenes.gamecake.spew.preloader").reset()
			oven.preloader_enabled="stop"
			oven.win:stop()
			oven.cake.stop()
			oven.cake.canvas.stop()
			if oven.now and oven.now.stop then
				oven.now.stop()
			end
			oven.started=false
		end

		function oven.clean()
			if oven.now and oven.now.clean then
				oven.now.clean()
			end
		end

		function oven.update()

			if oven.do_backtrace then
				oven.do_backtrace=false
				if oven.update_co then
					print( debug.traceback(oven.update_co) ) -- debug where we are?
				else
					print( debug.traceback() ) -- debug where we are?
				end
			end

			if oven.update_co then -- just continue coroutine until it ends
				if coroutine.status(oven.update_co)~="dead" then
--					print( "CO:"..coroutine.status(oven.update_co) )
					assert_resume(oven.update_co) -- run it, may need more than one resume before it finishes
					return
				else
					oven.update_co=nil
				end
			end
--[[
collectgarbage()
local gci=gcinfo()		
local gb=oven.gl.counts.buffers				
print(string.format("mem=%6.0fk gb=%4d",math.floor(gci),gb))
]]

			if oven.frame_rate and oven.frame_time then --  framerate limiter enabled
			
				if oven.frame_time<(oven.win:time()-0.500) then oven.frame_time=oven.win:time() end -- prevent race condition
				
				if wwin.hardcore.sleep then
					while (oven.frame_time-oven.frame_rate)>oven.win:time() do wwin.hardcore.sleep(0.0001) end -- sleep here until we need to update
				else
					if (oven.frame_time-oven.frame_rate)>oven.win:time() then return end -- cant sleep, just skip
				end
							
			end

			local f
			f=function()
			
				if oven.do_start then
					oven.start()
				end

				oven.change() -- run setup/clean codes if we are asked too

				if oven.frame_rate and oven.frame_time then --  framerate limiter enabled
					oven.frame_time=oven.frame_time+oven.frame_rate -- step frame forward one tick				
				end

--print( "UPDATE",math.floor(10000000+(oven.win:time()*1000)%1000000) )

				if oven.times then oven.times.update.start() end
				
				if oven.now and oven.now.update then
					oven.now.update()
				end
				for i,v in ipairs(oven.mods) do
					if v.update then
						v.update()
					end
				end

				if oven.times then oven.times.update.stop() end
				
				if oven.frame_rate and oven.frame_time then --  framerate limiter enabled
					if (oven.frame_time-oven.frame_rate)<oven.win:time() then -- repeat until we are a frame ahead of real time
						return f() -- tailcall
					end
				end
				
			end

			if not oven.update_co then -- create a new one
				oven.update_co=coroutine.create(f)
			end
			if coroutine.status(oven.update_co)~="dead" then
				assert_resume(oven.update_co) -- run it, may need more than one resume before it finishes
			end

		end

		oven.preloader_enabled=true
--		if wwin.flavour=="raspi" then -- do fullscreen on raspi
--			oven.preloader_enabled=false
--		end
		
		function oven.preloader(sa,sb)
			sa=sa or ""
			sb=sb or ""
print(sa.." : "..sb)

			if wwin.flavour=="nacl" then
				wwin.hardcore.print(sa.." : "..sb)
				if  oven.update_co and ( coroutine.status(oven.update_co)=="running" ) then
					coroutine.yield()
				end
				return
			end

			if not oven.preloader_enabled then return end

			if oven.win and oven.rebake("wetgenes.gamecake.images").get("fonts/basefont_8x8") then

				local p=oven.rebake(opts.preloader or "wetgenes.gamecake.spew.preloader")
				p.setup() -- warning, this is called repeatedly
				p.update(sa,sb)
				
				if not oven.preloader_time or ( oven.win:time() > ( oven.preloader_time + (1/60) ) ) then -- avoid frame limiting
				
					oven.preloader_time=oven.win:time()
					
					if wwin.hardcore and wwin.hardcore.swap_pending then -- cock blocked waiting for nacl draw code
						-- do not draw
					else
						oven.cake.canvas.draw()
						p.draw()
						oven.win:swap()
						oven.cake.images.adjust_mips() -- upgrade visible only
					end

					if  oven.update_co and ( coroutine.status(oven.update_co)=="running" ) then
						coroutine.yield()
					end
					
				end

			end
		end

		function oven.draw()
		
			if oven.update_co then
				if coroutine.status(oven.update_co)~="dead" then return end -- draw nothing until it is finished
				oven.update_co=nil -- create a new one next update
			else -- nothing to draw, waiting on update to change things
				return
			end
			
			if wwin.hardcore and wwin.hardcore.swap_pending then
				return
			end -- cock blocked waiting for nacl draw code
		
			oven.cake.canvas.draw() -- prepare tempory buffers
			
--print( "DRAW",math.floor(10000000+(oven.win:time()*1000)%1000000) )

			if oven.times then oven.times.draw.start() end -- between calls to draw
			
			if oven.now and oven.now.draw then
				oven.now.draw()
			end
			
			for i,v in ipairs(oven.mods) do
				if v.draw then
					v.draw()
				end
			end
						
			if oven.times then oven.times.draw.stop() end -- draw is squify so just use it as the total time

			if oven.win then
				oven.win:swap()
				oven.cake.images.adjust_mips({force=true}) -- upgrade all textures
			end
			
		end

		function oven.msgs() -- read and process any msgs we have from win:msg

			if oven.win then
				for m in oven.win:msgs() do

--[[
if m.class=="key" and m.keyname=="menu" and m.action==1 then
print("requesting backtrace")
	oven.do_backtrace=true
end
]]

					if m.class=="mouse" and m.x and m.y then	-- need to fix x,y numbers
						m.xraw,m.yraw=m.x,m.y					-- remember original
					end

					if m.class=="close" then -- window has been closed so do a shutdown
						oven.next=true
					end

					if m.class=="app" then -- androidy
print("caught : ",m.class,m.cmd)
						if		m.cmd=="init_window" then
							oven.do_start=true
						elseif	m.cmd=="gained_focus"  then
							oven.focus=true
						elseif	m.cmd=="lost_focus"  then
							oven.focus=false
						elseif	m.cmd=="term_window"  then
							oven.do_stop=true
						end
					end
						
					if not oven.preloader_enabled then -- discard all other msgs during preloader
						
						for i=#oven.mods,1,-1 do -- run it through the mods backwards, so the topmost layer gets first crack at the msgs
							local v=oven.mods[i]
							if m and v and v.msg then
								m=v.msg(m) -- mods can choose to eat the msgs, they must return it for it to bubble down
							end
						end
						if m and oven.now and oven.now.msg then
							oven.now.msg(m)
						end
						
					end
				end
			end
		end

-- a busy blocking loop, or not, if we are running on the wrong sort
-- of system it just returns and expects the other functions
-- eg oven.serv_pulse to be called when necesary.
		function oven.serv(oven)
		
			if wwin.flavour~="android" then -- android needs lots of complexity due to its "lifecycle" bollox
				oven.focus=true -- hack, default to focused
				oven.do_start=true
			end
			
			if oven.win.noblock then
				return oven -- and expect  serv_pulse to be called as often as possible
			end
			
			local finished
			repeat
				finished=oven.serv_pulse(oven)
			until finished
		end

		function oven.serv_pulse(oven)
			if oven.finished then return true end
			oven.msgs()
			
			oven.cake.update()
			
			if oven.do_stop then
				oven.do_stop=false
				oven.stop()
			end

			if ( oven.started or oven.do_start ) and oven.focus then -- rolling or ready to roll
				oven.update()
				if oven.started then -- can draw?
					oven.draw()
				end
			else
				if wwin.hardcore.sleep then
					wwin.hardcore.sleep(1/10)
				end
			end
		end
		

	return oven

end
