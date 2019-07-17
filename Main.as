package  {
	
	import flash.display.*;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.KeyboardEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	
	public class Main extends MovieClip {
		
		var player:Rifle = new Rifle();
		var Bullets:Array = new Array();
		var Enemies:Array = new Array();
		var AddEnemyTimer:Timer = new Timer(1700);
		var score:int = 0;
		var Lives:int = 3;
		var CurrentLevel:int = 1;
		var resetUI:Boolean = false;
		
		
		var reallyBackground; /////////////////////////////
		var maskobject; /////////////////////////////
		
		//sound 
		var gunfire:Sound = new GunFireSound();
		var shipexplode:Sound = new ShipExplodeSound();
		var bgroundm:Sound = new BGroundMSound();
		var sfxChannel:SoundChannel = new SoundChannel();
		var sfxChannel2:SoundChannel = new SoundChannel();
		var sfxChannel3:SoundChannel = new SoundChannel();
			
		
		//monitors
		var gameoverscreen:GameOverScreen = new GameOverScreen();
		var nextscreen:NextLevelScreen = new NextLevelScreen();
		var startscreen:StartScreen = new StartScreen();
		var winscreen:WinScreen = new WinScreen();
		var CurrentScreen:MovieClip;
		
		//quizscreens
		var quizscreen1:quizScreen1 = new quizScreen1();
		var quizscreen2:quizScreen2 = new quizScreen2();
		
		public function Main() {
			startscreen.x = stage.stageWidth * .5;
			startscreen.y = stage.stageHeight * .5;
			addChild(startscreen);
			CurrentScreen = startscreen;
			sfxChannel3 = bgroundm.play();		
			
			startscreen.start_btn.addEventListener(MouseEvent.CLICK, startButtonClicked);
			gameoverscreen.start_btn.addEventListener(MouseEvent.CLICK, startButtonClicked);
			winscreen.start_btn.addEventListener(MouseEvent.CLICK, startButtonClicked);
			nextscreen.start_btn.addEventListener(MouseEvent.CLICK, startButtonClicked);
			quizscreen1.quiz_btn12.addEventListener(MouseEvent.CLICK, quizButtonClicked1); // correct
			quizscreen1.quiz_btn11.addEventListener(MouseEvent.CLICK, quizButtonClicked2); // incorrect
			quizscreen1.quiz_btn13.addEventListener(MouseEvent.CLICK, quizButtonClicked2); // incorrect
			quizscreen1.quiz_btn14.addEventListener(MouseEvent.CLICK, quizButtonClicked2); // incorrect
			quizscreen2.quiz_btn23.addEventListener(MouseEvent.CLICK, quizButtonClicked3); // correct
			quizscreen2.quiz_btn21.addEventListener(MouseEvent.CLICK, quizButtonClicked4); // incorrect
			quizscreen2.quiz_btn22.addEventListener(MouseEvent.CLICK, quizButtonClicked4); // incorrect
			quizscreen2.quiz_btn24.addEventListener(MouseEvent.CLICK, quizButtonClicked4); // incorrect
		}
		
		public function startButtonClicked (e:MouseEvent){
			
			stage.focus = stage;

			removeChild(CurrentScreen);
			startGame();
			
		}
		
		public function quizButtonClicked1 (e:MouseEvent){
			
			stage.focus = stage;

			removeChild(CurrentScreen);
			goToNextLevelScreen();
			trace("Correct!")
		}
		
		public function quizButtonClicked2 (e:MouseEvent){
			
			stage.focus = stage;

			removeChild(CurrentScreen);
			CurrentLevel = 1
			startGame();
			trace("Incorrect!")
		}
		
		public function quizButtonClicked3 (e:MouseEvent){
			
			stage.focus = stage;

			removeChild(CurrentScreen);
			goToWinScreen();
			trace("Correct!")
		}
		
		public function quizButtonClicked4 (e:MouseEvent){
			
			stage.focus = stage;

			removeChild(CurrentScreen);
			CurrentLevel = 2
			startGame();
			trace("Incorrect!")
		}
		
		public function startGame() {
			
			addPlayer();
			stage.addEventListener(Event.ENTER_FRAME, mainLoop);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			AddEnemyTimer.addEventListener(TimerEvent.TIMER, addEnemy);
			AddEnemyTimer.start();
			updateUI();
			
			reallyBackground = new realBackground(); 
			addChildAt(reallyBackground,1); 
			
			maskobject = new MovieClip(); 
			reallyBackground.mask = maskobject; 
			reallyBackground.gotoAndStop(1);
			
			
			
		}
		
		public function addPlayer():void {
			
			player.x = 60; 
			player.y = stage.stageHeight * .5;
			player.rotation = 15;
			addChild(player);
		}
		
		public function addEnemy (event:TimerEvent):void {
			/*
			var monster:Enemy = new Enemy();
			monster.x = stage.stageWidth + 50;
			monster.y = Math.floor(Math.random() * (530 - 30) + 30);
			addChild(monster);
			Enemies.push(monster);
			*/
			if (CurrentLevel == 1) {
				var monster:Enemy = new Enemy();
				monster.x = stage.stageWidth + 50;
				monster.y = Math.floor(Math.random() * (530 - 30) + 30);
				addChild(monster);
				Enemies.push(monster);
				
			} else {
				reallyBackground.gotoAndStop(2);
				var monstertwo:EnemyTwo = new EnemyTwo();
				monstertwo.x = stage.stageWidth + 100;
				monstertwo.y = Math.floor(Math.random() * (500 - 175) + 175);
				addChild(monstertwo);
				Enemies.push(monstertwo);
				
			}
		}
		
		function keyDownHandler (keyEvent:KeyboardEvent):void {
			
			if(keyEvent.keyCode == 39) {
				shootBullet();
			} else if (keyEvent.keyCode == 38 && player.y > 40) {
				player.y -= 15;
			} else if (keyEvent.keyCode == 40 && player.y < stage.stageHeight - 40) {
				player.y += 15;
			}
 			
		}
		
		public function shootBullet ():void {
			
			var bullet:Bullet = new Bullet();
			bullet.x = player.x + 55;
			bullet.y = player.y - 70;
			addChild(bullet);
			Bullets.push(bullet);
			
			sfxChannel = gunfire.play();
			
		}
		
		public function mainLoop (event:Event):void {
			
			moveBullets();
			moveEnemies();
			checkCollisions();
			checkLives();
			checkScore();
			

			
		}
		
		public function moveBullets():void {
			
			for (var b:int = 0; b < Bullets.length; b++) {
				
				Bullets[b].x += 6;
				
				//if bullets moved off screen
				if (Bullets[b].x > stage.stageWidth) {
					
					removeChild(Bullets[b]);
					Bullets[b] = null;
					Bullets.splice(b,1);
					//trace("REMOVE OFF SCREEN BULLET");
				}
		
			}
			
		}
		
		public function moveEnemies():void {
			
			for (var e:int = 0; e < Enemies.length; e++) {
				
				//Enemies[e].x -= 3;
				if (CurrentLevel == 1) {
					Enemies[e].x -= 3;
				} else {
					Enemies[e].x -= 3;
					Enemies[e].y = Enemies[e].y + Math.floor(Math.random() * (18 - -18) + -18);
				}
				
				//if enemies moved off screen
				if (Enemies[e].x < 0) {
					
					removeChild(Enemies[e]);
					Enemies[e] = null;
					Enemies.splice(e,1);
					//trace("REMOVE OFF SCREEN ENEMY");
					
					if (Lives > 0) {
						Lives -= 1;
						updateUI();
					}
				
				}
				
			}
		}
		public function checkCollisions():void {
			
			for (var b = Bullets.length - 1; b >= 0; b--) {
				for (var e = Enemies.length - 1; e >= 0; e--) {
					
					if(Bullets[b].hitTestObject(Enemies[e])) {
						
						removeChild(Bullets[b]);
						//Enemies[e].gotoAndPlay(2); /////////////////////////////
						Bullets[b] = null;
						//Enemies[e] = null; /////////////////////////////
						Bullets.splice(b,1);
						maskobject.addChild(Enemies[e]);
						Enemies.splice(e,1);

						score += 10;
						updateUI();		
						
						sfxChannel2 = shipexplode.play();
						break;
					}
					
					
				}
			}
			
			
			
		}
			
		
		
		
		public function checkLives():void {
			if (Lives == 0) {
				cleanUp();
				goToGameOverScreen();
			}
		}
		
		public function cleanUp ():void {
			
			//trace("Bullets.length = " + Bullets.length);
			//trace("Enemies.length = " + Enemies.length);
			
			stage.removeEventListener(Event.ENTER_FRAME, mainLoop);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			AddEnemyTimer.stop();
			AddEnemyTimer.removeEventListener(TimerEvent.TIMER, addEnemy);
			
			
			removeChild(player);
			resetUI = true;

			for (var b = Bullets.length - 1; b >= 0; b--) {
				
				removeChild(Bullets[b]);
				Bullets[b] = null;
				Bullets.splice(b,1);
				
			}
			
			for (var e = Enemies.length - 1; e >= 0; e--) {
				
				removeChild(Enemies[e]);
				Enemies[e].stop();
				Enemies[e] = null;
				Enemies.splice(e,1);
				
			}
			
			//trace("Bullets.length = " + Bullets.length);
			//trace("Enemies.length = " + Enemies.length);
		}
		
		public function checkScore():void {
			
			if (score >= 100) {
				cleanUp();
				
				if (CurrentLevel == 1) {
					CurrentLevel = 2;
					goToquizScreen1();
					//goToNextLevelScreen();
				} else {
					CurrentLevel = 1;
					goToquizScreen2();	
				}
			}
		}
		
		
		public function goToStartScreen():void {
			while (maskobject.numChildren > 0){
				maskobject.removeChildAt(0)
			}
		}
		
		public function goToNextLevelScreen():void {
			while (maskobject.numChildren > 0){
				maskobject.removeChildAt(0)
			}
					
			reallyBackground.gotoAndStop(2);
			
			nextscreen.x = stage.stageWidth * .5;
			nextscreen.y = stage.stageHeight * .5;
			addChild(nextscreen);
			CurrentScreen = nextscreen;
			
		}
		
		public function goToWinScreen():void {
			while (maskobject.numChildren > 0){
				maskobject.removeChildAt(0)
			}
			winscreen.x = stage.stageWidth * .5;
			winscreen.y = stage.stageHeight * .5;
			addChild(winscreen);
			CurrentScreen = winscreen;
			
		}
		
		public function goToGameOverScreen():void {
			while (maskobject.numChildren > 0){
				maskobject.removeChildAt(0)
			}
			gameoverscreen.x = stage.stageWidth * .5;
			gameoverscreen.y = stage.stageWidth * .5;
			addChild(gameoverscreen);
			CurrentScreen = gameoverscreen;
			
		}
		
		public function goToquizScreen1():void {
			while (maskobject.numChildren > 0){
				maskobject.removeChildAt(0)
			}
			quizscreen1.x = stage.stageWidth * .5;
			//quizscreen1.y = stage.stageWidth * .5;
			addChild(quizscreen1);
			CurrentScreen = quizscreen1;
			
			
		}
		
		public function goToquizScreen2():void {
			while (maskobject.numChildren > 0){
				maskobject.removeChildAt(0)
			}
			quizscreen2.x = stage.stageWidth * .5;
			//quizscreen1.y = stage.stageWidth * .5;
			addChild(quizscreen2);
			CurrentScreen = quizscreen2;
			
			
		}
		
		
		public function updateUI():void {
			
			if (resetUI == true)  {
				score = 0;
				Lives = 3;
				resetUI = false;
				
			}
				
			
			ScoreBox.text = String(score);
			LivesBox.text = String(Lives);
			LevelBox.text = String(CurrentLevel);
		}
			
	}

}