--
-- (C) 2013 Kriss@XIXs.com
--
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

function M.bake(oven,wmenubar)
wmenubar=wmenubar or {}

local cake=oven.cake
local canvas=cake.canvas
local font=canvas.font


function wmenubar.update(widget)
	if not widget.hidden then
		if widget.hide_when_not then -- must stay over widget
			if not widget:isover(widget.hide_when_not) then
				widget.hidden=true
				widget.hide_when_not=nil
				widget.master:layout()
			end
		end
	end
	return widget.meta.update(widget)
end

function wmenubar.draw(widget)
	return widget.meta.draw(widget)
end

-- auto resize to text contents horizontally
function wmenubar.layout(widget)
	
	local px=0
	local hy=0
	for i,v in ipairs(widget) do
		if not v.hidden then
		
			v.hx=0
			v.hy=0
			
			if v[1] then -- we have sub widgets, assume layout will generate a size
				v:layout()
			else -- use text size
				if v.text then
					local f=v:bubble("font") or 1
					v.hy=v:bubble("text_size") or 16
					font.set(cake.fonts.get(f))
					font.set_size(v.hy,0)
					v.hx=font.width(v.text)
					
					v.hx=v.hx+v.hy
					v.hy=widget.hy -- use set height from parent
				end
			end
			
			v.px=px
			v.py=0
			
			px=px+v.hx
--				widget.hx=px
			
			if v.hy>hy then hy=v.hy end -- tallest

		end
	end
	
--		widget.hy=hy

	for i,v in ipairs(widget) do -- set all to tallest
		v.hy=hy
	end

	for i,v in ipairs(widget) do -- descend
		if not v.hidden then v:layout() end
	end
end

function wmenubar.setup(widget,def)

	widget.class="menubar"
	
	widget.update=wmenubar.update
	widget.draw=wmenubar.draw
	widget.layout=wmenubar.layout

	widget.solid=true
--	widget.can_focus=true

	return widget
end

return wmenubar
end
