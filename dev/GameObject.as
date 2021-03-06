﻿class GameObject extends MovieClip { 
	// Подсчет количества объектов класса 
	//=======================================================
	private static var gameObjectCount:Number=0;
	public var _oldname = null;

	// Объект на котором лежит данный объект. Если mov = true;
	public var downObject:GameObject = null;
	public var prevDownObject:GameObject = null;
	
	// Объект трансформер цветов
	public var _color:ColorTransformer; 
	
	public var areaNeeded:Boolean = false;
	public var myPrivateObjList = null;
	public var stopBounds = null;
	
	public function getType():String{
		return "GameObject";
	}
	
	public function setScale(s:Number){
		this._width*=s;
		this._height*=s;
	}
	
	// Жив ли объект?
	//======================================================
	private var lifeState:Boolean = true;
	public function getLifeState(){
		trace("Get life: "+this.lifeState);
		return this.lifeState;
	}
	
	public function set life(b:Boolean){
		this.lifeState=b;
	}
	public function get life():Boolean{
		return this.lifeState;
	}
	
	// Обрабатывать ли объект
	//======================================================
	private var calculateObject:Boolean = true;
	public function set calcObj(b:Boolean){
		this.calculateObject=b;
	}
	public function get calcObj():Boolean{
		return this.calculateObject;
	}
	
	private function lifeOrDie(){
		if(!this.lifeState){
			this.remove();
		}
	}
		
	public static var objectsList:Array = new Array();
	
	// Ускорение по X
	//=======================================================
	private var xBoost:Number; 
	public function set xA(xBoost:Number){
		this.xBoost = xBoost;

	}
	public function get xA():Number{
		return this.xBoost;
	}
	
	// Ускорение по Y
	//=======================================================
	private var yBoost:Number; 
	public function set yA(yBoost:Number){
		this.yBoost = yBoost;
	}
	public function get yA():Number{
		return this.yBoost;
	}
	
	// Скорость по X
	//=======================================================
	private var xSpeed:Number; 
	// Скорость по Y
	//=======================================================
	private var ySpeed:Number; 
	
	public var touchLeft :Boolean = false;
	public var touchRight:Boolean = false;
	public var touchUp   :Boolean = false;
	public var touchDown :Boolean = false;
	
	// Проверка уперлись ли мы в объект, если да скидываем значение скорости в этом направлении в ноль
	//=======================================================
	private function stopOnDirection(){
		if(touchUp && yBoost<0){
			yBoost = 0;
			//trace("touchUp");
		}
		if(touchDown && yBoost>0){
			yBoost = 0;
			//trace("touchDown");
		}
		if(touchLeft && xBoost<0){
			xBoost = 0;
			//trace("touchLeft");
		}
		if(touchRight && xBoost>0){
			xBoost = 0;
			//trace("touchRight");
		}
	}	
	
	// Удалить объект
	//=========================================================
	public function remove(){
		_global.abstractLaw.popMe(this);
		this.swapDepths(_root.getNextHighestDepth());
		this.removeMovieClip();
		//delete(del);		
	}
	
	// Можно ли перемещать игровой объект
	//=======================================================
	private var movable:Boolean;
	public function set mov(movable:Boolean){
		this.movable = movable;
	}
	public function get mov():Boolean{
		return this.movable;
	}
	public function goToAndStop(a:Number){
		this._currentframe = a;
	}
	
	public function GameObject(){
		this._color = new ColorTransformer(this);
		this.xBoost = 0;
		this.yBoost = 0;
		this.xSpeed = 0;
		this.ySpeed = 0;
		this.movable = false;
		this.lifeState = true;
		this._oldname = this._name;
		this._name = "gameObject_"+(gameObjectCount++);
		if(_global.abstractLaw){
			//trace(_global.abstractLaw.length);
			_global.abstractLaw.pushMe(this);
		}
	}
	
	public function deinit():Boolean{
		return false;
	}
	
	// Рассчет текущей скорости
	//=======================================================
	private function calcSpeeds(){
		this.xSpeed = this.xBoost;
		this.ySpeed = this.yBoost;
	}
	
	public function onEnterFrameAction(){
		this.movements();
	}
	
	public function movements(){
		this.calcSpeeds();
		var wantX = this.xSpeed;
		var wantY = this.ySpeed;

		if(this.downObject)this.prevDownObject = this.downObject;
		this.downObject = null;	
		
		if(_global.abstractLaw){
			var p = this.permissionToMov({x:wantX, y:wantY});
			this.downObject = p.object;

			this._x = this._x + p.x;
			this._y = this._y + p.y;
			touchLeft = p.left;
			touchRight = p.right;
			touchUp = p.up;
			touchDown = p.down;
			stopOnDirection();
		} else {
			this._x = wantX;
			this._y = wantY;
		}
	}
	
	public function onEnterFrameNoAction(){
		// No action
	}
	
	// Определяем обработчик onEnterFrame() 
	public function onEnterFrame() {
		if(!_global.doPause){
			if(movable && life){
				this.onEnterFrameAction();
			}else if(movable){
				this.movements();
			}else{
				this.onEnterFrameNoAction();
			}
			this.lifeOrDie();
		}
	}
	
	public function takeObject(object:GameObject):Boolean{
		return true;
	}
		
	private var bottomMargin:Number = 3;
	// I don't know what me doing hear! I am crazy! It can be optimized!
	public function permissionToMov(np):Object{
		var left:Boolean = false;
		var right:Boolean = false;
		var up:Boolean = false;
		var down:Boolean = false;
		
		var rx = np.x;
		var ry = np.y;
		var nWidth = this._width;
		var nHeight = this._height;
		var myBounds = this.getBounds(_root);
		var downObject = null;
		var nXMin = myBounds.xMin + np.x;
		var nYMin = myBounds.yMin + np.y-bottomMargin;
		var objList = (this.myPrivateObjList && this.areaNeeded ? this.myPrivateObjList : _global.abstractLaw);

		for(var i=0; i<objList.length; i++){
			if(objList[i]!=null && objList[i].calcObj && objList[i]!=this && (takeObject(objList[i]))){		
				var objBounds = objList[i].getBounds(_root);
				if((nXMin >= objBounds.xMin - nWidth)&&(nYMin >= objBounds.yMin - nHeight)&&(nXMin <= objBounds.xMax)&&(nYMin <= objBounds.yMax)){
					var razn1 = nXMin - (objBounds.xMin - nWidth);
					var razn2 = nYMin - (objBounds.yMin - nHeight);
					var razn3 = objBounds.xMax - nXMin;
					var razn4 = objBounds.yMax - nYMin;
					var thisDown = false;
					
					if((razn1 <= razn2)&&(razn1 <= razn3)&&(razn1 <= razn4)){
						rx = rx - razn1;
						right = true;
						if(objList[i].mov && !(objList[i] instanceof Player))objList[i].xA += this.xA/2;	
					}else if((razn2 <= razn1)&&(razn2 <= razn3)&&(razn2 <= razn4)){
						ry = ry - razn2;
						down = true;
						thisDown = true;
						if(objList[i].mov && !(objList[i] instanceof Player))objList[i].xA += -this.xA/4;
					}else if((razn3 <= razn1)&&(razn3 <= razn2)&&(razn3 <= razn4)){
						rx = rx + razn3;
						left = true; 
						if(objList[i].mov && !(objList[i] instanceof Player))objList[i].xA += this.xA/2;
					}else if((razn4 <= razn1)&&(razn4 <= razn2)&&(razn4 <= razn3)){
						ry = ry + razn4;
						up = true;
						if(objList[i].mov && !(objList[i] instanceof Player))objList[i].xA += this.xA;	
					}
					if(thisDown){
						downObject = objList[i];
					}
				}
			}	
		}
		if(this.stopBounds){
			if(myBounds.xMin+rx<this.stopBounds.minX)rx = this.stopBounds.minX - myBounds.xMin;
			if(myBounds.xMax+rx>this.stopBounds.maxX)rx = this.stopBounds.maxX - myBounds.xMax;
		}
		return {x:rx,y:ry,up:up,down:down,left:left,right:right,object:downObject};
	}
	
	// Поиск игрока в радиусе (Пока одного)
	//=============================================================================	
	public function onRadius(go:GameObject, radius:Number):Boolean{		
		if(go!=null){
				var x1 = this._x;
				var y1 = this._y;
				var x2 = go._x;
				var y2 = go._y;
				var dist = Math.pow(Math.pow(x1-x2,2)+Math.pow(y1-y2,2),0.5);
				if(dist<=radius){
					return true;
				}else{
					return false;
				}
		}else{
			return false;
		}
	}
}
