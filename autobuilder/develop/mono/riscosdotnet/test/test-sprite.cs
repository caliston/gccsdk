/*
 * Simple application to test the OSSpriteOp and dynamic area
 * RISC OS C# bindings.
 *
 * RISC OS Dot Net (the C# binding) is still evolving, so
 * this test app probably will too.
 *
 * In this case, I've used plain WIMP.
 *
 * Author:
 *	Lee Noar <leenoar@sky.com>
 */

using System;
using System.Collections.Generic;
using riscos;

namespace riscos.CSharpBindings.SpriteTest
{
	public class SpriteTask : WimpTask
	{
		public static OS.DynamicAreaHeap Heap;

		OSSpriteOp.SpriteArea SpriteArea;

		List<TestSprite> Sprites = new List<TestSprite> ();

		void CreateSprite ()
		{
			try {
				int sprite_type = OSSpriteOp.GenerateOldSpriteType (OS.PixelDepth.BPP24,
										    OSSpriteOp.SpriteDpi.Dpi90,
										    OSSpriteOp.SpriteDpi.Dpi90,
										    false);
				var sprite = new TestSprite (SpriteArea,
							     "sprite1",
							     false,
							     50,
							     50,
							     sprite_type);

				OSSpriteOp.RedirectContext context = sprite.SwitchTo (IntPtr.Zero);

				// Make sure that if any errors occur, output is directed back to the
				// screen.
				try {
					for (int x = 0; x < 100; x++)
					{
						uint red = (uint)((256 * x) / 256) + 30;

						ColourTrans.SetGCOL (red << ColourTrans.RedShift,
								     OS.GCOLAction.Replace_FG);
						OS.PlotLine (x, 0, x, 100);
					}

					Sprites.Add (sprite);
					MsgModeChange += sprite.ModeChangeHandler;
				}
				catch {
					throw;
				}
				finally {
					sprite.SwitchFrom (context);
				}
			}
			catch {
				throw;
			}
		}

		void Init ()
		{
			int[] mess_list = { 0 };

			Initialise (350, "Test App", mess_list);

			Heap = new OS.DynamicAreaHeap ("C# Sprites",
						       4 * 1024,		// 4KB Initial
						       10 * 1024 * 1024);	// 10MB Max

			// Allocate 1MB of memory from the dynamic area to use as a sprite area.
			var sprite_area = Heap.Alloc (1 * 1024 * 1024);
			SpriteArea = new OSSpriteOp.SpriteArea (sprite_area, 1 * 1024 * 1024);

			CreateSprite ();

			Wimp.WindowAttributes attributes = new Wimp.WindowAttributes ("CSharp Sprites");
			attributes.WorkArea = new OS.Rect (0, 0, 2000, 2000);
			attributes.UserRedrawn = true;

			SpriteWindow window = new SpriteWindow (Sprites,
								attributes);
			// Use a lambda expression for the Quit handler.
			window.Closed += (sender, e) => Quit = true;

			window.Open (new OS.Rect (100, 100, 2000, 1500),	// Visible area
				     new OS.Coord (0, 2000),			// Scroll offsets
				     Wimp.WindowStackPosition.Top);
		}

		void Run ()
		{
			while (Quit == false)
			{
				try {
					PollIdle (OS.ReadMonotonicTime() + 100);
				}
				catch (OS.ErrorException ex)
				{
					Wimp.ReportError (Wimp.ErrorBoxFlags.OKIcon,
							  "MonoTestApp",
							  ex.OSError.Number,
							  ex.OSError.Message);
				}
				catch (Exception ex)
				{
					Reporter.WriteLine (ex.Message);
					// Split the stacktrace into individual lines and feed each one to
					// Reporter.
					string[] lines = ex.StackTrace.Split (new char[]{'\n'});
					foreach (string s in lines)
						Reporter.WriteLine (s);
				}
			}
		}

		public static void Main(string[] args)
		{
			SpriteTask task = new SpriteTask();

			try
			{
				task.Init ();
				task.Run ();
			}
			catch (OS.ErrorException ex)
			{
				Reporter.WriteLine (ex.Message);
				Reporter.WriteLine (ex.OSError.Message);
				// Split the stacktrace into individual lines and feed each one to
				// Reporter.
				string[] lines = ex.StackTrace.Split (new char[]{'\n'});
				foreach (string s in lines)
					Reporter.WriteLine (s);
			}
			finally
			{
				task.CloseDown ();
			}
		}

		class TestSprite : OSSpriteOp.SpriteByPointer
		{
			public IntPtr TransTable = IntPtr.Zero;

			public TestSprite (OSSpriteOp.SpriteArea spriteArea, string name, bool palette,
						int width, int height, int mode)
				: base (spriteArea, name, palette, width, height, mode)
			{
				int buffer_size = GetTransTableSize (ColourTrans.CurrentMode,
								     ColourTrans.CurrentPalette,
								     false);
				if (buffer_size != 0)
				{
					TransTable = SpriteTask.Heap.Alloc (buffer_size);
					GetTransTable (TransTable,
						       ColourTrans.CurrentMode,
						       ColourTrans.CurrentPalette,
						       false);
				}
			}

			~TestSprite ()
			{
				if (TransTable != IntPtr.Zero)
					SpriteTask.Heap.Free (TransTable);
			}

			public void ModeChangeHandler (object sender, Wimp.MessageEventArgs e)
			{
				if (TransTable != IntPtr.Zero)
				{
					SpriteTask.Heap.Free (TransTable);
					TransTable = IntPtr.Zero;
				}

				int buffer_size = GetTransTableSize (ColourTrans.CurrentMode,
								     ColourTrans.CurrentPalette,
								     false);
				if (buffer_size != 0)
				{
					TransTable = SpriteTask.Heap.Alloc (buffer_size);
					GetTransTable (TransTable,
						       ColourTrans.CurrentMode,
						       ColourTrans.CurrentPalette,
						       false);
				}
			}
		}

		class SpriteWindow : Wimp.Window
		{
			List<TestSprite> Sprites;

			int WindowHeight;

			// Initialise to the identity matrix.
			OS.Matrix matrix = new OS.Matrix ();

			public SpriteWindow (List<TestSprite> sprites,
					     Wimp.WindowAttributes attr) : base (attr)
			{
				Sprites = sprites;

				WindowHeight = attr.WorkArea.MaxY - attr.WorkArea.MinY;

				matrix.Rotate (45);
			}

			protected override void OnPaint (Wimp.RedrawEventArgs e)
			{
				IntPtr trans_table = Sprites[0].TransTable;

				// Render as is.
				OS.Move (e.Origin.X + 40, e.Origin.Y + WindowHeight - 170);
				Sprites[0].Plot (OSSpriteOp.PlotAction.OverWrite);

				// Render scaled by factor of 2.
				Sprites[0].PlotScaled (e.Origin.X + 180,
						       e.Origin.Y + WindowHeight - 220,
						       OSSpriteOp.PlotAction.OverWrite,
						       new OS.ScaleFactors (2, 2, 1, 1),
						       trans_table);

				// Render transformed using matrix.
				// Transformed sprites are not plotted at the current graphics position;
				// the matrix/destination rectangle is used to place the sprite at the
				// required position.
				// The translation has to be applied here because we don't know ahead
				// of time where the screen position is and it will change as the
				// window is moved.
				// A copy of the matrix has to be used so that the translation is applied
				// only once to the original matrix rather than multiple times.
				var local_matrix = (OS.Matrix)matrix.Clone ();
				local_matrix.Translate (e.Origin.X + 480, e.Origin.Y + WindowHeight - 170);
				Sprites[0].PlotTransformed (OSSpriteOp.PlotAction.OverWrite,
							    local_matrix,
							    trans_table);

				// Render transformed to destination parallelogram
				var block = new OSSpriteOp.DestCoordBlock();

				block.x0 = OS.ToDrawUnits (e.Origin.X + 600);
				block.y0 = OS.ToDrawUnits (e.Origin.Y + WindowHeight - 70);
				block.x1 = OS.ToDrawUnits (e.Origin.X + 800);
				block.y1 = block.y0;
				block.x2 = block.x1 + OS.ToDrawUnits (50);
				block.y2 = OS.ToDrawUnits (e.Origin.Y + WindowHeight - 200);
				block.x3 = block.x0 + OS.ToDrawUnits (50);
				block.y3 = block.y2;
				Sprites[0].PlotTransformed (OSSpriteOp.PlotAction.OverWrite,
							    block,
							    trans_table);
			}
		}
	}
}
