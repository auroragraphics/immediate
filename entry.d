module aurora.immediate.entry;

import core.runtime;
import std.utf;
import std.conv;
import std.string;

import aurora.immediate.application;

version(Windows)
{
	import core.sys.windows.windows;
	
	extern (Windows) int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
	{
		int result;
		
		try
		{
			Runtime.initialize();
			Application.current.commandLine = to!string(lpCmdLine);
			Application.current.appHandle = hInstance;
			Application.current.Startup();

			while (!Application.current.shutdownRequested)
			{
				//Use PeekMessage so we don't stall while waiting for a message
				MSG msg = { };
				if(PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
					TranslateMessage(&msg);
					DispatchMessageW(&msg);
				}
			}

			Application.current.Shutdown();
			Runtime.terminate();
		}
		catch (Throwable e) // catch any uncaught exceptions
		{
			Application.current.ApplicationUnhandledException(e);
			MessageBoxW(null, toUTF16z(e.toString()), toUTF16z("Error"), MB_OK | MB_ICONEXCLAMATION);
			result = 0;     // failed
		}
		finally
		{
			Runtime.terminate();
		}
		
		return result;
	}
}
else version(Linux)
{
}