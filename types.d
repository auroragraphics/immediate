module aurora.immediate.types;

public struct SystemWindow 
{
	private void* data;
	private hash_t hash;

	@property public void* RawData() { return data; }

	const hash_t toHash() { return hash; }
	const bool opEquals(ref const SystemWindow t) { return hash == t.hash; }

	version(Windows) { 
		public this(void* window) { 
			data = window;
			hash = cast(hash_t)window;
		}
		@property public void* Window() { return data; }
	}

	version(Linux) { 
	}

	version(OSX) {
	}
}