/* Multilib support for ARM/RISC OS. 
   Written by Nick Burrett <nick@dsvr.net.  */

static char *multilib_raw[] = {
  "apcs26/unixlib !mlibscl !mapcs-32;",
  "apcs26/libscl mlibscl !mapcs-32;",

  "apcs26/libscl mlibscl !mapcs-32;",

  "apcs32/arch3/unixlib !mlibscl mapcs-32 archv3 !archv4;",
  "apcs32/arch4/unixlib !mlibscl mapcs-32 !archv3 archv4;",

  "apcs32/arch3/libscl mlibscl mapcs-32 archv3 !archv4;",
  "apcs32/arch4/libscl mlibscl mapcs-32 !archv3 archv4;",
  NULL
};

static char *multilib_matches_raw[] = {
"msoft-float msoft-float;",
"mlibscl mlibscl;",
"mapcs-32 mapcs-32;",
"mcpu=arm6 archv3;",
"mcpu=arm600 archv3;",
"mcpu=arm610 archv3;",
"mcpu=arm7 archv3;",
"mcpu=arm700 archv3;",
"mcpu=arm710 archv3;",
"mcpu=arm7500 archv3;",
"mcpu=arm7500fe archv3;",
"mcpu=strongarm archv4;",
"mcpu=strongarm110 archv4;",
"mcpu=strongarm1100 archv4;",
NULL
};

static char *multilib_extra = "";
