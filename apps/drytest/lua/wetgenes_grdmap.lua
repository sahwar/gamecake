

module(...,package.seeall)

local wstr=require("wetgenes.string")

local grd=require("wetgenes.grd")

local grdmap=require("wetgenes.grdmap")


function test_grdmap()

	print(wstr.dump(grdmap))
	
	local gm=grdmap.create()
	local gk=grdmap.create()

	gm:setup( assert(grd.create("GRD_FMT_U8_ARGB","dat/grdmap/t1.map.png","png")) )	
	gk:setup( assert(grd.create("GRD_FMT_U8_ARGB","dat/grdmap/t1.key.png","png")) )	
	
	gm:cutup(8,8)
	gk:cutup(8,8)
	
	gm:keymap(gk)
	
	print("GM\n",wstr.dump(gm))
	print("GK\n",wstr.dump(gk))
	
	for y=0,gm.th-1 do
	
		local s=""
	
		for x=0,gm.tw-1 do

			local t=gm:tile(x,y)

			if t.master then
				s=s..string.format("%02d ",t.master)
			else
				s=s.."00 "
			end

		end
		
		print(s)
	end




--[[
	local g=assert(grd.create("GRD_FMT_U8_ARGB","dat/grd/"..name..".bse.png","png"))
	assert( g:convert("GRD_FMT_U8_INDEXED") )
	assert( g:convert("GRD_FMT_U8_ARGB") )
	assert( g:save("dat/grd/"..name..".8x.out.png","png") )

	assert_true( do_file_compare("dat/grd/"..name..".8x.out.png","dat/grd/"..name..".8x.chk.png") )
]]
end
