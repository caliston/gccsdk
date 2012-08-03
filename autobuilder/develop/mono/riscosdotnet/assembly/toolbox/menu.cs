//
// toolbox/menu.cs - a binding of the RISC OS API to C#.
//
// Author: Lee Noar (leenoar@sky.com)
//

using System;
using System.Text;
using System.Runtime.InteropServices;

namespace riscos
{
	public static partial class Toolbox
	{
		/*! \class MenuEntry
		 * \brief Encapsulates an item in a Menu.
		 *
		 * Stricty speaking, a Menu Entry is not a type of gadget. However, as
		 * a lot of the code is the same, Gadget is used as a base object to
		 * allow code reuse. Where a method does not make sense for a Menu Entry,
		 * it is overridden and will generate an exception if called.<br>
		 * These methods are:<br>
		 * \li Gadget.Type
		 * \li Gadget.BoundingBox
		 * \li Gadget.SetFocus */
		public class MenuEntry : Gadget
		{
			static class Method
			{
				public const int SetTick = 0;
				public const int GetTick = 1;
				public const int SetFade = 2;
				public const int GetFade = 3;
				public const int SetEntryText = 4;
				public const int GetEntryText = 5;
				public const int SetEntrySprite = 6;
				public const int GetEntrySprite = 7;
				public const int SetSubMenuShow = 8;
				public const int GetSubMenuShow = 9;
				public const int SetSubMenuEvent = 10;
				public const int GetSubMenuEvent = 11;
				public const int SetClickShow = 12;
				public const int GetClickShow = 13;
				public const int SetClickEvent = 14;
				public const int GetClickEvent = 15;
				public const int SetEntryHelpMessage = 18;
				public const int GetEntryHelpMessage = 19;
			}

			public MenuEntry (Menu menu, uint cmpID) : base (menu, cmpID)
			{
			}

			/*! \brief Gets or sets the tick state of this MenuEntry.  */
			public bool Ticked
			{
				get { return CallMethod_GetR0 (Method.GetTick) != 0; }
				set { CallMethod_SetR4 (Method.SetTick, value ? 1U : 0U); }
			}

			/*! \brief Gets or sets the fade state of this MenuEntry.  */
			public override bool Faded
			{
				get { return CallMethod_GetR0 (Method.GetFade) != 0; }
				set { CallMethod_SetR4 (Method.SetFade, value ? 1U : 0U); }
			}

			/*! \brief Gets or sets the text used in this MenuEntry.
			 * \exception ArgumentNullException Thrown if text set to null.
			 * \exception OS.ErrorException Thrown if the entry's text buffer is not large
			 * enough to hold the supplied text.
			 * \exception OS.ErrorException Thrown if the entry is sprite only.  */
			public string Text
			{
				get { return GetText (Method.GetEntryText); }
				set
				{
					if (value == null)
						throw new ArgumentNullException ("value", "Attempt to set Menu Entry text to null");
					SetText (Method.SetEntryText, value);
				}
			}

			/*! \brief Gets or sets the sprite which is to be used in this MenuEntry.
			 * \exception ArgumentNullException Thrown if sprite set to null.
			 * \exception OS.ErrorException Thrown if the entry's sprite name buffer is not large
			 * enough to hold the supplied sprite name.
			 * \exception OS.ErrorException Thrown if the entry is text only.  */
			public string Sprite
			{
				get { return GetText (Method.GetEntrySprite); }
				set
				{
					if (value == null)
						throw new ArgumentNullException ("value", "Attempt to set Menu Entry sprite to null");
					SetText (Method.SetEntrySprite, value);
				}
			}

			/*! \brief Gets or sets the Toolbox object that will be shown when the user
			 * moves the pointer over the submenu arrow.
			 * 
			 * If set to null, then no object will be shown.  */
			public Object SubMenuShow
			{
				get
				{
					uint show_id = CallMethod_GetR0 (Method.GetSubMenuShow);

					if (show_id == 0)
						return null;

					Toolbox.Object tb_obj;
					if (!ToolboxTask.AllObjects.TryGetValue (show_id, out tb_obj))
						throw new UnknownObjectException (show_id);

					return tb_obj;
				}
				set
				{
					CallMethod_SetR4 (Method.SetSubMenuShow, (value == null) ? 0 : value.ID);
				}
			}

			/*! \brief Gets or sets the Toolbox event that will be raised when the user
			 * moves the pointer over this entry's submenu arrow.
			 * 
			 * If set to null, then default Toolbox event, Menu_SubMenu will be raised.  */
			public uint SubMenuEvent
			{
				get { return CallMethod_GetR0 (Method.GetSubMenuEvent); }
				set { CallMethod_SetR4 (Method.SetSubMenuEvent, value); }
			}

			/*! \brief Gets or sets the Toolbox object that will be shown when the user
			 * clicks on the MenuEntry.
			 * 
			 * If set to null, then no object will be shown.  */
			public Toolbox.ClickShow ClickShow
			{
				get { return GetClickShow (Method.GetClickShow); }
				set { SetClickShow (Method.SetClickShow, value); }
			}

			/*! \brief Gets or sets the Toolbox event that will be raised when the user
			 * clicks on the MenuEntry.
			 * 
			 * If set to 0, then default Toolbox event Menu_Selection will be raised.  */
			public uint ClickEvent
			{
				get { return CallMethod_GetR0 (Method.GetClickEvent); }
				set { CallMethod_SetR4 (Method.SetClickEvent, value); }
			}

			/*! \brief Gets or set the help message which will be returned when a Help
			 * Request message is received for this MenuEntry.
			 * 
			 * If set to null, the Help Message for this MenuEntry is detached.  */
			public override string HelpMessage
			{
				override get { return GetText (Method.GetEntryHelpMessage); }
				override set { SetText (Method.SetEntryHelpMessage, value); }
			}

			// Methods that have no meaning for a MenuEntry.

			/*! \brief A MenuEntry does not have a gadget type.
			 * \warning An exception will be thrown if accessed via a MenuEntry.
			 * \exception InvalidOperationException Thrown if accessed via a MenuEntry object.  */
			public override uint Type
			{
				override get
				{
					throw new InvalidOperationException ("A Menu Entry does not have a gadget type");
				}
			}

			/*! \brief A MenuEntry does not have a bounding box.
			 * \warning An exception will be thrown if accessed via a MenuEntry.
			 * \exception InvalidOperationException Thrown if accessed via a MenuEntry object.  */
			public override OS.Rect BoundingBox
			{
				override get
				{
					throw new InvalidOperationException ("A Menu Entry does not have a bounding box");
				}
				override set
				{
					throw new InvalidOperationException ("You cannot set the bounding box of a Menu Entry");
				}
			}

			/*! \brief Does not make sense for a Menu Entry.
			 * \warning An exception will be thrown if called on a MenuEntry.
			 * \exception InvalidOperationException Thrown if called on a MenuEntry object.  */
			public override void SetFocus ()
			{
				throw new InvalidOperationException ("You cannot set the input focus to a Menu Entry");
			}
		}

		/*! \class Menu
		 * \brief Encapsulates a Toolbox Menu object.  */
		public class Menu : Object
		{
			/*! \brief The Toolbox methods associated with the Toolbox Menu class.  */
			static class Method
			{
				public const int SetHelpMessage = 16;
				public const int GetHelpMessage = 17;
				public const int AddEntry = 20;
				public const int RemoveEntry = 21;
				public const int GetHeight = 22;
				public const int GetWidth = 23;
				public const int SetTitle = 24;
				public const int GetTitle = 25;
			}

			/*! \brief %Flags used in a %Menu %Toolbox template.  */
			public static class Flags
			{
				public const int GenerateAboutToBeShown = (1 << 0);
				public const int GenerateHasBeenHidden = (1 << 1);
			}

			public static class TemplateOffset
			{
				public const int Flags = 36;
				public const int Title = 40;
				public const int MaxTitle = 44;
				public const int HelpMessage = 48;
				public const int MaxHelp = 52;
				public const int ShowEvent = 56;
				public const int HideEvent = 60;
				public const int NumEntries = 64;
			}

			/*! \class EventCode
			 * \brief Toolbox events that can be generated by the Toolbox Menu object.  */
			public static class EventCode
			{
				public const int AboutToBeShown = 0x828c0;
				public const int HasBeenHidden = 0x828c1;
				public const int SubMenu = 0x828c2;
				public const int Selection = 0x828c3;
			}

			/*! \class AboutToBeShownEventArgs
			 * \brief An object that encapsulates the arguments for the event that is raised
			 * just before the Menu object is shown on screen.  */
			public class AboutToBeShownEventArgs : ToolboxEventArgs
			{
				/*! \brief Gives details of where the menu will be displayed.
				 * \note FullSpec is the same as TopLeft in the case of a Menu. DefaultSpec
				 * means that the menu will open 64 OS units to the left of the mouse pointer.  */
				public ShowObjectSpec ShowSpec;

				/*! \brief Create the event arguments from the raw event data.  */
				public AboutToBeShownEventArgs (IntPtr unmanagedEventData) : base (unmanagedEventData)
				{
					switch (Header.Flags)
					{
					case (uint)Toolbox.ShowObjectType.FullSpec:
					case (uint)Toolbox.ShowObjectType.TopLeft:
						var ev = (NativeToolbox.ShowObjectTopLeftEvent)
								Marshal.PtrToStructure (RawEventData,
											typeof (NativeToolbox.ShowObjectTopLeftEvent));
						ShowSpec = new ShowObjectTopLeft (new OS.Coord (ev.Spec.TopLeft));
						break;
					case (uint)Toolbox.ShowObjectType.Default:
						ShowSpec = new ShowObjectSpec (Toolbox.ShowObjectType.Default);
						break;
					default:
						ShowSpec = null;
						break;
					}
				}
			}

			public delegate void AboutToBeShownHandler (object sender, AboutToBeShownEventArgs e);

			/*! \brief The event handlers that will be called just before this Menu is shown.
			 *
			 * Handlers should have the signature:
			 * \code
			 * void handler_name (object sender, AboutToBeShownEventArgs e);
			 * \endcode
			 * and can be added to the list with:
			 * \code
			 * MenuObject.AboutToBeShown += handler_name;
			 * \endcode  */
			public event AboutToBeShownHandler AboutToBeShown;

			/*! \brief The event handlers that will be called when this Menu has been hidden.
			 *
			 * Handlers should have the signature:
			 * \code
			 * void handler_name (object sender, ToolboxEventHandler e);
			 * \endcode
			 * and can be added to the list with:
			 * \code
			 * MenuObject.HasBeenHidden += handler_name;
			 * \endcode  */
			public event ToolboxEventHandler HasBeenHidden;

			private int AboutToBeShownEventCode = 0;
			private int HasBeenHiddenEventCode = 0;

			/*! \brief Create a Toolbox Menu object from the named resource.
			 * \param [in] resName The name of the template in the resource file.  */
			public Menu (string resName) : base (resName)
			{
				IntPtr template = TemplateLookup (resName);
				RetrieveEventCodes (template);
			}

			/*! \brief Create a Toolbox Menu from the template data given.
			 * \param[in] templateData Pointer to the menu template.  */
			public Menu (IntPtr templateData)
			{
				Create (templateData);
				RetrieveEventCodes (templateData);
			}

			/*! \brief Create a Menu from a Toolbox object that already exists.
			 * \param [in] objectID The Toolbox ID of the existing object.  */
			public Menu (uint ObjectID) : base (ObjectID)
			{
				IntPtr template = Toolbox.TemplateLookup (TemplateName);
				RetrieveEventCodes (template);
			}

			/*! \todo Method to add a Menu Entry to a menu. Requires
			 * support for creation of objects from template data.  */
			public void AddEntry ()
			{
			}

			/*! \todo Method to remove a Menu Entry from a menu.
			 * Easy to do, but waiting for corresponding AddEntry.  */
			public void RemoveEntry ()
			{
			}

			/*! \brief The title of the Menu.
			 * \exception ArgumentNullException Thrown if the Title property is set to null.  */
			public string Title
			{
				set
				{
					if (value == null)
						throw new ArgumentNullException ("value", "Attempt to set Menu Title property to null");
					SetText (Method.SetTitle, value);
				}
				get { return GetText (Method.GetTitle); }
			}

			/*! \brief The help message which will be returned when a Help Message is
			 * received.  */
			public string HelpMessage
			{
				set { SetText (Method.SetHelpMessage, value); }
				get { return GetText (Method.GetHelpMessage); }
			}

			/*! \brief The height of the work area of the Menu in OS units.  */
			public int Height
			{
				get { return (int)CallMethod_GetR0 (Method.GetHeight); }
			}

			/*! \brief The width of the work area on the Menu in OS units.  */
			public int Width
			{
				get { return (int)CallMethod_GetR0 (Method.GetWidth); }
			}

			public override void Dispatch (ToolboxEvent ev)
			{
				// This call is likely to be temporary until events are also dispatched to
				// gadgets as well. Need this now for the Quit event.
				base.Dispatch (ev);

				if (ev.ToolboxArgs.Header.EventCode == AboutToBeShownEventCode &&
				    AboutToBeShown != null)
				{
					AboutToBeShown (this, new AboutToBeShownEventArgs (ev.ToolboxArgs.RawEventData));
				}
				else if (ev.ToolboxArgs.Header.EventCode == HasBeenHiddenEventCode &&
					 HasBeenHidden != null)
				{
					// There is no additional data after the event header.
					HasBeenHidden (this, ev.ToolboxArgs);
				}
			}

			private void RetrieveEventCodes (IntPtr template)
			{
				int flags = Marshal.ReadInt32 (template, TemplateOffset.Flags);
				if ((flags & Flags.GenerateAboutToBeShown) != 0)
				{
					var show_event = Marshal.ReadInt32 (template,
									    TemplateOffset.ShowEvent);
					AboutToBeShownEventCode = (show_event != -1) ?
								   show_event :
								   EventCode.AboutToBeShown;
				}
				if ((flags & Flags.GenerateHasBeenHidden) != 0)
				{
					var hide_event = Marshal.ReadInt32 (template,
									    TemplateOffset.HideEvent);
					HasBeenHiddenEventCode = (hide_event != -1) ?
								  hide_event :
								  EventCode.HasBeenHidden;
				}
			}
		}
	}
}
