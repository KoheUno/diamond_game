//
//  Cell.swift
//  diamond game
//
//  Created by Matsui Lab on 2018/12/01.
//  Copyright © 2018年 kohei uno. All rights reserved.
//

import UIKit

class Cell : Equatable{
	
	/**
	「この型同士の比較にはxとyが一致することが必要だ」という宣言
	**/
	static func ==(lhs: Cell, rhs: Cell) -> Bool{
		return lhs.x == rhs.x && lhs.y == rhs.y
	}
	
	var x:Int			//セルのX座標
	var y:Int			//セルのY座標
	var row:Int		//セルの所在する列数
	var line:Int	//セルの所在する行数
	var mitame:CAShapeLayer
	var team:Team
	var view:UIView
	var allowTeam:[Team] = [Team.blue,Team.red,Team.yellow]//このマスに移動が許可されるチーム
	/*
	初期化/イニシャライザ
	引数 :		x - x座標
	y - y座標
	row - 自身の存在する列数
	team - 今のチーム
	view - その駒を表示するビュー
	*/
	init(x:Int,y:Int,row:Int,line:Int,team:Team,view:UIView) {
		self.x = x
		self.y = y
		self.row = row
		self.line = line
		self.team = team
		self.mitame = Mitame.getMitame(x: x, y: y, team: team)
		self.view = view
		view.layer.insertSublayer(mitame, at: 0)
	}
	
	init(){
		x = 0;
		y = 0;
		row = 0;
		line = 0;
		team = Team.nai;
		mitame = Mitame.getMitame(x: 0, y: 0, team: Team.nai)
		allowTeam = [Team.nai]
		view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0 ))
	}
	
	/**
	このマスが指定されたチームの移動先にできるかを判定する関数
	引数:	team   -	判定するチーム
	戻り値: 移動可能かどうか:Bool
	**/
	func isAllowedTeam(team:Team) -> Bool {
		for nowCheckTeam in self.allowTeam {
			if(nowCheckTeam == team){
				return true //相手の移動許可チームのリストに自分のチームがあったらtrueを返す
			}
		}
		return false //そうでなければfalseを返す
	}
	
	/*コマの状態の更新
	引数:新しくなるチーム
	ex 無い状態 -> 青
	青　-> 無い状態
	*/
	func updateTeam(team:Team,view:UIView){
		self.mitame.removeFromSuperlayer()
		self.team = team//指定されたチームに変更
		self.mitame = Mitame.getMitame(x: x, y: y, team: team)//変わったチームに応じて更新（変更）
		view.layer.addSublayer(mitame)
	}
	
	//x,yの座標を教えてくれる関数
	func getPositions() -> (x:Int,y:Int) {
		return (x:self.x,y:self.y)
	}
	
	/**
	自分がタッチされたかどうかを判断する関数
	引数: タッチされた座標(CGPoint型)
	戻り値: 自分がタッチされてたとき　-> 自分自身(Cell型)
	自分がタッチされてなかった -> nul
	**/
	func hitTest(touchedPoint: CGPoint) -> Cell? {
		//タッチされた点と自分の座標の距離をとる
		let distance: CGFloat = pow(pow(CGFloat(self.x + Mitame.width/2) - touchedPoint.x, 2) + pow(CGFloat(self.y + Mitame.height/2) - touchedPoint.y, 2), 1/2)
		//距離が20以下 / 自分の円の範囲内に収まっていたら自分を返す
		if(distance <= 20){
			return self;
		}
		//そうじゃなかったらnilを返す
		return nil;
	}
	
	/**
	マスの表示を「選択中」に切り替える関数
	**/
	func switchSelected(){
		self.mitame.removeFromSuperlayer()
		self.mitame.lineWidth = 5;
		self.mitame.strokeColor = UIColor.green.cgColor
		self.view.layer.addSublayer(mitame)
	}
	
	/**
	「選択中」のマスの表示をもとに戻す関数
	**/
	func switchUnSelected(){
		self.mitame.removeFromSuperlayer()
		self.mitame.lineWidth = 1;
		self.mitame.strokeColor = UIColor.black.cgColor
		self.view.layer.addSublayer(mitame)
	}
	
	/**
	マスの表示を「移動可能」にする関数
	**/
	func switchCanMoveCell(){
		self.mitame.removeFromSuperlayer()
		self.mitame.strokeColor = UIColor.brown.cgColor
		self.view.layer.addSublayer(mitame)
	}
	
}

