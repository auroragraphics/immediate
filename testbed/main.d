module main;

import aurora.immediate;
import std.utf;
import core.sys.windows.windows;

class App : Application
{
	static this()
	{
		Application.current = new App();
		Application.current.applicationName = "Aurora Testbed";
	}

	TestWindow test;

	public override void Startup()
	{
		test = new TestWindow();
		test.Show();
	}
}

class TestWindow : Window
{
	this()
	{
		super("Aurora Test Window");
		this.x = 100;
		this.y = 100;
		this.height = 1000;
		this.width = 1000;
		this.onKeyDown = &ProcessOnKeyDown;
	}

	private void ProcessOnKeyDown(immutable(KeyData) args) nothrow
	{
		try {
		MessageBoxW(this.handle, toUTF16z("Key Event Received!"), toUTF16z(Application.current.applicationName), MB_ICONERROR);
		} catch { }
	}
}
