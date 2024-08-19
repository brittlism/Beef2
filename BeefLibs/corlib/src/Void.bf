namespace System
{
	struct Void : void
	{
		//public static operator implicit any (Void us) => 1;
		//public static . operator any(Void us) => null;

		public override void ToString(String strBuffer)
		{
			strBuffer.Append("void");
		}
	}
}
