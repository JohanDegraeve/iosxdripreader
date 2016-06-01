/**
 Copyright (C) 2016  Johan Degraeve
 
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
 
 */package skins
{
	import flash.display.GradientType;
	import flash.geom.Matrix;
	
	import spark.skins.mobile.TabbedViewNavigatorApplicationSkin;
	
	public class ApplicationSkin extends TabbedViewNavigatorApplicationSkin
	{
		//see http://code.tutsplus.com/tutorials/how-to-create-gradients-with-actionscript--active-6443
		static private var tabBackGroundColors:Array;
		static private var matrix:Matrix;

		public function ApplicationSkin()
		{
			super();
		}
		
		override protected function drawBackground(unscaledWidth:Number,unscaledHeight:Number):void {
			if (tabBackGroundColors == null) {
				tabBackGroundColors = [] ;
				tabBackGroundColors[0] = '0xC8C8C8';/* gradient will be applied from bottom to top, this is the bottom color*/
				tabBackGroundColors[1] = '0xFFFFFF';
				matrix = new Matrix();
				matrix.createGradientBox(unscaledWidth, unscaledHeight, 1.57, 0, 0);
			}
			
			//only if the tab is selected, then we'll have the gradient backup
			graphics.beginGradientFill(GradientType.LINEAR, tabBackGroundColors, [100,100],[0,255],matrix);
			
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			graphics.endFill();
		}
	}
}