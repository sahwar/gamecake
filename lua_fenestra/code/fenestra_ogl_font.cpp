/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// (C) Kriss Daniels 2003 http://www.XIXs.com
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
#include "all.h"


static unsigned char const font_bits[16*48]={

0x00,0x18,0x66,0x6c,0x18,0x00,0x70,0x18,0x0c,0x30,0x00,0x00,0x00,0x00,0x00,0x06,
0x00,0x18,0x66,0x6c,0x3e,0x66,0xd8,0x18,0x18,0x18,0xcc,0x30,0x00,0x00,0x00,0x0c,
0x00,0x18,0x00,0xfe,0x60,0xac,0xd0,0x00,0x30,0x0c,0x78,0x30,0x00,0x00,0x00,0x18,
0x00,0x18,0x00,0x6c,0x3c,0xd8,0x76,0x00,0x30,0x0c,0xfc,0xfc,0x00,0x7e,0x00,0x30,
0x00,0x18,0x00,0xfe,0x06,0x36,0xdc,0x00,0x30,0x0c,0x78,0x30,0x00,0x00,0x00,0x60,
0x00,0x00,0x00,0x6c,0x7c,0x6a,0xdc,0x00,0x18,0x18,0xcc,0x30,0x18,0x00,0x18,0xc0,
0x00,0x18,0x00,0x6c,0x18,0xcc,0x76,0x00,0x0c,0x30,0x00,0x00,0x18,0x00,0x18,0x80,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x30,0x00,0x00,0x00,

0x78,0x18,0x3c,0x3c,0x1c,0x7e,0x1c,0x7e,0x3c,0x3c,0x00,0x00,0x00,0x00,0x00,0x3c,
0xcc,0x38,0x66,0x66,0x3c,0x60,0x30,0x06,0x66,0x66,0x18,0x18,0x06,0x00,0x60,0x66,
0xdc,0x78,0x06,0x06,0x6c,0x7c,0x60,0x06,0x66,0x66,0x18,0x18,0x18,0x7e,0x18,0x06,
0xfc,0x18,0x0c,0x1c,0xcc,0x06,0x7c,0x0c,0x3c,0x3e,0x00,0x00,0x60,0x00,0x06,0x0c,
0xec,0x18,0x18,0x06,0xfe,0x06,0x66,0x18,0x66,0x06,0x00,0x00,0x18,0x7e,0x18,0x18,
0xcc,0x18,0x30,0x66,0x0c,0x66,0x66,0x18,0x66,0x0c,0x18,0x18,0x06,0x00,0x60,0x00,
0x78,0x18,0x7e,0x3c,0x0c,0x3c,0x3c,0x18,0x3c,0x38,0x18,0x18,0x00,0x00,0x00,0x18,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x30,0x00,0x00,0x00,0x00,

0x7c,0x3c,0x7c,0x1e,0x78,0x7e,0x7e,0x3c,0x66,0x3c,0x06,0xc6,0x60,0xc6,0xc6,0x3c,
0xc6,0x66,0x66,0x30,0x6c,0x60,0x60,0x66,0x66,0x18,0x06,0xcc,0x60,0xee,0xe6,0x66,
0xde,0x66,0x66,0x60,0x66,0x60,0x60,0x60,0x66,0x18,0x06,0xd8,0x60,0xfe,0xf6,0x66,
0xd6,0x7e,0x7c,0x60,0x66,0x78,0x78,0x6e,0x7e,0x18,0x06,0xf0,0x60,0xd6,0xde,0x66,
0xde,0x66,0x66,0x60,0x66,0x60,0x60,0x66,0x66,0x18,0x06,0xd8,0x60,0xc6,0xce,0x66,
0xc0,0x66,0x66,0x30,0x6c,0x60,0x60,0x66,0x66,0x18,0x66,0xcc,0x60,0xc6,0xc6,0x66,
0x78,0x66,0x7c,0x1e,0x78,0x7e,0x60,0x3e,0x66,0x3c,0x3c,0xc6,0x7e,0xc6,0xc6,0x3c,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,

0x7c,0x3c,0x7c,0x3c,0x7e,0x66,0x66,0xc6,0xc6,0xc6,0x7e,0x3c,0x80,0x3c,0x00,0x00,
0x66,0x66,0x66,0x66,0x18,0x66,0x66,0xc6,0x6c,0x6c,0x0c,0x30,0xc0,0x0c,0x18,0x00,
0x66,0x66,0x66,0x70,0x18,0x66,0x66,0xc6,0x38,0x38,0x18,0x30,0x60,0x0c,0x66,0x00,
0x7c,0x66,0x7c,0x3c,0x18,0x66,0x66,0xd6,0x38,0x18,0x30,0x30,0x30,0x0c,0x00,0x00,
0x60,0x66,0x6c,0x0e,0x18,0x66,0x3c,0xfe,0x38,0x18,0x60,0x30,0x18,0x0c,0x00,0x00,
0x60,0x6e,0x66,0x66,0x18,0x66,0x3c,0xee,0x6c,0x18,0xc0,0x30,0x0c,0x0c,0x00,0x00,
0x60,0x3f,0x66,0x3c,0x18,0x3c,0x18,0xc6,0xc6,0x18,0xfe,0x3c,0x06,0x3c,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xfe,

0x18,0x00,0x60,0x00,0x06,0x00,0x1c,0x00,0x60,0x18,0x0c,0x60,0x18,0x00,0x00,0x00,
0x18,0x00,0x60,0x00,0x06,0x00,0x30,0x00,0x60,0x00,0x00,0x60,0x18,0x00,0x00,0x00,
0x0c,0x3c,0x7c,0x3c,0x3e,0x3c,0x7c,0x3e,0x7c,0x18,0x0c,0x66,0x18,0xec,0x7c,0x3c,
0x00,0x06,0x66,0x60,0x66,0x66,0x30,0x66,0x66,0x18,0x0c,0x6c,0x18,0xfe,0x66,0x66,
0x00,0x3e,0x66,0x60,0x66,0x7e,0x30,0x66,0x66,0x18,0x0c,0x78,0x18,0xd6,0x66,0x66,
0x00,0x66,0x66,0x60,0x66,0x60,0x30,0x3e,0x66,0x18,0x0c,0x6c,0x18,0xc6,0x66,0x66,
0x00,0x3e,0x7c,0x3c,0x3e,0x3c,0x30,0x06,0x66,0x18,0x0c,0x66,0x0c,0xc6,0x66,0x3c,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x3c,0x00,0x00,0x78,0x00,0x00,0x00,0x00,0x00,

0x00,0x00,0x00,0x00,0x30,0x00,0x00,0x00,0x00,0x00,0x00,0x0c,0x18,0x30,0xfe,0xff,
0x00,0x00,0x00,0x00,0x30,0x00,0x00,0x00,0x00,0x00,0x00,0x1c,0x18,0x38,0x00,0xff,
0x7c,0x3e,0x7c,0x3c,0x7c,0x66,0x66,0xc6,0xc6,0x66,0x7e,0x18,0x18,0x18,0x00,0xff,
0x66,0x66,0x66,0x60,0x30,0x66,0x66,0xc6,0x6c,0x66,0x0c,0x38,0x18,0x1c,0x00,0xff,
0x66,0x66,0x60,0x3c,0x30,0x66,0x66,0xd6,0x38,0x66,0x18,0x38,0x18,0x1c,0x00,0xff,
0x7c,0x3e,0x60,0x06,0x30,0x66,0x3c,0xfe,0x6c,0x3c,0x30,0x18,0x18,0x18,0x00,0xff,
0x60,0x06,0x60,0x7c,0x1c,0x3e,0x18,0x6c,0xc6,0x18,0x7e,0x1c,0x18,0x38,0x00,0xff,
0x60,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x30,0x00,0x0c,0x18,0x30,0x00,0xff

};


/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// Setup junk
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
bool fenestra_ogl::font_setup()
{
int x,y,xx,yy;
u8 b;
u8 m;
cu8 *f=font_bits;
u32 *t;
u32 c;
bool last;
u32 bmap[8*8];
int i=0;

    // allocate texture names
    glGenTextures( 96, font_chars );

	for(yy=0;yy<48;yy+=8) // bitmap data is 6 chars high
	{
		last=false;
		for(xx=0;xx<128;xx+=8) // bitmap data is 16 chars wide
		{
			
// build a single char			
			for(y=0;y<8;y++)
			{
				f=font_bits+((yy+y)*16)+(xx/8);
				b=*f++;
				m=0x80;
				last=false;
				for(x=0;x<8;x++)
				{
					if(b&m)
					{
						c=0xffffffff; // solid
						last=true;
					}
					else
					{
						if(last)
						{
							c=0xff000000; // abgr shadow
						}
						else
						{
							c=0x00000000; // transparent
						}
						last=false;
					}
					m=m>>1;
					bmap[x+(y*8)]=c;
				}
			}
			
			// select our current texture
			glBindTexture( GL_TEXTURE_2D, font_chars[i] );

			// select modulate to mix texture with color for shading
			glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );

			// when texture area is small, bilinear filter the closest mipmap
			glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );

			// when texture area is large, bilinear filter the first mipmap
			glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );

			glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP );
			glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP );

			// build our texture mipmaps
		    gluBuild2DMipmaps( GL_TEXTURE_2D, GL_RGBA , 8, 8, GL_RGBA, GL_UNSIGNED_BYTE, bmap );
//			glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,8,8,0,GL_RGBA, GL_UNSIGNED_BYTE,bmap);
			
			i++;
		}
	}

	return true;
}

/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// Setup junk
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
void fenestra_ogl::flat_begin()
{
	glMatrixMode (GL_PROJECTION);
	glLoadIdentity ();
	glOrtho(0,width, height,0, -1.0,1.0);

	glEnable( GL_TEXTURE_2D );
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	glDisable(GL_LIGHTING);
	glDisable(GL_DEPTH_TEST);
	
	glEnable( GL_TEXTURE_2D );
	
	glDisable( GL_CULL_FACE );
	
}
/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// Setup junk
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
void fenestra_ogl::flat_end()
{
}

/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// Setup junk
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
void fenestra_ogl::font_position(f32 x, f32 y, f32 size, u32 color)
{
	font_x=x;
	font_y=y;
	font_size=size;
	font_color=color;
}

/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// Setup junk
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
void fenestra_ogl::font_draw(char c)
{
	GLfloat x,y,s;
	GLfloat cx,cy;

	x=(GLfloat)font_x;
	y=(GLfloat)font_y;
	s=(GLfloat)font_size;

	c=c-32;
	if(c<0)   { c=95; } 
	if(c>95)  { c=95; } 
    glBindTexture( GL_TEXTURE_2D, font_chars[c] );
    
	glColor4ub( (font_color>>16)&0xff , (font_color>>8)&0xff , (font_color)&0xff , (font_color>>24)&0xff );
	
	glBegin(GL_QUADS);
	 	glTexCoord2d(0,1); glVertex2f(x,   y+s);
	 	glTexCoord2d(0,0); glVertex2f(x,   y  );
	 	glTexCoord2d(1,0); glVertex2f(x+s, y  );
	 	glTexCoord2d(1,1); glVertex2f(x+s, y+s);
	glEnd();

	font_x+=font_size;
}

void fenestra_ogl::font_draw_string_base(const char *string)
{
const char *s;

	for(s=string;*s;s++)
	{
		font_draw(*s);
		
		if(font_x>width) break;
	}
}


/*+-----------------------------------------------------------------------------------------------------------------+*/
//
// alternative drawstring for "normal" use
//
/*+-----------------------------------------------------------------------------------------------------------------+*/
void fenestra_ogl::font_draw_string(const char *string)
{
const char *s;

glDisable(GL_LIGHTING);
glEnable( GL_TEXTURE_2D );
	
glColor4ub( (font_color>>16)&0xff , (font_color>>8)&0xff , (font_color)&0xff , (font_color>>24)&0xff );
		
	for(s=string;*s;s++)
	{
		char c=*s;
		
		GLfloat x,y,siz;

		x=(GLfloat)font_x;
		y=(GLfloat)font_y;
		siz=(GLfloat)font_size;
		
		c=c-32;
		if(c<0)   { c=95; } 
		if(c>95)  { c=95; } 
		glBindTexture( GL_TEXTURE_2D, font_chars[c] );
		
		glBegin(GL_QUADS);
			glTexCoord2d(0,1); glVertex2f(x,     y-siz);
			glTexCoord2d(0,0); glVertex2f(x,     y    );
			glTexCoord2d(1,0); glVertex2f(x+siz, y    );
			glTexCoord2d(1,1); glVertex2f(x+siz, y-siz);
		glEnd();

		font_x+=font_size;
		
		if(font_x>width) break;
	}
//	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
glDisable( GL_TEXTURE_2D );
glEnable(GL_LIGHTING);

}

