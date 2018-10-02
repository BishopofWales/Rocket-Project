//Hybrid system, use kinematics for when no forces are acting
//Idea for jitter, if the acutal x y distance increased, just use the same position
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
		private var zoomFactor:Number = C.zoomDefault

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
		private var controlKeyPressed:Boolean
		private var thrustAngle:Number = .05
		private var rightBracketPressed:Boolean
		private var leftBracketPressed:Boolean
		private var inGamePeriod:Number
		private var affineTransform:Matrix
		private var scaleFactor:Number = 1
		private var planetCircle:Shape
		
		public function startGame()
		{
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			planetCircle = new Shape;
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
			myBall.x=-(.03+637.1)*10000/C.mpp*zoomFactor
			
			//myBall.x=(1/Math.SQRT2)*(.03+637.1)
			//myBall.y=(1/Math.SQRT2)*(.03+637.1)
			
			//35,786km geostationary orbit
			//3.07km/s geostationary orbital velocity
			mcGameStage.addChild(myBall)
			mcGameStage.addChild(orbitalLine)
			mcGameStage.addChild(myPlanet)
			mcGameStage.addChild(orbitalCircle)
			mcGameStage.addChild(emptyFocci)
			mcGameStage.addChild(planetCircle)
			orbitalLine.graphics.moveTo(myBall.x, myBall.y);
			mcGameStage.addChild(testPoint);
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
			/*
			trace("initial angle:",angle)
			trace("orbital energy:",myBall.energy)
			trace("myBall.eccentricity:",myBall.eccentricity)
			
			trace("focci angle:",focciAngle)
			trace("semimajor Axis:",semimajorAxis)
			trace("semiminor Axis:",semiminorAxis)
			trace("Actual rVector:",myBall.rVector())
			trace("Derived rVector:",derivedRVector)
			*/
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
				newTextField.restrict = "0-9";
				
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
			inputBoxes[1].text = 10
			inputBoxes[2].text = 6371 //+.3
			inputBoxes[3].text = 0
			inputBoxes[4].text = timewarpFactor
			
			textBoxes[0].text = "Semimajor axis:"
			textBoxes[1].text = "Semiminor axis:"
			textBoxes[2].text = "Orbital energy:"
			textBoxes[3].text = "Focci Angle:"
			textBoxes[4].text = "Velocity:"
			textBoxes[5].text = "Thurst Angle:"
			textBoxes[6].text = "R Vector:"
			
			dynamicTextBoxes[0].text = semimajorAxis
			dynamicTextBoxes[1].text = semiminorAxis
			dynamicTextBoxes[2].text = myBall.energy
			dynamicTextBoxes[3].text = focciAngle*(180/Math.PI);
			dynamicTextBoxes[4].text = myBall.velocity
			dynamicTextBoxes[5].text = thrustAngle
			dynamicTextBoxes[6].text = myBall.rVector()
			velocityLine = new Shape;
			rVectorLine = new Shape;
			mcGameStage.addChild(velocityLine);
			mcGameStage.addChild(rVectorLine);
			emptyFocciLine = new Shape;
			mcGameStage.addChild(emptyFocciLine);
			mcGameStage.addEventListener(Event.ENTER_FRAME,update);
			testPoint.x = 300
			testPoint.y = 150
			
			orbitalCircle.graphics.lineStyle(200, 0x50000,1);
			orbitalCircle.graphics.drawCircle(0,0, 6371*1000/C.mpp);
			
			//trace("period:", Math.PI*2*Math.sqrt(Math.pow(semimajorAxis,3)/u))
			
		}
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
		private function update(evt:Event)
		{
			
			
			if(angle == 0) inGamePeriod = getTimer();
			if(myBall.rVector() < 3000000) mcGameStage.removeEventListener(Event.ENTER_FRAME,update);
			
			
			if(inputBoxNumber < C.numberOfInputBoxes)stage.focus = inputBoxes[inputBoxNumber];
			else
			{
				processInput();
				inputBoxNumber = 0
			}
			
			myBall.velocity = Math.sqrt(u*(2/derivedRVector-1/semimajorAxis))
			//
			
			
			//trace("sin:", Math.sin(rVectorAngle-testAngle))
			angle+=(myBall.angMom/Math.pow(derivedRVector,2))*3*timewarpFactor/119.97923//*Math.sin(rVectorAngle-testAngle);;
			
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
			
			
			
			derivedRVector=semimajorAxis*2-(-Math.pow(2*myBall.eccentricity*semimajorAxis,2)-Math.pow(2*semimajorAxis,2)+2*2*myBall.eccentricity*semimajorAxis*Math.cos(focciAngle+angle)*semimajorAxis*2)/(2*(semimajorAxis*2*myBall.eccentricity*Math.cos(focciAngle+angle)-2*semimajorAxis));	
			trace("derviedRvector:", derivedRVector)
			myBall.x=Math.cos(angle)*derivedRVector/C.mpp;
			myBall.y=Math.sin(angle)*derivedRVector/C.mpp;
			
			mcGameStage.x = 300 - myBall.x*scaleFactor
			mcGameStage.y = 300 - myBall.y*scaleFactor
			orbitalLine.graphics.lineTo(myBall.x, myBall.y);
			//mcGameStage.x = -myBall.x*scaleFactor + 300
			//mcGameStage.y = -myBall.y*scaleFactor + 300
			trace("true rVector:", myBall.rVector())
			myBall.velocity = Math.sqrt(u*(2/derivedRVector-1/semimajorAxis))
			//emptyFocciAngle = Math.atan2(myBall.y-Math.cos(focciAngle+Math.PI/2)*2*myBall.eccentricity*semimajorAxis/C.mpp*zoomFactor, myBall.x-Math.sin(focciAngle+Math.PI/2)*2*myBall.eccentricity*semimajorAxis/C.mpp*zoomFactor) + Math.PI
			emptyFocciAngle = Math.atan2(Math.sin(angle)*derivedRVector/C.mpp*zoomFactor-Math.cos(focciAngle+Math.PI/2)*2*myBall.eccentricity*semimajorAxis/C.mpp*zoomFactor,Math.cos(angle)*derivedRVector/C.mpp*zoomFactor-Math.sin(focciAngle+Math.PI/2)*2*myBall.eccentricity*semimajorAxis/C.mpp*zoomFactor) + Math.PI

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
			
			if(mustRecalculate == true || shiftKeyPressed == true||controlKeyPressed == true)
			{
				
				if(shiftKeyPressed ==true) myBall.velocity = vectorAddMag(myBall.velocity,testAngle,200,thrustAngle);
				if(shiftKeyPressed == true) testAngle = vectorAddAngle(myBall.velocity,testAngle,10,thrustAngle);
				if(controlKeyPressed == true) myBall.velocity -= 10;
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
			
			
			//trace("angle:",angle*(180/Math.PI))
			//trace("angmom:",myBall.angMom)
			//trace("focciAngle:" , focciAngle*(180/Math.PI))
			//Drawing bull goes here:
			dynamicTextBoxes[4].text = myBall.velocity
			inputBoxes[4].text = timewarpFactor
			dynamicTextBoxes[5].text = thrustAngle*(180/Math.PI)
			dynamicTextBoxes[6].text = derivedRVector//myBall.rVector()
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
			rVectorLine.graphics.lineStyle(1, 0x30000,7);
			rVectorLine.graphics.moveTo(myBall.x,myBall.y);
			rVectorLine.graphics.lineTo(myBall.x+Math.cos(rVectorAngle)*100,myBall.y+Math.sin(rVectorAngle)*100)
			emptyFocciLine.graphics.lineStyle(1, 0x31000,7);
			emptyFocciLine.graphics.moveTo(myBall.x,myBall.y);
			emptyFocciLine.graphics.lineTo(myBall.x+Math.cos(emptyFocciAngle)*100,myBall.y+Math.sin(emptyFocciAngle)*100)
			velocityLine.graphics.lineStyle(1, 0x990000,10);
			velocityLine.graphics.moveTo(myBall.x,myBall.y);
			velocityLine.graphics.lineTo(myBall.x+Math.cos(testAngle)*100,myBall.y+Math.sin(testAngle)*100)
			orbitalCircle.graphics.drawEllipse(0,0,2*semimajorAxis/C.mpp*zoomFactor, 2*semiminorAxis/C.mpp*zoomFactor)
			emptyFocci.x=Math.cos(focciAngle)*2*myBall.eccentricity*semimajorAxis/C.mpp*zoomFactor
			emptyFocci.y=Math.sin(-focciAngle)*2*myBall.eccentricity*semimajorAxis/C.mpp*zoomFactor
			orbitalCircle.x=500
			//trace("angmom:", myBall.angMom);
			//trace("gravity:", u/Math.pow(myBall.rVector(),2))
			//trace("period:", Math.PI*2*Math.sqrt(Math.pow(semimajorAxis,3)/u))
			//trace("rVector:" ,derivedRVector)
			//trace("semimajorAxis:",semimajorAxis)
			if(leftBracketPressed == true) thrustAngle -= .01
			if(rightBracketPressed == true) thrustAngle += .01
			
			
		}
		private function processInput():void
		{
			mcGameStage.removeChild(orbitalLine);
			orbitalLine = new Shape
			mcGameStage.addChild(orbitalLine);
			orbitalLine.graphics.lineStyle(2, 0x990000,1);
			myBall.velocity = inputBoxes[1].text
			myBall.x = inputBoxes [2].text/10*10000/C.mpp*zoomFactor;
			myBall.y = inputBoxes [3].text*10000/C.mpp*zoomFactor;
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
				case 16:
					shiftKeyPressed=false
					//Shift key
				break;
				case 17:
					controlKeyPressed=false
					//Control key
				break;
				case 219:
				
					//leftbracket
					leftBracketPressed = false
					break;
				case 221:
					//rightbracket
					rightBracketPressed = false
					break;
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
				case 17:
					controlKeyPressed=true
					break;
				case 13:
					inputBoxNumber+=1;
					break;
				case 187:
					/*
					if(scaleFactor < Math.pow(1.2,3))
					{
						
						mcGameStage.width *= 1.2
						mcGameStage.height *= 1.2
					}
					*/
					/*
					scaleFactor *=1.2
					scaleAt(scaleFactor,300,150)
					mcGameStage.x = 300 - 300*scaleFactor
					mcGameStage.y = 300 - 150*scaleFactor
					*/
					scaleFactor *=1.2
					scaleAt(scaleFactor,myBall.x,myBall.y)
					mcGameStage.x = 300 - myBall.x*scaleFactor
					mcGameStage.y = 300 - myBall.y*scaleFactor
					
					//scaleAt(scaleFactor,myBall.x*scaleFactor,myBall.y*scaleFactor)
					//plus
					break;
				case 189:
					/*
					if(scaleFactor > Math.pow(1.2,-3))
					{
						
						mcGameStage.width /= 1.2
						mcGameStage.height /= 1.2
					}
					*/
					/*
					scaleFactor /=1.2
					scaleAt(scaleFactor,300,150)
					mcGameStage.x = 300 - 300*scaleFactor
					mcGameStage.y = 300 - 150*scaleFactor
					*/
					
					scaleFactor /=1.2
					scaleAt(scaleFactor,myBall.x,myBall.y)
					mcGameStage.x = 300 - myBall.x*scaleFactor
					mcGameStage.y = 300 - myBall.y*scaleFactor
					
					//scaleAt(scaleFactor,myBall.xscaleFactor,myBall.y/scaleFactor)
					
					
					
					//minus
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
				case 219:
					//leftbracket
					leftBracketPressed = true
					break;
				case 221:
					//rightbracket
					rightBracketPressed = true
					break;
				
					
			}
			
			
			
		}
		// Transformations
        public function scaleAt( scale : Number, originX : Number, originY : Number ) : void
        {
            // get the transformation matrix of this object
            affineTransform = new Matrix()


            // move the object to (0/0) relative to the origin
            affineTransform.translate( -originX, -originY )

            // scale
            affineTransform.scale( scale, scale )

            // move the object back to its original position
            affineTransform.translate( originX, originY )


            // apply the new transformation to the object
            mcGameStage.transform.matrix = affineTransform;
        }

	}
}