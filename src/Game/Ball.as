package  Game
{
	import flash.display.MovieClip;
	
	public class Ball extends MovieClip
	{
		import flash.display.MovieClip
		private var _mass:Number
		private var _velocity:Number
		private var _energy:Number
		private var _angMom:Number
		private var _eccentricity:Number
		private var _nodeAngle:Number

		public function Ball() 
		{
			
		}
		public function rVector():Number
		{
			return Math.sqrt((this.y)*(this.y)+(this.x)*(this.x))*C.gameMpp;
		}
			public function get mass()
		{
			return _mass
		}
		public function set mass(receivedNumber)
		{
			_mass = receivedNumber
		}
		public function get velocity()
		{
			return _velocity
		}
		public function set velocity(receivedNumber)
		{
			_velocity = receivedNumber
		}
		public function get energy()
		{
			return _energy
		}
		public function set energy(receivedNumber)
		{
			_energy = receivedNumber
		}
		public function get angMom()
		{
			return _angMom
		}
		public function set angMom(receivedNumber)
		{
			_angMom = receivedNumber
		}
		public function get eccentricity()
		{
			return _eccentricity	
		}
		public function set eccentricity(receivedNumber)
		{
			_eccentricity = receivedNumber
		}


	}
	
}
