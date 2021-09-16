package {
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	import flash.display.StageDisplayState;

	public class Main extends MovieClip {

		var speed: Number = 10;
		var currSpeed: Number = 0;
		var increment: Number = speed / 10;

		var Model: Object = {
			turnsObj: {
				left: false,
				right: false,
				up: false,
				down: false
			}
		}
		var bgColor: uint = 0x000000;
		var explosionsArr: Array = [];
		var bdShip: BitmapData = new SpaceShipBD();

		var shipObj: AssetObj;

		var deadCount: int = 0;
		var movingDegrees: Array = [];
		var bullets: Array = [];


		var bdBigRock: BitmapData = new BigRock();
		var bdMedRock: BitmapData = new MedRock();
		var bdSmlRock: BitmapData = new SmallRock();
		var rockBds: Array = [bdBigRock, bdMedRock, bdSmlRock];

		var numAsteroids: int = 4;
		var asteroidsArr: Array = [];
		var shipArr: Array = [];
		var rockSizes: Array = [];
		var bigBd: BitmapData;
		var bmp: Bitmap;
		var rect: Rectangle;
		var starsArr: Array = [];



		public function Main() {
			// constructor code
			stage.scaleMode = "noScale";
			stage.align = "topLeft";
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			bigBd = new BitmapData(stage.stageWidth, stage.stageHeight, false);
			bmp = new Bitmap(bigBd);
			rect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);

			stage.addChild(bmp);

			createShip();
			createAsteroidSizes();
			resetGame();
			//return;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, myKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, myKeyUp);
			stage.addEventListener(Event.ENTER_FRAME, update);

		}

		function createStars(): void {
			starsArr = [];
			var numStars: int = 20 + Math.random() * 30;
			for (var i: int = 0; i < numStars; i++) {
				var starObj: Object = {
					x: stage.stageWidth * Math.random(),
					y: stage.stageHeight * Math.random(),
					speed: (Math.random() * 2) + 1,
					color: getColor()
				};
				starsArr.push(starObj);
			}
		}

		function getColor(): uint {
			var color: uint = Math.random() * 0xffffff;

			while (bgColor == color) {
				color = Math.random() * 0xffffff;
			}

			return color;
		}


		function resetGame() {

			//bgColor = Math.random() * 0xffffff;

			createStars();
			explosionsArr = [];
			movingDegrees = [];
			bullets = [];
			asteroidsArr = [];
			shipObj.dead = false;
			shipObj.x = stage.stageWidth / 2;
			shipObj.y = stage.stageHeight / 2;
			shipObj.virtualDegree = 0;
			shipObj.degree = 0;

			var createdAsteroids: int = 0;
			while (createdAsteroids != numAsteroids) {
				var asteroidX: int = stage.stageWidth * Math.random();
				var asteroidY: int = stage.stageHeight * Math.random();
				var dx: Number = (shipObj.x) - (asteroidX);
				var dy: Number = (shipObj.y) - (asteroidY);
				var distToShip: Number = Math.sqrt((dy * dy) + (dx * dx));
				var asteroidCenterX: int = rockBds[0].width / 2;

				if (distToShip > asteroidCenterX + shipObj.centerY) {
					var found: Boolean = true;
					for (var i: int = 0; i < asteroidsArr.length; i++) {
						var asteroid: Object = asteroidsArr[i];
						dx = (asteroid.x) - (asteroidX);
						dy = (asteroid.y) - (asteroidY);
						var distToOtherAsteroid: Number = Math.sqrt((dy * dy) + (dx * dx));
						if (distToOtherAsteroid < asteroidCenterX + asteroidCenterX) {
							found = false;
							break;
						}
					}
					if (found) {
						createAsteriod(0, asteroidX, asteroidY);
						createdAsteroids++;
					}

				}
			}
		}



		function createAsteriod(_size: int, _x: int, _y: int): void {

			var asteroid: AssetObj = new AssetObj();
			asteroid.x = _x;
			asteroid.y = _y;
			asteroid.virtualDegree = Math.random() * 360;
			asteroid.spinSpeed = Math.random() * (1 - 3);
			asteroid.centerX = rockBds[_size].width / 2;
			asteroid.centerY = rockBds[_size].height / 2;
			asteroid.trajectory = Math.random() * 360;
			asteroid.size = _size;
			asteroid.pixelList = rockSizes[_size];
			asteroid.color = getColor();

			asteroidsArr.push(asteroid);
		}



		function createAsteroidSizes(): void {

			var bigRock: Array = [];

			for (var row: int = 0; row < bdBigRock.height; row++) {
				for (var col: int = 0; col < bdBigRock.width; col++) {
					var pixel: uint = bdBigRock.getPixel32(col, row);
					if (pixel != 0) {
						bigRock.push({
							color: pixel,
							row: row,
							col: col
						});
					}
				}
			}
			rockSizes[0] = bigRock;

			var medRock: Array = [];
			for (row = 0; row < bdMedRock.height; row++) {
				for (col = 0; col < bdMedRock.width; col++) {
					var pixel: uint = bdMedRock.getPixel32(col, row);
					if (pixel != 0) {
						medRock.push({
							color: pixel,
							row: row,
							col: col
						});
					}
				}
			}
			rockSizes[1] = medRock;

			var smlRock: Array = [];
			for (row = 0; row < bdSmlRock.height; row++) {
				for (col = 0; col < bdSmlRock.width; col++) {
					var pixel: uint = bdSmlRock.getPixel32(col, row);
					if (pixel != 0) {
						smlRock.push({
							color: pixel,
							row: row,
							col: col
						});
					}
				}
			}
			rockSizes[2] = smlRock;

		}




		function createShip(): void {

			var idleShipArr: Array = [];
			for (var row: int = 0; row < bdShip.height; row++) {
				for (var col: int = 0; col < bdShip.width; col++) {
					var pixel: uint = bdShip.getPixel32(col, row);
					if (pixel != 0) {
						idleShipArr.push({
							color: pixel,
							row: row,
							col: col
						});
					}
				}
			}



			shipObj = new AssetObj();
			shipObj.x = stage.stageWidth / 2;
			shipObj.y = stage.stageHeight / 2;
			shipObj.virtualDegree = 0;
			shipObj.degree = 0;
			shipObj.centerX = bdShip.width / 2;
			shipObj.centerY = bdShip.height / 2;
			shipObj.pixelList = idleShipArr;
			shipObj.color = getColor();
		}


		function myKeyUp(e: KeyboardEvent): void {

			if (e.keyCode == Keyboard.W) {
				onUpKeyUp();
			}
			if (e.keyCode == Keyboard.S) {

				onDownKeyUp();
			}
			if (e.keyCode == Keyboard.A) {

				onLeftKeyUp();
			}
			if (e.keyCode == Keyboard.D) {

				onRightKeyUp();
			}
			if (e.keyCode == Keyboard.SPACE) {
				onSpacePressed();
			}
		}

		function myKeyDown(e: KeyboardEvent): void {

			if (e.keyCode == Keyboard.W) {
				onUpKeyDown();
			}
			if (e.keyCode == Keyboard.S) {

				onDownKeyDown();
			}
			if (e.keyCode == Keyboard.A) {

				onLeftKeyDown();
			}
			if (e.keyCode == Keyboard.D) {

				onRightKeyDown();
			}
		}



		function onLeftKeyDown(): void {
			Model.turnsObj.left = true;
			Model.turnsObj.right = false;
		}

		function onRightKeyDown(): void {
			Model.turnsObj.right = true;
			Model.turnsObj.left = false;
		}

		function onUpKeyDown(): void {
			Model.turnsObj.up = true;
			Model.turnsObj.down = false;
		}

		function onDownKeyDown(): void {
			Model.turnsObj.down = true;
			Model.turnsObj.up = false;
		}



		///////mouse up////
		function onUpKeyUp(): void {
			Model.turnsObj.up = false;
		}

		function onDownKeyUp(): void {
			Model.turnsObj.down = false;
		}

		function onLeftKeyUp(): void {
			Model.turnsObj.left = false;
		}

		function onRightKeyUp(): void {
			Model.turnsObj.right = false;
		}



		function renderStars(): void {
			for (var h: int = 0; h < starsArr.length; h++) {
				var obj: Object = starsArr[h];
				obj.x += obj.speed;
				if (obj.x > stage.stageWidth) {
					obj.x = 0;
				}

				var hidden: Boolean = false;

				for (var a: int = 0; a < asteroidsArr.length; a++) {
					var asteroidObj: Object = asteroidsArr[a];
					var dx: Number = (obj.x) - (asteroidObj.x);
					var dy: Number = (obj.y) - (asteroidObj.y);
					var distToStar: Number = Math.sqrt((dy * dy) + (dx * dx));
					if (distToStar < asteroidObj.centerX) {
						hidden = true;
						break;
					}
				}

				if (!hidden) {
					for (var j: int = 0; j < 4; j++) {
						for (var k: int = 0; k < 4; k++) {
							bigBd.setPixel32(int(obj.x) + k, int(obj.y) + j, obj.color);
						}
					}
				}
			}
		}


		function update(e: Event): void {
			bigBd.lock();
			bigBd.fillRect(rect, bgColor);
			renderStars();

			if (!shipObj.dead) {
				if (Model.turnsObj.right) {
					shipObj.virtualDegree += speed / 2;
					if (shipObj.virtualDegree == 360) {
						shipObj.virtualDegree = 0;
					}
				}
				if (Model.turnsObj.left) {
					shipObj.virtualDegree -= speed / 2;
					if (shipObj.virtualDegree == 0) {
						shipObj.virtualDegree = 360;
					}
				}
				if (Model.turnsObj.up) {
					increaseVelocity();
				}

				if (Model.turnsObj.down) {
					decreaseVelocity();
				}

				moveShip();
				render(shipObj);
			} else {
				deadCount++;

				if (deadCount == 30) {
					deadCount = 0;
					resetGame();
				}
			}


			processBullets();
			animateExpolsions();

			for (var i: int = 0; i < asteroidsArr.length; i++) {
				var asteroidObj: Object = asteroidsArr[i];

				asteroidObj.virtualDegree += asteroidObj.spinSpeed;

				if (asteroidObj.virtualDegree > 360) {
					asteroidObj.virtualDegree = 0;
				}

				render(asteroidObj);
				moveAsteroid(asteroidObj);

				//cehck collission with ship
				var dx: Number = (shipObj.x) - (asteroidObj.x);
				var dy: Number = (shipObj.y) - (asteroidObj.y);
				if (!shipObj.dead) {
					var distToShip: Number = Math.sqrt((dy * dy) + (dx * dx));
					if (distToShip < asteroidObj.centerX + shipObj.centerY) {
						shipObj.dead = true;
						deadCount = 0;
						createExpolsion(shipObj.x, shipObj.y, 5);

					}
				}


				//check for clission
				for (var j: int = 0; j < bullets.length; j++) {
					var bullet: Object = bullets[j];
					dx = (bullet.x) - (asteroidObj.x);
					dy = (bullet.y) - (asteroidObj.y);
					var distToBullet: Number = Math.sqrt((dy * dy) + (dx * dx));
					if (distToBullet < asteroidObj.centerX) {
						asteroidsArr.splice(i, 1);
						bullets.splice(j, 1);
						createExpolsion(asteroidObj.x, asteroidObj.y, 3 - asteroidObj.size);
						if (rockSizes[asteroidObj.size + 1]) {
							for (var h: int = 0; h < numAsteroids; h++) {
								createAsteriod(asteroidObj.size + 1, asteroidObj.x, asteroidObj.y);

							}
						}

						break;
					}
				}
			}
			bigBd.unlock();

		}

		function createExpolsion(_x: int, _y: int, amount: int): void {
			for (var i: int = 0; i < Math.random() * 15 * amount; i++) {
				var obj: Object = {};
				obj.angle = Math.random() * 360;
				obj.speed = (Math.random() * 10) + 5;
				obj.x = _x;
				obj.y = _y;
				obj.time = 100;
				obj.color = getColor();
				explosionsArr.push(obj);

			}

		}

		function animateExpolsions(): void {
			for (var i: int = 0; i < explosionsArr.length; i++) {
				var obj: Object = explosionsArr[i];
				if (obj.time > 0) {
					var newX: Number = 0;
					var newY: Number = 0;
					var currentRad: Number = obj.angle * Math.PI / 180; //degrees ti radians
					newX += Math.cos(currentRad) * obj.speed;
					newY += Math.sin(currentRad) * obj.speed;
					obj.x += newX;
					obj.y += newY;
					obj.time--;

					for (var j: int = 0; j < 5; j++) {
						for (var k: int = 0; k < 5; k++) {
							bigBd.setPixel32(int(obj.x) + k, int(obj.y) + j, obj.color);
						}
					}

				} else {
					explosionsArr.splice(i, 1);
				}
			}
		}





		function onSpacePressed(): void {
			var bullet: Object = {
				x: shipObj.x,
				y: shipObj.y,
				angle: shipObj.virtualDegree,
				color: getColor()
			};
			bullets.push(bullet);
		}


		function processBullets(): void {
			for (var i: int = 0; i < bullets.length; i++) {
				var bullet: Object = bullets[i];

				var newX: Number = 0;
				var newY: Number = 0;
				var currentRad: Number = bullet.angle * Math.PI / 180; //degrees ti radians
				newX += Math.cos(currentRad) * speed * 2;
				newY += Math.sin(currentRad) * speed * 2;
				bullet.x += newX;
				bullet.y += newY;


				if (bullet.x < 0 || bullet.y < 0 || bullet.x > stage.stageWidth || bullet.y > stage.stageHeight) {
					bullets.splice(i, 1);
				}

				//trace(int(bullet.x), int(bullet.y));
				for (var j: int = 0; j < 5; j++) {
					for (var k: int = 0; k < 5; k++) {
						bigBd.setPixel32(int(bullet.x) + k, int(bullet.y) + j, bullet.color);
					}
				}

			}
		}

		function increaseVelocity(): void {
			var found: Boolean = false;
			var obj: Object = null;
			for (var i: int = 0; i < movingDegrees.length; i++) {
				obj = movingDegrees[i];

				if (shipObj.virtualDegree == obj.degree) {
					found = true;
					shipObj.degree = obj.degree;
					break;
				}
			}

			if (!found) {
				obj = {
					degree: shipObj.virtualDegree,
					currSpeed: 0
				}
				shipObj.degree = shipObj.virtualDegree;
				movingDegrees.push(obj);
			}


			for (i = 0; i < movingDegrees.length; i++) {
				obj = movingDegrees[i];

				if (shipObj.degree == obj.degree) {
					obj.currSpeed += increment / 10;
					if (obj.currSpeed > speed) {
						obj.currSpeed = speed;
					}
				} else {
					obj.currSpeed -= (increment / 30);
					if (obj.currSpeed <= 0) {
						obj.currSpeed = 0;
					}
				}
			}
		}

		function decreaseVelocity(): void {
			var obj: Object = null;
			for (var i: int = 0; i < movingDegrees.length; i++) {
				obj = movingDegrees[i];
				obj.currSpeed -= (increment / 10);
				if (obj.currSpeed < 0) {
					obj.currSpeed = 0;
				}
			}
		}

		function moveAsteroid(asteroidObj: Object): void {
			var newX: Number = 0;
			var newY: Number = 0;
			var currentRad: Number = asteroidObj.trajectory * Math.PI / 180;
			newX += Math.cos(currentRad) * asteroidObj.size * 1.1;
			newY += Math.sin(currentRad) * asteroidObj.size * 1.1;

			asteroidObj.x += newX;
			asteroidObj.y += newY;

			handleEdges(asteroidObj);
		}

		function moveShip(): void {
			var newX: Number = 0;
			var newY: Number = 0;
			var obj: Object = null;
			for (var i: int = 0; i < movingDegrees.length; i++) {
				obj = movingDegrees[i];
				var currentRad: Number = obj.degree * Math.PI / 180; //degrees ti radians
				newX += Math.cos(currentRad) * obj.currSpeed;
				newY += Math.sin(currentRad) * obj.currSpeed;
			}


			shipObj.x += newX;
			shipObj.y += newY;

			handleEdges(shipObj);



		}

		function handleEdges(obj: Object): void {
			if (obj.x < 0) {
				obj.x = stage.stageWidth;
			}

			if (obj.y < 0) {
				obj.y = stage.stageHeight;
			}

			if (obj.x > stage.stageWidth) {
				obj.x = obj.x - stage.stageWidth;
			}

			if (obj.y > stage.stageHeight) {
				obj.y = obj.y - stage.stageHeight;
			}
		}

		function render(obj: Object): void {
			var centerX: Number = obj.centerX;
			var centerY: Number = obj.centerY;
			var currentRad: Number = obj.virtualDegree * Math.PI / 180; //degrees ti radians
			var pixelList: Array = obj.pixelList;

			var performPixelCheck: Boolean = false;
			var l: int = asteroidsArr.length;
			var asteroidsToCheck: Array = [];
			for (var a: int = 0; a < l; a++) {
				var asteroidObj: Object = asteroidsArr[a];
				if (asteroidObj != obj) {
					var dx: Number = obj.x - (asteroidObj.x);
					var dy: Number = obj.y - (asteroidObj.y);
					//get all asteroids close enough to this one
					var distToAsteroid: Number = Math.sqrt((dy * dy) + (dx * dx));
					if (distToAsteroid < (asteroidObj.centerX + obj.centerX)) {
						performPixelCheck = true;
						asteroidsToCheck.push(asteroidObj);
					}
				}
				else
				{
					break;
				}
			}



			for (var i: int = 0; i < pixelList.length; i++) {

				var col: int = pixelList[i].col;
				var row: int = pixelList[i].row;
				var dx: Number = (col) - (centerX);
				var dy: Number = (row) - (centerY);
				var pixelDistToCenter: Number = Math.sqrt((dy * dy) + (dx * dx));
				var currAngle: Number = Math.atan2(dy, dx);

				currAngle += currentRad;

				var newX: Number = Math.cos(currAngle) * pixelDistToCenter;
				var newY: Number = Math.sin(currAngle) * pixelDistToCenter;

				var pixelX: Number = obj.x + newX;
				var pixelY: Number = obj.y + newY;

				//check collosion with all asteroids
				//this is a performance KILLER!
				var hidden: Boolean = false;
				if (performPixelCheck) {
					var l: int = asteroidsToCheck.length
					for (a = 0; a < l; a++) {
						var asteroidObj: Object = asteroidsToCheck[a];
						var dx: Number = pixelX - (asteroidObj.x);
						var dy: Number = pixelY - (asteroidObj.y);
						var distToStar: Number = Math.sqrt((dy * dy) + (dx * dx));
						if (distToStar < asteroidObj.centerX) {
							hidden = true;
							break;
						}
					}
				}

				if (!hidden) {
					if (pixelX == 0) {
						pixelX = stage.stageWidth;
					}

					if (pixelY == 0) {
						pixelY = stage.stageHeight;
					}

					if (pixelX > stage.stageWidth) {
						pixelX = pixelX - stage.stageWidth;
					}

					if (pixelY > stage.stageHeight) {
						pixelY = pixelY - stage.stageHeight;
					}

					//var pixel: uint = pixelList[i].color;
					//if (pixel != 0) {
					bigBd.setPixel32(pixelX, pixelY, obj.color);
					//}
				}

			}
		}

	}

}