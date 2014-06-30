module aurora.immediate.application;

import aurora.immediate.window;
import aurora.directx;

import std.utf;
import std.conv;
import std.string;

import core.sys.windows.windows;

export enum ShutdownMode
{
	OnLastWindowClose,
	OnManualShutdown,
}

export class Application {
private:
	static Application _instance = null;

	DXPtr!IDXGIFactory2 _factory;
	DXPtr!IDXGIAdapter1[] _adapters;

	protected this() {
		//Initialize DirectX
		IDXGIFactory2 tf = null;
		if(CreateDXGIFactory1(&IID_IDXGIFactory2, cast(void**)&tf) != S_OK)
			MessageBoxA(null, "Error acquiring a DXGIFactory", "Error", MB_OK | MB_ICONEXCLAMATION);
		
		_factory = new DXPtr!IDXGIFactory2(tf);
		
		uint eac = 0;
		IDXGIAdapter1 t;
		while(_factory.EnumAdapters1(eac++, &t) != DXGI_ERROR_NOT_FOUND)
			_adapters ~= new DXPtr!IDXGIAdapter1(t);
	}

public:
	@property static Application current() {
		return _instance;
	}
	@property static Application current(Application value) {
		if(_instance is null) 
			return _instance = value;
		return _instance;
	}

	public void Startup() { return; }
	public void Shutdown() { return; }
	public void ApplicationUnhandledException(Throwable e) { return; }
	
	private string _commandLine = "";
	@property public string commandLine() { return _commandLine; }
	@property public string commandLine(string value) { if(_commandLine == "") return _commandLine = value; return _commandLine; }

	private wstring _appName = "";
	@property public wstring applicationName() { return _appName; }
	@property public wstring applicationName(wstring value) { if(_appName == "") return _appName = value; return _appName; }

	private void* _appHandle = null;
	@property public void* appHandle() { return _appHandle; }
	@property public void* appHandle(void* value) { if(_appHandle == null) return _appHandle = value; return _appHandle; }

	private ShutdownMode _shutdownMode = ShutdownMode.OnLastWindowClose;
	@property public ShutdownMode shutdownMode() { return _shutdownMode; }
	@property public ShutdownMode shutdownMode(ShutdownMode value) { return _shutdownMode = value; }

	private bool _shutdownRequested = false;
	@property public bool shutdownRequested() { return _shutdownRequested; }

	public void Shutdown(int returnCode = 0) nothrow
	{
		PostQuitMessage(returnCode);
		_shutdownRequested = true;
	}

}