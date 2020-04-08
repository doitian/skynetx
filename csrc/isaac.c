/***
 * 随机数发生器，基于 isaac.
 *
 *    local isaac = require "isaac"
 *    local generator = isaac.generator(os.time())
 *    generator() ---> Generate next random number
 *
 * 随机数范围是 0 到 4294967295 (包含 0 和 4294967295)
 * @module isaac
 */
#include <stdint.h>
#include <lauxlib.h>
#include <lua.h>

/**
 * begin http://burtleburtle.net/bob/rand/isaacafa.html
 */

#define RANDSIZL   (8)
#define RANDSIZ    (1<<RANDSIZL)

typedef unsigned long ub4;
typedef int word;

/* context of random number generator */
struct isaacctx
{
  ub4 randcnt;
  ub4 randrsl[RANDSIZ];
  ub4 randmem[RANDSIZ];
  ub4 randa;
  ub4 randb;
  ub4 randc;
};
typedef struct isaacctx isaacctx;


#define ind(mm,x)  ((mm)[(x>>2)&(RANDSIZ-1)])
#define rngstep(mix,a,b,mm,m,m2,r,x) \
{ \
  x = *m;  \
  a = ((a^(mix)) + *(m2++)); \
  *(m++) = y = (ind(mm,x) + a + b); \
  *(r++) = b = (ind(mm,y>>RANDSIZL) + x) & 0xffffffff; \
}

void isaac(isaacctx* ctx)
{
   ub4 a,b,x,y,*m,*mm,*m2,*r,*mend;
   mm=ctx->randmem; r=ctx->randrsl;
   a = ctx->randa; b = ctx->randb + (++ctx->randc);
   for (m = mm, mend = m2 = m+(RANDSIZ/2); m<mend; )
   {
      rngstep( a<<13, a, b, mm, m, m2, r, x);
      rngstep( (a & 0xffffffff) >>6 , a, b, mm, m, m2, r, x);
      rngstep( a<<2 , a, b, mm, m, m2, r, x);
      rngstep( (a & 0xffffffff) >>16, a, b, mm, m, m2, r, x);
   }
   for (m2 = mm; m2<mend; )
   {
      rngstep( a<<13, a, b, mm, m, m2, r, x);
      rngstep( (a & 0xffffffff) >>6 , a, b, mm, m, m2, r, x);
      rngstep( a<<2 , a, b, mm, m, m2, r, x);
      rngstep( (a & 0xffffffff) >>16, a, b, mm, m, m2, r, x);
   }
   ctx->randb = b; ctx->randa = a;
}


#define mix(a,b,c,d,e,f,g,h) \
{ \
   a^=b<<11;              d+=a; b+=c; \
   b^=(c&0xffffffff)>>2;  e+=b; c+=d; \
   c^=d<<8;               f+=c; d+=e; \
   d^=(e&0xffffffff)>>16; g+=d; e+=f; \
   e^=f<<10;              h+=e; f+=g; \
   f^=(g&0xffffffff)>>4;  a+=f; g+=h; \
   g^=h<<8;               b+=g; h+=a; \
   h^=(a&0xffffffff)>>9;  c+=h; a+=b; \
}

/* if (flag==TRUE), then use the contents of randrsl[] to initialize mm[]. */
void randinit(isaacctx* ctx, word flag)
{
   word i;
   ub4 a,b,c,d,e,f,g,h;
   ub4 *m,*r;
   ctx->randa = ctx->randb = ctx->randc = 0;
   m=ctx->randmem;
   r=ctx->randrsl;
   a=b=c=d=e=f=g=h=0x9e3779b9;  /* the golden ratio */

   for (i=0; i<4; ++i)          /* scramble it */
   {
     mix(a,b,c,d,e,f,g,h);
   }

   if (flag) 
   {
     /* initialize using the contents of r[] as the seed */
     for (i=0; i<RANDSIZ; i+=8)
     {
       a+=r[i  ]; b+=r[i+1];
       c+=r[i+2]; d+=r[i+3];
       e+=r[i+4]; f+=r[i+5];
       g+=r[i+6]; h+=r[i+7];
       mix(a,b,c,d,e,f,g,h);
       m[i  ]=a; m[i+1]=b; m[i+2]=c; m[i+3]=d;
       m[i+4]=e; m[i+5]=f; m[i+6]=g; m[i+7]=h;
     }
     /* do a second pass to make all of the seed affect all of m */
     for (i=0; i<RANDSIZ; i+=8)
     {
       a+=m[i  ]; b+=m[i+1];
       c+=m[i+2]; d+=m[i+3];
       e+=m[i+4]; f+=m[i+5];
       g+=m[i+6]; h+=m[i+7];
       mix(a,b,c,d,e,f,g,h);
       m[i  ]=a; m[i+1]=b; m[i+2]=c; m[i+3]=d;
       m[i+4]=e; m[i+5]=f; m[i+6]=g; m[i+7]=h;
     }
   }
   else
   {
     for (i=0; i<RANDSIZ; i+=8)
     {
       /* fill in mm[] with messy stuff */
       mix(a,b,c,d,e,f,g,h);
       m[i  ]=a; m[i+1]=b; m[i+2]=c; m[i+3]=d;
       m[i+4]=e; m[i+5]=f; m[i+6]=g; m[i+7]=h;
     }
   }

   isaac(ctx);            /* fill in the first set of results */
   ctx->randcnt=RANDSIZ;  /* prepare to use the first set of results */
}

/**
 * end http://burtleburtle.net/bob/rand/isaacafa.html
 */

static void newisaacctx(lua_State *L)
{
  int i;
  isaacctx *ctx = lua_newuserdata(L, sizeof(isaacctx));
  int argn = lua_gettop(L);
  if (argn == 0) {
    randinit(ctx, 0);
  } else {
    if (argn > RANDSIZ) {
      argn = RANDSIZ;
    }
    for (i = 0; i < argn; ++i) {
      ctx->randrsl[i] = (ub4)lua_tonumber(L, i + 1);
    }
    for (i = argn; i < RANDSIZ; ++i) {
      ctx->randrsl[i] = 0;
    }
    randinit(ctx, 1);
  }
}

static int isaac_generator_cclosure(lua_State *L)
{
  isaacctx *ctx = (isaacctx*)lua_touserdata(L, lua_upvalueindex(1));
  if (ctx->randcnt > 0) {
    --(ctx->randcnt);
  } else {
    isaac(ctx);
    ctx->randcnt = RANDSIZ - 1;
  }
  lua_pushinteger(L, ctx->randrsl[ctx->randcnt]);
  return 1;
}

/// 给 Lua 返回一个用来生成随机序列的函数.
//
// @function generator
// @tparam integer seed 随机种子
// @treturn function generator 每次调用返回一个 `[0, 4294967295]` 区间内的随机数
static int isaac_generator(lua_State *L)
{
  newisaacctx(L);
  lua_pushcclosure(L, isaac_generator_cclosure, 1);
  return 1;
}

static int isaac_batch_cclosure(lua_State *L)
{
  int i;
  isaacctx *ctx = (isaacctx*)lua_touserdata(L, lua_upvalueindex(1));
  if (!lua_checkstack(L, RANDSIZ)) {
    return 0;
  }
  for (i = RANDSIZ - 1; i >= 0; --i) {
    lua_pushinteger(L, ctx->randrsl[i]);
  }
  isaac(ctx);
  return RANDSIZ;
}

/// 给 Lua 返回一个用来批量生成随机序列的函数.
//
// @function batch
// @tparam integer seed 随机种子
// @treturn function batch 每次调用返回 256 个 `[0, 4294967295]` 区间内的随机数
static int isaac_batch(lua_State *L)
{
  newisaacctx(L);
  lua_pushcclosure(L, isaac_batch_cclosure, 1);
  return 1;
}

LUALIB_API int luaopen_isaac(lua_State *L)
{
  luaL_Reg reg[] = {
    {"generator", isaac_generator},
    {"batch", isaac_batch},
    {NULL, NULL}
  };
  luaL_newlib(L, reg);
  return 1;
}
