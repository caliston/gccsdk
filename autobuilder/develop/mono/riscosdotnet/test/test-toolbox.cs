/*
 * Simple application to test the RISC OS C# bindings and
 * demonstrate what a RISC OS toolbox application might
 * look like when written in C#.
 *
 * RISC OS Dot Net (the C# binding) is still evolving, so
 * this test app probably will too.
 *
 * Author:
 *	Lee Noar <leenoar@sky.com>
 */

using System;
using riscos;

public class MyTask : ToolboxTask
{
	private Toolbox.Iconbar Iconbar;
	private Toolbox.Window MainWindow;
	private Font.Instance MainFont;
	private bool main_window_on_screen;

	enum MyEvent : uint
	{
		IconbarSelect = 0x100,
		IconbarAdjust = 0x101,
		Quit = 0x9999
	}

	public void Init ()
	{
		int[] mess_list = { 0 };
		int[] event_list = { 0 };

		// The message and event lists are copied by the toolbox, so we can
		// discard them after initialisation.
		Initialise (350, mess_list, event_list, "<MonoTestTB$Dir>");

		Iconbar = new Toolbox.Iconbar ("AppIcon");
		// Set the text to be displayed under the Iconbar sprite.
		Iconbar.Text = "MonoTestTB";
		Iconbar.HelpMessage = "Click SELECT to toggle the main window open/closed|MClick ADJUST to quit";
		// Set the Iconbar object to return our own events when clicked with SELECT/ADJUST.
		Iconbar.SelectEvent = (uint)MyEvent.IconbarSelect;
		Iconbar.AdjustEvent = (uint)MyEvent.IconbarAdjust;
		// Add our own event handlers to be called for the events we set above.
		Iconbar.ToolboxHandlers.Add ((uint)MyEvent.IconbarSelect, IconbarSelectHandler);
		Iconbar.ToolboxHandlers.Add ((uint)MyEvent.IconbarAdjust, QuitHandler);
		// Display our application icon on the Iconbar.
		Iconbar.Show ();

		MainFont = new Font.Instance ("Trinity.Medium", 24 << 4, 24 << 4);
		MainWindow = new Toolbox.Window ("MainWindow");

		// Can also use MainWindow.SetTitle ("CSharp Toolbox Window");
		MainWindow.Title = "CSharp Toolbox Window";

		// Register the event handlers for the window.
		MainWindow.RedrawHandler += new Wimp.RedrawEventHandler (RedrawMainWindow);
		MainWindow.ToolboxHandlers.Add ((uint)MyEvent.Quit, QuitHandler);
	}

	public void Run ()
	{
		PollLoop ();
	}

	private void RedrawMainWindow (object sender, Wimp.RedrawEventArgs args)
	{
		ColourTrans.SetFontColours (ColourTrans.White, ColourTrans.Black, 7);
		MainFont.Paint ("CSharp Toolbox Task",
				Font.PlotType.OSUnits,
				args.Origin.X + 10,
				args.Origin.Y - 100,
				0); // Length ignored (paint whole string) if bit 7 of flags not set
	}

	private void QuitHandler (object sender, Toolbox.ToolboxEventArgs args)
	{
		Reporter.WriteLine ("Quit handler called - Exiting...");
		Quit = true;
	}

	private void IconbarSelectHandler (object sender, Toolbox.ToolboxEventArgs args)
	{
		// Toggle the main window open/closed when SELECT clicked on the Iconbar icon.
		if (main_window_on_screen)
			MainWindow.Hide ();
		else
			MainWindow.Show ();
		main_window_on_screen ^= true;
	}
}

public class Test
{
	public static void Main(string[] args)
	{
		MyTask task = new MyTask();

		// Most methods that call a SWI throw an OS.ErrorException if the
		// SWI returns an error.
		try
		{
			task.Init ();
			task.Run ();
		}
		catch (OS.ErrorException ex)
		{
			Reporter.WriteLine ("error number = {0}, error string = {1}",ex.OSError.errnum,ex.OSError.errmess);
		}
		finally
		{
		}
	}
}
