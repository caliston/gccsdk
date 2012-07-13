//
// toolbox/menu.cs - a binding of the RISC OS API to C#.
//
// Author: Lee Noar (leenoar@sky.com)
//

using System;
using System.Text;

namespace riscos
{
	public static partial class Toolbox
	{
		/*! \class Menu
		 * \brief Encapsulates a Toolbox Menu object.  */
		public class Menu : Object
		{
			/*! \class EventCode
			 * \brief Toolbox events that can be generated by the Toolbox Menu object.  */
			public class EventCode
			{
				public const uint AboutToBeShown = 0x828c0;
				public const uint HasBeenHidden = 0x828c1;
				public const uint SubMenu = 0x828c2;
				public const uint Selection = 0x828c3;
			}

			/*! \brief Create a Toolbox Menu object from the named resource.
			 * \param [in] resName The name of the template in the resource file.  */
			public Menu (string resName) : base (resName)
			{
			}

			/*! \brief This method affects the tick state of a Menu entry.
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \param [in] tick The new tick state of the menu entry.
			 * \return Nothing.  */
			public void SetTick (uint entryCmp, bool tick)
			{
				OS.ThrowOnError (NativeMethods.Menu_SetTick (0, ID, entryCmp, tick));
			}

			/*! \brief Return the tick state of a Menu entry.
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \return \e true if the Menu entry is ticked, otherwise \e false.  */
			public bool GetTick (uint entryCmp)
			{
				bool tick;
				OS.ThrowOnError (NativeMethods.Menu_GetTick (0, ID, entryCmp, out tick));
				return tick;
			}

			/*! \brief This method affects the fade state of a Menu entry.
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \param [in] fade The new fade state of the menu entry.
			 * \return Nothing.  */
			public void SetFade (uint entryCmp, bool fade)
			{
				OS.ThrowOnError (NativeMethods.Menu_SetFade (0, ID, entryCmp, fade));
			}

			/*! \brief Return the fade state of a Menu entry.
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \return \e true if the Menu entry is faded, otherwise \e false.  */
			public bool GetFade (uint entryCmp)
			{
				bool fade;
				OS.ThrowOnError (NativeMethods.Menu_GetFade (0, ID, entryCmp, out fade));
				return fade;
			}

			/*! \brief Set the text which is to be used in the named text Menu entry.
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \param [in] text The text to be used for the menu entry.
			 * \return Nothing.  */
			public void SetEntryText (uint entryCmp, string text)
			{
				if (text != null)
					OS.ThrowOnError (NativeMethods.Menu_SetEntryText (0,
											  ID,
											  entryCmp,
											  text));
			}

			/*! \brief Return the text string of the given Menu entry.
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \return A string containing the text of the Menu entry.  */
			public string GetEntryText (uint entryCmp)
			{
				int buffer_size;
				OS.ThrowOnError (NativeMethods.Menu_GetEntryText (0,
										  ID,
										  entryCmp,
										  null,
										  0,
										  out buffer_size));
				StringBuilder buffer = new StringBuilder (buffer_size);
				OS.ThrowOnError (NativeMethods.Menu_GetEntryText (0,
										  ID,
										  entryCmp,
										  buffer,
										  buffer_size,
										  out buffer_size));
				return buffer.ToString();
			}

			/*! \brief Set the sprite which is to be used in the named sprite Menu entry.
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \param [in] spriteName The name of the sprite to be used for the menu entry.
			 * \return Nothing.  */
			public void SetEntrySprite (uint entryCmp, string spriteName)
			{
				if (spriteName != null)
					OS.ThrowOnError (NativeMethods.Menu_SetEntrySprite (0,
											    ID,
											    entryCmp,
											    spriteName));
			}

			/*! \brief Return the name of the sprite used to displayed for the given Menu entry.
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \return A string containing the name of the sprite used in the Menu entry.  */
			public string GetEntrySprite (uint entryCmp)
			{
				int buffer_size;
				OS.ThrowOnError (NativeMethods.Menu_GetEntrySprite (0,
										    ID,
										    entryCmp,
										    null,
										    0,
										    out buffer_size));
				StringBuilder buffer = new StringBuilder (buffer_size);
				OS.ThrowOnError (NativeMethods.Menu_GetEntrySprite (0,
										    ID,
										    entryCmp,
										    buffer,
										    buffer_size,
										    out buffer_size));
				return buffer.ToString();
			}

			/*! \brief Set the Toolbox object to be shown when the user moves the
			 * pointer over the submenu arrow.
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \param [in] subMenu The object to be shown as a sub menu.
			 * \return Nothing.
			 * \note Set \e subMenu to null if no object should be shown.<br>
			 * Also causes the submenu to be shown or hidden as appropriate.  */
			public void SetSubMenuShow (uint entryCmp, Toolbox.Object subMenu)
			{
				uint show_id = (subMenu == null) ? 0 : subMenu.ID;

				OS.ThrowOnError (NativeMethods.Menu_SetSubMenuShow (0, ID, entryCmp, show_id));
			}

			/*! \brief Return the Toolbox object which will be shown when the user moves
			 * the pointer over the submenu arrow.
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \return The Toolbox object that is to be shown.  */
			public Toolbox.Object GetSubMenuShow (uint entryCmp)
			{
				uint show_id;

				OS.ThrowOnError (NativeMethods.Menu_GetSubMenuShow (0, ID, entryCmp, out show_id));

				Toolbox.Object tb_obj;
				if (ToolboxTask.AllObjects.TryGetValue (show_id, out tb_obj))
					return tb_obj;
				return null;
			}

			/*! \brief Set the Toolbox event to be raised when the user moves the
			 * pointer over the submenu arrow.
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \param [in] eventCode The event to be raised.
			 * \return Nothing.
			 * \note Set \e eventCode to 0 if default Toolbox event Menu_SubMenu should be
			 * raised instead.<br>
			 * Also causes the submenu to be shown or hidden as appropriate.  */
			public void SetSubMenuEvent (uint entryCmp, uint eventCode)
			{
				OS.ThrowOnError (NativeMethods.Menu_SetSubMenuEvent (0, ID, entryCmp, eventCode));
			}

			/*! \brief Return the Toolbox event which will be raised when the user moves
			 * the pointer over the submenu arrow.
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \return The Toolbox event that will be raised.  */
			public uint GetSubMenuEvent (uint entryCmp)
			{
				uint event_code;

				OS.ThrowOnError (NativeMethods.Menu_GetSubMenuEvent (0, ID, entryCmp, out event_code));

				return event_code;
			}

			/*! \brief Set the Toolbox object to be shown when the user clicks this
			 * Menu entry.
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \param [in] clickObject The object to be shown.
			 * \param [in] flags Show flags.
			 * \return Nothing.
			 * \note Set \e clickObject to null if no object should be shown.  */
			public void SetClickShow (uint entryCmp, Toolbox.Object clickObject, uint flags)
			{
				uint click_id = (clickObject == null) ? 0 : clickObject.ID;

				OS.ThrowOnError (NativeMethods.Menu_SetClickShow (0,
										  ID,
										  entryCmp,
										  click_id,
										  flags));
			}

			/*! \brief Return the Toolbox object which will be shown when the user clicks
			 * this Menu entry.
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \return The Toolbox object that is to be shown.  */
			public Toolbox.Object GetClickShow (uint entryCmp)
			{
				uint click_id;

				OS.ThrowOnError (NativeMethods.Menu_GetClickShow (0, ID, entryCmp, out click_id));

				Toolbox.Object tb_obj;
				if (ToolboxTask.AllObjects.TryGetValue (click_id, out tb_obj))
					return tb_obj;
				return null;
			}

			/*! \brief Set the Toolbox event to be raised when the user clicks this Menu entry
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \param [in] eventCode The event to be raised.
			 * \return Nothing.
			 * \note Set \e eventCode to 0 if default Toolbox event Menu_Selection should be
			 * raised instead.<br>
			 * Also causes the submenu to be shown or hidden as appropriate.  */
			public void SetClickEvent (uint entryCmp, uint eventCode)
			{
				OS.ThrowOnError (NativeMethods.Menu_SetClickEvent (0, ID, entryCmp, eventCode));
			}

			/*! \brief Return the Toolbox event which will be raised when the user clicks
			 * this Menu entry.
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \return The Toolbox event that will be raised.  */
			public uint GetClickEvent (uint entryCmp)
			{
				uint event_code;

				OS.ThrowOnError (NativeMethods.Menu_GetClickEvent (0, ID, entryCmp, out event_code));

				return event_code;
			}

			/*! \brief Set the help message which will be used when a Help Request message
			 * is received for this Menu entry.
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \param [in] messageText The help message to use.
			 * \return Nothing.
			 * \note Set \e messageText to null to detach the Help Message from this Menu entry.  */
			public void SetEntryHelpMessage (uint entryCmp, string messageText)
			{
				OS.ThrowOnError (NativeMethods.Menu_SetEntryHelpMessage (0,
											 ID,
											 entryCmp,
											 messageText));
			}

			/*! \brief Read the help message which will be returned when a Help Request message
			 * is received for this Menu entry.
			 * \param [in] entryCmp The Toolbox component ID of the menu entry.
			 * \return The help message as a string.  */
			public string GetEntryHelpMessage (uint entryCmp)
			{
				int buffer_size;
				OS.ThrowOnError (NativeMethods.Menu_GetEntryHelpMessage (0,
											 ID,
											 entryCmp,
											 null,
											 0,
											 out buffer_size));
				StringBuilder buffer = new StringBuilder (buffer_size);
				OS.ThrowOnError (NativeMethods.Menu_GetEntryHelpMessage (0,
											 ID,
											 entryCmp,
											 buffer,
											 buffer_size,
											 out buffer_size));

				return buffer.ToString();
			}

			/* TODO:
			public void AddEntry ()
			{
			}

			public void RemoveEntry ()
			{
			}
			*/

			/*! \brief The title of the Menu.  */
			public string Title
			{
				set
				{
					if (value != null)
						OS.ThrowOnError (NativeMethods.Menu_SetTitle (0, ID, value));
				}
				get
				{
					int buffer_size;
					OS.ThrowOnError (NativeMethods.Menu_GetTitle (0,
										      ID,
										      null,
										      0,
										      out buffer_size));
					StringBuilder buffer = new StringBuilder (buffer_size);
					OS.ThrowOnError (NativeMethods.Menu_GetTitle (0,
										      ID,
										      buffer,
										      buffer_size,
										      out buffer_size));

					return buffer.ToString();
				}
			}

			/*! \brief The help message which will be returned when a Help Message is
			 * received.  */
			public string HelpMessage
			{
				set
				{
					OS.ThrowOnError (NativeMethods.Menu_SetHelpMessage (0, ID, value));
				}
				get
				{
					int buffer_size;
					OS.ThrowOnError (NativeMethods.Menu_GetHelpMessage (0, ID, null, 0,
											    out buffer_size));
					StringBuilder buffer = new StringBuilder (buffer_size);
					OS.ThrowOnError (NativeMethods.Menu_GetHelpMessage (0, ID, buffer,
											    buffer_size,
											    out buffer_size));
					return buffer.ToString ();
				}
			}

			/*! \brief The height of the work area of the Menu in OS units.  */
			public int Height
			{
				get
				{
					int height;
					OS.ThrowOnError (NativeMethods.Menu_GetHeight (0, ID, out height));

					return height;
				}
			}

			/*! \brief The width of the work area on the Menu in OS units.  */
			public int Width
			{
				get
				{
					int width;
					OS.ThrowOnError (NativeMethods.Menu_GetWidth (0, ID, out width));

					return width;
				}
			}
		}
	}
}