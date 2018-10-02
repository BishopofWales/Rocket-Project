package Game
{
	import flash.display.MovieClip;
	public class Planet extends MovieClip
	{
		private var _mass:Number

		public function Planet() 
		{
			// constructor code
		}
		public function get mass()
		{
			return _mass
		}
		public function set mass(receivedNumber)
		{
			_mass = receivedNumber
		}

	}
	
}
