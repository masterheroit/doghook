#include "precompiled.hh"

#include <thread>

#if doghook_platform_windows()

extern u32 __stdcall doghook_process_attach(void *a);

__declspec(dllexport) BOOL APIENTRY DllMain(HMODULE hModule,
                                            DWORD   reason,
                                            LPVOID  lpReserved) {
    switch (reason) {
    case DLL_PROCESS_ATTACH:
        CreateThread(nullptr, 0, (LPTHREAD_START_ROUTINE)&doghook_process_attach, hModule, 0, nullptr);
        break;
    }

    return true;
}
#else
// TODO: send process attach over to gamesystem

extern void doghook_process_attach();

void __attribute__((constructor)) startup() {
    std::thread{&doghook_process_attach}.detach();
}

void __attribute__((destructor)) shutdown() {}
#endif
