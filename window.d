module aurora.immediate.window;

import aurora.immediate.application;
import std.utf;
import std.conv;
import std.string;

version(Windows)
{
	import core.sys.windows.windows;
	extern(Windows) bool DestroyWindow(HWND hWnd) nothrow;

	private __gshared Object windowlock = new Object();

	public class Window
	{
		private static Window[HWND] _windows;

		private static void addwindow(Window value) nothrow {
			try { 
				synchronized(windowlock) {
					_windows[value._handle] = value;
				}
			} catch { }
		}

		private static void removewindow(Window value) nothrow {
			try { 
				bool nowindows = false;
				synchronized(windowlock) {
					_windows.remove(value._handle);
					if(_windows.length == 0) nowindows = true;
				}
				if(nowindows && Application.current.shutdownMode == ShutdownMode.OnLastWindowClose) {
					Application.current.Shutdown(0);
				}
			} catch { }
		}

		private void* _handle;
		@property public void* handle() { return _handle; }

		this(string Title) {
			WNDCLASSW wndclass;
			wndclass.style         = CS_HREDRAW | CS_VREDRAW;
			wndclass.lpfnWndProc   = &WndProc;
			wndclass.cbClsExtra    = 0;
			wndclass.cbWndExtra    = 0;
			wndclass.hInstance     = Application.current.appHandle;
			wndclass.hIcon         = LoadIconA(null, IDI_APPLICATION);
			wndclass.hCursor       = LoadCursorA(null, IDC_ARROW);
			wndclass.hbrBackground = cast(HBRUSH)GetStockObject(WHITE_BRUSH);
			wndclass.lpszMenuName  = null;
			wndclass.lpszClassName = toUTF16z(Application.current.applicationName);

			if(!RegisterClassW(&wndclass))
				MessageBoxW(null, toUTF16z("This program requires Windows NT!"), toUTF16z(Application.current.applicationName), MB_ICONERROR);

			_handle = CreateWindowW(toUTF16z(Application.current.applicationName), toUTF16z(Title), WS_THICKFRAME | WS_MAXIMIZEBOX | WS_MINIMIZEBOX | WS_SYSMENU | WS_VISIBLE, CW_USEDEFAULT, CW_USEDEFAULT, 500, 400, HWND_DESKTOP, null, Application.current.appHandle, null);
			if(_handle is null)
				MessageBoxW(null, toUTF16z("Unable to Create Window"), toUTF16z("Error"), MB_OK | MB_ICONEXCLAMATION);

			addwindow(this);
		}

		~this() {
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
			switch (message)
			{
				case WM_CREATE:
					return 0;

				case WM_CLOSE:
					DestroyWindow(hwnd);
					return 0;

				case WM_DESTROY:
					removewindow(this);
					return 0;

				default:
			}

			return DefWindowProcW(hwnd, message, wParam, lParam);
		}
	}

	extern(Windows) LRESULT WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) nothrow {
		if(message == WM_CREATE) return 0;
		if(message == WM_GETMINMAXINFO) return 0;
		if(message == WM_NCCREATE) return TRUE;
		try {
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
