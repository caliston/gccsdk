//
// toolbox/number-range.cs - a binding of the RISC OS API to C#.
//
// Author: Lee Noar (leenoar@sky.com)
//
 
using System;
using System.Runtime.InteropServices;

namespace riscos
{
	public static partial class Toolbox
	{
		/*! \brief Used to display one of a range of possible integer or fixed
		 * point values.  */
		public class NumberRange : Gadget
		{
			static class Method
			{
				public const int SetValue = 832;
				public const int GetValue = 833;
				public const int SetBounds = 834;
				public const int GetBounds = 835;
				public const int GetComponents = 836;
			}

			/*! \brief The default Toolbox event that a number range can raise.  */
			public static class EventCode
			{
				public const uint ValueChanged = 0x8288d;
			}

			/*! \brief An object that encapsulates the arguments for the event that is raised when the
			 * value of a NumberRange changes.  */
			public class ValueChangeEventArgs : ToolboxEventArgs
			{
				/*! \brief Constant defining event specific data offset after the header.  */
				public static class EventOffset
				{
					public const int NewValue = 16;
				}

				/*! \brief New value shown in the display area.  */
				public int NewValue;

				/*! \brief Create the arguments for a ValueChange event from the raw event data.  */
				public ValueChangeEventArgs (IntPtr unmanagedEventBlock) : base (unmanagedEventBlock)
				{
					NewValue = Marshal.ReadInt32 (RawEventData, EventOffset.NewValue);
				}
			}

			/*! \brief The signature of a ValueChange event handler.  */
			public delegate void ValueChangeEventHandler (object sender, ValueChangeEventArgs e);

			/*! \brief The event handlers that will be called when the value of this NumberRange
			 * changes.
			 *
			 * Handlers should have the signature:
			 * \code
			 * void handler_name (object sender, ValueChangeEventArgs e);
			 * \endcode
			 * and can be added to the list with:
			 * \code
			 * NumberRangeObject.ValueChange += handler_name;
			 * \endcode  */
			public event ValueChangeEventHandler ValueChange;

			/*! \brief Wrap an existing number range, e.g., from a Resource file created
			 * Window.  */
			public NumberRange (Window window, uint cmpID) : base (window, cmpID)
			{
			}

			/*! \brief The value of the number range as an integer.  */
			public int Value
			{
				set { CallMethod_SetR4 (Method.SetValue, (uint)value); }
				get { return (int)CallMethod_GetR0 (Method.GetValue); }
			}

/* TODO:
   GetBounds
   SetBounds
   GetComponents
*/
			public override void Dispatch (ToolboxEvent ev)
			{
				if (ev.ToolboxArgs.Header.EventCode == EventCode.ValueChanged && ValueChange != null)
				{
					ValueChange (this, new ValueChangeEventArgs (ev.ToolboxArgs.RawEventData));
				}
			}
		}
	}
}