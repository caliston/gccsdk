/*
 * Copyright (c) 1997 Darren Salt
 * Copyright (c) 2004-2010 GCCSDK Developers
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 * depend.c
 */

#include <stdio.h>

#include "depend.h"
#include "error.h"
#include "filestack.h"
#include "main.h"

const char *DependFileName = NULL;

void
dependWrite (const char *objname)
{
  if (DependFileName == NULL)
    return;

  FILE *dependFile;
  if ((dependFile = fopen (DependFileName, "w")) == NULL)
    errorAbort ("Failed to open dependencies file \"%s\"", DependFileName);

  if (objname[0] == '@' && objname[1] == '.')
    objname += 2;
  fprintf (dependFile, "%s:", objname);
  for (const FileNameList *fnListP = gFileNameListP; fnListP != NULL; fnListP = fnListP->nextP)
    fprintf (dependFile, " \\\n\t%s", fnListP->fileName);

  fputc ('\n', dependFile);
  fclose (dependFile);
}
