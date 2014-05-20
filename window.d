module aurora.immediate.window;

import aurora.immediate.application;
import std.utf;
import std.conv;

version(Windows)
{
	import core.sys.windows.windows;

	private __gshared Object windowlock = new Object();

	public class Window
	{
		private static Window[HWND] _windows;

		private void* _handle;
		@property private void* handle() { return _handle; }

		this(string Title) {
			WNDCLASS wndclass;
			wndclass.style         = CS_HREDRAW | CS_VREDRAW;
			wndclass.lpfnWndProc   = &WndProc;
			wndclass.cbClsExtra    = 0;
			wndclass.cbWndExtra    = 0;
			wndclass.hInstance     = Application.current.appHandle;
			wndclass.hIcon         = LoadIconA(null, IDI_APPLICATION);
			wndclass.hCursor       = LoadCursorA(null, IDC_ARROW);
			wndclass.hbrBackground = cast(HBRUSH)GetStockObject(WHITE_BRUSH);
			wndclass.lpszMenuName  = null;
			wndclass.lpszClassName = Application.current.applicationName.ptr;
			MessageBoxA(null, wndclass.lpszClassName, "Error", MB_OK);

			if(!RegisterClassA(&wndclass))
				MessageBoxW(null, toUTFz!(const(wchar)*)("This program requires Windows NT!"), toUTFz!(const(wchar)*)(Application.current.applicationName), MB_ICONERROR);

			_handle = CreateWindowA(Application.current.applicationName.ptr, Title.ptr, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, null, null, Application.current.appHandle, null);
			if(_handle is null)
				MessageBoxA(null, "Unable to Create Window", "Error", MB_OK | MB_ICONEXCLAMATION);

			synchronized(windowlock) {
				_windows[_handle] = this;
			}

		}

		~this() {
			synchronized(windowlock) {
				_windows.remove(_handle);
			}
		}

		public void Hide() {
			ShowWindow(_handle, SW_HIDE);
		}

		public void Minimize() {
			ShowWindow(_handle, SW_MINIMIZE);
		}

		public void Maximize() {
			ShowWindow(_handle, SW_MAXIMIZE);
		}

		public void Restore() {
			ShowWindow(_handle, SW_RESTORE);
		}

		public void Show() {
			ShowWindow(_handle, SW_SHOW);
			UpdateWindow(_handle);
		}

		public void Close() {
			SendMessageA(_handle, WM_CLOSE, 0, 0);
		}

		private LRESULT internalWndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) nothrow
		{
			//MessageBoxA(null, "Run 2", "Error", MB_OK | MB_ICONEXCLAMATION);
			switch (message)
			{
				case WM_CREATE:
					return 0;

				case WM_DESTROY:
					PostQuitMessage(0);
					return 0;
					
				default:
			}

			return DefWindowProcW(hwnd, message, wParam, lParam);
		}
	}

	extern(Windows) LRESULT WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) nothrow {
		try {
			if(message == WM_CREATE) return 0;
			if(message == WM_GETMINMAXINFO) return 0;
			if(message == WM_NCCREATE) return TRUE;
			synchronized(windowlock) {
				return Window._windows[hwnd].internalWndProc(hwnd, message, wParam, lParam);
			}
		}
		catch { }
		return 0;
	}


}
else version(Linux)
{
}
