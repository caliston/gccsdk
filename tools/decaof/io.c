/*
 * file input/output
 *
 * Copyright (c) 1992 Andy Duplain, andy.duplain@dsl.pipex.com
 * Copyright (c) 2005-2012 GCCSDK Developers
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 */

#include "config.h"

#include <stdio.h>
#include <stdlib.h>

#include "decaof.h"
#include "error.h"
#include "io.h"

/*
 * check for EOF or write/read errors on stream.
 */
Ferror
check_stream (FILE * fp)
{
  int ret = FNOERR;

  if (feof (fp))
    ret = FEND;
  else if (ferror (fp))
    ret = FRWERR;
  if (ret != FNOERR)
    clearerr (fp);
  return (ret);
}

/*
 * read a byte from the input stream.
 */
Byte
read_byte (FILE * ifp)
{
  return ((Byte) getc (ifp));
}

/*
 * read a little-endian 2-byte halfword from the input stream.
 */
Halfword
read_halfword (FILE * ifp)
{
  Byte lowByte = read_byte (ifp);
  Byte highByte = read_byte (ifp);

  return lowByte + (highByte << 8);
}

/*
 * read a little-endian 4-byte word from the input stream.
 */
Word
read_word (FILE * ifp)
{
  Halfword lowHalfword = read_halfword (ifp);
  Halfword highHalfword = read_halfword (ifp);

  return lowHalfword + (highHalfword << 16);
}

/*
 * read in the chunk header
 */
struct chunkhdr *
read_chunkhdr (FILE * ifp)
{
  static struct chunkhdr hdr;

  fseek (ifp, 0L, SEEK_SET);
  hdr.chunkfileid = read_word (ifp);
  hdr.maxchunks = read_word (ifp);
  hdr.numchunks = read_word (ifp);
  return (check_stream (ifp) != FRWERR ? &hdr : NULL);
}

/*
 * memory pointers maintained by read_xxx functions
 */

static struct chunkent *ents;	/* chunk file entries */
static aof_obj_strt *strptr;	/* string table */
static struct symbol *symptr;	/* symbol table */
static char *idptr;		/* identification string */
static struct aofhdr *aofhdr;	/* AOF header */

/**
 * Free the memory used by a chunk
 */
void
free_chunk_memory (const void *ptr)
{
  if (!ptr)
    return;

  if (ptr == (const void *) ents)
    {
      free ((void *) ents);
      ents = NULL;
    }
  else if (ptr == (const void *) strptr)
    {
      free ((void *) strptr);
      strptr = NULL;
    }
  else if (ptr == (const void *) symptr)
    {
      free ((void *) symptr);
      symptr = NULL;
    }
  else if (ptr == (const void *) idptr)
    {
      free ((void *) idptr);
      idptr = NULL;
    }
  else if (ptr == (const void *) aofhdr)
    {
      free ((void *) aofhdr);
      aofhdr = NULL;
    }
}

/*
 * read in the chunk entries
 */
struct chunkent *
read_chunkents (FILE * ifp, struct chunkhdr *hdr)
{
  int i;

  if (ents)
    free (ents);
  ents = (struct chunkent *) malloc (sizeof (struct chunkent) * hdr->maxchunks);
  if (!ents)
    {
      error ("memory exhausted");
      exit (EXIT_FAILURE);
    }

  fseek (ifp, sizeof (struct chunkhdr), SEEK_SET);
  for (i = 0; i < hdr->numchunks; i++)
    {
      fread (ents[i].chunkid, 1, 8, ifp);
      ents[i].offset = read_word (ifp);
      ents[i].size = read_word (ifp);
    }

  return (check_stream (ifp) != FRWERR ? ents : NULL);
}

/**
 * Read in the string table OBJ_STRT
 */
const aof_obj_strt *
read_stringtab (FILE * ifp, struct chunkent *strent)
{
  if (strptr)
    free (strptr);
  strptr = malloc (strent->size);
  if (!strptr)
    {
      error ("memory exhausted");
      exit (EXIT_FAILURE);
    }

  fseek (ifp, strent->offset, SEEK_SET);
  strptr->size = read_word (ifp);	/* size in 1st word */
  fread (&strptr->str, 1, strent->size - 4, ifp);

  return check_stream (ifp) != FRWERR ? strptr : NULL;
}

/*
 * read in the symbol table
 */
struct symbol *
read_symboltab (FILE * ifp, struct chunkent *syment, int numsyms)
{
  int i;

  if (symptr)
    free (symptr);
  symptr = (struct symbol *) malloc (numsyms * sizeof (struct symbol));
  if (!symptr)
    {
      error ("memory exhausted");
      exit (EXIT_FAILURE);
    }

  fseek (ifp, syment->offset, SEEK_SET);
  for (i = 0; i < numsyms; i++)
    {
      symptr[i].name = read_word (ifp);
      symptr[i].flags = read_word (ifp);
      symptr[i].value = read_word (ifp);
      symptr[i].areaname = read_word (ifp);
    }

  return (check_stream (ifp) != FRWERR ? symptr : NULL);
}

/*
 * read in the identification chunk
 */
char *
read_ident (FILE * ifp, struct chunkent *ident)
{
  if (idptr)
    free (idptr);
  idptr = malloc (ident->size);
  if (!idptr)
    {
      error ("memory exhausted");
      exit (EXIT_FAILURE);
    }

  fseek (ifp, (long) ident->offset, SEEK_SET);
  fread (idptr, 1, (int) ident->size, ifp);

  return (check_stream (ifp) != FRWERR ? idptr : NULL);
}

/*
 * read in the AOF header
 */
struct aofhdr *
read_aofhdr (FILE * ifp, struct chunkent *hdrent)
{
  int i;
  struct areahdr *areahdr;

  if (hdrent->size < sizeof (struct aofhdr))
    {
      error ("AOF header size is %d which is smaller than the expected minimum size %zd",
	     hdrent->size, sizeof (struct aofhdr));
      return NULL;
    }
  if (aofhdr)
    free (aofhdr);
  aofhdr = (struct aofhdr *) malloc (hdrent->size);
  if (!aofhdr)
    {
      error ("memory exhausted");
      exit (EXIT_FAILURE);
    }

  /* read-in whole of AOF header */
  fseek (ifp, hdrent->offset, SEEK_SET);
  aofhdr->filetype = read_word (ifp);
  aofhdr->version = read_word (ifp);
  aofhdr->numareas = read_word (ifp);
  aofhdr->numsyms = read_word (ifp);
  aofhdr->entryarea = read_word (ifp);
  aofhdr->entryoffset = read_word (ifp);
  if (hdrent->size != sizeof (struct aofhdr) + aofhdr->numareas * sizeof (struct areahdr))
    {
      error ("Malformed header size : is %d bytes but based on number of declared areas we expect it to be %zd bytes",
	     hdrent->size,
	     sizeof (struct aofhdr) + aofhdr->numareas * sizeof (struct areahdr));
      return NULL;
    }
  areahdr = (struct areahdr *) &aofhdr[1];
  for (i = 0; i < aofhdr->numareas; i++)
    {
      areahdr[i].name = read_word (ifp);
      areahdr[i].flags = read_word (ifp);
      areahdr[i].size = read_word (ifp);
      areahdr[i].numrelocs = read_word (ifp);
      areahdr[i].baseaddr = read_word (ifp);
    }
  return (check_stream (ifp) != FRWERR ? aofhdr : NULL);
}

/*
 * read in a relocation directive
 */
struct reloc *
read_reloc (FILE * ifp)
{
  static struct reloc reloc;

  reloc.offset = read_word (ifp);
  reloc.flags = read_word (ifp);
  return (check_stream (ifp) != FRWERR ? &reloc : NULL);
}
