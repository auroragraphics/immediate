module main;

import aurora.immediate;
import core.sys.windows.windows;

class App : Application
{
	static this()
	{
		Application.current = new App();
		Application.current.applicationName = "DConf 2014";
	}

	Window test;

	public override void Startup()
	{
		test = new Window("Welcome to DConf 2014!");
		test.Show();
	}
}
