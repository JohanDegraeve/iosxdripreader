package Utilities
{
	import flash.system.Capabilities;
	
	import spark.formatters.DateTimeFormatter;
	
	public class Trace
	{
		private static var dateFormatter:DateTimeFormatter;

		public function Trace()
		{
		}
		
		public static function myTrace(tag:String, log:String):void {
			if (dateFormatter == null) {
				dateFormatter = new DateTimeFormatter();
				dateFormatter.dateTimePattern = "HH-mm-ss-SSS";
				dateFormatter.useUTC = false;
				dateFormatter.setStyle("locale",Capabilities.language.substr(0,2));
			}
			trace(dateFormatter.format(new Date()) + " " + tag +  ": " + log);
		}
	}
}