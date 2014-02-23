/*
 * Copyright (C) 2000 Robin Watts/Justin Fletcher
 */

#include <stdio.h>
#include <string.h>

#include "gfile.h"
#include "error.h"
#include "options.h"
#include "comments.h"

#include "copyright.h"

#include "VersionNum" /* CVS maintained version file */

/* Define this to use X-variant SWIs in h files - not really useful */
/* #define USE_X_IN_HFILE */

static FILE *file;

static void hdr_swis(void)
{
  const char * const prefix=opt.swi_names->name;

  if (!opt.swi_names)
    return;

  asm_comment(file, "SWI numbers");

  /* Non-X variants */
  if (opt.toolchain != tc_gcc)
  {
    swi_list l;
    int len=0;
    while (len++<24) fputc(' ',file);
    fprintf(file, "^ &%08x\n",opt.swi_base);

    for (l = opt.swi_names->next; l; l = l->next)
    {
      int len;
      len = fprintf(file, "%s_%s ", prefix, l->name);
      while (len++<24) fputc(' ',file);
      fprintf(file, "# 1\n");
    }
  }
  else
  {
    swi_list l;
    int swi;
    for (l = opt.swi_names->next, swi=opt.swi_base; l; l = l->next, ++swi)
      fprintf(file, ".set %s_%s,0x%x\n", prefix, l->name, swi);
  }

  /* X variants */
  if (opt.toolchain != tc_gcc)
  {
    swi_list l;
    int len=0;
    while (len++<24) fputc(' ',file);
    fprintf(file, "^ &%08x\n", opt.swi_base + (1<<17));

    for (l = opt.swi_names->next; l; l = l->next)
    {
      int len;
      len = fprintf(file, "X%s_%s ", prefix, l->name);
      while (len++<24) fputc(' ',file);
      fprintf(file, "# 1\n");
    }
  }
  else
  {
    swi_list l;
    int swi;
    for (l = opt.swi_names->next, swi=opt.swi_base; l; l = l->next, ++swi)
      fprintf(file, ".set X%s_%s,0x%x\n", prefix, l->name, swi+(1<<17));
  }
}

static void h_swis(void) {

  swi_list l;
  const char * const prefix=opt.swi_names->name;
  int swi;

  if (!opt.swi_names)
    return;

  c_comment(file, "SWI numbers");

  for (l = opt.swi_names->next, swi=opt.swi_base; l; l = l->next, ++swi) {
    const char *name=l->name;
    int len;
    len = fprintf(file, "#define %s_%s ", prefix, name);
    while (len++<32) fputc(' ',file);
    fprintf(file, "0x%x\n",swi);
#ifdef USE_X_IN_HFILE
    len = fprintf(file, "#define X%s_%s ", prefix, name);
    while (len++<32) fputc(' ',file);
    fprintf(file, "0x%x\n",0x20000+swi);
#endif
  }

  fprintf(file, "\n");
}

/* we output an assembler hdr file sometimes, so that we don't have
   to worry about anything nasty like inconsistant constructs; the only
   important ones here really are the SWI numbers which it is very useful
   to have in an exported hdr file */
void WriteExport_Hdr(void) {

  if (!opt.x_hdr)
    return;

  file = file_write(opt.x_hdr, remove_onfail);
  if (file == NULL)
    ErrorFatal("Couldn't create assembler SWI header file: %s", opt.x_hdr);

  asm_comment(file, "Generated by CMunge " Module_FullVersionAndDate "\n"
                    "CMunge " Copyright_CMunge );

  fprintf(file, "\n");

  if (opt.swi_handler || opt.swi_codesupplied)
    hdr_swis();

  if (opt.toolchain != tc_gcc)
    fprintf(file, "\n\tEND\n");
  file_close(file);
}

/* we output a C SWI header file so that the SWI numbers are know
   elsewhere */
void WriteExport_H(void) {

  if (!opt.x_h)
    return;

  file = file_write(opt.x_h, remove_onfail);
  if (file == NULL)
    ErrorFatal("Couldn't create C SWI header file: %s", opt.x_hdr);

  c_comment(file, "Generated by CMunge " Module_FullVersionAndDate "\n"
                  "CMunge " Copyright_CMunge);

  fprintf(file, "\n");
  fprintf(file, "#ifndef %s_SWI_H\n",opt.title);
  fprintf(file, "#define %s_SWI_H\n\n",opt.title);

  if (opt.swi_handler || opt.swi_codesupplied)
    h_swis();

  fprintf(file, "#endif\n\n");
  file_close(file);
}