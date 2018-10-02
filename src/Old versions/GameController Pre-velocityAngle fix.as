
package
{
		
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	import Game.*;
	import flash.accessibility.Accessibility;
	import flash.utils.*;
	import flash.display.*;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;

	public class GameController extends MovieClip
	{	
		//The object the orbits
		private var myBall:Ball;
		// The line drawn behing the object as it moves
		private var orbitalLine:Shape;
		private var myPlanet:Planet;
		private var semimajorAxis:Number;
		private var semiminorAxis:Number;
		//Determines the angle betweent the planet and the orbiting "ball"
		private var angle:Number;
		private var u=C.g*(5.972*Math.pow(10,24))/100;
		//Angle between the two focus points of the ellipse the ball is traveling on
		private var focciAngle:Number;
		//Rvector refers to distance, this is the one that is derived geometrically
		private var derivedRVector:Number;
		private var estimateFocciAngle:Number;
		//The circle drawn on the map
		private var orbitalCircle:Shape;
		//Angle between craft and focci not occupied by the planet
		private var emptyFocciAngle:Number;
		
		private var timewarpFactor:Number = 1;
		private var velocityAngle:Number;
		private var velocityLine:Shape;
		//Line pointing at planet
		private var rVectorLine:Shape;
		//Angle of the "rVector" the vector of distance to planet
		private var rVectorAngle:Number;
		//Line pointing at empty focci
		private var emptyFocciLine:Shape;
		

		private var inGamePeriod:Number;
		private var gameScaleFactor:Number = C.gameZoomDefault;
		private var planetCircle:Shape;
		private var gravity:Number;
		private var xSpeed:Number;
		private var ySpeed:Number;
		private var periapsisAngle:Number;
		private var myNavBall:NavBall;
		private var craftAngle:Number = -Math.PI/2
		//Map Variables
		private var mapScaleFactor:Number = C.mapZoomDefault;
		private var myMapCraft:MapCraft;
		private var mapShowing:Boolean = false;
		private var myPeriapsisMarker:PeriapsisMarker
		private var myApoapsisMarker:ApoapsisMarker
		private var apoapsis:Number;
		private var periapsis:Number;
		//Keyboard Variables
		private var aKeyPressed:Boolean
		private var dKeyPressed:Boolean
		private var shiftKeyPressed:Boolean;
		private var controlKeyPressed:Boolean;
		
		//UI Variables
		private var myThrottle:Throttle;
		private var textBoxLables:Array;
		private var textBoxes:Array;
		private var inputBoxLables:Array;
		private var inputBoxes:Array;
		private var inputBoxNumber:Number = 0;
		private var mapPlanetCircle:Shape;
		private var myPositionIndicator:PositionIndicator;
		private var myRetrogradeMarker:RetrogradeMarker;
		private var myProgradeMarker:ProgradeMarker;
		private var myThrottleMarker:ThrottleMarker;
		private var thrustLevel:Number = C.thrustDefault
		private var gamePaused:Boolean = true
		
		public function startGame()
		{
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			planetCircle = new Shape;
			
			//Map Init
			myMapCraft =  new MapCraft();
			myApoapsisMarker = new  ApoapsisMarker();
			myPeriapsisMarker = new  PeriapsisMarker();
			orbitalCircle=new Shape;
			mapPlanetCircle = new Shape;
			mcMapStage.addChild(mapPlanetCircle);
			mcMapStage.addChild(myPeriapsisMarker);
			
			mcMapStage.addChild(myApoapsisMarker);
			mcMapStage.addChild(orbitalCircle);
			mcGameStage.addChild(planetCircle);
			mcMapStage.addChild(myMapCraft);
			
			mcMapStage.alpha = 0
			scaleAt(mcMapStage, mapScaleFactor,myMapCraft.x,myMapCraft.y)
			mcMapStage.x = 300 - myMapCraft.x*mapScaleFactor
			mcMapStage.y = 300 - myMapCraft.y*mapScaleFactor
			myMapCraft.width = 10/mapScaleFactor
			myMapCraft.height = 10/mapScaleFactor
			myPeriapsisMarker.width = 10/mapScaleFactor*C.markerScale
			myPeriapsisMarker.height = 10/mapScaleFactor*C.markerScale
			
			mapPlanetCircle.graphics.beginFill(0x669933, 1);
			mapPlanetCircle.graphics.drawCircle(0,0, C.planetRadius/C.mapMpp);

			//UI Initialization
			myNavBall =  new NavBall();
			myThrottleMarker = new ThrottleMarker();
			myThrottle = new Throttle();
			myProgradeMarker = new ProgradeMarker;
			myRetrogradeMarker = new RetrogradeMarker;
			myPositionIndicator = new PositionIndicator();
			mcUIStage.addChild(myNavBall);
			mcUIStage.addChild(myThrottle);
			mcUIStage.addChild(myThrottleMarker);
			mcUIStage.addChild(myPositionIndicator);
			mcUIStage.addChild(myRetrogradeMarker);
			mcUIStage.addChild(myProgradeMarker);
			myThrottle.x = -120
			myThrottleMarker.x = myThrottle.x
			myPositionIndicator.y = -75 + myNavBall.y
			myRetrogradeMarker.x = myNavBall.x
			myRetrogradeMarker.y = myNavBall.y
			myProgradeMarker.x = myNavBall.x
			myProgradeMarker.y = myNavBall.y
			mcUIStage.width *= C.uiScale
			mcUIStage.height *= C.uiScale
			
			inputBoxLables = new Array;
			inputBoxes = new Array;
			
			orbitalLine=new Shape;
			textBoxLables = new Array;
			textBoxes = new Array;
			myPlanet=new Planet;
			myPlanet.mass=5.972*Math.pow(10,24);
			
			orbitalLine.graphics.lineStyle(1, 0x990000,1);
			myBall=new Ball;
			//The velocity can't start at zero, so I start it at 1m /s
			myBall.velocity= 1;
			myBall.y = -637100/C.gameMpp
			mcGameStage.addChild(myBall);
			mcGameStage.addChild(orbitalLine);
			mcGameStage.addChild(myPlanet);
			
			orbitalLine.graphics.moveTo(myBall.x, myBall.y);
			mcGameStage.addChild(testPoint);
			myBall.energy=Math.pow(myBall.velocity,2)/2-u/myBall.rVector();
			myBall.angMom=myBall.velocity*myBall.rVector()*Math.sin(Math.PI/2);
			myBall.eccentricity=Math.sqrt(1+(2*myBall.energy*Math.pow(myBall.angMom,2))/Math.pow(u,2));
			semimajorAxis=-u/(2*myBall.energy);
			semiminorAxis=semimajorAxis*Math.sqrt(1-Math.pow(myBall.eccentricity,2));
			angle=Math.atan2(myBall.y,myBall.x);
			estimateFocciAngle=(Math.pow(2*myBall.eccentricity*semimajorAxis,2)+Math.pow(myBall.rVector(),2)-Math.pow(2*semimajorAxis-myBall.rVector(),2))/(2*2*myBall.eccentricity*semimajorAxis*myBall.rVector());
			if(estimateFocciAngle>1)estimateFocciAngle=1;
			if(estimateFocciAngle<-1)estimateFocciAngle=-1;
			focciAngle = Math.acos(estimateFocciAngle)+angle;
			periapsisAngle = focciAngle + Math.PI;
			derivedRVector = (semimajorAxis*(1 - Math.pow(myBall.eccentricity,2)))/(1 + myBall.eccentricity*Math.cos(periapsisAngle - angle));
			apoapsis = 2*myBall.eccentricity*semimajorAxis + semimajorAxis-myBall.eccentricity*semimajorAxis;
			periapsis = semimajorAxis-myBall.eccentricity*semimajorAxis;
			//Game Initilization
			scaleAt(mcGameStage, gameScaleFactor,myBall.x,myBall.y)
			mcGameStage.x = 300 - myBall.x*gameScaleFactor
			mcGameStage.y = 300 - myBall.y*gameScaleFactor
			//Text Box Initlization
			//textBox, and textBox Label, refers to everything on the left
			//inputText Box, and input textBox Label refers to everything on the right
			for(var l:int=0;l<C.numberOfTextBoxes;l++)
			{
				var newTextField:TextField=new TextField;
				
				newTextField.text="hello";
				newTextField.y=l*20;
				addChild(newTextField);
				textBoxLables.push(newTextField);
			}
			for(var l:int=0;l<C.numberOfTextBoxes;l++)
			{
				var newTextField:TextField=new TextField;
				newTextField.x = 90;
				newTextField.text="hello";
				newTextField.y=l*20;
				newTextField.width=1000
				addChild(newTextField);
				textBoxes.push(newTextField);
			}
			for(var l:int=0;l<C.numberOfInputBoxes;l++)
			{
				var newTextField:TextField=new TextField();
				addChild(newTextField);
				newTextField.x = 360;
				newTextField.y=l*20;
				newTextField.text="hello";
				newTextField.width = 10000;
				newTextField.type=TextFieldType.INPUT; 
				newTextField.restrict = "0-9" , "-", ".";
				
				inputBoxes.push(newTextField);
			}
			for(var l:int=0;l<C.numberOfInputBoxes;l++)
			{
				var newTextField:TextField=new TextField;
				newTextField.x = 250;
				newTextField.text="hello";
				newTextField.y=l*20;
				newTextField.width=1000;
				addChild(newTextField);
				inputBoxLables.push(newTextField);
			}
			inputBoxLables[0].text = "Direction(degrees):"
			inputBoxLables[1].text = "Velocity (m/s):"
			inputBoxLables[2].text = "X position(m):"
			inputBoxLables[3].text = "Y position(m):"
			inputBoxLables[4].text = "Timewarp factor:"

			inputBoxes[0].text = 90
			inputBoxes[1].text = 2000
			inputBoxes[2].text = 637100
			inputBoxes[3].text = 0
			inputBoxes[4].text = timewarpFactor
			
			textBoxLables[0].text = "Periapsis:"
			textBoxLables[1].text = "Apoapsis:"
			textBoxLables[2].text = "Velocity:"
			textBoxLables[3].text = "Altitude:"
			
			textBoxes[0].text = periapsis - C.planetRadius
			textBoxes[1].text =  apoapsis - C.planetRadius;
			textBoxes[2].text = myBall.velocity;
			textBoxes[3].text = myBall.rVector() - C.planetRadius;
			
			myPeriapsisMarker.x = Math.cos(focciAngle+Math.PI)*(periapsis)/C.mapMpp
			myPeriapsisMarker.y = Math.sin(focciAngle+Math.PI)*(periapsis)/C.mapMpp
			myApoapsisMarker.x = Math.cos(focciAngle)*(apoapsis)/C.mapMpp
			myApoapsisMarker.y = Math.sin(focciAngle)*(apoapsis)/C.mapMpp
			velocityLine = new Shape;
			rVectorLine = new Shape;
			mcGameStage.addChild(velocityLine);
			mcGameStage.addChild(rVectorLine);
			emptyFocciLine = new Shape;
			mcGameStage.addChild(emptyFocciLine);
			//stage.addEventListener(Event.ENTER_FRAME,update);
			myBall.width /= C.gameMpp;
			myBall.height /= C.gameMpp;
			planetCircle.graphics.beginFill(0x669933, 1);
			planetCircle.graphics.drawCircle(0,0, C.planetRadius / C.gameMpp);
			//trace("period:", Math.PI*2*Math.sqrt(Math.pow(semimajorAxis,3)/u))
			
		}
		//These two functions, when combined, allow you to add two vectors together.
		private function vectorAddAngle(vector1Mag:Number,vector1Angle:Number, vector2Mag:Number, vector2Angle:Number):Number
		{
			var vector1X = Math.cos(vector1Angle)*vector1Mag
			var vector1Y = Math.sin(vector1Angle)*vector1Mag
			
			var vector2X = Math.cos(vector2Angle)*vector2Mag
			var vector2Y = Math.sin(vector2Angle)*vector2Mag
			
			var vectorTotAngle = Math.atan2(vector2Y+vector1Y,vector1X+vector2X);
			trace(vectorTotAngle)
			return vectorTotAngle
		}
		private function vectorAddMag(vector1Mag:Number,vector1Angle:Number, vector2Mag:Number, vector2Angle:Number):Number
		{
			var vector1X = Math.cos(vector1Angle)*vector1Mag
			var vector1Y = Math.sin(vector1Angle)*vector1Mag
			
			var vector2X = Math.cos(vector2Angle)*vector2Mag
			var vector2Y = Math.sin(vector2Angle)*vector2Mag
			
			var vectorTotMag = Math.sqrt(Math.pow(vector1X+vector2X,2)+Math.pow(vector1Y+vector2Y,2))
			trace(vectorTotMag)
			return vectorTotMag
		}
		//Main Update loop, plays every 1/30th of a second
		private function update(evt:Event)
		{
			//Control Inerpretation
			if(aKeyPressed == true) craftAngle -= .01;
			if(dKeyPressed == true) craftAngle += .01;
			if(timewarpFactor == 1)
			{
				if(shiftKeyPressed == true && thrustLevel != 1)
				{
					thrustLevel += C.thrustChange;
					if(thrustLevel > 1) thrustLevel = 1
				}
				if(controlKeyPressed == true && thrustLevel != 0)
				{
					thrustLevel -=  C.thrustChange;
					if(thrustLevel < 0) thrustLevel = 0;
				}
			}
			// When thrust level is equal to zero, the orbit is projected using gemoetry and keperian orbital mechanics, the craft rotates around the planet in a set path.
			// This allows for timewarp, as the shape of orbit is set. 
			// The real meat of this program is in these next two if() functions.
			// The hardest part was taking a speed and a location and turning it into an ellipse that predicts the orbit
			if(thrustLevel == 0)
			{
				if(angle == 0) inGamePeriod = getTimer();
				if(myBall.rVector() < 3000) mcGameStage.removeEventListener(Event.ENTER_FRAME,update);
				var oldFocciAngle = focciAngle
				
				if(inputBoxNumber < C.numberOfInputBoxes)stage.focus = inputBoxes[inputBoxNumber];
				else
				{
					processInput();
					inputBoxNumber = 0
				}
				
				
				angle+=(myBall.angMom/Math.pow(derivedRVector,2))*3*timewarpFactor/119.97923;
				
				//this makes sure that the angle stays within good values
				//->
				while(angle > Math.PI*2)
				{
					angle-=Math.PI*2
					trace(getTimer()-inGamePeriod)
					inGamePeriod = getTimer();
				}
				while(angle < 0)
				{
					angle+=Math.PI*2
				}
				//<-
				
				
				derivedRVector = (semimajorAxis*(1 - Math.pow(myBall.eccentricity,2)))/(1 + myBall.eccentricity*Math.cos(periapsisAngle - angle))

				myBall.x=Math.cos(angle)*derivedRVector/C.gameMpp;
				myBall.y=Math.sin(angle)*derivedRVector/C.gameMpp;
				
				myBall.velocity = Math.sqrt(u*(2/derivedRVector-1/semimajorAxis))
	
				emptyFocciAngle = Math.atan2(Math.sin(angle)*derivedRVector/C.gameMpp-Math.sin(focciAngle)*2*myBall.eccentricity*semimajorAxis/C.gameMpp,Math.cos(angle)*derivedRVector/C.gameMpp-Math.cos(focciAngle)*2*myBall.eccentricity*semimajorAxis/C.gameMpp) + Math.PI
				
				rVectorAngle = angle + Math.PI
				gravity = u/Math.pow(myBall.rVector(),2)
				//Making sure that rVectorAngle is always dispalyed so that a straight numerical comparison to yield the larger angle
				while(Math.abs(emptyFocciAngle - rVectorAngle) > Math.PI)
				{
					if(rVectorAngle > emptyFocciAngle) rVectorAngle -= Math.PI*2
					else if(emptyFocciAngle > rVectorAngle) rVectorAngle += Math.PI*2
				}
				
				velocityAngle = Math.abs(rVectorAngle-emptyFocciAngle);
				velocityAngle = (Math.PI-velocityAngle)/2
				if(rVectorAngle < emptyFocciAngle) velocityAngle = velocityAngle + emptyFocciAngle +Math.PI;
				if(rVectorAngle > emptyFocciAngle) velocityAngle = velocityAngle + rVectorAngle + Math.PI;
				if(myBall.angMom < 0) velocityAngle += Math.PI
				//if(myBall.angMom<0)velocityAngle = velocityAngle + Math.PI;
				//Recalc stuff
				xSpeed = Math.cos(velocityAngle)*myBall.velocity/30/C.gameMpp
				ySpeed = Math.sin(velocityAngle)*myBall.velocity/30/C.gameMpp
			}
			// When not zero, a simpistic model of vector addition is used, with one vector being gravity and the other the thrust
			// More forces can easily be added in. 
			if(thrustLevel != 0)
			{
				
				xSpeed += Math.cos(rVectorAngle)*gravity/C.gameMpp/900 + Math.cos(craftAngle)*.03/C.gameMpp*thrustLevel;
				ySpeed += Math.sin(rVectorAngle)*gravity/C.gameMpp/900 + Math.sin(craftAngle)*.03/C.gameMpp*thrustLevel;
				
				myBall.x += xSpeed
				
				myBall.y += ySpeed
				
				myBall.velocity = Math.sqrt(Math.pow(xSpeed*30*C.gameMpp,2)+Math.pow(ySpeed*30*C.gameMpp,2));
				
				angle = Math.atan2(myBall.y,myBall.x)
				rVectorAngle = angle + Math.PI
				
				velocityAngle = Math.atan2(ySpeed,xSpeed);
				
				
				var differenceAngle = Math.abs(rVectorAngle- velocityAngle);
				while(differenceAngle > Math.PI*2)
				{
					differenceAngle -= Math.PI*2
				}
				while(differenceAngle < 0)
				{
					differenceAngle += Math.PI*2
				}
				
				// This is where the magic happens! Taking the speed and velocity given by the vector addition, and turning into an ellipse. 
				myBall.energy=Math.pow(myBall.velocity,2)/2-u/myBall.rVector()
				myBall.angMom = myBall.velocity*myBall.rVector()*Math.sin(differenceAngle);
				myBall.eccentricity=Math.sqrt(1+(2*myBall.energy*Math.pow(myBall.angMom,2))/Math.pow(u,2))
				semimajorAxis= -u/(2*myBall.energy)
				semiminorAxis=semimajorAxis*Math.sqrt(1-Math.pow(myBall.eccentricity,2))
				estimateFocciAngle=(Math.pow(2*myBall.eccentricity*semimajorAxis,2)+Math.pow(myBall.rVector(),2)-Math.pow(2*semimajorAxis-myBall.rVector(),2))/(2*2*myBall.eccentricity*semimajorAxis*myBall.rVector())
				if(estimateFocciAngle>1)estimateFocciAngle = 1;
				if(estimateFocciAngle<-1)estimateFocciAngle =- 1;
				if((differenceAngle > 0 && differenceAngle <= Math.PI/2) || (differenceAngle > Math.PI && differenceAngle <= Math.PI*3/2) )
				{
					focciAngle = angle - Math.acos(estimateFocciAngle)
				}
				else focciAngle = angle + Math.acos(estimateFocciAngle);
				periapsisAngle = focciAngle + Math.PI
				apoapsis = 2*myBall.eccentricity*semimajorAxis + semimajorAxis-myBall.eccentricity*semimajorAxis;
				periapsis = semimajorAxis-myBall.eccentricity*semimajorAxis;
				myPeriapsisMarker.x = Math.cos(focciAngle+Math.PI)*(periapsis)/C.mapMpp
				myPeriapsisMarker.y = Math.sin(focciAngle+Math.PI)*(periapsis)/C.mapMpp
				myApoapsisMarker.x = Math.cos(focciAngle)*(apoapsis)/C.mapMpp
				myApoapsisMarker.y = Math.sin(focciAngle)*(apoapsis)/C.mapMpp
				textBoxes[0].text = periapsis - C.planetRadius
				textBoxes[1].text =  apoapsis - C.planetRadius;
				derivedRVector = (semimajorAxis*(1 - Math.pow(myBall.eccentricity,2)))/(1 + myBall.eccentricity*Math.cos(periapsisAngle - angle))
				
			}
			
			myBall.rotation = craftAngle * 180/Math.PI;
			myNavBall.rotation = (rVectorAngle - craftAngle) * 180/Math.PI;
			myProgradeMarker.rotation = (velocityAngle - craftAngle -Math.PI/2) *180/Math.PI;
			myRetrogradeMarker.rotation = (velocityAngle - craftAngle +Math.PI/2) *180/Math.PI;
			myMapCraft.x = Math.cos(angle)*derivedRVector/C.mapMpp
			myMapCraft.y = Math.sin(angle)*derivedRVector/C.mapMpp
			mcMapStage.x = 300 - myMapCraft.x*mapScaleFactor
			mcMapStage.y = 300 - myMapCraft.y*mapScaleFactor
			mcGameStage.x = 300 - myBall.x*gameScaleFactor
			mcGameStage.y = 300 - myBall.y*gameScaleFactor
			orbitalLine.graphics.lineTo(myBall.x, myBall.y);
			
			//Updates to the visual part of the program go here, not essential to really understanding the program
			myThrottleMarker.y = -thrustLevel*140+70+myThrottle.y
			textBoxes[2].text = myBall.velocity
			inputBoxes[4].text = timewarpFactor
			
			textBoxes[3].text = myBall.rVector() - C.planetRadius;
			mcMapStage.removeChild(orbitalCircle);
			orbitalCircle=new Shape
			mcMapStage.addChild(orbitalCircle);
			orbitalCircle.graphics.lineStyle(0, 0x50000,1);
			mcGameStage.removeChild(rVectorLine)
			mcGameStage.removeChild(velocityLine)
			mcGameStage.removeChild(emptyFocciLine)
			velocityLine = new Shape
			rVectorLine = new Shape
			emptyFocciLine = new Shape
			mcGameStage.addChild(velocityLine)
			
			mcGameStage.addChild(rVectorLine)
			mcGameStage.addChild(emptyFocciLine)
			rVectorLine.graphics.lineStyle(1, 0x30000,7);
			rVectorLine.graphics.moveTo(myBall.x,myBall.y);
			rVectorLine.graphics.lineTo(myBall.x+Math.cos(rVectorAngle)*100,myBall.y+Math.sin(rVectorAngle)*100)
			emptyFocciLine.graphics.lineStyle(1, 0x31000,7);
			emptyFocciLine.graphics.moveTo(myBall.x,myBall.y);
			emptyFocciLine.graphics.lineTo(myBall.x+Math.cos(emptyFocciAngle)*100,myBall.y+Math.sin(emptyFocciAngle)*100)
			velocityLine.graphics.lineStyle(1, 0x990000,10);
			velocityLine.graphics.moveTo(myBall.x,myBall.y);
			velocityLine.graphics.lineTo(myBall.x+Math.cos(velocityAngle)*100,myBall.y+Math.sin(velocityAngle)*100)
			orbitalCircle.graphics.drawEllipse(0,0,2*semimajorAxis/C.mapMpp, 2*semiminorAxis/C.mapMpp)
			orbitalCircle.x = -(semimajorAxis - myBall.eccentricity*semimajorAxis)/C.mapMpp
			orbitalCircle.y = -semiminorAxis/C.mapMpp
			rotateAt(orbitalCircle, focciAngle, 0,0);
			//trace("period:", Math.PI*2*Math.sqrt(Math.pow(semimajorAxis,3)/u))
			//trace("rVector:" ,derivedRVector)
			//trace("semimajorAxis:",semimajorAxis)
			
			
			
		}
		//This function does the work of putting the craft into a new orbit when you enter one in.
		private function processInput():void
		{

			mcGameStage.removeChild(orbitalLine);
			orbitalLine = new Shape
			mcGameStage.addChild(orbitalLine);
			orbitalLine.graphics.lineStyle(2, 0x990000,1);
			myBall.velocity = inputBoxes[1].text
			var differenceAngle = inputBoxes[0].text*(Math.PI/180)
			while(differenceAngle > Math.PI*2)
				{
					differenceAngle-=Math.PI*2
					trace(getTimer()-inGamePeriod)
					inGamePeriod = getTimer();
				}
				while(differenceAngle < 0)
				{
					differenceAngle+=Math.PI*2
				}
			
			myBall.x = inputBoxes [2].text/C.gameMpp;
			myBall.y = inputBoxes [3].text/C.gameMpp;
			orbitalLine.graphics.moveTo(myBall.x, myBall.y);
			angle=Math.atan2(myBall.y,myBall.x)
			myBall.energy=Math.pow(myBall.velocity,2)/2-u/myBall.rVector()
			
			myBall.angMom=myBall.velocity*myBall.rVector()*Math.sin(differenceAngle);
			myBall.eccentricity=Math.sqrt(1+(2*myBall.energy*Math.pow(myBall.angMom,2))/Math.pow(u,2))
			
			semimajorAxis=-u/(2*myBall.energy)
			semiminorAxis=semimajorAxis*Math.sqrt(1-Math.pow(myBall.eccentricity,2))
			trace(myBall.rVector()+2*myBall.eccentricity*semimajorAxis)
			trace(2*semimajorAxis-myBall.rVector())
			estimateFocciAngle=(Math.pow(2*myBall.eccentricity*semimajorAxis,2)+Math.pow(myBall.rVector(),2)-Math.pow(2*semimajorAxis-myBall.rVector(),2))/(2*2*myBall.eccentricity*semimajorAxis*myBall.rVector())
			trace("estimate focci angle",estimateFocciAngle)
			if(estimateFocciAngle>1)estimateFocciAngle = 1;
			if(estimateFocciAngle<-1)estimateFocciAngle =- 1;
			if((differenceAngle > 0 && differenceAngle <= Math.PI/2) || (differenceAngle > Math.PI && differenceAngle <= Math.PI*3/2) )
			{
				focciAngle = angle + Math.acos(estimateFocciAngle)
			}
			else focciAngle = angle - Math.acos(estimateFocciAngle);
			periapsisAngle = focciAngle + Math.PI
		}
		// Input handing functions to follow, pretty boring stuff. 
		private function keyUpHandler(evt:KeyboardEvent):void
		{
							
			switch(evt.keyCode)
			{
				case 65:
					aKeyPressed = false
					
					//a
					break;
				case 68:
					dKeyPressed = false
					
					//d
					break;
				case 16:
					shiftKeyPressed=false
					//Shift key
					break;
				case 17:
					controlKeyPressed=false
					//Control key
					break;
				
			}
			
			
			
		}
		
		private function keyDownHandler(evt:KeyboardEvent):void
		{
							
			switch(evt.keyCode)
			{
				case 65:
					aKeyPressed = true
					//a
					break;
				case 68:
					dKeyPressed = true
					//d
					break;
				case 190:
					//period
					if(thrustLevel == 0)
					{
						timewarpFactor = timewarpFactor*10
					}
					
					break;
				case 188:
					//comma
					if(thrustLevel == 0)
					{
						timewarpFactor = timewarpFactor/10
					}
					break;
				case 32:
					if(gamePaused == false)
					{
						stage.removeEventListener(Event.ENTER_FRAME,update);
						gamePaused = true
					}
					else if(gamePaused == true)
					{
						stage.addEventListener(Event.ENTER_FRAME,update);
						gamePaused = false
					}
					//space key

					break;
				case 16:
					shiftKeyPressed=true
					//Shift key
					break;
				case 17:
					controlKeyPressed=true
					break;
				case 13:
					inputBoxNumber+=1;
					break;
				case 187:
					
					if(mapShowing == false)
					{
						gameScaleFactor *=1.2
						scaleAt(mcGameStage, gameScaleFactor,myBall.x,myBall.y)
						mcGameStage.x = 300 - myBall.x*gameScaleFactor
						mcGameStage.y = 300 - myBall.y*gameScaleFactor
					}
					else if(mapShowing == true && mapScaleFactor < C.mapMinZoom)
					{
						mapScaleFactor *=1.2
						scaleAt(mcMapStage, mapScaleFactor,myMapCraft.x,myMapCraft.y)
						mcMapStage.x = 300 - myMapCraft.x*mapScaleFactor
						mcMapStage.y = 300 - myMapCraft.y*mapScaleFactor
						myMapCraft.width = 10/mapScaleFactor
						myMapCraft.height = 10/mapScaleFactor
						myPeriapsisMarker.width = 10/mapScaleFactor*C.markerScale
						myPeriapsisMarker.height = 10/mapScaleFactor*C.markerScale
						myApoapsisMarker.width = 10/mapScaleFactor*C.markerScale
						myApoapsisMarker.height = 10/mapScaleFactor*C.markerScale
					}
					
					//plus
					break;
				case 189:
					
					if(mapShowing == false)
					{
						gameScaleFactor /=1.2
						scaleAt(mcGameStage, gameScaleFactor,myBall.x,myBall.y)
						mcGameStage.x = 300 - myBall.x*gameScaleFactor
						mcGameStage.y = 300 - myBall.y*gameScaleFactor
					}
					else if(mapShowing == true && mapScaleFactor > C.mapMaxZoom)
					{
						mapScaleFactor /=1.2
						scaleAt(mcMapStage, mapScaleFactor,myMapCraft.x,myMapCraft.y)
						mcMapStage.x = 300 - myMapCraft.x*mapScaleFactor
						mcMapStage.y = 300 - myMapCraft.y*mapScaleFactor
						myMapCraft.width = 10/mapScaleFactor
						myMapCraft.height = 10/mapScaleFactor
						myPeriapsisMarker.width = 10/mapScaleFactor*C.markerScale
						myPeriapsisMarker.height = 10/mapScaleFactor*C.markerScale
						myApoapsisMarker.width = 10/mapScaleFactor*C.markerScale
						myApoapsisMarker.height = 10/mapScaleFactor*C.markerScale
					}
					
					
					//scaleAt(gameScaleFactor,myBall.xgameScaleFactor,myBall.y/gameScaleFactor)
					
					
					
					//minus
					break;
		
				case 77:
					if(mapShowing == true)
					{
						mcGameStage.alpha = 1
						mcMapStage.alpha = 0
						mapShowing = false
					}
					else if(mapShowing == false)
					{
						
						mcGameStage.alpha = 0
						mcMapStage.alpha = 1
						mapShowing = true
					}
					//m
					break;
					//up
					mcGameStage.y+=50
					break;
				case 65:
					//left
					mcGameStage.x+=50
					break;
				case 68:
					//right
					mcGameStage.x-=50
					break;
				case 83:
					//down
					mcGameStage.y-=50
					break;
				
				
					
			}
			
			
			
		}
		// Transformations used to scale and rotate objects at a point  other than thier registration point
		//I just copy pasted it, it's basically just magic. 

        public function scaleAt( givenObject, scale : Number, originX : Number, originY : Number ) : void
        {
            // get the transformation matrix of this object
            var affineTransform:Matrix = new Matrix();


            // move the object to (0/0) relative to the origin
            affineTransform.translate( -originX, -originY )

            // scale
            affineTransform.scale( scale, scale )

            // move the object back to its original position
            affineTransform.translate( originX, originY )


            // apply the new transformation to the object
            givenObject.transform.matrix = affineTransform;
        }
				public function rotateAt(givenObject, givenRotation : Number, originX : Number, originY : Number) : void
        {
            // get the transformation matrix of this object
            var affineTransform : Matrix = givenObject.transform.matrix
			//var affineTransform : Matrix = new Matrix();
			



            // move the object to (0/0) relative to the origin
            affineTransform.translate( -originX, -originY )

            // rotate
            affineTransform.rotate(givenRotation) 

            // move the object back to its original position
            affineTransform.translate( originX, originY )


            // apply the new transformation to the object
            givenObject.transform.matrix = affineTransform;
        }

	}
}