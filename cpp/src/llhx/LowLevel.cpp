#include <hxcpp.h>

#ifndef INCLUDED_llhx_LowLevel
#include <llhx/LowLevel.h>
#endif
namespace llhx{


static ::String sMemberFields[] = {
	String(null()) };

static void sMarkStatics(HX_MARK_PARAMS) {
	HX_MARK_MEMBER_NAME(LowLevel_obj::__mClass,"__mClass");
};

static void sVisitStatics(HX_VISIT_PARAMS) {
	HX_VISIT_MEMBER_NAME(LowLevel_obj::__mClass,"__mClass");
};

Class LowLevel_obj::__mClass;

void LowLevel_obj::__register()
{
	hx::Static(__mClass) = hx::RegisterClass(HX_CSTRING("llhx.LowLevel"), hx::TCanCast< LowLevel_obj> ,0,sMemberFields,
	0, 0,
	&super::__SGetClass(), 0, sMarkStatics, sVisitStatics);
}

void LowLevel_obj::__boot()
{
}

} // end namespace llhx
