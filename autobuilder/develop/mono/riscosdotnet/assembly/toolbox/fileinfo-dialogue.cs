//
// toolbox/fileinfo-dialogue.cs - a binding of the RISC OS API to C#.
//
// Author: Lee Noar (leenoar@sky.com)
//
 
using System;
using System.Runtime.InteropServices;

namespace riscos
{
	public static partial class Toolbox
	{
		/*! \brief Encapsulates a Toolbox FileInfo Dialogue Box.  */
		public class FileInfoDialogue : Object
		{
			static class Method
			{
				public const int GetWindowID = 0;
				public const int SetModified = 1;
				public const int GetModified = 2;
				public const int SetFileType = 3;
				public const int GetFileType = 4;
				public const int SetFileName = 5;
				public const int GetFileName = 6;
				public const int SetFileSize = 7;
				public const int GetFileSize = 8;
				public const int SetDate = 9;
				public const int GetDate = 10;
				public const int SetTitle = 11;
				public const int GetTitle = 12;
			}

			/*! \brief Default Toolbox events that can be generated by the %Toolbox FileInfo Dialogue.  */
			public static class EventCode
			{
				public const int AboutToBeShown = 0x82ac0;
				public const int DialogueCompleted = 0x82ac1;
			}

			/*! \brief Create a %Toolbox FileInfo Dialogue from the named template in the
			 * Resource file.
			 * \param[in] resName The name of the FileInfo template to use.  */
			public FileInfoDialogue (string resName) : base (resName)
			{
			}

			/*! \brief Create a %Toolbox FileInfo Dialogue from the template data given.
			 * \param[in] templateData Pointer to the window template.  */
			public FileInfoDialogue (IntPtr templateData)
			{
				Create (templateData);
			}

			/*! \brief Create a %Toolbox %FileInfoDialogue from an object that already exists.
			 * \param [in] objectID The Toolbox ID of the existing object.  */
			public FileInfoDialogue (uint objectID) : base (objectID)
			{
			}

			/*! \brief Get the ID of the underlying Window object.  */
			public uint WindowID
			{
				get { return GetWindowID(); }
			}

			/*! \brief Gets or sets whether the file is to be indicated as modified or not.  */
			public bool Modified
			{
				set { SetModified (value); }
				get { return GetModified(); }
			}

			/*! \brief Gets or sets the file type to be indicated in the dialogue box.  */
			public int FileType
			{
				set { SetFileType (value); }
				get { return GetFileType(); }
			}

			/*! \brief Gets or sets the filename used in the FileInfo Dialogue box.
			 *
			 * There is a limit of 256 characters on the filename length.  */
			public string FileName
			{
				set { SetFileName (value); }
				get { return GetFileName(); }
			}

			/*! \brief Gets or sets the file size to be indicated in the dialogue box.  */
			public int FileSize
			{
				set { SetFileSize (value); }
				get { return GetFileSize (); }
			}

			/*! \brief Sets the date string used in the FileInfo dialogue's window or gets
			 * the current UTC time used to set the date string.  */
			public OS.DateTime Date
			{
				set { SetDate (value); }
				get { return GetDate (); }
			}

			/*! \brief Gets or sets the text which is to be used in the title bar
			 * of this FileInfo Dialogue.  */
			public string Title
			{
				set { SetTitle (value); }
				get { return GetTitle (); }
			}

			/*! \brief Return the ID of the underlying Window object used to implement this
			 * FileInfo Dialogue.
			 * \return The ID of the Window Object.
			 * \note The \e WindowID property can be used for the same purpose.  */
			public uint GetWindowID ()
			{
				return MiscOp_GetR0 (0, Method.GetWindowID);
			}

			/*! \brief Indicate in the dialogue whether the file is modified or not.
			 * \param [in] modified \e true if the file is modified, otherwise \e false.
			 * \return Nothing.  */
			public void SetModified (bool modified)
			{
				MiscOp_SetR3 (0, Method.SetModified, modified ? 1U : 0);
			}

			/*! \brief Return whether the file is marked as modified in the FileInfo dialogue.
			 * \return \e true if the file is marked as modified, otherwise \e false.  */
			public bool GetModified ()
			{
				return MiscOp_GetR0 (0, Method.GetModified) == 0 ? false : true;
			}

			/*! \brief Set the filetype of the file in the FileInfo dialogue.  */
			public void SetFileType (int filetype)
			{
				MiscOp_SetR3 (0, Method.SetFileType, (uint)filetype);
			}

			/*! \brief Return the filetype of the file as indicated in the FileInfo dialogue.  */
			public int GetFileType ()
			{
				return (int)MiscOp_GetR0 (0, Method.GetFileType);
			}

			/*! \brief Set the filename to display in the FileInfo dialogue.  */
			public void SetFileName (string filename)
			{
				SetText (0, Method.SetFileName, filename);
			}

			/*! \brief Return the filename that is displayed in the FileInfo dialogue. */
			public string GetFileName ()
			{
				return GetText (Method.GetFileName);
			}

			/*! \brief Set the file size display in the FileInfo dialogue.  */
			public void SetFileSize (int size)
			{
				MiscOp_SetR3 (0, Method.SetFileSize, (uint)size);
			}

			/*! \brief Return the file size that is displayed in the FileInfo dialogue.  */
			public int GetFileSize ()
			{
				return (int)MiscOp_GetR0 (0, Method.GetFileSize);
			}

			/*! \brief Set the date and time displayed in the FileInfo dialogue.  */
			public void SetDate (OS.DateTime date)
			{
				GCHandle pinned_array;
				try {
					// Prevent the GC from moving the memory while we use its address.
					pinned_array = GCHandle.Alloc (date.Utc, GCHandleType.Pinned);
					MiscOp_SetR3 (0, Method.SetDate, pinned_array.AddrOfPinnedObject());
				}
				catch {
					throw;
				}
				finally {
					// The GC can have control of this back now.
					pinned_array.Free ();
				}
			}

			/*! \brief Get the date and time that is displayed in the FileInfo dialogue.  */
			public OS.DateTime GetDate ()
			{
				OS.DateTime date = new OS.DateTime ();
				GCHandle pinned_array;
				try {
					// Prevent the GC from moving the memory while we use its address.
					pinned_array = GCHandle.Alloc (date.Utc, GCHandleType.Pinned);
					MiscOp_SetR3 (0, Method.GetDate, pinned_array.AddrOfPinnedObject());
				}
				catch {
					throw;
				}
				finally {
					// The GC can have control of this back now.
					pinned_array.Free ();
				}

				return date;
			}

			/*! \brief Set the text string which is used in the title bar of the FileInfo dialogue.  */
			public void SetTitle (string title)
			{
				SetText (0, Method.SetTitle, title);
			}

			/*! \brief Return the text string which is used in the title bar of the FileInfo dialogue.  */
			public string GetTitle ()
			{
				return GetText (Method.GetTitle);
			}

			/*! \brief Raising an event invokes the event handler through a delegate.
			 *
			 * The \b OnAboutToBeShown method also allows derived classes to handle the
			 * event without attaching a delegate. This is the preferred technique for
			 * handling the event in a derived class.
			 * \note  When overriding \b OnAboutToBeShown in a derived class, be sure to
			 * call the base class's \b OnAboutToBeShown method so that registered delegates
			 * receive the event.  */
			protected virtual void OnAboutToBeShown (AboutToBeShownEventArgs e)
			{
				if (AboutToBeShown != null)
					AboutToBeShown (this, e);
			}

			/*! \brief Raising an event invokes the event handler through a delegate.
			 *
			 * The \b OnDialogueCompleted method also allows derived classes to handle the
			 * event without attaching a delegate. This is the preferred technique for
			 * handling the event in a derived class.
			 * \note  When overriding \b OnDialogueCompleted in a derived class, be sure to
			 * call the base class's \b OnDialogueCompleted method so that registered delegates
			 * receive the event.  */
			protected virtual void OnDialogueCompleted (ToolboxEventArgs e)
			{
				if (DialogueCompleted != null)
					DialogueCompleted (this, e);
			}

			/*! \brief Check if the given event is relevant to the FileInfo Dialogue and call the
			 * associated event handlers.  */
			public override void Dispatch (ToolboxEventArgs e)
			{
				switch (e.Header.EventCode)
				{
				case EventCode.AboutToBeShown:
					OnAboutToBeShown (new AboutToBeShownEventArgs (e.RawEventData));
					break;
				case EventCode.DialogueCompleted:
					OnDialogueCompleted (e);
					break;
				}
			}

			/*! \brief The event handlers that will be called just before this FileInfo Dialogue is shown.
			 *
			 * Handlers should have the signature:
			 * \code
			 * void handler_name (object sender, Object.AboutToBeShownEventArgs e);
			 * \endcode
			 * and can be added to the list with:
			 * \code
			 * FileInfoDialogueObject.AboutToBeShown += handler_name;
			 * \endcode  */
			public event EventHandler<AboutToBeShownEventArgs> AboutToBeShown;

			/*! \brief The event handlers that will be called when this dialogue is hidden.
			 *
			 * Handlers should have the signature:
			 * \code
			 * void handler_name (object sender, ToolboxEventArgs e);
			 * \endcode
			 * and can be added to the list with:
			 * \code
			 * FileInfoDialogueObject.DialogueCompleted += handler_name;
			 * \endcode  */
			public event EventHandler<ToolboxEventArgs> DialogueCompleted;
		}
	}
}
