//
// toolbox/window.cs - a binding of the RISC OS API to C#.
//
// Author: Lee Noar (leenoar@sky.com)
//

using System;
using System.Text;

namespace riscos
{
	public static partial class Toolbox
	{
		/*! \class Window
		 * \brief Encapsulates a Toolbox window.  */
		public class Window : Object
		{
			class Method
			{
				public const int GetWimpHandle = 0;
				public const int AddGadget = 1;
				public const int RemoveGadget = 2;
				public const int SetMenu = 3;
				public const int GetMenu = 4;
				public const int SetPointer = 5;
				public const int GetPointer = 6;
				public const int SetHelpMessage = 7;
				public const int GetHelpMessage = 8;
				public const int AddKeyboardShortcuts = 9;
				public const int RemoveKeyboardShortcuts = 10;
				public const int SetTitle = 11;
				public const int GetTitle = 12;
				public const int SetDefaultFocus = 13;
				public const int GetDefaultFocus = 14;
				public const int SetExtent = 15;
				public const int GetExtent = 16;
				public const int ForceRedraw = 17;
				public const int SetToolBars = 18;
				public const int GetToolBars = 19;
			}

			public enum Toolbar
			{
				InternalBottomLeft = 1,
				InternalTopLeft = 2,
				ExternalBottomLeft = 4,
				ExternalTopLeft = 8
			}

			/*! \class EventCode
			 * \brief Toolbox events that can be generated by the Toolbox Window object.  */
			public class EventCode
			{
				public const uint AboutToBeShown = 0x82880;
				public const uint HasBeenHidden = 0x82890;
			}

			/*! \class PointerShape
			 * \brief Used to set/read the Pointer property of the Window.  */
			public class PointerShape
			{
				/*! \brief The sprite name of the pointer shape.  */
				public string SpriteName;
				/*! \brief The x coordinate of the active point in the sprite.  */
				public int xHotSpot;
				/*! \brief The y coordinate of the active point in the sprite.  */
				public int yHotSpot;

				public PointerShape (string spriteName, int x, int y)
				{
					SpriteName = spriteName;
					xHotSpot = x;
					yHotSpot = y;
				}
			}

			/*! \class PointerInfo
			 * \brief Used as a buffer to retrieve information about the pointer using
			 * method Window.GetPointerInfo.  */
			public class PointerInfo
			{
				/*! \brief Current position of the mouse pointer in OS units.  */
				public OS.Coord Pos;
				/*! \brief Current state of the mouse buttons. See \e PointerInfo.ButtonState. */
				public uint Buttons;
				/*! \brief Window ID, or WIMP window handle if \e Buttons
				 * bit \e NotToolboxWindow is set.  */
				public uint ObjectID;
				/*! \brief Component ID, or WIMP icon handle if \e Buttons
				 * bit \e NotToolboxWindow is set.  */
				public uint CmpID;

				/*! \class ButtonState
				 * \brief Possible bit states for \e PointerInfo.Buttons  */
				public class ButtonState
				{
					public const uint Adjust = (1 << 0);
					public const uint Menu = (1 << 1);
					public const uint Select = (1 << 2);
					public const uint NotToolboxWindow = (1 << 8);
				}
			}

			/*! \brief Used when setting the \e DefaultFocus property of the Window to
			 * remove the default focus.  */
			public const uint DefaultFocusNone = 0xffffffff;
			/*! \brief Used when setting the \e DefaultFocus property of the Window to
			 * make the Window work area the default focus.  */
			public const uint DefaultFocusWindow = 0xfffffffe;

			/*! \brief The WIMP handle for this toolbox window.  */
			Wimp.WindowHandle Handle;

			public event Wimp.RedrawEventHandler RedrawHandler;

			/*! \brief Create a toolbox window from the named template in the
			 * Resource file.
			 * \param[in] resName The name of the window template to use.  */
			public Window (string resName)
			{
				Create (resName);
				Handle = new Wimp.WindowHandle (WimpHandle);
			}

			/*! \brief Create a toolbox window from the template data given.
			 * \param[in] templateData Pointer to the window template.  */
			public Window (IntPtr templateData)
			{
				Create (templateData);
				Handle = new Wimp.WindowHandle (WimpHandle);
			}

			/*! \brief Create a Toolbox Window from an object that already exists.
			 * \param [in] objectID The Toolbox ID of the existing object.  */
			public Window (uint objectID) : base (objectID)
			{
			}

			/*! \brief Force a redraw on the area of the window given.
			 * \param [in] area The rectangular area of the window to redraw.
			 * \return Nothing.  */
			public void ForceRedraw (OS.Rect area)
			{
				OS.ThrowOnError (NativeMethods.Window_ForceRedraw (0,
										   ID,
										   new NativeOS.Rect (area)));
			}

			/*! \brief Attach toolbars to this Window object. If the object is showing then
			 * the new toolbars will be shown.
			 * \param [in] intBottomLeft Internal Bottom Left toolbar.
			 * \param [in] intTopLeft Internal Top Left toolbar.
			 * \param [in] extBottomLeft External Bottom Left toolbar.
			 * \param [in] extTopLeft External Top Left toolbar.
			 * \return Nothing.
			 * \note Setting a toolbar to \e null means that there is no toolbar of that type. */
			public void SetToolBars (Window intBottomLeft,
						 Window intTopLeft,
						 Window extBottomLeft,
						 Window extTopLeft)
			{
				uint mask = 0;
				uint ibl = 0, itl = 0, ebl = 0, etl = 0;

				if (intBottomLeft != null)
				{
					mask |= (uint)Toolbar.InternalBottomLeft;
					ibl = intBottomLeft.ID;
				}
				if (intTopLeft != null)
				{
					mask |= (uint)Toolbar.InternalTopLeft;
					itl = intTopLeft.ID;
				}
				if (extBottomLeft != null)
				{
					mask |= (uint)Toolbar.ExternalBottomLeft;
					ebl = extBottomLeft.ID;
				}
				if (extTopLeft != null)
				{
					mask |= (uint)Toolbar.ExternalTopLeft;
					etl = extTopLeft.ID;
				}

				OS.ThrowOnError (NativeMethods.Window_SetToolBars (mask,
										   ID,
										   ibl,
										   itl,
										   ebl,
										   etl));
			}

			/*! \brief Return the requested toolbar Window.
			 * \param [in] toolbar The code of the required toolbar.
			 * \return A window object representing the toolbar or null if there is no
			 * attached toolbar.  */
			Window GetToolBar (Toolbar toolbar)
			{
				uint tb_obj_id = 0;
				uint dummy_obj_id; // For the IDs we're not interested in

				switch (toolbar)
				{
				case Toolbar.InternalBottomLeft:
					OS.ThrowOnError (NativeMethods.Window_GetToolBars ((uint)toolbar,
											   ID,
											   out tb_obj_id,
											   out dummy_obj_id,
											   out dummy_obj_id,
											   out dummy_obj_id));
					break;
				case Toolbar.InternalTopLeft:
					OS.ThrowOnError (NativeMethods.Window_GetToolBars ((uint)toolbar,
											   ID,
											   out dummy_obj_id,
											   out tb_obj_id,
											   out dummy_obj_id,
											   out dummy_obj_id));
					break;
				case Toolbar.ExternalBottomLeft:
					OS.ThrowOnError (NativeMethods.Window_GetToolBars ((uint)toolbar,
											   ID,
											   out dummy_obj_id,
											   out dummy_obj_id,
											   out tb_obj_id,
											   out dummy_obj_id));
					break;
				case Toolbar.ExternalTopLeft:
					OS.ThrowOnError (NativeMethods.Window_GetToolBars ((uint)toolbar,
											   ID,
											   out dummy_obj_id,
											   out dummy_obj_id,
											   out dummy_obj_id,
											   out tb_obj_id));
					break;
				}

				if (tb_obj_id == 0)
					return null;

				Toolbox.Object tb_obj;
				if (ToolboxTask.AllObjects.TryGetValue (tb_obj_id, out tb_obj))
					return (Window)tb_obj;

				// FIXME: Should we create a new window object here?
				return null;
			}

			/*! \brief The title of the window.  */
			public string Title
			{
				get { return GetText (Method.GetTitle); }
				set
				{
					if (value == null)
						throw new ArgumentNullException ("value", "Attempted to set Window title to null");
					SetText (Method.SetTitle, value);
				}
			}

			/*! \brief The WIMP handle of the Toolbox window.  */
			public uint WimpHandle
			{
				get { return CallMethod_GetR0 (Method.GetWimpHandle); }
			}

			/*! \brief The Menu which will be displayed when the Menu button is pressed over
			 * this Window object.
			 * \exception UnknownObjectException Thrown if the toolbox object ID is unknown when
			 * reading the property.
			 * \note Set to null to detach the Menu from the Window.  */
			public Toolbox.Menu Menu
			{
				set { SetMenu (Method.SetMenu, value); }
				get { return GetMenu (Method.GetMenu); }
			}

			/*! \brief The Pointer shape which will be used when the pointer enters this
			 * Window object.
			 * \note Set to null to detach the Pointer for this Window.  */
			public PointerShape Pointer
			{
				set
				{
					OS.ThrowOnError (NativeMethods.Window_SetPointer (0,
											  ID,
											  value.SpriteName,
											  value.xHotSpot,
											  value.yHotSpot));
				}
				get
				{
					int buffer_size, x, y;
					OS.ThrowOnError (NativeMethods.Window_GetPointer (0,
											  ID,
											  null,
											  0,
											  out buffer_size,
											  out x,
											  out y));
					StringBuilder buffer = new StringBuilder (buffer_size);
					OS.ThrowOnError (NativeMethods.Window_GetPointer (0,
											  ID,
											  buffer,
											  buffer_size,
											  out buffer_size,
											  out x,
											  out y));
					return new Window.PointerShape (buffer.ToString(), x, y);
				}
			}

			/*! \brief The help message which will be returned when a Help Request message is
			 * received for this Window object.
			 * \note Set to null to remove the Help Message from this Window.  */
			public string HelpMessage
			{
				set { SetText (Method.SetHelpMessage, value); }
				get { return GetText (Method.GetHelpMessage); }
			}

			/*! \brief The default focus component for this window.
			 * \note Set to \e DefaultFocusNone to remove or \e DefaultFocusWindow to make the Window
			 * itself the default focus.<br>
			 * Setting takes effect when next shown.  */
			public uint DefaultFocus
			{
				set
				{
					OS.ThrowOnError (NativeMethods.Object_SetR3 (0,
										    ID,
										    Method.SetDefaultFocus,
										    value));
				}
				get
				{
					uint cmp;

					OS.ThrowOnError (NativeMethods.Object_GetR0 (0,
										     ID,
										     Method.GetDefaultFocus,
										     out cmp));
					return cmp;
				}
			}

			/*! \brief The extent of the underlying WIMP Window.  */
			public OS.Rect Extent
			{
				set
				{
					OS.ThrowOnError (NativeMethods.Window_SetExtent (0,
											 ID,
											 new NativeOS.Rect (value)));
				}
				get
				{
					NativeOS.Rect extent = new NativeOS.Rect ();
					OS.ThrowOnError (NativeMethods.Window_GetExtent (0,
											 ID,
											 out extent));
					return new OS.Rect (extent);
				}
			}

			/*! \brief Return information about the state of the pointer.
			 * \param [out] pointer Object used to return pointer information.
			 * \return The Toolbox Window object currently under the pointer or
			 * null if not over a known toolbox window.  */
			public static Window GetPointerInfo (PointerInfo pointer)
			{
				OS.ThrowOnError (NativeMethods.Window_GetPointerInfo (0,
										      out pointer.Pos.X,
										      out pointer.Pos.Y,
										      out pointer.Buttons,
										      out pointer.ObjectID,
										      out pointer.CmpID));
				if ((pointer.Buttons & PointerInfo.ButtonState.NotToolboxWindow) != 0)
					return null;

				Toolbox.Object tb_obj;
				if (ToolboxTask.AllObjects.TryGetValue (pointer.ObjectID, out tb_obj))
					return (Toolbox.Window)tb_obj;

				// FIXME: It's a toolbox window, but we're not aware of it,
				// should we create a new window object here? It may have been
				// auto created.
				return null;
			}

			/*! \brief Return the Window object and component ID that contains the
			 * specified icon.
			 * \param [in] windowHandle The handle of the WIMP window.
			 * \param [in] iconHandle The handle of the WIMP icon
			 * \param [out] cmpID The Toolbox ID of the component that contains the icon.
			 * \return The Window object that contains the icon or null if unknown.  */ 
			static public Window WimpToToolbox (uint windowHandle,
							    uint iconHandle,
							    out uint cmpID)
			{
				uint tb_obj_id;

				OS.ThrowOnError (NativeMethods.Window_WimpToToolbox (0,
										     windowHandle,
										     iconHandle,
										     out tb_obj_id,
										     out cmpID));
				if (tb_obj_id == 0)
					return null;

				Toolbox.Object tb_obj;
				if (ToolboxTask.AllObjects.TryGetValue (tb_obj_id, out tb_obj))
					return (Toolbox.Window)tb_obj;

				// FIXME: It's a toolbox window, but we're not aware of it,
				// should we create a new window object here? It may have been
				// auto created.
				return null;
			}
/*
			TODO:

			void AddKeyboardShortcuts();
			void RemoveKeyboardShortcuts();
			void ExtractGadgetInfo();
*/
			public virtual void OnRedraw (Wimp.RedrawWindowEvent ev)
			{
				int more;

				// Start the redraw. Given the window handle, the OS fills in RedrawWimpBlock
				// with details of what needs redrawing.
				NativeMethods.Wimp_RedrawWindow (ref ev.RedrawArgs.RedrawWimpBlock, out more);

				// The origin of the window only needs to be calculated once before entering
				// the redraw loop.
				ev.RedrawArgs.Origin = Handle.GetOrigin (ref ev.RedrawArgs.RedrawWimpBlock.Visible,
									 ref ev.RedrawArgs.RedrawWimpBlock.Scroll);
				while (more != 0)
				{
					if (RedrawHandler != null)
						RedrawHandler (this, ev.RedrawArgs);
					NativeMethods.Wimp_GetRectangle (ref ev.RedrawArgs.RedrawWimpBlock, out more);
				}
			}
		}
	}
}
