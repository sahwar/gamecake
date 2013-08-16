/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// (C) Kriss Daniels 2003 http://www.XIXs.com
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
#include "all.h"






/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// allocate an surface
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
bool t3d_surface::setup(void)
{
	DMEM_ZERO(this);

	return true;
}

/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// allocate an surface
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
bool t3d_surface::reset(void)
{
	clean();
	return setup();
}

/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// allocate an surface
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
void t3d_surface::clean(void)
{
}



/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// allocate an surface
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
t3d_surface *thunk3d::AllocSurface(void)
{
t3d_surface *ret;


	if(!(ret=(t3d_surface *)surfaces->alloc()))
	{
		DBG_Error("Failed to allocate thunk3D.surface.\n");
		goto bogus;
	}

	if(!ret->setup())
	{
		DBG_Error("Failed to setup thunk3D.surface.\n");
		goto bogus;
	}

	DLIST_PASTE(surfaces->atoms->last,ret,0);

	return ret;

bogus:
	FreeSurface(ret);
	return 0;
}

/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// free an surface
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
void thunk3d::FreeSurface(t3d_surface *item)
{
	if(item)
	{
		DLIST_CUT(item);

		item->clean();

		surfaces->free((llatom*)item);
	}
}
