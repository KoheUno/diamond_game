//
//  Board.swift
//  diamond game
//
//  Created by Matsui Lab on 2018/12/01.
//  Copyright © 2018年 kohei uno. All rights reserved.
//

import UIKit

class Board: UIView {
	var grid : [Cell] = []
	let numOfLines:Int = 17 //ボードの行数
	let centerOfx = 510     //中心のx座標
	let topOfy = 30         //いちばん上の頂点のy座標
	let diff_x = 80         //x座標の間隔
	let diff_y = 40         //y座標の間隔
	let directionList:[Direction] = [Direction.rightfront,Direction.leftfront,Direction.right,Direction.left,Direction.rightback,Direction.leftback]
	let cantMove:[(team:Team,disAllowLabels:[Int])] = [(team : Team.red,disAllowLabels: [0,1,2,3,4,5,6,7,8,9,74,84,85,95,96,97,107,108,109,110]),(team:Team.blue,disAllowLabels:[0,1,2,3,4,5,6,7,8,9,65,75,76,86,87,88,98,99,100,101]),(team:Team.yellow,disAllowLabels:[74,84,85,95,96,97,107,108,109,110,65,75,76,86,87,88,98,99,100,101])]
	var is_firstTouch:Bool = true
	var selectedObject:Cell = Cell.init();
	var canMoveTo:[Int] = []
	
	
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder:aDecoder)
		
	}
	
	override func draw(_ rect: CGRect) {
		initBoard();
	}
	
	/**
	一行あたりのマスの数を返す関数
	引数:何行目か
	戻り値:その行のマスの数
	**/
	func getNumInRow(lineNum:Int) -> Int {
		switch lineNum {
		case 1:
			return 1
		case 2:
			return 2
		case 3:
			return 3
		case 4:
			return 4
		case 5:
			return 13
		case 6:
			return 12
		case 7:
			return 11
		case 8:
			return 10
		case 9:
			return 9
		case 10:
			return 10
		case 11:
			return 11
		case 12:
			return 12
		case 13:
			return 13
		case 14:
			return 4
		case 15:
			return 3
		case 16:
			return 2
		case 17:
			return 1
		default:
			return 0
		}
	}
	
	/**
	行番号と何マス目かを渡すと、そのマスの座標を返す関数
	**/
	func calcPointXY(line: Int, cell: Int) -> (x: Int,y: Int){
		var set_x :Int = 0
		var set_y :Int
		//今処理する行は奇数行めかどうか
		if((line % 2) == 1){ //奇数行のとき
			if(cell == (getNumInRow(lineNum: line) / 2) + 1){ //今処理するマスはその行の真ん中より右か左か真ん中か
				set_x = centerOfx //真ん中なのでcenterOfx
			}else if(cell < (getNumInRow(lineNum: line) / 2) + 1){ //真ん中より左
				set_x = centerOfx - ((getNumInRow(lineNum: line) / 2 - cell)  + 1 ) * diff_x //真ん中の値 - (真ん中から何個分左か) * 1個分のズレ
			}else if(cell > (getNumInRow(lineNum: line) / 2) + 1){  //真ん中より右
				set_x = centerOfx + (((cell - 1)  - getNumInRow(lineNum: line) / 2)  ) * diff_x //真ん中の値 + (真ん中から何個分左か) * 1個分のズレ
			}
		}else{ //偶数行のとき
			if(cell <= (getNumInRow(lineNum: line) / 2)){ //真ん中より左
				set_x = (centerOfx - diff_x / 2) - (getNumInRow(lineNum: line) / 2 - cell) * diff_x //(偶数業の真ん中左寄りのあたい) - (真ん中から何個分左か) * 1個分のズレ
			}else if(cell > (getNumInRow(lineNum: line) / 2)){  //真ん中より右
				set_x = (centerOfx - diff_x / 2) + (cell - getNumInRow(lineNum: line) / 2) * diff_x //(偶数業の真ん中右寄りのあたい) - (真ん中から何個分左か) * 1個分のズレ
			}
		}
		set_y = topOfy + diff_y * line //行に合わせたY座標を設定
		return (x: set_x, y: set_y)
	}
	
	/**
	初期配置の時に、その座標がなんのチームに属するかを返す関数
	引数: 座標 x,y
	戻り値: 所属するチーム
	**/
	func whichTeamAtStart(lineNum: Int,cellNum: Int) -> Team{
		if(5 <= lineNum && lineNum <= 9){ //5-9行目のとき
			//右端から(5 - (赤の5行目まで))にあるマスは赤チームとする
			if((getNumInRow(lineNum: lineNum) - 5 ) - ( 4 - lineNum ) <= cellNum){
				return Team.red
			}
			//左端から(5 - 青の5行目まで)にあるマスを青チームとする
			if(cellNum <= (5 + (5 - lineNum))){
				return Team.blue
			}
		}else if(13 <= lineNum ){ //13行目以降のとき
			if(lineNum == 13){//13行目のときは、5-9個目は黄色チームである
				if(5 <= cellNum && cellNum <= 9){
					return Team.yellow
				}
			}else{ //14行目以降は全部黄色チームである
				return Team.yellow
			}
		}
		//どれでもなかった時、無いチームとする
		return Team.nai
	}
	
	/**
	マスの位置に応じてそのマスに移動可能なチームに配列を返す関数
	**/
	func tellAllowTeam(labelOfGrid :Int) -> [Team]{
		var allowTeam: [Team] = [Team.blue,Team.red,Team.yellow]
		for nowCheckTeams in cantMove {
			for checkLabel in nowCheckTeams.disAllowLabels {
				if checkLabel == labelOfGrid {
					allowTeam.remove(at: allowTeam.firstIndex(of: nowCheckTeams.team)!)
					break;
				}
			}
		}
		return allowTeam
	}
	
	/**
	盤の背景を初期化/描画する関数
	**/
	func initBackground(){
		//太線部分を描く処理
		let pathForBoldLine = UIBezierPath();
		pathForBoldLine.lineWidth = 6 //線の太さの設定
		pathForBoldLine.move(to: CGPoint(x: centerOfx - (getNumInRow(lineNum: 5)/2) * diff_x + Mitame.width/2, y: topOfy + diff_y * 5 + Mitame.height/2));
		//                  x座標の中心 + (5行目のコマの数 の半分) * コマの間隔1個分 + コマの中心とのxのずれ, y座標の一番上 + コマの間隔1個分 * 5行目 + コマの中心とのyのずれ
		pathForBoldLine.addLine(to: CGPoint(x: centerOfx + (getNumInRow(lineNum: 5)/2) * diff_x + Mitame.width/2, y: topOfy + diff_y * 5 + Mitame.height/2));
		pathForBoldLine.addLine(to: CGPoint(x: centerOfx + Mitame.width/2, y: topOfy + diff_y * numOfLines + Mitame.height/2));
		pathForBoldLine.addLine(to: CGPoint(x: centerOfx - (getNumInRow(lineNum: 5)/2) * diff_x + Mitame.width/2, y: topOfy + diff_y * 5 + Mitame.height/2));
		pathForBoldLine.move(to: CGPoint(x:centerOfx + Mitame.width/2 , y: topOfy + diff_y + Mitame.height/2))
		pathForBoldLine.addLine(to: CGPoint(x: centerOfx + (getNumInRow(lineNum: 5)/2) * diff_x + Mitame.width/2, y: topOfy + diff_y * 13 + Mitame.height/2))
		pathForBoldLine.addLine(to: CGPoint(x: centerOfx - (getNumInRow(lineNum: 5)/2) * diff_x + Mitame.width/2, y: topOfy + diff_y * 13 + Mitame.height/2))
		pathForBoldLine.addLine(to: CGPoint(x:centerOfx + Mitame.width/2 , y: topOfy + diff_y  * 1 + Mitame.height/2))
		UIColor.black.setStroke()
		pathForBoldLine.stroke(); //線を描く
		
		//細い線の部分を描く処理
		let pathForNormalLine = UIBezierPath();
		pathForNormalLine.lineWidth = 3 //線の太さの設定
		//細い横線を引く(真横)　引くのは2~16(numOfLines - 1)行目
		for nowLine:Int in 2 ... (numOfLines - 1) {
			let nowPoints = (
				fromX: calcPointXY(line: nowLine, cell: 1).x, //マスの座標(nowLine行目,1マス目)のX座標 / 線の開始点
				fromY: calcPointXY(line: nowLine, cell: 1).y,
				toX: calcPointXY(line: nowLine, cell: getNumInRow(lineNum: nowLine)).x, //マスの座標(nowLine行目の右端(getNumInRow(nowLine))のマス)のX座標 / 線の終点
				toY: calcPointXY(line: nowLine, cell: getNumInRow(lineNum: nowLine)).y
			);
			pathForNormalLine.move(to: CGPoint(x: nowPoints.fromX + Mitame.width/2, y: nowPoints.fromY + Mitame.height/2))
			pathForNormalLine.addLine(to: CGPoint(x: nowPoints.toX + Mitame.width/2, y: nowPoints.toY + Mitame.height/2))
		}
		
		//細い横線を引く(右上->左下)
		for nowLine:Int in 2 ... (numOfLines - 1) {
			//2-4行目と9-12行目はnowLine行目の1マス目からひく
			if((2 <= nowLine && nowLine <= 4) || (9 <= nowLine && nowLine <= 12)){
				let nowPoints = (
					fromX: calcPointXY(line: nowLine, cell: getNumInRow(lineNum: nowLine)).x, //マスの座標(nowLine行目,最後のマス目)のX座標 / 線の開始点
					fromY: calcPointXY(line: nowLine, cell: getNumInRow(lineNum: nowLine)).y,
					toX: calcPointXY(line: 13, cell: nowLine).x, //マスの座標( 13行目のnowLineのマス)のX座標 / 線の終点
					toY: calcPointXY(line: 13, cell: nowLine).y
				);
				pathForNormalLine.move(to: CGPoint(x: nowPoints.fromX + Mitame.width/2, y: nowPoints.fromY + Mitame.height/2))
				pathForNormalLine.addLine(to: CGPoint(x: nowPoints.toX + Mitame.width/2, y: nowPoints.toY + Mitame.height/2))
			}else if(nowLine == 5){
				for nowCell in 2 ... getNumInRow(lineNum: 5) - 1 {
					if(nowCell <= 4 || 10 <= nowCell){
						let nowPoints = (
							fromX: calcPointXY(line: nowLine, cell: nowCell).x, //マスの座標(nowLine行目,nowCellマス目)のX座標 / 線の開始点
							fromY: calcPointXY(line: nowLine, cell: nowCell).y,
							toX: calcPointXY(line: 4 + nowCell, cell: 1).x, //マスの座標(4 + nowCell行目の1マス目)のX座標 / 線の終点
							toY: calcPointXY(line: 4 + nowCell, cell: 1).y
						);
						pathForNormalLine.move(to: CGPoint(x: nowPoints.fromX + Mitame.width/2, y: nowPoints.fromY + Mitame.height/2))
						pathForNormalLine.addLine(to: CGPoint(x: nowPoints.toX + Mitame.width/2, y: nowPoints.toY + Mitame.height/2))
					}else if(nowCell == 9){
						let nowPoints = (
							fromX: calcPointXY(line: nowLine, cell: nowCell).x, //マスの座標(nowLine行目,1マス目)のX座標 / 線の開始点
							fromY: calcPointXY(line: nowLine, cell: nowCell).y,
							toX: calcPointXY(line: 13 , cell: 5).x, //マスの座標(13行目の5マス目)のX座標 / 線の終点
							toY: calcPointXY(line: 13 , cell: 5).y
						);
						pathForNormalLine.move(to: CGPoint(x: nowPoints.fromX + Mitame.width/2, y: nowPoints.fromY + Mitame.height/2))
						pathForNormalLine.addLine(to: CGPoint(x: nowPoints.toX + Mitame.width/2, y: nowPoints.toY + Mitame.height/2))
					}
				}
			}
		}
		
		
		//細い横線を引く(左上->右下)
		for nowLine:Int in 2 ... (numOfLines - 1) {
			//2-4行目と9-12行目はnowLine行目の1マス目からひく
			if((2 <= nowLine && nowLine <= 4) || (9 <= nowLine && nowLine <= 12)){
				let nowPoints = (
					fromX: calcPointXY(line: nowLine, cell: 1).x, //マスの座標(nowLine行目,1マス目)のX座標 / 線の開始点
					fromY: calcPointXY(line: nowLine, cell: 1).y,
					toX: calcPointXY(line: 13, cell: 14 - nowLine).x, //マスの座標(nowLine行目の右端(getNumInRow(nowLine))のマス)のX座標 / 線の終点
					toY: calcPointXY(line: 13, cell: 14 - nowLine).y
				);
				pathForNormalLine.move(to: CGPoint(x: nowPoints.fromX + Mitame.width/2, y: nowPoints.fromY + Mitame.height/2))
				pathForNormalLine.addLine(to: CGPoint(x: nowPoints.toX + Mitame.width/2, y: nowPoints.toY + Mitame.height/2))
			}else if(nowLine == 5){
				for nowCell in 2 ... getNumInRow(lineNum: 5) - 1 {
					if(nowCell <= 4 || 10 <= nowCell){
						let nowPoints = (
							fromX: calcPointXY(line: nowLine, cell: nowCell).x, //マスの座標(nowLine行目,1マス目)のX座標 / 線の開始点
							fromY: calcPointXY(line: nowLine, cell: nowCell).y,
							toX: calcPointXY(line: 18 - nowCell, cell: getNumInRow(lineNum: 18 - nowCell)).x, //マスの座標(nowLine行目の右端(getNumInRow(nowLine))のマス)のX座標 / 線の終点
							toY: calcPointXY(line: 18 - nowCell, cell: getNumInRow(lineNum: 18 - nowCell)).y
						);
						pathForNormalLine.move(to: CGPoint(x: nowPoints.fromX + Mitame.width/2, y: nowPoints.fromY + Mitame.height/2))
						pathForNormalLine.addLine(to: CGPoint(x: nowPoints.toX + Mitame.width/2, y: nowPoints.toY + Mitame.height/2))
					}else if(nowCell == 5){
						let nowPoints = (
							fromX: calcPointXY(line: nowLine, cell: nowCell).x, //マスの座標(nowLine行目,1マス目)のX座標 / 線の開始点
							fromY: calcPointXY(line: nowLine, cell: nowCell).y,
							toX: calcPointXY(line: 18 - nowCell, cell: 9).x, //マスの座標(nowLine行目の右端(getNumInRow(nowLine))のマス)のX座標 / 線の終点
							toY: calcPointXY(line: 18 - nowCell, cell: 9).y
						);
						pathForNormalLine.move(to: CGPoint(x: nowPoints.fromX + Mitame.width/2, y: nowPoints.fromY + Mitame.height/2))
						pathForNormalLine.addLine(to: CGPoint(x: nowPoints.toX + Mitame.width/2, y: nowPoints.toY + Mitame.height/2))
					}
				}
			}
		}
		
		pathForNormalLine.stroke(); //線を描く
	}
	
	/** 盤上のCellオブジェクトを初期化する関数
	**/
	func initCells(){
		for line:Int in 1 ... numOfLines{ //その行にあるマスの数(getNumInRow(line))だけforを回す
			for row:Int in 1 ... getNumInRow(lineNum: line){ //今処理する行は奇数行めかどうか
				let set_x :Int = calcPointXY(line: line,cell: row).x
				let set_y :Int = calcPointXY(line: line,cell: row).y
				//設定した値でCellオブジェクトを初期化して配列に追加
				grid.append(
					Cell.init(
						x: set_x,
						y: set_y,
						row: row,
						line: line,
						team: whichTeamAtStart(lineNum: line, cellNum: row),
						view: self)
					)
				grid[grid.count - 1].allowTeam = tellAllowTeam(labelOfGrid: grid.count - 1) //マスに移動が許可れるチームを登録
			}
		}
	}
	
	/**
	タッチされた座標にマスがあるか探す関数
	引数: 探す座標(CGPoint)
	戻り値: マスが見つかった -> みつかったマス(Cell型)
	マスがなかった   -> nil
	**/
	func searchPointedObject(touchedPoint: CGPoint) -> Cell? {
		for nowCheckingCell in grid {
			if let touchedCell = nowCheckingCell.hitTest(touchedPoint: touchedPoint) {
				return touchedCell
			}
		}
		return nil
	}
	
	/**
	ゲーム開始の状況を作る関数
	**/
	func initBoard(){
		initBackground();   //背景を初期化する
		initCells();        //各交点のオブジェクト達を初期化
	}
	
	
	/**
	与えれたマスから移動できるマスのlabelを返す関数
	引数: 探索基準のマス
	戻り値: 移動できるマスの配列
	**/
	func getCanMoveTo(selectedObject : Cell) -> [Int]{
		var canMoveTo:[Int] = []
		var checkedCellList: [Int] = []
		let depth:Int = 0
		recursionSearch(selectedObject: (selectedObject,selectedObject.team), canMoveTo: &canMoveTo, checkedCellList: &checkedCellList,depth: depth)
		return canMoveTo
	}
	
	/**
	周囲１マスの範囲で移動できるマスを探索する関数
	引数:	selectedObject	-	探索基準のマス
	canMoveTo 			-	移動可能なマスのリスト(参照渡し)
	checkedCellList - 探索済みのマスのリスト(参照渡し)
	depth						-	探索深度
	**/
	func recursionSearch(selectedObject : (cell: Cell,team: Team),canMoveTo: inout [Int],checkedCellList: inout [Int],depth:Int){
		var searchingPoint :CGPoint //探索する座標
		//探索する方向によって探索するマスの相対的な座標を割り出し、座標からオブジェクトを取得する
		for nowCheckingDirection in directionList {
			switch nowCheckingDirection {
			case Direction.rightfront:
				searchingPoint = CGPoint(x: selectedObject.cell.x + diff_x/2, y: selectedObject.cell.y - diff_y)
			case Direction.leftfront:
				searchingPoint = CGPoint(x: selectedObject.cell.x - diff_x/2, y: selectedObject.cell.y - diff_y)
			case Direction.right:
				searchingPoint = CGPoint(x: selectedObject.cell.x + diff_x, y: selectedObject.cell.y)
			case Direction.left:
				searchingPoint = CGPoint(x: selectedObject.cell.x - diff_x, y: selectedObject.cell.y)
			case Direction.rightback:
				searchingPoint = CGPoint(x: selectedObject.cell.x + diff_x/2, y: selectedObject.cell.y + diff_y)
			case Direction.leftback:
				searchingPoint = CGPoint(x: selectedObject.cell.x - diff_x/2, y: selectedObject.cell.y + diff_y)
			}
			let searchingObject = searchPointedObject(touchedPoint: searchingPoint)
			if searchingObject != nil{ //指定した座標にオブジェクトがあるとき
				if(!checkedCellList.contains(grid.index(of: searchingObject!)!) && (searchingObject!.isAllowedTeam(team: selectedObject.team))){ //探索中のマスは今までに探索したマスと被っておらず、移動先は所属していたチームが移動できるマスか
					checkedCellList.append(grid.index(of: searchingObject!)!)	//これから探索するマスをチェック済みリストに追加
					if(searchingObject?.team == Team.nai && depth == 0){ //調べた先のオブジェクトがチームに所属しているかどうか
						canMoveTo.append(grid.index(of: searchingObject!)!) //オブジェクトのgrid配列の要素番号を移動可能なマスの一覧に追加
					}else if (searchingObject?.team != Team.nai ) {
						/* 見つけた埋まってるマスの先を探索 */
						switch nowCheckingDirection {
						case Direction.rightfront:
							searchingPoint = CGPoint(x: searchingObject!.x + diff_x/2, y: searchingObject!.y - diff_y)
						case Direction.leftfront:
							searchingPoint = CGPoint(x: searchingObject!.x - diff_x/2, y: searchingObject!.y - diff_y)
						case Direction.right:
							searchingPoint = CGPoint(x: searchingObject!.x + diff_x, y: searchingObject!.y)
						case Direction.left:
							searchingPoint = CGPoint(x: searchingObject!.x - diff_x, y: searchingObject!.y)
						case Direction.rightback:
							searchingPoint = CGPoint(x: searchingObject!.x + diff_x/2, y: searchingObject!.y + diff_y)
						case Direction.leftback:
							searchingPoint = CGPoint(x: searchingObject!.x - diff_x/2, y: searchingObject!.y + diff_y)
						}
						let nextSearchObject = searchPointedObject(touchedPoint: searchingPoint)
						if nextSearchObject != nil {
							if(nextSearchObject?.team == Team.nai && nextSearchObject!.isAllowedTeam(team: selectedObject.team)){
								canMoveTo.append(grid.index(of: nextSearchObject!)!)
								recursionSearch(selectedObject: (nextSearchObject!,selectedObject.team), canMoveTo: &canMoveTo, checkedCellList: &checkedCellList,depth: depth+1)
							}
						}
					}
				}
			}
		}
	}
	
	func resetSelect(cancelCellList: [Int]){
		is_firstTouch = true; //1回目のタッチかのフラグを初期化
		selectedObject.switchUnSelected() //選択していたマスの表示をリセット
		//移動候補にしていたマスの表示をリセット
		for cancel in cancelCellList {
			grid[cancel].mitame.strokeColor = UIColor.clear.cgColor
		}
		selectedObject = Cell.init() //選択していたマスの情報を空っぽにする
	}
	
	/**
	画面がタッチされた時に呼び出される関数
	**/
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		var touchedPoint:CGPoint = CGPoint.init(); //タッチされた座標の情報の入れ物
		
		
		//タッチされた座標の情報の取得
		for touch:UITouch in touches {
			//そのタッチはView(自分)の座標でいうとどこなのか
			touchedPoint = touch.location(in: self)
		}
		
		//タッチされたオブジェクトの探索
		let touchedObject = searchPointedObject(touchedPoint: touchedPoint);
		if (touchedObject == nil) { //オブジェクトが見つからない/何も無いところをタッチしたとき
			resetSelect(cancelCellList: canMoveTo) //今選択しているマスなどの情報をリセット
		}else{ //見つかった時
			if(is_firstTouch && touchedObject!.team != Team.nai){ //firstTouch/1回目で、かつ色付きのとき
				selectedObject = touchedObject! //選択中のオブジェクトを変数に格納
				selectedObject.switchSelected() //枠線をつけて選択状態であることを示す
				canMoveTo = getCanMoveTo(selectedObject: selectedObject) //選択されたマスから移動可能なマスの配列をつくる
				//移動可能なマスを移動可能の表示に切り替える
				for nowCell in canMoveTo {
					grid[nowCell].switchCanMoveCell()
				}
				is_firstTouch = false;  //firsttouch判定をfalseに
			}else if(!is_firstTouch){
				let secondTouchObject = touchedObject! //選択中のオブジェクトを変数に格納
				//選ばれたマスが移動移動可能だったら
				if(canMoveTo.contains(grid.index(of: secondTouchObject)!)){
					//移動可能なマスの表示をリセット
					for cancel in canMoveTo {
						grid[cancel].mitame.strokeColor = UIColor.clear.cgColor
					}
					secondTouchObject.updateTeam(team: selectedObject.team, view: self) //移動先のマスを移動元と同じ所属に変更
					selectedObject.updateTeam(team: Team.nai, view: self) //移動元のマスをTeam.naiに変更
					selectedObject = Cell.init() //選択中のマスを初期化
					is_firstTouch = true  //1回目のタッチのフラグを初期化
				}else{
					resetSelect(cancelCellList: canMoveTo) //今選択しているマスなどの情報をリセット
				}
			}
		}
	}
}
