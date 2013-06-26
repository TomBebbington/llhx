#include <hxcpp.h>

#ifndef INCLUDED_Testy
#include <Testy.h>
#endif
#ifndef INCLUDED_hxMath
#include <hxMath.h>
#endif
#ifndef INCLUDED_llhx_LowLevel
#include <llhx/LowLevel.h>
#endif

Void Testy_obj::__construct()
{
	return null();
}

Testy_obj::~Testy_obj() { }

Dynamic Testy_obj::__CreateEmpty() { return  new Testy_obj; }
hx::ObjectPtr< Testy_obj > Testy_obj::__new()
{  hx::ObjectPtr< Testy_obj > result = new Testy_obj();
	result->__construct();
	return result;}

Dynamic Testy_obj::__Create(hx::DynamicArray inArgs)
{  hx::ObjectPtr< Testy_obj > result = new Testy_obj();
	result->__construct();
	return result;}

hx::Object *Testy_obj::__ToInterface(const hx::type_info &inType) {
	if (inType==typeid( ::llhx::LowLevel_obj)) return operator ::llhx::LowLevel_obj *();
	return super::__ToInterface(inType);
}

Float Testy_obj::run( ){
	HX_STACK_PUSH("Testy::run","Test.hx",2);
	HX_STACK_LINE(2)
	return ::Math_obj::PI;
}


STATIC_HX_DEFINE_DYNAMIC_FUNC0(Testy_obj,run,return )


Testy_obj::Testy_obj()
{
}

void Testy_obj::__Mark(HX_MARK_PARAMS)
{
	HX_MARK_BEGIN_CLASS(Testy);
	HX_MARK_END_CLASS();
}

void Testy_obj::__Visit(HX_VISIT_PARAMS)
{
}

Dynamic Testy_obj::__Field(const ::String &inName,bool inCallProp)
{
	switch(inName.length) {
	case 3:
		if (HX_FIELD_EQ(inName,"run") ) { return run_dyn(); }
	}
	return super::__Field(inName,inCallProp);
}

Dynamic Testy_obj::__SetField(const ::String &inName,const Dynamic &inValue,bool inCallProp)
{
	return super::__SetField(inName,inValue,inCallProp);
}

void Testy_obj::__GetFields(Array< ::String> &outFields)
{
	super::__GetFields(outFields);
};

static ::String sStaticFields[] = {
	HX_CSTRING("run"),
	String(null()) };

static ::String sMemberFields[] = {
	String(null()) };

static void sMarkStatics(HX_MARK_PARAMS) {
	HX_MARK_MEMBER_NAME(Testy_obj::__mClass,"__mClass");
};

static void sVisitStatics(HX_VISIT_PARAMS) {
	HX_VISIT_MEMBER_NAME(Testy_obj::__mClass,"__mClass");
};

Class Testy_obj::__mClass;

void Testy_obj::__register()
{
	hx::Static(__mClass) = hx::RegisterClass(HX_CSTRING("Testy"), hx::TCanCast< Testy_obj> ,sStaticFields,sMemberFields,
	&__CreateEmpty, &__Create,
	&super::__SGetClass(), 0, sMarkStatics, sVisitStatics);
}

void Testy_obj::__boot()
{
}

