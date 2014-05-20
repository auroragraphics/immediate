module aurora.immediate.entry;

import core.runtime;
import std.string;
import std.conv;
import aurora.immediate.application;

version(Windows)
{
	import core.sys.windows.windows;
	
	extern (Windows) int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
	{
		int result;
		
		void exceptionHandler(Throwable e) {
			Application.current.ApplicationUnhandledException(e);
		}
		
		try
		{
			Runtime.initialize(&exceptionHandler);
			Application.current.commandLine = to!string(lpCmdLine);
			Application.current.appHandle = hInstance;
			Application.current.Startup();

			MSG msg = { };
			while (GetMessageA(&msg, null, 0, 0))
			{
				TranslateMessage(&msg);
				DispatchMessageA(&msg);
			}

			Application.current.Shutdown();
			Runtime.terminate(&exceptionHandler);
		}
		catch (Throwable e) // catch any uncaught exceptions
		{
			MessageBoxA(null, e.toString().toStringz(), "Error", MB_OK | MB_ICONEXCLAMATION);
			result = 0;     // failed
		}
		finally
		{
			Runtime.terminate(&exceptionHandler);
		}
		
		return result;
	}
}
else version(Linux)
{
}