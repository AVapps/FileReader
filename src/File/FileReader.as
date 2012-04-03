package File
{
	import flash.events.*;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.errors.EOFError;
	import mx.utils.Base64Encoder;

	public class FileReader extends EventDispatcher
	{
		public static const EMPTY:uint = 0;
		public static const LOADING:uint = 1;
		public static const DONE:uint = 2;
		
		public static const DATA:uint = 0;
		public static const BINARY:uint = 1;
		public static const TEXT:uint = 2;
		
		public var readyState:uint;
		public var readFormat:uint;
		
		public var error:Error;
		
		private var _result:String;
		private var _encoding;String;
		
		public function FileReader()
		{
			super();
			readyState = EMPTY;
		}
		
		public function readAsDataURL(file:FileReference):void
		{
			readFormat = DATA;
			_start(file);
		}
		
		public function readAsBinaryString(file:FileReference):void
		{
			readFormat = BINARY;
			_start(file);
		}
		
		public function readAsText(file:FileReference, encoding:String = null):void
		{
			readFormat = TEXT;
			if (encoding) _encoding = encoding;
			_start(file);
		}
		
		public function abort():void
		{
			if (readyState === LOADING) {
				readyState = DONE;
			}
			_result = null;
			dispatchEvent(new ProgressEvent('abort'));
			dispatchEvent(new ProgressEvent('loadend'));
		}
		
		
		// _result Get
		
		public function get result():*
		{
			if (readyState === EMPTY || error) {
				return null;
			}
			return _result;
		}
		
		
		// Private
		
		private function _start(file:FileReference):void
		{
			readyState = LOADING;
			dispatchEvent(new ProgressEvent('loadstart'));
			file.addEventListener('progress', onProgress);
			file.addEventListener('complete', onComplete);
			file.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			file.load();
		}
		
		private function _done():void
		{
			readyState = DONE;
			dispatchEvent(new ProgressEvent('loadend'));
		}
		
		
		// Event Handlers
		
		public function onProgress(evt:ProgressEvent):void
		{
			dispatchEvent(evt);
		}

		public function onComplete(evt:Event):void
		{
			var file = evt.target;
			switch (readFormat) 
			{
				case DATA:
					var encoder:Base64Encoder = new Base64Encoder();
					encoder.encodeBytes(file.data, 0, file.data.length);
					var mimeType:String = MimeTypeMap.getMimeType(file.name.substr(-3));
					if (!mimeType) mimeType = 'text/plain';
					_result = "data:" + mimeType + ";base64," + encoder.toString();
					break;
				case TEXT:
					if (_encoding) {
						_result = file.data.readMultiByte(file.data.length, _encoding);
					} else {
						_result = file.data.toString();
					}
					break;
				case BINARY:
					_result = file.data.readMultiByte(file.data.length, 'ascii');
					break;
			}
			dispatchEvent(new ProgressEvent('load'));
			_done();
		}
		
		public function onIOError(evt:IOErrorEvent):void
		{
			_result = null;
			error = new Error("The File cannot be read!");
			error.name = 'NotReadableError';
			dispatchEvent(new Event('error'));
			_done();
		}
	}
}