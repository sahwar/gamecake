#include "all.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>
 
//
// we can use either this string as a string identifier
// or its address as a light userdata identifier, both will be unique
//
const char *lua_wetwin_ptr_name="wetwin*ptr";

	
/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// check that a userdata at the given index is a wetwin object
// return the userdata if it does, otherwise return 0
// this userdata will be a pointer to the real data
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
wetwin_lua **lua_wetwin_ptr_ptr (lua_State *l, int idx)
{
wetwin_lua **pp=0;

	pp = ((wetwin_lua **)luaL_checkudata(l, idx , lua_wetwin_ptr_name));

	return pp;
}


/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// *lua_wetwin_check with auto error on 0 ptr
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
wetwin_lua *lua_wetwin_check_ptr (lua_State *l, int idx)
{
wetwin_lua **pp=lua_wetwin_ptr_ptr(l,idx);

	if (*pp == 0)
	{
		luaL_error(l, "bad wetwin userdata" );
	}

	return *pp;
}

/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// fill a table in with the current settings
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
int lua_wetwin_getinfo (lua_State *l, wetwin_lua *p, int tab)
{
	if(p)
	{
		lua_pushnumber(l,p->width);		lua_setfield(l,tab,"width");
		lua_pushnumber(l,p->height);	lua_setfield(l,tab,"height");
	}
	else
	{
		lua_pushstring(l,"unbound wetwin"); lua_setfield(l,tab,"err");
	}

	return 0;
}

/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// set info into the given table
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
int lua_wetwin_info (lua_State *l)
{
wetwin_lua *p=lua_wetwin_check_ptr(l,1);
	lua_wetwin_getinfo(l,p,2);
	return 0;
}


/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// get info about the screen size
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
int lua_wetwin_screen (lua_State *l)
{
	Display		*dsp = XOpenDisplay( NULL );

/*
	Rotation original_rotation;
	int num_sizes;
	Window root = RootWindow(dsp, 0);
	XRRScreenSize *xrrs = XRRSizes(dsp, 0, &num_sizes);

	XRRScreenConfiguration *conf = XRRGetScreenInfo(dsp, root);
	short original_rate = XRRConfigCurrentRate(conf);
	SizeID original_size_id = XRRConfigCurrentConfiguration(conf, &original_rotation);

// size of single screen
	lua_pushnumber(l, xrrs[original_size_id].width);
	lua_pushnumber(l, xrrs[original_size_id].height);
*/

// size of all screens joined
	lua_pushnumber(l,DisplayWidth(dsp,0));
	lua_pushnumber(l,DisplayHeight(dsp,0));
	
	XCloseDisplay( dsp );
	
	return 2;
}


/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// create and return the data
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
int lua_wetwin_create (lua_State *l)
{
wetwin_lua_wrap *wp;
wetwin_lua *p;

int x=0;
int y=0;

int width=640;
int height=480;

const char *title=" http://gamecake.4lfa.com/ ";
const char *name="GameCake";

XClassHint class_hint;

	lua_getfield(l,1,"title");	if( lua_isstring(l,-1) ) { title=lua_tostring(l,-1);	} lua_pop(l,1);
	lua_getfield(l,1,"name");	if( lua_isstring(l,-1) ) { name=lua_tostring(l,-1);		} lua_pop(l,1);

	class_hint.res_name=(char*)name;
	class_hint.res_class=(char*)name;

	lua_getfield(l,1,"width");	if( lua_isnumber(l,-1) ) { width=lua_tonumber(l,-1);	} lua_pop(l,1);
	lua_getfield(l,1,"height");	if( lua_isnumber(l,-1) ) { height=lua_tonumber(l,-1);	} lua_pop(l,1);
	lua_getfield(l,1,"x");		if( lua_isnumber(l,-1) ) { x=lua_tonumber(l,-1); 		} lua_pop(l,1);
	lua_getfield(l,1,"y");		if( lua_isnumber(l,-1) ) { y=lua_tonumber(l,-1);		} lua_pop(l,1);

	wp = (wetwin_lua_wrap *)lua_newuserdata(l, sizeof(wetwin_lua_wrap)); // we need a pointer, this makes lua GC a bit easier
	memset(wp,0,sizeof(wetwin_lua_wrap)); // make sure it is 0
	wp->p=wp->a; // point the pointer to the struct
	p=wp->p; // take an easy to use copy of the pointer
	luaL_getmetatable(l, lua_wetwin_ptr_name);
	lua_setmetatable(l, -2);
	
	p->dsp = XOpenDisplay( NULL );
	if(p->dsp)
	{
		Bool do_not_care=0;
		XkbSetDetectableAutoRepeat (p->dsp, 1, &do_not_care); // turn off the fake release keyboard msgs

		p->fp_dsp=ConnectionNumber(p->dsp);
		
		FD_ZERO(&p->set_dsp);
        FD_SET(p->fp_dsp, &p->set_dsp);
        
		p->screen = DefaultScreen(p->dsp);
		unsigned long white = WhitePixel(p->dsp,p->screen);
		unsigned long black = BlackPixel(p->dsp,p->screen);	
		p->win = XCreateSimpleWindow(p->dsp,
										DefaultRootWindow(p->dsp),
										0, 0,   					// origin
										width, height, 				// size
										0, white, 					// border
										black );  					// backcolour
		if(p->win)
		{
			XMapWindow( p->dsp, p->win );

			XStoreName( p->dsp, p->win, title );

			XSetClassHint( p->dsp, p->win, &class_hint );

			XSelectInput( p->dsp , p->win ,
				KeyPressMask | KeyReleaseMask |
				ButtonPressMask | ButtonReleaseMask |
				PointerMotionMask | StructureNotifyMask );

			if( (x>0) && (y>0) )
			{
//				XMoveWindow( p->dsp , p->win , x,y);
			}
			
			XFlush(p->dsp);
		}

	}

	return 1;
}

/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// set an icon (raw unix icon data) 16x16 or 32x32?
// we will convert from a grd to this in lua code.
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
int lua_wetwin_rawicon(lua_State *l)
{
XEvent xev;
size_t len;
const char *data;
long *lbuff;
int i;

	wetwin_lua *p=lua_wetwin_check_ptr(l,1);
	data=lua_tolstring(l,2,&len);

    Atom net_wm_icon = XInternAtom(p->dsp, "_NET_WM_ICON", False);
    Atom cardinal = XInternAtom(p->dsp, "CARDINAL", False);

// FFS array must be cast to (long) as it *may* be expecting 64bit values 
	lbuff=(long*)calloc(len/4,sizeof(long));
	if(lbuff)
	{
		for(i=0;i<len/4;i++)
		{
			lbuff[i]=((u32*)data)[i];
		}
		XChangeProperty(p->dsp , p->win, net_wm_icon, cardinal, 32, PropModeReplace, (const unsigned char*) lbuff, len/4);
		free(lbuff);
	}


	return 0;
}

/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// fullscreen a window as best we can...
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
int lua_wetwin_show(lua_State *l)
{
XEvent xev;

wetwin_lua *p=lua_wetwin_check_ptr(l,1);

Atom _NET_WM_STATE 					= XInternAtom(p->dsp, "_NET_WM_STATE", False);
Atom _NET_WM_STATE_MAXIMIZED_VERT 	= XInternAtom(p->dsp, "_NET_WM_STATE_MAXIMIZED_VERT", False);
Atom _NET_WM_STATE_MAXIMIZED_HORZ 	= XInternAtom(p->dsp, "_NET_WM_STATE_MAXIMIZED_HORZ", False);
Atom _NET_WM_STATE_FULLSCREEN 		= XInternAtom(p->dsp, "_NET_WM_STATE_FULLSCREEN", False);
//Atom _NET_WM_STATE_FOCUSED 			= XInternAtom(p->dsp, "_NET_WM_STATE_FOCUSED", False);

int max=0;
int full=0;

const char *s=lua_tostring(l,2);

	if(s)
	{
		if(strcmp("max",s)==0) { max=1; }   // maximised, can still see taskbar/title
		if(strcmp("full",s)==0) { full=1; } // try and take over the screen
	}

	if(full)
	{
		memset(&xev, 0, sizeof(xev));
		xev.type = ClientMessage;
		xev.xclient.window = p->win;
		xev.xclient.message_type = _NET_WM_STATE;
		xev.xclient.format = 32;
		xev.xclient.data.l[0] = 1; // add
		xev.xclient.data.l[1] = _NET_WM_STATE_FULLSCREEN;
		xev.xclient.data.l[2] = _NET_WM_STATE_FULLSCREEN;
		XSendEvent(p->dsp, DefaultRootWindow(p->dsp), False, SubstructureNotifyMask, &xev);
	}
	else
    if(max)
    {
		memset(&xev, 0, sizeof(xev));
		xev.type = ClientMessage;
		xev.xclient.window = p->win;
		xev.xclient.message_type = _NET_WM_STATE;
		xev.xclient.format = 32;
		xev.xclient.data.l[0] = 1; // add
		xev.xclient.data.l[1] = _NET_WM_STATE_MAXIMIZED_VERT;
		xev.xclient.data.l[2] = _NET_WM_STATE_MAXIMIZED_HORZ;
		XSendEvent(p->dsp, DefaultRootWindow(p->dsp), False, SubstructureNotifyMask, &xev);
	}
    else // clear all flags
    {
		memset(&xev, 0, sizeof(xev));
		xev.type = ClientMessage;
		xev.xclient.window = p->win;
		xev.xclient.message_type = _NET_WM_STATE;
		xev.xclient.format = 32;
		xev.xclient.data.l[0] = 0; // remove
		xev.xclient.data.l[1] = _NET_WM_STATE_MAXIMIZED_VERT;
		xev.xclient.data.l[2] = _NET_WM_STATE_MAXIMIZED_HORZ;
		XSendEvent(p->dsp, DefaultRootWindow(p->dsp), False, SubstructureNotifyMask, &xev);

		memset(&xev, 0, sizeof(xev));
		xev.type = ClientMessage;
		xev.xclient.window = p->win;
		xev.xclient.message_type = _NET_WM_STATE;
		xev.xclient.format = 32;
		xev.xclient.data.l[0] = 0; // remove
		xev.xclient.data.l[1] = _NET_WM_STATE_FULLSCREEN;
		xev.xclient.data.l[2] = _NET_WM_STATE_FULLSCREEN;
		XSendEvent(p->dsp, DefaultRootWindow(p->dsp), False, SubstructureNotifyMask, &xev);
    }


	return 0;
}


/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// destroy data if it exists
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
int lua_wetwin_destroy (lua_State *l)
{
wetwin_lua **pp=lua_wetwin_ptr_ptr(l,1);

	if(*pp)
	{
		if((*pp)->dsp)
		{
			if((*pp)->win)
			{
				if((*pp)->context)
				{
					glXMakeCurrent((*pp)->dsp,None,NULL);
					glXDestroyContext((*pp)->dsp,(*pp)->context);
				}
				XDestroyWindow( (*pp)->dsp, (*pp)->win );
			}
			XCloseDisplay( (*pp)->dsp );
		}
	}
	(*pp)=0;

	return 0;
}

/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// prepare a gl surface in the window
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
int lua_wetwin_context (lua_State *l)
{
wetwin_lua *p=lua_wetwin_check_ptr(l,1);

	int attrcount;
	int AttributeList[] = {
			GLX_RED_SIZE, 1,
			GLX_GREEN_SIZE, 1,
			GLX_BLUE_SIZE, 1,
			GLX_ALPHA_SIZE, 0,
			GLX_DEPTH_SIZE, 1,
			GLX_STENCIL_SIZE, 0,
			GLX_X_RENDERABLE,1,
			GLX_DOUBLEBUFFER,1,
			None};
			
	GLXFBConfig *conf=glXChooseFBConfig(p->dsp,p->screen,AttributeList,&attrcount);

	p->context=glXCreateNewContext( p->dsp , *conf , GLX_RGBA_TYPE , NULL , 1 );

	glXMakeContextCurrent( p->dsp , p->win , p->win, p->context );

	return 0;
}

/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// swap a gl surface 
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
int lua_wetwin_swap (lua_State *l)
{
wetwin_lua *p=lua_wetwin_check_ptr(l,1);

	glXSwapBuffers( p->dsp, p->win );

	return 0;
}



/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// are there msgs waiting to be delt with?
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
int lua_wetwin_peek (lua_State *l)
{
wetwin_lua *p=lua_wetwin_check_ptr(l,1);

	if( XPending( p->dsp ) > 0 )
	{
		lua_pushboolean(l,1);
	}
	else
	{
		lua_pushboolean(l,0);
	}
	return 1;
}


/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// wait a while to see if any msgs turn up
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
int lua_wetwin_wait (lua_State *l)
{
wetwin_lua *p=lua_wetwin_check_ptr(l,1);

	struct timeval tv;
	tv.tv_sec = 0;
	tv.tv_usec = 1000; // 1ms
	
	select(p->fp_dsp, &p->set_dsp, 0, 0, &tv);
	
	return 0;
}

/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// grab the next msg, and return info about it
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
int lua_wetwin_msg (lua_State *l)
{
wetwin_lua *p=lua_wetwin_check_ptr(l,1);

char lua=' ';
int act=0;
int key=0;
int x=0;
int y=0;
char asc[255];
KeySym k;
double time;

	XEvent e[1];
	if( XPending( p->dsp ) > 0 )
	{
		XNextEvent(p->dsp, e);
		
		switch(e->type)
		{
			case KeyPress:
				time=(e->xkey.time/1000.0);
				lua='k';
				act=1;
			break;
			case KeyRelease:
				time=(e->xkey.time/1000.0);
				lua='k';
				act=-1;
			break;
			
			case ButtonPress:
				time=(e->xbutton.time/1000.0);
				lua='m';
				act=1;
				key=(e->xbutton.button);
				x=e->xbutton.x;
				y=e->xbutton.y;
			break;
			case ButtonRelease:
				time=(e->xbutton.time/1000.0);
				lua='m';
				act=-1;
				key=(e->xbutton.button);
				x=e->xbutton.x;
				y=e->xbutton.y;
			break;
			case MotionNotify:
				time=(e->xmotion.time/1000.0);
				lua='m';
				x=e->xmotion.x;
				y=e->xmotion.y;
			break;
			
			case ConfigureNotify:
//				time=(e->xconfigure.time/1000.0);
				lua='s';
				x=e->xconfigure.width;
				y=e->xconfigure.height;
				
				// remember this value
				p->width=x;
				p->height=y;
				
			break;
		}
	}
	
    if(lua=='m')
    {
		lua_newtable(l);
		lua_pushnumber(l,time);					lua_setfield(l,-2,"time");
		lua_pushstring(l,"mouse");				lua_setfield(l,-2,"class");
		lua_pushnumber(l,key);					lua_setfield(l,-2,"keycode");
		lua_pushnumber(l,act);					lua_setfield(l,-2,"action");
		lua_pushnumber(l,x);					lua_setfield(l,-2,"x");
		lua_pushnumber(l,y);					lua_setfield(l,-2,"y");
		return 1;
	}
    else
    if(lua=='k')
    {
		int ts=XLookupString(&e->xkey,asc,32,&k,0);
		asc[ts]=0; // null term the ascii

		lua_newtable(l);
		lua_pushnumber(l,time);					lua_setfield(l,-2,"time");
		lua_pushstring(l,"key");				lua_setfield(l,-2,"class");
		lua_pushstring(l,asc);					lua_setfield(l,-2,"ascii");
		lua_pushnumber(l,act);					lua_setfield(l,-2,"action");
		lua_pushnumber(l,k);					lua_setfield(l,-2,"keycode");
		lua_pushstring(l,XKeysymToString(k));	lua_setfield(l,-2,"keyname");
		return 1;
	}
    else
    if(lua=='s')
	{	
		lua_newtable(l);
//		lua_pushnumber(l,time);					lua_setfield(l,-2,"time");
		lua_pushstring(l,"size");				lua_setfield(l,-2,"class");
		lua_pushnumber(l,x);					lua_setfield(l,-2,"x");
		lua_pushnumber(l,y);					lua_setfield(l,-2,"y");
		return 1;
	}
	
	return 0; // no more msgs
}

/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// wait a while to see if any msgs turn up
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
int lua_wetwin_sleep (lua_State *l)
{
    double n = luaL_checknumber(l, 1);
//#ifdef _WIN32
//    Sleep((int)(n*1000));
//#else
    struct timespec t, r;
    t.tv_sec = (int) n;
    n -= t.tv_sec;
    t.tv_nsec = (int) (n * 1000000000);
    if (t.tv_nsec >= 1000000000) t.tv_nsec = 999999999;
    while (nanosleep(&t, &r) != 0) {
        t.tv_sec = r.tv_sec;
        t.tv_nsec = r.tv_nsec;
    }
//#endif
    return 0;
}

/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// what time is it, with sub second resolution
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
int lua_wetwin_time (lua_State *l)
{

	struct timeval tv;
	gettimeofday ( &tv, NULL );
	lua_pushnumber(l, ((double)tv.tv_sec) + ( ((double)tv.tv_usec) / 1000000.0 ) );
	return 1;
}

/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// what time is it, with sub second resolution
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
int lua_wetwin_jread (lua_State *l)
{
wetwin_lua *p=lua_wetwin_check_ptr(l,1);
int n = (int)luaL_checknumber(l, 2);

unsigned char b[16];
char s[256];

	strcpy(s,"/dev/input/js0");

	if(n<0) { n=0; }
	if(n>3) { n=3; }
	if(! p->joy_fd[n])
	{
		s[13]='0'+n;
		p->joy_fd[n] = open(s,O_RDONLY|O_NONBLOCK);
	}

	if(p->joy_fd[n])
	{
		if( read(p->joy_fd[n], b, 8) == 8 )
		{
			lua_pushlstring(l,(const char *)b,8);
			return 1;
		}
	}
	return 0;
}


/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// this is fucking dangerous
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
int lua_wetwin_ioctl (lua_State *l)
{
int i1 = (int)luaL_checknumber(l, 1);
int i2 = (int)luaL_checknumber(l, 2);
int i3 = (int)luaL_checknumber(l, 3);
int r;
	r=ioctl(i1,i2,i3);
	lua_pushnumber(l,(double)r);
	return 1;
}

/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// non blocking getc, returns nil if there is nothing there, otherwise a char code
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
static int lua_wetwin_getc (lua_State *l)
{
char c;
    struct timeval tv;
    fd_set fds;
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    FD_ZERO(&fds);
    FD_SET(0, &fds); //STDIN_FILENO is 0
    select(0+1, &fds, NULL, NULL, &tv);
    if( FD_ISSET(0, &fds) )
    {
		c=fgetc(stdin);
		lua_pushnumber(l,c);
		return 1;
	}
	
	return 0;
}
/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// open library.
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
LUALIB_API int luaopen_wetgenes_win_linux_core(lua_State *l)
{
	const luaL_Reg lib[] =
	{
		{"screen",			lua_wetwin_screen},
		
		{"create",			lua_wetwin_create},
		{"destroy",			lua_wetwin_destroy},
		{"info",			lua_wetwin_info},
		{"show",			lua_wetwin_show},
		{"rawicon",			lua_wetwin_rawicon},

		{"context",			lua_wetwin_context},
		{"swap",			lua_wetwin_swap},

		{"peek",			lua_wetwin_peek},
		{"wait",			lua_wetwin_wait},
		{"msg",				lua_wetwin_msg},

		{"sleep",			lua_wetwin_sleep},
		{"time",			lua_wetwin_time},

// the following are hacks that will be removed/replaced with less hacks

		{"jread",			lua_wetwin_jread},
		
		{"ioctl",			lua_wetwin_ioctl},
		{"getc",			lua_wetwin_getc},
		
		{0,0}
	};

 	const luaL_Reg meta[] =
	{
		{"__gc",			lua_wetwin_destroy},
		{0,0}
	};
	
	luaL_newmetatable(l, lua_wetwin_ptr_name);
	luaL_openlib(l, NULL, meta, 0);
	lua_pop(l,1);

	lua_newtable(l);
	luaL_openlib(l, NULL, lib, 0);
	
	return 1;
}

