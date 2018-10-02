
//Ask yourself, can estimateFocciAngle truly be trusted?
//Maybe this house is built on pillars of sand.
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
		private var myBall:Ball
		private var orbitalLine:Shape
		private var myPlanet:Planet
		private var thrusting:Boolean=false;

		private var semimajorAxis:Number
		private var semiminorAxis:Number
		private var angle:Number
		private var u=C.g*(5.972*Math.pow(10,24))
		private var focciAngle:Number
		private var derivedRVector:Number
		private var estimateFocciAngle:Number
		private var shiftKeyPressed:Boolean;
		private var orbitalCircle:Shape
		private var emptyFocciAngle:Number
		private var solution:Number
		private var textBoxes:Array
		private var dynamicTextBoxes:Array
		private var inputBoxLables:Array;
		private var inputBoxes:Array
		private var inputBoxNumber:Number = 0
		private var timewarpFactor:Number = 1
		
		
		public function startGame()
		{
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			orbitalCircle=new Shape;
			inputBoxLables = new Array;
			inputBoxes = new Array;
			orbitalLine=new Shape;
			textBoxes = new Array;
			dynamicTextBoxes = new Array;
			myPlanet=new Planet
			myPlanet.mass=5.972*Math.pow(10,24)
			orbitalLine.graphics.lineStyle(2, 0x990000,1);
			myBall=new Ball
			myBall.mass=1000
			
			myBall.velocity=7900
			//myBall.x=-(.03+637.1)
			
			myBall.x=.03+637.1
			myBall.y=0
			//35,786km geostationary orbit
			//3.07km/s geostationary orbital velocity
			mcGameStage.addChild(myBall)
			mcGameStage.addChild(orbitalLine)
			mcGameStage.addChild(myPlanet)
			mcGameStage.addChild(orbitalCircle)
			mcGameStage.addChild(emptyFocci)
			orbitalLine.graphics.moveTo(myBall.x, myBall.y);
			
			myBall.energy=Math.pow(myBall.velocity,2)/2-u/myBall.rVector()
			myBall.angMom=myBall.velocity*myBall.rVector()*Math.sin(Math.PI/2);
			myBall.eccentricity=Math.sqrt(1+(2*myBall.energy*Math.pow(myBall.angMom,2))/Math.pow(u,2))
			
			semimajorAxis=-u/(2*myBall.energy)
			semiminorAxis=semimajorAxis*Math.sqrt(1-Math.pow(myBall.eccentricity,2))
			trace(myBall.rVector()+2*myBall.eccentricity*semimajorAxis)
			trace(2*semimajorAxis-myBall.rVector())
			angle=Math.atan2(myBall.y,myBall.x)
			estimateFocciAngle=(Math.pow(2*myBall.eccentricity*semimajorAxis,2)+Math.pow(myBall.rVector(),2)-Math.pow(2*semimajorAxis-myBall.rVector(),2))/(2*2*myBall.eccentricity*semimajorAxis*myBall.rVector())
			trace("estimate focci angle",estimateFocciAngle)
			if(estimateFocciAngle>1)estimateFocciAngle=1;
			if(estimateFocciAngle<-1)estimateFocciAngle=-1;
			focciAngle=Math.acos(estimateFocciAngle)-angle
			
			derivedRVector=semimajorAxis*2-(-Math.pow(2*myBall.eccentricity*semimajorAxis,2)-Math.pow(2*semimajorAxis,2)+2*2*myBall.eccentricity*semimajorAxis*Math.cos(focciAngle+angle)*semimajorAxis*2)/(2*(semimajorAxis*2*myBall.eccentricity*Math.cos(focciAngle+angle)-2*semimajorAxis))
			trace("initial angle:",angle)
			trace("orbital energy:",myBall.energy)
			trace("myBall.eccentricity:",myBall.eccentricity)
			
			trace("focci angle:",focciAngle)
			trace("semimajor Axis:",semimajorAxis)
			trace("semiminor Axis:",semiminorAxis)
			trace("Actual rVector:",myBall.rVector())
			trace("Derived rVector:",derivedRVector)
			
			for(var l:int=0;l<C.numberOfTextBoxes;l++)
			{
				var newTextField:TextField=new TextField
				
				newTextField.text="hello";
				newTextField.y=l*20;
				addChild(newTextField);
				textBoxes.push(newTextField);
			}
			for(var l:int=0;l<C.numberOfTextBoxes;l++)
			{
				var newTextField:TextField=new TextField
				newTextField.x = 90
				newTextField.text="hello";
				newTextField.y=l*20;
				newTextField.width=1000
				addChild(newTextField);
				dynamicTextBoxes.push(newTextField);
			}
			for(var l:int=0;l<C.numberOfInputBoxes;l++)
			{
				var newTextField:TextField=new TextField();
				addChild(newTextField);
				newTextField.x = 360
				newTextField.y=l*20;
				newTextField.text="hello";
				newTextField.width = 10000
				newTextField.type=TextFieldType.INPUT; 
				newTextField.restrict = "0-9"
				
				inputBoxes.push(newTextField);
			}
			for(var l:int=0;l<C.numberOfInputBoxes;l++)
			{
				var newTextField:TextField=new TextField
				newTextField.x = 250
				newTextField.text="hello";
				newTextField.y=l*20;
				newTextField.width=1000
				addChild(newTextField);
				inputBoxLables.push(newTextField);
			}
			inputBoxLables[0].text = "Direction(degrees):"
			inputBoxLables[1].text = "Velocity (m/s):"
			inputBoxLables[2].text = "X position(km):"
			inputBoxLables[3].text = "Y position(km):"
			inputBoxLables[4].text = "Timewarp factor:"

			inputBoxes[0].text = 90
			inputBoxes[1].text = 7900
			inputBoxes[2].text = .3+6371
			inputBoxes[3].text = 0
			inputBoxes[4].text = timewarpFactor
			
			textBoxes[0].text = "Semimajor axis:"
			textBoxes[1].text = "Semiminor axis:"
			textBoxes[2].text = "Orbital energy:"
			textBoxes[3].text = "Focci Angle:"
			textBoxes[4].text = "Velocity:"
			
			dynamicTextBoxes[0].text = semimajorAxis
			dynamicTextBoxes[1].text = semiminorAxis
			dynamicTextBoxes[2].text = myBall.energy
			dynamicTextBoxes[3].text = focciAngle*(180/Math.PI);
			dynamicTextBoxes[4].text = myBall.velocity
			mcGameStage.addEventListener(Event.ENTER_FRAME,update);
			
		}
		private function update(evt:Event)
		{
			if(inputBoxNumber < C.numberOfInputBoxes)stage.focus = inputBoxes[inputBoxNumber];
			else
			{
				processInput();
				inputBoxNumber = 0
			}
			
			
			
			
			
			
			myBall.velocity = Math.sqrt(u*(2/myBall.rVector()-1/semimajorAxis))
			orbitalLine.graphics.lineTo(myBall.x, myBall.y);
			angle+=(myBall.velocity/derivedRVector)*3*timewarpFactor
			dynamicTextBoxes[4].text = myBall.velocity
			mcGameStage.removeChild(orbitalCircle)
			orbitalCircle=new Shape
			mcGameStage.addChild(orbitalCircle);
			orbitalCircle.graphics.lineStyle(2, 0x50000,1);
			myBall.x=Math.cos(angle)*derivedRVector/C.kmpp;
			myBall.y=Math.sin(angle)*derivedRVector/C.kmpp;
			orbitalCircle.graphics.drawEllipse(0,0,2*semimajorAxis/C.kmpp, 2*semiminorAxis/C.kmpp)
			orbitalCircle.x=500
			emptyFocci.x=Math.sin(focciAngle+Math.PI/2)*2*myBall.eccentricity*semimajorAxis/C.kmpp
			emptyFocci.y=Math.cos(focciAngle+Math.PI/2)*2*myBall.eccentricity*semimajorAxis/C.kmpp
			emptyFocciAngle = Math.atan2(myBall.y-Math.cos(focciAngle+Math.PI/2)*2*myBall.eccentricity*semimajorAxis/C.kmpp,myBall.x-Math.sin(focciAngle+Math.PI/2)*2*myBall.eccentricity*semimajorAxis/C.kmpp)
			
			inputBoxes[4].text = timewarpFactor
			derivedRVector=semimajorAxis*2-(-Math.pow(2*myBall.eccentricity*semimajorAxis,2)-Math.pow(2*semimajorAxis,2)+2*2*myBall.eccentricity*semimajorAxis*Math.cos(focciAngle+angle)*semimajorAxis*2)/(2*(semimajorAxis*2*myBall.eccentricity*Math.cos(focciAngle+angle)-2*semimajorAxis));		

			//trace("velocity angle",velocityAngle*(180/Math.PI))
			
			//orbitaldrawEllipse(x:Number, y:Number, 2*semimajorAxis/C.kmpp, 2*semiminorAxis):void
			//Recaculating stuff goes here
			
						
		}
		private function recalculate():void
		{
			myBall.energy=Math.pow(myBall.velocity,2)/2-u/myBall.rVector()
			//trace("solution:",solution*(180/Math.PI))
			myBall.angMom=myBall.velocity*myBall.rVector()*Math.sin(solution+Math.PI/2);/*add angle between rVector and velocity vector here*/
			myBall.eccentricity=Math.sqrt(1+(2*myBall.energy*Math.pow(myBall.angMom,2))/Math.pow(u,2))
			
			semimajorAxis=-u/(2*myBall.energy)
			semiminorAxis=semimajorAxis*Math.sqrt(1-Math.pow(myBall.eccentricity,2))
			trace(myBall.rVector()+2*myBall.eccentricity*semimajorAxis)
			trace(2*semimajorAxis-myBall.rVector())
			estimateFocciAngle=(Math.pow(2*myBall.eccentricity*semimajorAxis,2)+Math.pow(myBall.rVector(),2)-Math.pow(2*semimajorAxis-myBall.rVector(),2))/(2*2*myBall.eccentricity*semimajorAxis*myBall.rVector())
			trace("estimate focci angle",estimateFocciAngle)
			if(estimateFocciAngle>1)estimateFocciAngle=1;
			if(estimateFocciAngle<-1)estimateFocciAngle=-1;
			focciAngle=Math.acos(estimateFocciAngle)-angle
		}
		private function processInput():void
		{
			mcGameStage.removeChild(orbitalLine);
			orbitalLine = new Shape
			mcGameStage.addChild(orbitalLine);
			orbitalLine.graphics.lineStyle(2, 0x990000,1);
			
			myBall.velocity = inputBoxes[1].text
			myBall.x = inputBoxes [2].text/10;
			myBall.y = inputBoxes [3].text;
			orbitalLine.graphics.moveTo(myBall.x, myBall.y);
			angle=Math.atan2(myBall.y,myBall.x)
			myBall.energy=Math.pow(myBall.velocity,2)/2-u/myBall.rVector()
			//trace("solution:",solution*(180/Math.PI))
			myBall.angMom=myBall.velocity*myBall.rVector()*Math.sin(inputBoxes[0].text*(Math.PI/180));/*add angle between rVector and velocity vector here*/
			myBall.eccentricity=Math.sqrt(1+(2*myBall.energy*Math.pow(myBall.angMom,2))/Math.pow(u,2))
			
			semimajorAxis=-u/(2*myBall.energy)
			semiminorAxis=semimajorAxis*Math.sqrt(1-Math.pow(myBall.eccentricity,2))
			trace(myBall.rVector()+2*myBall.eccentricity*semimajorAxis)
			trace(2*semimajorAxis-myBall.rVector())
			estimateFocciAngle=(Math.pow(2*myBall.eccentricity*semimajorAxis,2)+Math.pow(myBall.rVector(),2)-Math.pow(2*semimajorAxis-myBall.rVector(),2))/(2*2*myBall.eccentricity*semimajorAxis*myBall.rVector())
			trace("estimate focci angle",estimateFocciAngle)
			if(estimateFocciAngle>1)estimateFocciAngle=1;
			if(estimateFocciAngle<-1)estimateFocciAngle=-1;
			focciAngle=Math.acos(estimateFocciAngle)-angle
			dynamicTextBoxes[0].text = semimajorAxis
			dynamicTextBoxes[1].text = semiminorAxis
			dynamicTextBoxes[2].text = myBall.energy
			dynamicTextBoxes[3].text = focciAngle*(180/Math.PI);
			dynamicTextBoxes[4].text = myBall.velocity
		}
		private function keyUpHandler(evt:KeyboardEvent):void
		{
							
			switch(evt.keyCode)
			{
				
				case 32:
				//space bar
					

					break;
				case 16:
					shiftKeyPressed=false
					//Shift key
					break;

					
			}
			
			
			
		}
		private function keyDownHandler(evt:KeyboardEvent):void
		{
							
			switch(evt.keyCode)
			{
				
				case 190:
					trace("period")
					timewarpFactor = timewarpFactor*10
					break;
				case 188:
					trace("comma");
					timewarpFactor = timewarpFactor/10
					break;
				case 32:
					recalculate();
					

					break;
				case 16:
					shiftKeyPressed=true
					//Shift key
					break;
				case 13:
					inputBoxNumber+=1;
					break;
				case 187:
					mcGameStage.width=mcGameStage.width*1.2
					mcGameStage.height=mcGameStage.height*1.2
					break;
				case 189:
					mcGameStage.width=mcGameStage.width/1.2
					mcGameStage.height=mcGameStage.height/1.2
					break;
				case 87:
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
	}
}