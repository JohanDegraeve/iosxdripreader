package skins
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