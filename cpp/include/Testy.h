#ifndef INCLUDED_Testy
#define INCLUDED_Testy

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <llhx/LowLevel.h>
HX_DECLARE_CLASS0(Testy)
HX_DECLARE_CLASS1(llhx,LowLevel)


class HXCPP_CLASS_ATTRIBUTES  Testy_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Testy_obj OBJ_;
		Testy_obj();
		Void __construct();

	public:
		static hx::ObjectPtr< Testy_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		~Testy_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::llhx::LowLevel_obj *()
			{ return new ::llhx::LowLevel_delegate_< Testy_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("Testy"); }

		static Float run( );
		static Dynamic run_dyn();

};


#endif /* INCLUDED_Testy */ 
