/**
 Copyright (C) 2017  Johan Degraeve
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/gpl.txt>.
 
 */
package renderers
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.graphics.BitmapFillMode;
	
	import spark.components.Image;
	import spark.components.LabelItemRenderer;
	
	import Utilities.FromtimeAndValue;
	
	import databaseclasses.AlertType;
	import databaseclasses.BgReading;
	import databaseclasses.CommonSettings;
	
	import model.ModelLocator;
	
	public class AlertTypeItemRenderer extends LabelItemRenderer
	{
		private var editImage:Image;
		private var deleteImage:Image;
		
		/**
		 * to dispatch event data delete button as clicked
		 */
		public static var DELETE_CLICKED:String = "FROMTIME_AND_VALUE_ITEMRENDERER_DELETE_CLICKED";
		
		/**
		 * to dispatch event data edit button as clicked
		 */
		public static var EDIT_CLICKED:String = "FROMTIME_AND_VALUE_ITEMRENDERER_EDIT_CLICKED";
		
		private function deleteClicked(event:Event):void {
			this.dispatchEvent(new Event(DELETE_CLICKED,true,true));
		}
		
		private function editClicked(event:Event):void {
			this.dispatchEvent(new Event(EDIT_CLICKED,true,true));
		}
		
		static private var ITEM_HEIGHT:int = 48;
		static private var ICON_WIDTH:int = 48;
		static private var offsetToPutTextInTheMiddle:int = 15;
		
		public function AlertTypeItemRenderer()
		{
			super();
			deleteImage = new Image();
			deleteImage.fillMode = BitmapFillMode.CLIP;
			deleteImage.contentLoader = ModelLocator.iconCache;
			deleteImage.source = "assets/Trash_48x48.png";
			deleteImage.addEventListener(MouseEvent.CLICK,deleteClicked);
			addChild(deleteImage);

			editImage = new Image();
			editImage.fillMode = BitmapFillMode.CLIP;
			editImage.contentLoader = ModelLocator.iconCache;
			editImage.source = "assets/edit48x48.png";
			editImage.addEventListener(MouseEvent.CLICK,editClicked);
			addChild(editImage);
		}
		
		/**
		 * @private
		 *
		 * Override this setter to respond to data changes
		 */
		override public function set data(value:Object):void
		{
			super.data = value;
			if (value == null)
				return;
			var theDataAsAlertType:FromtimeAndValue = value as AlertType
				;
			var valueInCorrectUnit:Number = theDataAsAlertType.value;
			if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_DO_MGDL) != "true") {
				valueInCorrectUnit = valueInCorrectUnit * BgReading.MGDL_TO_MMOLL;
			}
			label = 
				theDataAsAlertType.fromAsString() 
				+ " "
				+ (Math.round(valueInCorrectUnit) == valueInCorrectUnit ?
					valueInCorrectUnit
					:
					(Math.round((valueInCorrectUnit * 10)) / 10).toString())
				+ " "
				+ theDataAsAlertType.alarmName;
			deletable = theDataAsAlertType.deletable;
			editable = theDataAsAlertType.editable;
			elementCanBeAdded = (theDataAsAlertType.from == 86400 || theDataAsAlertType.from == (86400 - 60)) ? false:true;
		} 
		
		/**
		 * @private
		 * 
		 * Override this method to change how the item renderer 
		 * sizes itself. For performance reasons, do not call 
		 * super.measure() unless you need to.
		 */ 
		override protected function measure():void
		{
			super.measure();
			// measure all the subcomponents here and set measuredWidth, measuredHeight, 
			// measuredMinWidth, and measuredMinHeight      		
		}
		
		/**
		 * @private
		 * 
		 * Override this method to change how the background is drawn for 
		 * item renderer.  For performance reasons, do not call 
		 * super.drawBackground() if you do not need to.
		 */
		override protected function drawBackground(unscaledWidth:Number, 
												   unscaledHeight:Number):void
		{
			//only draw a border line
			graphics.lineStyle(1, 0x212121);
			graphics.moveTo(0,unscaledHeight - 1);
			graphics.lineTo(unscaledWidth,unscaledHeight - 1);
			graphics.endFill();
		}
		
		/**
		 * @private
		 *  
		 * Override this method to change how the background is drawn for this 
		 * item renderer. For performance reasons, do not call 
		 * super.layoutContents() if you do not need to.
		 */
		override protected function layoutContents(unscaledWidth:Number, 
												   unscaledHeight:Number):void
		{
			//super.layoutContents(unscaledWidth, unscaledHeight);
			if (editImage) {
				setElementSize(editImage,ICON_WIDTH,ITEM_HEIGHT);
				setElementPosition(editImage,unscaledWidth - ICON_WIDTH,0);
			}
			if (addImage) {
				setElementSize(addImage,ICON_WIDTH,ITEM_HEIGHT);
				setElementPosition(addImage,unscaledWidth - ICON_WIDTH - (editImage?ICON_WIDTH:0),0); 
			}
			if (deleteImage) {
				setElementSize(deleteImage,ICON_WIDTH,ITEM_HEIGHT);
				setElementPosition(deleteImage,unscaledWidth - ICON_WIDTH - (editImage?ICON_WIDTH:0) - (addImage?ICON_WIDTH:0),0); 
			}
			setElementSize(labelDisplay,unscaledWidth - ICON_WIDTH *2 ,ITEM_HEIGHT);
			setElementPosition(labelDisplay,0,offsetToPutTextInTheMiddle);
		}

	}
}