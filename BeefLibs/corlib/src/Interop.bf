using System.Reflection;

namespace System
{
	namespace Interop
	{
		typealias c_bool = bool;
		typealias c_short = int16;
		typealias c_ushort = uint16;
		typealias c_int = int32;
		typealias c_uint = uint32;
		typealias c_longlong = int64;
		typealias c_ulonglong = uint64;
		typealias c_intptr = int;
		typealias c_uintptr = uint;
		typealias c_size = uint;
		typealias c_char = char8;
		typealias c_uchar = uint8;

#if BF_PLATFORM_WINDOWS
		typealias c_wchar = char16;
#else
		typealias c_wchar = char32;
#endif

#if BF_PLATFORM_WINDOWS || BF_32_BIT
		typealias c_long = int32;
		typealias c_ulong = uint32;
#else
		typealias c_long = int64;
		typealias c_ulong = uint64;
		
#endif

		class FlexibleArray<T> where T : struct, new
		{
			typealias ElementType = comptype(GetElementType());

			int32 mCount;
			T* mVal;

			static Type GetElementType()
			{
				var t = typeof(T);
				if (t.IsGenericParam)
					return typeof(void);
				var field = t.GetField(t.FieldCount - 1).GetValueOrDefault();
				if ((field.FieldType == null) || (!field.FieldType.IsSizedArray) || (field.FieldType.Size != 0))
					Runtime.FatalError("Type must end in a zero-sized array");
				return (field.FieldType as SizedArrayType).UnderlyingType;
			}

			public ref ElementType this[int index]
			{
				[Checked]
				get
				{
					Runtime.Assert((uint)index < (uint)mCount);
					return ref ((ElementType*)((uint8*)mVal + Math.Align(typeof(T).Size, typeof(ElementType).Align)))[index];
				}

				[Unchecked]
				get
				{
					return ref ((ElementType*)((uint8*)mVal + Math.Align(typeof(T).Size, typeof(ElementType).Align)))[index];
				}
			}

			public static ref T operator ->(Self self) => ref *self.mVal;
			public ref T Value => ref *mVal;
			public T* Ptr => mVal;

			[AllowAppend]
			public this(int count)
			{
				var val = append T();
				var data = append ElementType[count]*;
				mVal = val;
				(void)data;
				mCount = (.)count;
			}
		}
	}
}
