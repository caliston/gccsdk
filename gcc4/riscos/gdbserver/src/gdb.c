#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "asmutils.h"
#include "debug.h"
#include "gdb.h"

typedef enum
{
  WAITING_FOR_PACKET,
  READ_PACKET_DATA,
  READ_CHECKSUM1,
  READ_CHECKSUM2,
} gdb_state;

struct gdb_ctx
{
  gdb_state state;

  uint8_t data_buf[256];
  uint8_t data_len;
  uint8_t checksum;
  uint8_t refcksum;

  unsigned got_killed:1;
  
  gdb_send_cb send_fnc;
  gdb_break_cb brk_fnc;
  gdb_continue_cb cont_fnc;
  gdb_get_regs_cb get_regs_fnc;
  gdb_set_bkpt_cb set_bkpt_fnc;
  gdb_clear_bkpt_cb clear_bkpt_fnc;
  gdb_step_cb step_fnc;
  uintptr_t pw;
};

#define N_CTX 5
static gdb_ctx ctxs[N_CTX];

static void process_packet (gdb_ctx *ctx);
static void send_packet (gdb_ctx *ctx, const char *buf, size_t len);

static const char hexDigits[] = "0123456789abcdef";

static int
hexToInt (uint8_t c)
{
  if ('0' <= c && c <= '9')
    return c - '0';
  else if ('A' <= (c & ~0x20) && (c & ~0x20) <= 'F')
    return 10 + (c & ~0x20) - 'A';

  return 0;
}

gdb_ctx *
gdb_ctx_create (gdb_send_cb send, gdb_break_cb brk,
		gdb_continue_cb cont, gdb_get_regs_cb get_regs,
		gdb_set_bkpt_cb set_bkpt, gdb_clear_bkpt_cb clear_bkpt,
		gdb_step_cb step, uintptr_t pw)
{
  int i;
  for (i = 0; i < N_CTX; i++)
    {
      if (ctxs[i].send_fnc == NULL)
	break;
    }
  if (i == N_CTX)
    return NULL;

  gdb_ctx *ctx = &ctxs[i];

  ctx->state = WAITING_FOR_PACKET;

  ctx->send_fnc = send;
  ctx->brk_fnc = brk;
  ctx->cont_fnc = cont;
  ctx->get_regs_fnc = get_regs;
  ctx->set_bkpt_fnc = set_bkpt;
  ctx->clear_bkpt_fnc = clear_bkpt;
  ctx->step_fnc = step;
  ctx->pw = pw;

  return ctx;
}

void
gdb_ctx_destroy (gdb_ctx *ctx)
{
  /** \todo Need to tell debugger that we're disappearing */
  memset (ctx, 0, sizeof (gdb_ctx));
}

/**
 * \return true when we got the 'kill request'. false otherwise.
 */
bool
gdb_got_killed (const gdb_ctx *ctx)
{
  return ctx->got_killed != 0;
}

void
gdb_process_input (gdb_ctx *ctx, const uint8_t *data, size_t len)
{
  while (len)
    {
      switch (ctx->state)
	{
	case WAITING_FOR_PACKET:
	  switch (data[0])
	    {
	    case 3:
	      /* Tell client to interrupt application */
	      dprintf ("Received interrupt\n");
	      ctx->brk_fnc (ctx->pw);
	      break;
	    case '$':
	      ctx->checksum = 0;
	      ctx->data_len = 0;
	      ctx->state = READ_PACKET_DATA;
	      break;
	    default:
	      break;
	    }
	  break;

	case READ_PACKET_DATA:
	  if (data[0] == '#')
	    ctx->state = READ_CHECKSUM1;
	  else
	    {
	      ctx->checksum += data[0];
	      ctx->data_buf[ctx->data_len++] = data[0];
	    }
	  break;

	case READ_CHECKSUM1:
	  ctx->refcksum = hexToInt (data[0]) << 4;
	  ctx->state = READ_CHECKSUM2;
	  break;

	case READ_CHECKSUM2:
	  ctx->refcksum += hexToInt (data[0]);

	  /* Ensure the buffer is NUL terminated */
	  ctx->data_buf[ctx->data_len] = '\0';

	  if (ctx->checksum != ctx->refcksum)
	    ctx->send_fnc (ctx->pw, (const uint8_t *)"-", sizeof ("-")-1);
	  else
	    {
	      ctx->send_fnc (ctx->pw, (const uint8_t *)"+", sizeof ("+")-1);
	      process_packet (ctx);
	    }

	  ctx->state = WAITING_FOR_PACKET;
	  break;
	}

      data++;
      len--;
    }
}

static void
process_packet (gdb_ctx *ctx)
{
  uint8_t buf[512];
  uint8_t *p = buf;

  /* Empty packet */
  if (ctx->data_len == 0)
    return;

  bool support_request = true;
  switch (ctx->data_buf[0])
    {
    case '?':
      /* Indicate the reason the target halted.  */
      /** \todo Make sure we return the correct signal number */
      send_packet (ctx, "S05", sizeof ("S05")-1);
      break;

    case 'c':
      /** \todo parse addr, if any (and update PC) */
      ctx->cont_fnc (ctx->pw);
      break;

    case 'g':
      {
	/* Read general registers.  */
	const cpu_registers *regs = ctx->get_regs_fnc (ctx->pw);
	int config = cpuconfig ();

        for (size_t i = 0; i < sizeof (regs->raw) / sizeof (regs->raw[0]); ++i)
	  {
	    uint32_t val = regs->raw[i];

	    if (config == 26)
	      {
		/* Remove PSR flags */
		/** \todo is this sane? should we just 
		 * teach GDB about 26 bit ARMs, instead?
		 */
		if (i == 14 || i == 15)
		  val &= ~0xfc000003;
	      }

	    for (int j = 0; j < 4; j++)
	      {
		uint8_t b = (val >> (8 * j)) & 0xff;

		*p++ = hexDigits[b >> 4];
		*p++ = hexDigits[b & 0xf];
	      }
	  }
	
	send_packet (ctx, (const char *)buf, p - buf);
      }
      break;

    case 'G':
      {
	cpu_registers *regs = ctx->get_regs_fnc (ctx->pw);

	p = &ctx->data_buf[1];

        for (size_t i = 0;
	     i < sizeof (regs->raw) / sizeof (regs->raw[0])
	        && p - ctx->data_buf <= ctx->data_len;
	     ++i)
	  {
	    regs->raw[i] = 0;
	    for (int j = 0; j < 4; j++)
	      {
		uint8_t b = hexToInt (*p++) << 4;
		b |= hexToInt (*p++);

		regs->raw[i] |= b << (8 * j);
	      }
	  }

	send_packet (ctx, "OK", sizeof ("OK")-1);
      }
      break;

    case 'H':
      {
	/* Set thread for operation.  */
	uint8_t type = ctx->data_buf[1];
	int thread = strtol ((const char *)&ctx->data_buf[2], NULL, 16);
	if ((thread == -1 || thread == 0) && (type == 'c' || type == 'g'))
	  send_packet (ctx, "OK", sizeof ("OK")-1);
	else
	  send_packet (ctx, "E00", sizeof ("E00")-1);
      }
      break;

    case 'k':
      /* Kill request.  */
      ctx->got_killed = 1;
      break;

    case 'm':
      {
	/* "m" <addr> "," <length>
	   Read 'length' bytes of memory starting at address <addr>.  */
	support_request = false;

	char *comma;
	uint32_t addr = strtoul ((const char *)&ctx->data_buf[1], &comma, 16);
	if (*comma != ',')
	  break;
	uint32_t length = strtoul (comma + 1, NULL, 16);

	if (length > sizeof (buf) / 2)
	  {
	    dprintf ("Packet m request was about to overflow our buffer.\n");
	    break;
	  }
	while (length--)
	  {
	    /** \todo This may abort. */
	    uint8_t b = *(const uint8_t *)addr;

	    *p++ = hexDigits[b >> 4];
	    *p++ = hexDigits[b & 0xf];

	    ++addr;
	  }

	send_packet (ctx, (const char *)buf, p - buf);

	support_request = true;
      }
      break;
	
    case 'M':
      {
	char *comma;
	uint32_t addr = strtoul ((const char *)&ctx->data_buf[1], &comma, 16);
	uint32_t length = strtoul (comma + 1, &comma, 16);

	p = (uint8_t *)comma + 1;

	while (length-- && p - ctx->data_buf <= ctx->data_len - 2)
	  {
	    uint8_t b = 0;
	    for (int i = 0; i < 2; i++)
	      b = b << 4 | hexToInt (*p++);

	    /** \todo This may abort. */
	    *(uint8_t *)addr++ = b;
	  }

	flush_caches ();

	send_packet (ctx, "OK", sizeof ("OK")-1);
      }
      break;

    case 'q':
      {
	/* General query packet.  */
	size_t len;
	for (len = 1; len != ctx->data_len && ctx->data_buf[len] != ':'; ++len)
	  /* */;
	switch (len)
	  {
	    case 1 + sizeof ("C")-1:
	      /* Return current thread ID.  */
	      if (ctx->data_buf[1] == 'C')
		send_packet (ctx, "QC1", sizeof ("QC1")-1);
	      else
		support_request = false;
	      break;

	    case 1 + sizeof ("Offsets")-1:
	    /* case 1 + sizeof ("TStatus")-1: */
	      if (!strcmp ((const char *)&ctx->data_buf[1], "Offsets"))
		{
		  /* Indicate Text and Data relocation offset from its original
		     address.  */
		  send_packet (ctx, "Text=0;Data=0;Bss=0", sizeof ("Text=0;Data=0;Bss=0")-1);
		}
	      else if (!strcmp ((const char *)&ctx->data_buf[1], "TStatus"))
		{
		  /* We're asked if there is a trace experiment running right
		     now.  We reply no trace is running nor has one been run
		     yet.  */
		  send_packet (ctx, "T0;tnotrun:0", sizeof ("T0;tnotrun:0")-1);
		}
	      else
		support_request = false;
	      break;

	    case 1 + sizeof ("Symbol::")-1:
	    /* case 1 + sizeof ("Attached")-1: */
	      if (!strcmp ((const char *)&ctx->data_buf[1], "Symbol::"))
		{
		  /* GDB is prepared to server symbol lookup requests.  We're
		     not interested in atm.  */
		  send_packet (ctx, "OK", sizeof ("OK")-1);
		}
	      else if (!strcmp ((const char *)&ctx->data_buf[1], "Attached"))
	        {
		  /* Return whether remote server attached to an existing process
		     or created a new process.  We always create a new
		     process.  */
		  send_packet (ctx, "0", sizeof ("0")-1);
	        }
	      else
	        support_request = false;
	      break;

	    default:
	      /** \todo unsupported query.  */
	      support_request = false;
	      break;
	  }
      }
      break;

    case 's':
      /** \todo parse addr, if any (and update PC) */
      ctx->step_fnc (ctx->pw);
      break;

    case 'z':
    case 'Z':
      {
	char *comma;
	uint8_t type = ctx->data_buf[1];
	uint32_t addr = strtoul ((const char *)&ctx->data_buf[3], &comma, 16);
	uint32_t kind = strtoul (comma + 1, NULL, 16);

	/* Type '0' : memory breakpoint
	   Type '1' : hardware breakpoint
	   Type '2' : write watchpoint
	   Type '3' : read watchpoint
	   Type '4' : access watchpoint
	   Kind '2' : 16-bit Thumb
	   Kind '3' : 32-bit Thumb-2
	   Kind '4' : 32-bit ARM
	   We only support type 0 and ARM instructions.  */
	if (type != '0' || kind != 4)
	  {
	    send_packet (ctx, "", sizeof ("")-1);
	    break;
	  }

	int success;
	if (ctx->data_buf[0] == 'z')
	  success = ctx->clear_bkpt_fnc (ctx->pw, addr);
	else
	  success = ctx->set_bkpt_fnc (ctx->pw, addr);

	if (success == 0)
	  send_packet (ctx, "E00", sizeof ("E00")-1);
	else
	  send_packet (ctx, "OK", sizeof ("OK")-1);
      }
      break;

    default:
      support_request = false;
      break;
    }

  if (!support_request)
    {
      dprintf ("Unsupported packet '%.*s'\n",
	       ctx->data_len, (const char *)ctx->data_buf);
      send_packet (ctx, "", sizeof ("")-1);
    }
}

static void
send_packet (gdb_ctx *ctx, const char *buf, size_t len)
{
  ctx->send_fnc (ctx->pw, (const uint8_t *)"$", sizeof ("$")-1);
  
  uint8_t cksum = 0;
  if (len)
    {
      for (const uint8_t *p = (const uint8_t *)buf;
	   p != (const uint8_t *)buf + len;
	   ++p)
	cksum += *p;
      ctx->send_fnc (ctx->pw, (const uint8_t *)buf, len);
    }

  const uint8_t checksum[] =
    {
      '#',
      hexDigits[cksum >> 4],
      hexDigits[cksum & 0xf]
    };
  ctx->send_fnc (ctx->pw, checksum, sizeof (checksum));
}
