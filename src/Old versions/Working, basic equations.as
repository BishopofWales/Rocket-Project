
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
		private var mustRecalculate:Boolean = false
		private var myBall:Ball
		private var orbitalLine:Shape
		private var myPlanet:Planet

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
		private var testAngle:Number
		private var velocityLine:Shape
		private var rVectorLine:Shape
		private var rVectorAngle:Number
		private var emptyFocciLine:Shape;
		
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
			
			myBall.velocity=9000
			//myBall.x=-(.03+637.1)
			
			myBall.x=(1/Math.SQRT2)*(.03+637.1)
			myBall.y=(1/Math.SQRT2)*(.03+637.1)
			
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
			focciAngle = -Math.acos(estimateFocciAngle)-angle
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
			inputBoxes[1].text = myBall.velocity
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
			velocityLine = new Shape;
			rVectorLine = new Shape;
			mcGameStage.addChild(velocityLine);
			mcGameStage.addChild(rVectorLine);
			emptyFocciLine = new Shape;
			mcGameStage.addChild(emptyFocciLine);
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
			if(myBall.angMom>0) angle+=(myBall.velocity/derivedRVector)*3*timewarpFactor;
			if(myBall.angMom<0) angle-=(myBall.velocity/derivedRVector)*3*timewarpFactor;
			while(angle > Math.PI*2)
			{
				angle-=Math.PI*2
			}
			while(angle < 0)
			{
				angle+=Math.PI*2
			}
			//this makes sure that the angle stays within good values
			/*
			if(angle > Math.PI*2)
			{
				while(angle >Math.PI*2)
				{
					angle -= Math.PI*2
				}
			}
			//this is for when the angle is decreasing, not increasing
			if(angle < 0)
			{
				while(angle < 0)
				{
					angle += Math.PI*2
				}
			}
			*/
			
			dynamicTextBoxes[4].text = myBall.velocity
			
			derivedRVector=semimajorAxis*2-(-Math.pow(2*myBall.eccentricity*semimajorAxis,2)-Math.pow(2*semimajorAxis,2)+2*2*myBall.eccentricity*semimajorAxis*Math.cos(focciAngle+angle)*semimajorAxis*2)/(2*(semimajorAxis*2*myBall.eccentricity*Math.cos(focciAngle+angle)-2*semimajorAxis));		
			myBall.x=Math.cos(angle)*derivedRVector/C.kmpp;
			myBall.y=Math.sin(angle)*derivedRVector/C.kmpp;
			myBall.velocity = Math.sqrt(u*(2/myBall.rVector()-1/semimajorAxis))
			emptyFocciAngle = Math.atan2(myBall.y-Math.cos(focciAngle+Math.PI/2)*2*myBall.eccentricity*semimajorAxis/C.kmpp,myBall.x-Math.sin(focciAngle+Math.PI/2)*2*myBall.eccentricity*semimajorAxis/C.kmpp) + Math.PI
			rVectorAngle = angle + Math.PI
			//Making sure that rVectorAngle is always dispalyed so that a straight numerical comparison to yield the larger angle
			while(Math.abs(emptyFocciAngle - rVectorAngle) > Math.PI)
			{
				if(rVectorAngle > emptyFocciAngle) rVectorAngle -= Math.PI*2
				else if(emptyFocciAngle > rVectorAngle) rVectorAngle += Math.PI*2
			}
			
			testAngle = Math.abs(rVectorAngle-emptyFocciAngle);
			testAngle = (Math.PI-testAngle)/2
			if(rVectorAngle < emptyFocciAngle) testAngle = testAngle + emptyFocciAngle +Math.PI;
			if(rVectorAngle > emptyFocciAngle) testAngle = testAngle + rVectorAngle + Math.PI;
			if(myBall.angMom < 0) testAngle += Math.PI
			//if(myBall.angMom<0)testAngle = testAngle + Math.PI;
			//Recalc stuff
			
			if(mustRecalculate == true)
			{
				
				myBall.energy=Math.pow(myBall.velocity,2)/2-u/myBall.rVector()
				myBall.angMom=myBall.velocity*myBall.rVector()*Math.sin(rVectorAngle-testAngle);
				myBall.eccentricity=Math.sqrt(1+(2*myBall.energy*Math.pow(myBall.angMom,2))/Math.pow(u,2))
				
				semimajorAxis=-u/(2*myBall.energy)
				semiminorAxis=semimajorAxis*Math.sqrt(1-Math.pow(myBall.eccentricity,2))
				estimateFocciAngle=(Math.pow(2*myBall.eccentricity*semimajorAxis,2)+Math.pow(myBall.rVector(),2)-Math.pow(2*semimajorAxis-myBall.rVector(),2))/(2*2*myBall.eccentricity*semimajorAxis*myBall.rVector())
				trace(semimajorAxis);
				if(estimateFocciAngle>1)estimateFocciAngle=1;
				if(estimateFocciAngle<-1)estimateFocciAngle=-1;
				
				
				//it is unknown why, but you have to use the opposite focciAngle when theta is "above" the line drawn by the foccis.
				//this part of the fix makes the two angles close to eachother, so they can be compared by the computer
				while(Math.abs(-focciAngle -  angle) > Math.PI)
				{
					if( angle > -focciAngle) angle -= Math.PI*2
					else if(-focciAngle > rVectorAngle) angle += Math.PI*2
				}
				if(angle < -focciAngle && angle > -focciAngle -Math.PI)
				{
					trace("use normal")
					focciAngle = -Math.acos(estimateFocciAngle)-angle;
				}
				
				else if(angle < -focciAngle +Math.PI&& angle > -focciAngle)
				{
					trace("use inverse")
					focciAngle = -(-Math.acos(estimateFocciAngle)+angle);
				}
				else trace("error")
				// this ends the fix
				trace("recalculate now!");
				mustRecalculate = false;
			}			
			
			
			trace("angle:",angle*(180/Math.PI))
			//trace("focciAngle:" , focciAngle*(180/Math.PI))
			//Drawing bull goes here:
			
			inputBoxes[4].text = timewarpFactor
			mcGameStage.removeChild(orbitalCircle)
			orbitalCircle=new Shape
			mcGameStage.addChild(orbitalCircle);
			orbitalCircle.graphics.lineStyle(2, 0x50000,1);
			mcGameStage.removeChild(rVectorLine)
			mcGameStage.removeChild(velocityLine)
			mcGameStage.removeChild(emptyFocciLine)
			velocityLine = new Shape
			rVectorLine = new Shape
			emptyFocciLine = new Shape
			mcGameStage.addChild(velocityLine)
			
			mcGameStage.addChild(rVectorLine)
			mcGameStage.addChild(emptyFocciLine)
			rVectorLine.graphics.lineStyle(20, 0x30000,7);
			rVectorLine.graphics.moveTo(myBall.x,myBall.y);
			rVectorLine.graphics.lineTo(myBall.x+Math.cos(rVectorAngle)*100,myBall.y+Math.sin(rVectorAngle)*100)
			emptyFocciLine.graphics.lineStyle(20, 0x31000,7);
			emptyFocciLine.graphics.moveTo(myBall.x,myBall.y);
			emptyFocciLine.graphics.lineTo(myBall.x+Math.cos(emptyFocciAngle)*100,myBall.y+Math.sin(emptyFocciAngle)*100)
			velocityLine.graphics.lineStyle(20, 0x30000,10);
			velocityLine.graphics.moveTo(myBall.x,myBall.y);
			velocityLine.graphics.lineTo(myBall.x+Math.cos(testAngle)*100,myBall.y+Math.sin(testAngle)*100)
			orbitalCircle.graphics.drawEllipse(0,0,2*semimajorAxis/C.kmpp, 2*semiminorAxis/C.kmpp)
			
			emptyFocci.x=Math.cos(focciAngle)*2*myBall.eccentricity*semimajorAxis/C.kmpp
			emptyFocci.y=Math.sin(-focciAngle)*2*myBall.eccentricity*semimajorAxis/C.kmpp
			orbitalCircle.x=500
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
					
			}
			
			
			
		}
		private function keyDownHandler(evt:KeyboardEvent):void
		{
							
			switch(evt.keyCode)
			{
				
				case 190:
					//period
					timewarpFactor = timewarpFactor*10
					break;
				case 188:
					//comma
					timewarpFactor = timewarpFactor/10
					break;
				case 32:
					//space key
					 mustRecalculate = true
					

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