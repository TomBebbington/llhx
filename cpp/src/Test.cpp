#include <hxcpp.h>

#ifndef INCLUDED_Test
#include <Test.h>
#endif
#ifndef INCLUDED_Testy
#include <Testy.h>
#endif
#ifndef INCLUDED_haxe_Log
#include <haxe/Log.h>
#endif
#ifndef INCLUDED_llhx_LowLevel
#include <llhx/LowLevel.h>
#endif

Void Test_obj::__construct()
{
	return null();
}

Test_obj::~Test_obj() { }

Dynamic Test_obj::__CreateEmpty() { return  new Test_obj; }
hx::ObjectPtr< Test_obj > Test_obj::__new()
{  hx::ObjectPtr< Test_obj > result = new Test_obj();
	result->__construct();
	return result;}

Dynamic Test_obj::__Create(hx::DynamicArray inArgs)
{  hx::ObjectPtr< Test_obj > result = new Test_obj();
	result->__construct();
	return result;}

Void Test_obj::main( ){
{
		HX_STACK_PUSH("Test::main","Test.hx",7);
		HX_STACK_LINE(8)
		Float r = ::Testy_obj::run();		HX_STACK_VAR(r,"r");
		HX_STACK_LINE(9)
		::haxe::Log_obj::trace(r,hx::SourceInfo(HX_CSTRING("Test.hx"),9,HX_CSTRING("Test"),HX_CSTRING("main")));
	}
return null();
}


STATIC_HX_DEFINE_DYNAMIC_FUNC0(Test_obj,main,(void))


Test_obj::Test_obj()
{
}

void Test_obj::__Mark(HX_MARK_PARAMS)
{
	HX_MARK_BEGIN_CLASS(Test);
	HX_MARK_END_CLASS();
}

void Test_obj::__Visit(HX_VISIT_PARAMS)
{
}

Dynamic Test_obj::__Field(const ::String &inName,bool inCallProp)
{
	switch(inName.length) {
	case 4:
		if (HX_FIELD_EQ(inName,"main") ) { return main_dyn(); }
	}
	return super::__Field(inName,inCallProp);
}

Dynamic Test_obj::__SetField(const ::String &inName,const Dynamic &inValue,bool inCallProp)
{
	return super::__SetField(inName,inValue,inCallProp);
}

void Test_obj::__GetFields(Array< ::String> &outFields)
{
	super::__GetFields(outFields);
};

static ::String sStaticFields[] = {
	HX_CSTRING("main"),
	String(null()) };

static ::String sMemberFields[] = {
	String(null()) };

static void sMarkStatics(HX_MARK_PARAMS) {
	HX_MARK_MEMBER_NAME(Test_obj::__mClass,"__mClass");
};

static void sVisitStatics(HX_VISIT_PARAMS) {
	HX_VISIT_MEMBER_NAME(Test_obj::__mClass,"__mClass");
};

Class Test_obj::__mClass;

void Test_obj::__register()
{
	hx::Static(__mClass) = hx::RegisterClass(HX_CSTRING("Test"), hx::TCanCast< Test_obj> ,sStaticFields,sMemberFields,
	&__CreateEmpty, &__Create,
	&super::__SGetClass(), 0, sMarkStatics, sVisitStatics);
}

void Test_obj::__boot()
{
}

