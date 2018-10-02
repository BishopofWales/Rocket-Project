
package Game

{
	import flash.events.*;

	public class C extends EventDispatcher
	{	
		public static const g:Number=6.67384*Math.pow(10,-11);
		public static const gameMpp:Number = .1;
		public static const mapMpp:Number = 50;
		public static const numberOfTextBoxes:Number = 4;
		public static const numberOfInputBoxes:Number = 5;
		public static const gameZoomDefault:Number = 1;
		public static const mapZoomDefault:Number = .5;
		public static const uiScale = 1.5;
		public static const markerScale:Number = 2.5;
		public static const planetRadius:Number = 637100;
		public static const thrustDefault:Number = 0;
		//Bigger number = more zoomed in
		public static const mapMinZoom:Number = 1;
		//Smaller number = more zommed out
		public static const mapMaxZoom:Number = 1/200;
		public static const thrustChange = .055;
		//Stats
		//circular orbit at 717km: 2357 m/s
		
	}
}