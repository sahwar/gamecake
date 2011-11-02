-- copy all globals into locals
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


-- a scrolling area, the widget is biger than display area but scroll bars allow you to see it all



module("fenestra.widget.scroll")


function mouse(widget,act,x,y,key)
--	widget.master.focus=widget
	return widget.meta.mouse(widget,act,x,y,key)
end


function key(widget,ascii,key,act)
	return widget.meta.key(widget,ascii,key,act)
end


function update(widget)
	return widget.meta.update(widget)
end


function setup(widget,def)
	local it={}
	widget.scroll=it
	widget.class="scroll"
	
	widget.key=key
	widget.mouse=mouse
	widget.update=update

-- auto add the draging button as a child
	local ss=24
	if widget.hx<ss*2 then ss=widget.hx/2 end
	if widget.hy<ss*2 then ss=widget.hy/2 end
	
	it.pan=		widget:add({class="pan",	hx=widget.hx-ss,	hy=widget.hy-ss,	})
	it.slidey=	widget:add({class="slide",	hx=ss,				hy=widget.hy-ss,	pxr=widget.hx-ss,	pyr=0,
		datx={max=0},daty={max=1},color=0xffffffff})
	it.slidex=	widget:add({class="slide",	hx=widget.hx-ss,	hy=ss,           	pxr=0,           	pyr=widget.hy-ss,
		datx={max=1},daty={max=0},color=0xffffffff})

	return widget
end
