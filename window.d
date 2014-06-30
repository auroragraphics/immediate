module aurora.immediate.window;

import aurora.immediate.application;
import aurora.immediate.input;
import aurora.immediate.types;
import std.utf;
import std.conv;
import std.string;

version(Windows)
{
	import core.sys.windows.windows;

	//DRuntime missing exported functions
	extern(Windows) export bool DestroyWindow(HWND hWnd) nothrow;
	extern(Windows) export bool SetWindowPos(HWND hWnd, HWND hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags) nothrow;

	enum : uint
	{
		SWP_ASYNCWINDOWPOS = 0x4000,
		SWP_DEFERERASE = 0x2000,
		SWP_DRAWFRAME = 0x0020,
		SWP_FRAMECHANGED = 0x0020,
		SWP_HIDEWINDOW = 0x0080,
		SWP_NOACTIVATE = 0x0010,
		SWP_NOCOPYBITS = 0x0100,
		SWP_NOMOVE = 0x0002,
		SWP_NOOWNERZORDER = 0x0200,
		SWP_NOREDRAW = 0x0008,
		SWP_NOREPOSITION = 0x0200,
		SWP_NOSENDCHANGING = 0x0400,
		SWP_NOSIZE = 0x0001,
		SWP_NOZORDER = 0x0004,
		SWP_SHOWWINDOW = 0x0040,
	}

	private __gshared Object windowlock = new Object();

	public class Window
	{
		private static Window[SystemWindow] _windows;

		private static void addwindow(Window value) nothrow {
			try { 
				synchronized(windowlock) {
					_windows[SystemWindow(value._handle)] = value;
				}
			} catch { }
		}

		private static void removewindow(Window value) nothrow {
			try { 
				bool nowindows = false;
				synchronized(windowlock) {
					_windows.remove(SystemWindow(value._handle));
					if(_windows.length == 0) nowindows = true;
				}
				if(nowindows && Application.current.shutdownMode == ShutdownMode.OnLastWindowClose) {
					Application.current.Shutdown(0);
				}
			} catch { }
		}

		private void* _handle;
		@property public void* handle() nothrow { return _handle; }

		protected this(string Title) {
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

			_handle = CreateWindowW(toUTF16z(Application.current.applicationName), toUTF16z(Title), WS_THICKFRAME | WS_MAXIMIZEBOX | WS_MINIMIZEBOX | WS_SYSMENU | WS_VISIBLE, _x, _y, _width, _height, HWND_DESKTOP, null, Application.current.appHandle, null);
			if(_handle is null)
				MessageBoxW(null, toUTF16z("Unable to Create Window"), toUTF16z("Error"), MB_OK | MB_ICONEXCLAMATION);

			addwindow(this);

			Show();
		}

		~this() {
		}

		public void Hide() nothrow {
			ShowWindow(_handle, SW_HIDE);
		}

		public void Minimize() nothrow {
			ShowWindow(_handle, SW_MINIMIZE);
		}

		public void Maximize() nothrow {
			ShowWindow(_handle, SW_MAXIMIZE);
		}

		public void Restore() nothrow {
			ShowWindow(_handle, SW_RESTORE);
		}

		public void Show() nothrow {
			ShowWindow(_handle, SW_SHOW);
			UpdateWindow(_handle);
		}

		public void Close() nothrow {
			SendMessageA(_handle, WM_CLOSE, 0, 0);
		}

		private int _height = 400;
		@property public int height() nothrow { return _height; }
		@property public int height(int value) nothrow { 
			SetWindowPos(_handle, null, _x, _y, _width, value, SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE);
			return _height = value; 
		}
		
		private int _width = 500;
		@property public int width() nothrow { return _width; }
		@property public int width(int value) nothrow { 
			SetWindowPos(_handle, null, _x, _y, value, _height, SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE);
			return _width = value; 
		}

		private int _x = CW_USEDEFAULT;
		@property public int x() nothrow { return _x; }
		@property public int x(int value) nothrow { 
			SetWindowPos(_handle, null, value, _y, _width, _height, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);
			return _x = value; 
		}
		
		private int _y = CW_USEDEFAULT;
		@property public int y() nothrow { return _y; }
		@property public int y(int value) nothrow { 
			SetWindowPos(_handle, null, _x, value, _width, _height, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);
			return _y = value; 
		}

		protected void delegate(immutable KeyData args) nothrow onKeyDown;
		protected void delegate(immutable KeyData args) nothrow onKeyUp;

		private LRESULT internalWndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) nothrow
		{
			try {
			switch (message)
			{
				case WM_CLOSE:
					DestroyWindow(hwnd);
					return 0;

				case WM_KEYDOWN:
					if (onKeyDown !is null) onKeyDown(immutable KeyData(cast(Key)wParam, true, false, false));
					return 0;

				case WM_KEYUP:
					if (onKeyUp !is null) onKeyUp(immutable KeyData(cast(Key)wParam, false, true, false));
					return 0;

				case WM_DESTROY:
					removewindow(this);
					return 0;

				default: return DefWindowProcW(hwnd, message, wParam, lParam);
			}
			} catch { }

			return DefWindowProcW(hwnd, message, wParam, lParam);
		}
	}

	extern(Windows) LRESULT WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) nothrow {
		try {
			synchronized(windowlock) {
				if((SystemWindow(hwnd) in Window._windows) is null) return DefWindowProcW(hwnd, message, wParam, lParam);
				return Window._windows[SystemWindow(hwnd)].internalWndProc(hwnd, message, wParam, lParam);
			}
		}
		catch { }
		return 0;
	}


}
else version(Linux)
{
}
