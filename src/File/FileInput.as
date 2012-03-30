package File
{
	import flash.events.*; 
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	
	public class FileInput extends EventDispatcher
	{
		private var _id:String;
		public var multiple:Boolean;
		public var _files:*;
		
		private var filters:Array = [];
		
		public function FileInput(id:String, multiple:Boolean = false)
		{
			_id = id;
			this.multiple = multiple;
			if (multiple) {
				_files = new FileReferenceList();
			} else {
				_files = new FileReference();
			}
			_files.addEventListener(Event.SELECT, onSelect);
			_files.addEventListener(Event.CANCEL, onCancel);
			
		}
		
		public function addExtensions(label:String, extensions:String):int
		{
			return filters.push(new FileFilter(label, extensions));
		}
		
		public function addMimeType(mimeType:String):int
		{
			var extensions:* = MimeTypeMap.getExtensions(mimeType);
			if (extensions) {
				return filters.push(new FileFilter(mimeType, extensions));
			} else {
				return filters.length;
			}
		}
		
		public function browse():void
		{
			_files.browse(filters);
		}
		
		public function getFile(filename:String):FileReference
		{
			for each (var file:FileReference in this.files)
			{
				if (filename == file.name) {
					return file;
				}
			}
			return null;
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function get files():Array
		{
			if (multiple) {
				return _files.fileList;
			} else {
				return [_files];
			}
		}
		
		public function filesToJSON():Array
		{
			var array:Array = [];
			for each (var file:FileReference in this.files)
			{
				array.push({
					'type': MimeTypeMap.getMimeType(file.name.substr(-3)),
					'size': file.size,
					'name': file.name,
					'lastModifiedDate': file.modificationDate,
					'input': _id
				});
			}
			return array;
		}
		
		/* 
		* Events Handlers
		*/

		public function onSelect(evt:Event):void
		{
			dispatchEvent(new Event('change'));
		}
		
		public function onCancel(evt:Event):void
		{
			dispatchEvent(new Event('cancel'));
		}
	}
}