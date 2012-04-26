//
// os.cs - a binding of the RISC OS API to C#.
//
// Author: Lee Noar (leenoar@sky.com)
//

using riscos;
using System;
using System.Runtime.InteropServices;

namespace riscos
{
	public static class OS
	{
		public enum GCOLAction
		{
			Replace_FG,
			OR_FG,
			AND_FG,
			EOR_FG,
			NOT_FG,
			Leave_FG,
			BIC_FG,
			ORNOT_FG,
			Replace_BG,
			OR_BG,
			AND_BG,
			EOR_BG,
			NOT_BG,
			Leave_BG,
			BIC_BG,
			ORNOT_BG
		}

		public static class PlotType
		{
			public const int SolidLine = 0;
			public const int SolidLineIncEnd = 0;
			public const int SolidLineExcEnd = 8;
			public const int DottedLine = 16;
			public const int DottedLineIncEnd = 16;
			public const int DottedLineExcEnd = 24;
			public const int SolidLineExcFirst = 32;
			public const int SolidLineExcBoth = 40;
			public const int DottedLineExcFirst = 48;
			public const int DottedLineExcBoth = 56;
			public const int Point = 64;
			public const int HFLeftAndRightNonBG = 72; // Horitontal Fill
			public const int TriangleFill = 80;
			public const int HFToRightToBG = 88;
			public const int RectangleFill = 96;
			public const int HFLeftAndRightToFG = 104;
			public const int ParallelogramFill = 112;
			public const int HFToRightNonFG = 120;
			public const int FloodToNonBG = 128;
			public const int FloodToNonFG = 136;
			public const int CircleOutline = 144;
			public const int CircleFill = 152;
			public const int CircleArc = 160;
			public const int Segment = 168;
			public const int Sector = 176;
			public const int BlockCopyMove = 184;
			public const int EllipseOutline = 192;
			public const int EllipseFill = 200;
			public const int SpritePlot = 232;
		}

		public static class PlotModifier
		{
			public const int MoveRelative = 0;
			public const int PlotRelativeFG = 1;
			public const int PlotRelativeInverse = 2;
			public const int PlotRelativeBG = 3;
			public const int MoveAbsolute = 4;
			public const int PlotAbsoluteFG = 5;
			public const int PlotAbsoluteInverse = 6;
			public const int PlotAbsoluteBG = 7;
		}

		public class ErrorException : System.Exception
		{
			public NativeOS.Error OSError;

			public ErrorException(IntPtr error_ptr) : base ()
			{
				OSError = (NativeOS.Error)Marshal.PtrToStructure (error_ptr, typeof(NativeOS.Error));
			}
		}

		public static void ThrowOnError (IntPtr error)
		{
			if (error != IntPtr.Zero)
				throw new ErrorException (error);
		}

		public class Rect
		{
			public int MinX { get; set; }
			public int MinY { get; set; }
			public int MaxX { get; set; }
			public int MaxY { get; set; }

			public Rect (int MinX, int MinY, int MaxX, int MaxY)
			{
				this.MinX = MinX;
				this.MinY = MinY;
				this.MaxX = MaxX;
				this.MaxY = MaxY;
			}

			public Rect (NativeOS.Rect rect)
			{
				MinX = rect.MinX;
				MinY = rect.MinY;
				MaxX = rect.MaxX;
				MaxY = rect.MaxY;
			}
		}

		public class Coord
		{
			public int X;
			public int Y;

			public Coord (int X, int Y)
			{
				this.X = X;
				this.Y = Y;
			}

			public Coord (NativeOS.Coord coord)
			{
				X = coord.X;
				Y = coord.Y;
			}
		}

		public class Matrix : ICloneable
		{
			public int [,] m;

			// Create identity matrix
			public Matrix ()
			{
				int x, y;

				m = new int [3, 3];

				for (y = 0; y < 3; y++)
					for (x = 0; x < 3; x++)
						m[x,y] = (x == y) ? ToTransformUnits(1.0) : 0;
			}

			// Create matrix with rotate, scale and translation elements.
			public Matrix (int m00, int m01, int m10, int m11, int transX, int transY)
			{
				m = new int [3, 3];

				Set (m00, m01, m10, m11, transX, transY);
			}

			// Create matrix with rotate and scale elements - x,y translation set to zero.
			public Matrix (int m00, int m01, int m10, int m11)
			{
				m = new int [3, 3];

				Set (m00, m01, m10, m11, 0, 0);
			}

			// Create matrix with x,y translation - rotate, scale elements set to identity
			public Matrix (int transX, int transY)
			{
				m = new int [3, 3];

				Set (ToTransformUnits (1.0), 0, 0, ToTransformUnits (1.0), transX, transY);
			}

			// Create matrix from existing 3x3 array
			public Matrix (int [,] matrix_array)
			{
				m = (int [,])matrix_array.Clone();
			}

			public Object Clone()
			{
				return new Matrix (m);
			}

			public void Set (int m00, int m01, int m10, int m11, int transX, int transY)
			{
				m[0,0] = m00;
				m[0,1] = m01;
				m[1,0] = m10;
				m[1,1] = m11;
				m[2,0] = transX;
				m[2,1] = transY;
			}

			public void Multiply (Matrix m2)
			{
				Matrix m1 = (Matrix)Clone ();
				int sum = 0, i, j, k;

				for (i = 0; i < 3; i++) {
					for (j = 0; j < 3; j++) {
						for (k = 0; k < 3; k++) {
							sum += (int)(Math.BigMul(m1.m[i,k], m2.m[k,j]) >> 16);
						}
						m[i,j] = sum;
						sum = 0;
					}
				}
			}

			public void Translate (int x, int y)
			{
				m[2, 0] += ToDrawUnits (x);
				m[2, 1] += ToDrawUnits (y);
			}

			public void Scale (double x, double y)
			{
				m[0, 0] += ToTransformUnits (x);
				m[1, 1] += ToTransformUnits (y);
			}

			public void Rotate (double angle_degrees)
			{
				double rads = DegreeToRadian (angle_degrees % 360);
				Matrix matrix = new Matrix (ToTransformUnits (Math.Cos (rads)),
							    ToTransformUnits (Math.Sin (rads)),
							    ToTransformUnits (-Math.Sin (rads)),
							    ToTransformUnits (Math.Cos (rads)));
				Multiply (matrix);
			}
		}

		public static double DegreeToRadian (double angle)
		{
			return Math.PI * angle / 180.0;
		}

		public static int ToTransformUnits (double value)
		{
			return (int)(value * (double)0x10000);
		}

		public static int ToDrawUnits (double value)
		{
			return (int)(value * 256);
		}

		// Straight through to SWI OS_Plot
		public static void Plot (int type, int x, int y)
		{
			NativeMethods.OS_Plot (type, x, y);
		}

		// Equivalent to MOVE in BASIC
		public static void Move (int x, int y)
		{
			Plot (PlotType.SolidLine + PlotModifier.MoveAbsolute, x, y);
		}

		// Equivalent to DRAW in BASIC
		public static void Draw (int x, int y)
		{
			Plot (PlotType.SolidLine + PlotModifier.PlotAbsoluteFG, x, y);
		}

		// Equivalent to MOVE BY in BASIC
		public static void MoveBy (int x, int y)
		{
			Plot (PlotType.SolidLine + PlotModifier.MoveRelative, x, y);
		}

		// Equivalent to DRAW BY in BASIC
		public static void DrawBy (int x, int y)
		{
			Plot (PlotType.SolidLine + PlotModifier.PlotRelativeFG, x, y);
		}

		public static void PlotLine (int x1, int y1, int x2, int y2)
		{
			Move (x1, y1);
			Draw (x2, y2);
		}

		public static void PlotLine (Coord c1, Coord c2)
		{
			Move (c1.X, c1.Y);
			Draw (c2.X, c2.Y);
		}

		public static void PlotCircleOutline (int centre_x, int centre_y, int radius)
		{
			Move (centre_x, centre_y);
			Plot (PlotType.CircleOutline + PlotModifier.PlotRelativeFG, radius, 0);
		}

		public static void PlotCircleFill (int centre_x, int centre_y, int radius)
		{
			Move (centre_x, centre_y);
			Plot (PlotType.CircleFill + PlotModifier.PlotRelativeFG, radius, 0);
		}

		public static void PlotRectangleFill (Coord c1, Coord c2)
		{
			Move (c1.X, c1.Y);
			Plot (PlotType.RectangleFill + PlotModifier.PlotAbsoluteFG, c2.X, c2.Y);
		}

		public static void PlotRectangleFill (Rect rect)
		{
			Move (rect.MinX, rect.MinY);
			Plot (PlotType.RectangleFill + PlotModifier.PlotAbsoluteFG, rect.MaxX, rect.MaxY);
		}
	}
}
