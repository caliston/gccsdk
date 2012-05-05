--- Makefile.in.orig	2012-04-14 04:41:48.000000000 +0100
+++ Makefile.in	2012-04-14 04:42:50.000000000 +0100
@@ -74,7 +74,7 @@
 
 sdlquake_LDADD = @MATHLIB@ @INETLIB@
 
-sdlquake_SOURCES =  	adivtab.h			anorm_dots.h			anorms.h			asm_draw.h			asm_i386.h			block16.h			block8.h			bspfile.h			cd_sdl.c			cdaudio.h			chase.c				cl_demo.c			cl_input.c			cl_main.c			cl_parse.c			cl_tent.c			clean.bat			client.h			cmd.c				cmd.h				common.c			common.h			conproc.h			console.c			console.h			crc.c				crc.h				cvar.c				cvar.h				d_copy.S			d_edge.c			d_fill.c			d_iface.h			d_ifacea.h			d_init.c			d_local.h			d_modech.c			d_part.c			d_polyse.c			d_scan.c			d_sky.c				d_sprite.c			d_surf.c			d_zpoint.c			dosasm.S			dosisms.h			draw.c				draw.h				host.c				host_cmd.c			input.h				keys.c				keys.h				mathlib.c			mathlib.h			menu.c				menu.h				model.c				model.h				modelgen.h			mpdosock.h			net.h				net_bsd.c			net_bw.h			net_dgrm.c			net_dgrm.h			net_loop.c			net_loop.h			net_main.c			net_udp.c			net_udp.h			net_vcr.c			net_vcr.h			net_wso.c			pr_cmds.c			pr_comp.h			pr_edict.c			pr_exec.c			progdefs.h			progs.h				protocol.h			quakeasm.h			quakedef.h			r_aclip.c			r_alias.c			r_bsp.c				r_draw.c			r_edge.c			r_efrag.c			r_light.c			r_local.h			r_main.c			r_misc.c			r_part.c			r_shared.h			r_sky.c				r_sprite.c			r_surf.c			r_vars.c			r_varsa.S			render.h			resource.h			sbar.c				sbar.h				scitech				screen.c			screen.h			server.h			snd_dma.c			snd_mem.c			snd_mix.c			snd_sdl.c			sound.h				spritegn.h			sv_main.c			sv_move.c			sv_phys.c			sv_user.c			sys.h				sys_sdl.c			vgamodes.h			vid.h				vid_sdl.c			view.c				view.h				wad.c				wad.h				winquake.h			world.c				world.h				zone.c				zone.h				$(X86_SRCS) $(NONX86_SRCS)
+sdlquake_SOURCES =  	adivtab.h			anorm_dots.h			anorms.h			asm_draw.h			asm_i386.h			block16.h			block8.h			bspfile.h			cd_sdl.c			cdaudio.h			chase.c				cl_demo.c			cl_input.c			cl_main.c			cl_parse.c			cl_tent.c			clean.bat			client.h			cmd.c				cmd.h				common.c			common.h			conproc.h			console.c			console.h			crc.c				crc.h				cvar.c				cvar.h				d_edge.c			d_fill.c			d_iface.h			d_ifacea.h			d_init.c			d_local.h			d_modech.c			d_part.c			d_polyse.c			d_scan.c			d_sky.c				d_sprite.c			d_surf.c			d_zpoint.c			dosisms.h			draw.c				draw.h				host.c				host_cmd.c			input.h				keys.c				keys.h				mathlib.c			mathlib.h			menu.c				menu.h				model.c				model.h				modelgen.h			mpdosock.h			net.h				net_bsd.c			net_bw.h			net_dgrm.c			net_dgrm.h			net_loop.c			net_loop.h			net_main.c			net_udp.c			net_udp.h			net_vcr.c			net_vcr.h			net_wso.c			pr_cmds.c			pr_comp.h			pr_edict.c			pr_exec.c			progdefs.h			progs.h				protocol.h			quakeasm.h			quakedef.h			r_aclip.c			r_alias.c			r_bsp.c				r_draw.c			r_edge.c			r_efrag.c			r_light.c			r_local.h			r_main.c			r_misc.c			r_part.c			r_shared.h			r_sky.c				r_sprite.c			r_surf.c			r_vars.c			r_varsa.S			render.h			resource.h			sbar.c				sbar.h				scitech				screen.c			screen.h			server.h			snd_dma.c			snd_mem.c			snd_mix.c			snd_sdl.c			sound.h				spritegn.h			sv_main.c			sv_move.c			sv_phys.c			sv_user.c			sys.h				sys_sdl.c			vgamodes.h			vid.h				vid_sdl.c			view.c				view.h				wad.c				wad.h				winquake.h			world.c				world.h				zone.c				zone.h				$(X86_SRCS) $(NONX86_SRCS)
 
 
 X86_SRCS =  	snd_mixa.S			sys_dosa.S			d_draw.S			d_draw16.S			d_parta.S			d_polysa.S			d_scana.S			d_spr8.S			d_varsa.S			math.S				r_aclipa.S			r_aliasa.S			r_drawa.S			r_edgea.S			surf16.S			surf8.S				worlda.S
@@ -117,9 +117,9 @@
 LDFLAGS = @LDFLAGS@
 LIBS = @LIBS@
 sdlquake_OBJECTS =  cd_sdl.o chase.o cl_demo.o cl_input.o cl_main.o \
-cl_parse.o cl_tent.o cmd.o common.o console.o crc.o cvar.o d_copy.o \
+cl_parse.o cl_tent.o cmd.o common.o console.o crc.o cvar.o \
 d_edge.o d_fill.o d_init.o d_modech.o d_part.o d_polyse.o d_scan.o \
-d_sky.o d_sprite.o d_surf.o d_zpoint.o dosasm.o draw.o host.o \
+d_sky.o d_sprite.o d_surf.o d_zpoint.o draw.o host.o \
 host_cmd.o keys.o mathlib.o menu.o model.o net_bsd.o net_dgrm.o \
 net_loop.o net_main.o net_udp.o net_vcr.o net_wso.o pr_cmds.o \
 pr_edict.o pr_exec.o r_aclip.o r_alias.o r_bsp.o r_draw.o r_edge.o \