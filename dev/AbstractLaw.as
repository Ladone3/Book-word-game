﻿class AbstractLaw extends Array{ 
	public var MaxAttractiveSpeed:Number=55;
	public var AttractiveForce:Number=4;
	public var FrictionForce:Number=1;
	
	public function forceIteration(){
		for(var i=0; i<GameObject.count || i<this.length; i++){
			this.attractiveForce(i);
			this.frictionForce(i);
		}
	}
	
	public function deinit(){
		for(var i=0; i<GameObject.count || i<this.length; i++){
			if(this[i].deinit()){
				this[i].removeMovieClip();
				trace("Remove "+this[i]._name);
			}else{
				trace("Don't Remove "+this[i]._name);
			}
		}
		/*
		this._name = "";
		this.Target._name = "";
		this.fonImage._name = "";
		this.IndicatorPlace._name = "";
		this.cameraBorder._name = "";
		*/
	}
	
	private function attractiveForce(i:Number) {
		//trace("1) Yahooo i'm in!");
			if(this[i].mov && this[i]!=null){
				if(this[i].yBoost<=this.MaxAttractiveSpeed)this[i].yBoost+=AttractiveForce;
			}
	}
	private function frictionForce(i:Number) {
		//trace("2) Yahooo i'm in!");
			if((this[i].mov) && (this[i].touchDown) && (this[i]!=null)){
				if(this[i].xBoost!=0){
					if(this[i].xBoost>0){
						this[i].xBoost-=FrictionForce; 
					}else{
						this[i].xBoost+=FrictionForce;
					}
				}
			}
	}
	
	public function	AbstractLaw(){
		this._name = " AbstractLaw";
		//AsBroadcaster.initialize(this);
		for(var i=0; i<GameObject.count || i<this.length; i++){			
			this[i] = _root["gameobject"+i];
			this[i].law = this;
		}
		if(_root["FonImage"]!=undefined){
			this.fonImage = _root["FonImage"];
		}
		if(_root["CameraBorder"]!=undefined){
			this.cameraBorder = _root["CameraBorder"].getBounds(_root);
		}
	} 
			

	// Работа камеры
	//=============================================================================
	public var Target:Player=null;
	public var fonImage:MovieClip=null;
	public var IndicatorPlace:MovieClip=null;
	public var cameraBorder:Object=0;
	public var widthWindow:Number = 1024;
	public var heightWindow:Number = 768;
	public var borderX1:Number = widthWindow*(2/5);
	public var borderX2:Number = widthWindow*(3/5);
	public var borderY1:Number = heightWindow*(2/5);
	public var borderY2:Number = heightWindow*(3/5);
	public function chaseCamera(){
		if(Target._x < this.borderX1){
			if(this.cameraBorder==0 || this.cameraBorder.xMax>_root._x){
				_root._x+= this.borderX1 - Target._x;
				this.IndicatorPlace._x -= this.borderX1 - Target._x;
				this.fonImage._x -= (this.borderX1 - Target._x)*0.8;
				this.borderX1 = Target._x;
				this.borderX2 = Target._x+widthWindow*(1/5);
			}
		}
		if(Target._x > this.borderX2){
			if(this.cameraBorder==0 || this.cameraBorder.xMin<_root._x){
				_root._x -= Target._x - this.borderX2;
				this.IndicatorPlace._x += Target._x - this.borderX2;
				this.fonImage._x += (Target._x - this.borderX2)*0.8;
				this.borderX2 = Target._x;
				this.borderX1 = Target._x-widthWindow*(1/5);
			}
		}
		
		if(Target._y < this.borderY1){
			if(this.cameraBorder==0 || this.cameraBorder.yMin<-_root._y){
				_root._y+=this.borderY1-Target._y;
				this.IndicatorPlace._y -= this.borderY1-Target._y;
				this.fonImage._y -= (this.borderY1-Target._y)*0.5;
				this.borderY1 = Target._y;
				this.borderY2 = Target._y+heightWindow*(1/5);
			}
		}
		if(Target._y > this.borderY2){
			if(this.cameraBorder==0 || this.cameraBorder.yMax>-_root._y){
				_root._y-=Target._y-this.borderY2;
				this.IndicatorPlace._y += Target._y-this.borderY2;
				this.fonImage._y += (Target._y-this.borderY2)*0.5;
				this.borderY2 = Target._y;
				this.borderY1 = Target._y-heightWindow*(1/5);
			}
		}
	}
	
	
	// Поиск игрока в радиусе (Пока одного)
	//=============================================================================	
	public function findObject(go:GameObject, radius:Number):Number{		
		if(this.Target!=null){
				var obj1 = go.getBounds(_root);
				var x1 = obj1.xMin;
				var y1 = obj1.yMin;
				var obj2 = this.Target.getBounds(_root);
				var x2 = obj2.xMin;
				var y2 = obj2.yMin;
				var dist = Math.pow(Math.pow(x1-x2,2)+Math.pow(y1-y2,2),0.5);
				if(dist<radius){
					if(x1>x2){
						return -dist;
					}else{
						return dist;
					}
				}else{
					return 0;
				}
		}else{
			return 0;
		}
	}
}
