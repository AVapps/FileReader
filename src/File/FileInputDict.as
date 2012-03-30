package File
{
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	public class FileInputDict extends EventDispatcher
	{
		
		private var _dict:Object = new Object();
		private var _listeners:Object = {'change': [], 'cancel': []};

		public function create(id:String, multiple:Boolean = false, accept:String = null, label:String = null, extensions:String = null):FileInput
		{
			var input:FileInput = new FileInput(id, multiple);
			if (accept) input.addMimeType(accept);
			if (label && extensions) input.addExtensions(label, extensions);
			_dict[id] = input;
			input.addEventListener('change', _bubble);
			input.addEventListener('cancel', _bubble);
			return input;
		}
	
		public function get(id:String):FileInput
		{
			if (_dict.hasOwnProperty(id)) return _dict[id];
			return null;
		}
		
		public function remove(id:String):void
		{
			if (_dict.hasOwnProperty(id)) delete _dict[id];
		}
		
		public function browse(id:String):void
		{
			if (_dict.hasOwnProperty(id)) _dict[id].browse();
		}
		
		public function addFileInputEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			if (type in _listeners) _listeners[type].push(listener);
		}
		
		private function _bubble(evt:Event):void
		{
			if (evt.type in _listeners)
			{
				trace('Bubling... ', evt);
				for each (var fn:Function in _listeners[evt.type])
				{
					fn(evt);
				}
			}
		}
	}
}