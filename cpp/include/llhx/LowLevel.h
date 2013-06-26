#ifndef INCLUDED_llhx_LowLevel
#define INCLUDED_llhx_LowLevel

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS1(llhx,LowLevel)
namespace llhx{


class HXCPP_CLASS_ATTRIBUTES  LowLevel_obj : public hx::Interface{
	public:
		typedef hx::Interface super;
		typedef LowLevel_obj OBJ_;
		HX_DO_INTERFACE_RTTI;
		static void __boot();
};

#define DELEGATE_llhx_LowLevel \


template<typename IMPL>
class LowLevel_delegate_ : public LowLevel_obj
{
	protected:
		IMPL *mDelegate;
	public:
		LowLevel_delegate_(IMPL *inDelegate) : mDelegate(inDelegate) {}
		hx::Object *__GetRealObject() { return mDelegate; }
		void __Visit(HX_VISIT_PARAMS) { HX_VISIT_OBJECT(mDelegate); }
		DELEGATE_llhx_LowLevel
};

} // end namespace llhx

#endif /* INCLUDED_llhx_LowLevel */ 
