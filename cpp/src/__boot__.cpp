#include <hxcpp.h>

#include <haxe/Log.h>
#include <Test.h>
#include <Testy.h>
#include <llhx/LowLevel.h>
#include <Std.h>

void __boot_all()
{
hx::RegisterResources( hx::GetResources() );
::haxe::Log_obj::__register();
::Test_obj::__register();
::Testy_obj::__register();
::llhx::LowLevel_obj::__register();
::Std_obj::__register();
::haxe::Log_obj::__boot();
::Std_obj::__boot();
::llhx::LowLevel_obj::__boot();
::Testy_obj::__boot();
::Test_obj::__boot();
}

