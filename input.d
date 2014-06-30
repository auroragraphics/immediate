module aurora.immediate.input;

import std.bitmanip;

public enum Key {
	LeftButton =    0x01,
	RightButton =   0x02,
	Cancel =        0x03,
	MiddleButton =  0x04, /* NOT contiguous with L & RBUTTON */
	
	Back =          0x08,
	Tab =           0x09,
	
	Clear =         0x0C,
	Return =        0x0D,
	
	Shift =         0x10,
	Control =       0x11,
	Alt =           0x12,
	Pause =         0x13,
	Capital =       0x14,
		
	Escape =        0x1B,
	
	Space =         0x20,
	Prior =         0x21,
	Next =          0x22,
	End =           0x23,
	Home =          0x24,
	Left =          0x25,
	Up =            0x26,
	Right =         0x27,
	Down =          0x28,
	Select =        0x29,
	Print =         0x2A,
	Execute =       0x2B,
	Snapshot =      0x2C,
	Insert =        0x2D,
	Delete =        0x2E,
	Help =          0x2F,

	D0 =			0x30,
	D1 =			0x31,	
	D2 =			0x32,
	D3 =			0x33,
	D4 =			0x34,
	D5 =			0x35,
	D6 =			0x36,
	D7 =			0x37,
	D8 =			0x38,
	D9 =			0x39,

	A =				0x41,	
	B =				0x42,	
	C =				0x43,	
	D =				0x44,	
	E =				0x45,	
	F =				0x46,	
	G =				0x47,	
	H =				0x48,	
	I =				0x49,	
	J =				0x4A,	
	K =				0x4B,	
	L =				0x4C,	
	M =				0x4D,	
	N =				0x4E,	
	O =				0x4F,	
	P =				0x50,	
	Q =				0x51,	
	R =				0x52,	
	S =				0x53,	
	T =				0x54,	
	U =				0x55,	
	V =				0x56,	
	W =				0x57,	
	X =				0x58,	
	Y =				0x59,	
	Z =				0x5A,	

	LeftWin =        0x5B,
	RightWin =       0x5C,
	Apps =           0x5D,
	
	NumPad0 =        0x60,
	NumPad1 =        0x61,
	NumPad2 =        0x62,
	NumPad3 =        0x63,
	NumPad4 =        0x64,
	NumPad5 =        0x65,
	NumPad6 =        0x66,
	NumPad7 =        0x67,
	NumPad8 =        0x68,
	NumPad9 =        0x69,
	Multiply =       0x6A,
	Add =            0x6B,
	Seperator =      0x6C,
	Suntract =       0x6D,
	Decimal =        0x6E,
	Divide =         0x6F,
	F1 =             0x70,
	F2 =             0x71,
	F3 =             0x72,
	F4 =             0x73,
	F5 =             0x74,
	F6 =             0x75,
	F7 =             0x76,
	F8 =             0x77,
	F9 =             0x78,
	F10 =            0x79,
	F11 =            0x7A,
	F12 =            0x7B,
	F13 =            0x7C,
	F14 =            0x7D,
	F15 =            0x7E,
	F16 =            0x7F,
	F17 =            0x80,
	F18 =            0x81,
	F19 =            0x82,
	F20 =            0x83,
	F21 =            0x84,
	F22 =            0x85,
	F23 =            0x86,
	F24 =            0x87,
	
	NumLock =        0x90,
	Scroll =         0x91,
	
	/*
 * KeyL* & KeyR* - left and right Alt, Ctrl and Shift virtual keys.
 * Used only as parameters to GetAsyncKeyState() and GetKeyState().
 * No other API or message will distinguish left and right keys in this way.
 */
	LeftShift =     0xA0,
	RightShift =	0xA1,
	LeftControl =   0xA2,
	RightControl =  0xA3,
	LeftAlt =       0xA4,
	RightAlt =      0xA5,
	ProcessKey =    0xE5,
	Attn =          0xF6,
	CRSEL =         0xF7,
	EXSEL =         0xF8,
	EREOF =         0xF9,
	Play =          0xFA,
	Zoom =          0xFB,
	NONAME =        0xFC,
	PA1 =           0xFD,
	OEM_CLEAR =     0xFE,
}

//DRuntime missing exported functions
extern(Windows) export short GetKeyState(int vKey) nothrow;
extern(Windows) export short GetAsyncKeyState(int vKey) nothrow;
extern(Windows) export bool GetKeyboardState(ubyte* lpKeyState) nothrow;
extern(Windows) export bool SetKeyboardState(ubyte* lpKeyState) nothrow;
extern(Windows) export uint MapVirtualKey(uint uCode, uint uMapType) nothrow;

private bool keydown(int keyCode) nothrow { return (GetAsyncKeyState(keyCode) & 0x8000) ? true : false; } 
private bool keyup(int keyCode) nothrow { return (GetAsyncKeyState(keyCode) & 0x8000) ? false : true; } 

public immutable struct KeyData
{
	private Key _key;
	@property public Key KeyCode() { return _key; }

	private bool _isDown;
	@property public bool IsDown() { return _isDown; }

	private bool _isUp;
	@property public bool IsUp() { return _isUp; }

	private bool _isRepeating;
	@property public bool IsRepeating() { return _isRepeating; }

	private bool _isLeftControlPressed;
	@property public bool IsLeftControlPressed() { return _isLeftControlPressed; }
	
	private bool _isRightControlPressed;
	@property public bool IsRightControlPressed() { return _isRightControlPressed; }
	
	private bool _isLeftShiftPressed;
	@property public bool IsLeftShiftPressed() { return _isLeftShiftPressed; }
	
	private bool _isRightShiftPressed;
	@property public bool IsRightShiftPressed() { return _isRightShiftPressed; }
	
	private bool _isLeftAltPressed;
	@property public bool IsLeftAltPressed() { return _isLeftAltPressed; }
	
	private bool _isRightAltPressed;
	@property public bool IsRightAltPressed() { return _isRightAltPressed; }

	private bool _isCapsLockToggled;
	@property public bool IsCapsLockToggled() { return _isCapsLockToggled; }

	public this(Key key, bool isDown, bool isUp, bool isRepeating = false) nothrow
	{
		_key = key;
		_isDown = isDown;
		_isUp = isUp;
		_isRepeating = isRepeating;
		_isLeftControlPressed = keydown(Key.LeftControl);
		_isRightControlPressed = keydown(Key.RightControl);
		_isLeftShiftPressed = keydown(Key.LeftShift);
		_isRightShiftPressed = keydown(Key.RightShift);
		_isLeftAltPressed = keydown(Key.LeftAlt);
		_isRightAltPressed = keydown(Key.RightAlt);
		_isCapsLockToggled = keyup(Key.Capital);
	}
}