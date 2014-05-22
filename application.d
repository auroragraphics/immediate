module aurora.immediate.application;

import aurora.immediate.window;
import aurora.directx;

export enum ShutdownMode
{
	OnMainWindowClose,
	OnLastWindowClose,
	OnManualShutdown,
}

export class Application {
private:
	static bool instantiated_ = false;  // Thread local
	static Application instance_ = null;

	IDXGIFactory2 _factory;
	IDXGIAdapter1[] _adapters;

	protected this() {
		_openWindows = new Window[256]; 	//Give the array some high initial value to prevent multiple reallocations.

		//Initialize DirectX
		if(CreateDXGIFactory1(&IID_IDXGIFactory2, cast(void**)&_factory) != S_OK)
			MessageBoxA(null, "Error acquiring a DXGIFactory", "Error", MB_OK | MB_ICONEXCLAMATION);
					
		uint eac = 0;
		IDXGIAdapter1 t;
		while(_factory.EnumAdapters1(eac++, &t) != DXGI_ERROR_NOT_FOUND)
			_adapters ~= t;

	}

public:
	@property static Application current() {
//		if (!instantiated_) {
//			synchronized {
//				if (instance_ is null) {
//					instance_ = new Application;
//				}
//				instantiated_ = true;
//			}
//		}
		return instance_;
	}
	@property static Application current(Application value) {
		if(instance_ is null) 
			return instance_ = value;
		return instance_;
	}

	public void Startup() { return; }
	public void Shutdown() { return; }
	public void ApplicationUnhandledException(Throwable e) { return; }
	
	private string _commandLine = "";
	@property public string commandLine() { return _commandLine; }
	@property public string commandLine(string value) { if(_commandLine == "") return _commandLine = value; return _commandLine; }

	private string _appName = "";
	@property public string applicationName() { return _appName; }
	@property public string applicationName(string value) { if(_appName == "") return _appName = value; return _appName; }

	private void* _appHandle = null;
	@property public void* appHandle() { return _appHandle; }
	@property public void* appHandle(void* value) { if(_appHandle == null) return _appHandle = value; return _appHandle; }

	private ShutdownMode _shutdownMode = ShutdownMode.OnMainWindowClose;
	@property public ShutdownMode shutdownMode() { return _shutdownMode; }
	@property public ShutdownMode shutdownMode(ShutdownMode value) { return _shutdownMode = value; }

	public void Shutdown(int returnCode)
	{

	}

	private Window[] _openWindows;

	public void addWindow(Window window) {
		//If there is a free slot in the previously allocated space, use that instead.
		synchronized(this) {
			bool slotfound = false;
			for(int i=0;i<_openWindows.length;i++) {
				if(_openWindows[i] is null) {
					_openWindows[i] = window;
					slotfound = true;
				}
			}	
			if(!slotfound)
				_openWindows ~= window;
		}
	}

	public void releaseWindow(Window window) {
		synchronized(this) {
			for(int i=0;i<_openWindows.length;i++)
				if(_openWindows[i] == window)
					_openWindows[i] = null;
		}
	}

}