-- copy all globals into locals
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


-- a scrolling area, the widget is biger than display area but scroll bars allow you to see it all



--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

function M.bake(oven,wscroll)
wscroll=wscroll or {}

local widget_data=oven.rebake("wetgenes.gamecake.widgets.data")

function wscroll.mouse(widget,act,x,y,key)
--	widget.master.focus=widget
	return widget.meta.mouse(widget,act,x,y,key)
end


function wscroll.key(widget,ascii,key,act)
	return widget.meta.key(widget,ascii,key,act)
end


function wscroll.update(widget)

	local pan=widget.pan
	
	local pan_px=-widget.datx.num
	local pan_py=widget.daty.num
	
	if pan_px~=pan.pan_px or pan_py~=pan.pan_py then
	
		pan.pan_px=pan_px
		pan.pan_py=pan_py
		
		pan:set_dirty()
	end

	return widget.meta.update(widget)
end

function wscroll.draw(widget)

--	local it=widget.scroll
	
	return widget.meta.draw(widget)
end

function wscroll.layout(widget)

--	local it=widget.scroll
	
	widget.meta.layout(widget.pan) -- creates hx_max,hy_max

	widget.datx.max=widget.pan.hx_max-widget.pan.hx
	if widget.datx.max<0 then widget.datx.max=0 end
	widget.datx.size=widget.pan.hx/widget.pan.hx_max
	
	widget.daty.max=widget.pan.hy_max-widget.pan.hy
	if widget.daty.max<0 then widget.daty.max=0 end
	widget.daty.size=widget.pan.hy/widget.pan.hy_max
	
	widget.meta.layout(widget)
end

function wscroll.setup(widget,def)
--	local it={}
--	widget.scroll=it
	widget.class="scroll"
	
	widget.key=wscroll.key
	widget.mouse=wscroll.mouse
	widget.update=wscroll.update
	widget.layout=wscroll.layout
	widget.draw=wscroll.draw

-- auto add the draging button as a child
	local ss=16
	if widget.hx<ss*2 then ss=widget.hx/2 end
	if widget.hy<ss*2 then ss=widget.hy/2 end
	
	widget.datx=widget_data.new_data{max=1}
	widget.daty=widget_data.new_data{max=1}
	widget.solid=true

	widget.pan=		widget:add({class="pan",	hx=widget.hx-ss,	hy=widget.hy-ss	})
	widget.slidey=	widget:add({class="slide",	hx=ss,				hy=widget.hy-ss,	px=widget.hx-ss,	py=0,
		daty=widget.daty,color=0xffffffff})
	widget.slidex=	widget:add({class="slide",	hx=widget.hx-ss,	hy=ss,           	px=0,           	py=widget.hy-ss,
		datx=widget.datx,color=0xffffffff})

	return widget
end

return wscroll
end
