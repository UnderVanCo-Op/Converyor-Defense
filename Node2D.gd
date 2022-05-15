extends Node2D

var mobModel:Dictionary

func _ready():
	var file=File.new()
	file.open("res://Game Files/Level1.json",File.READ)
	var mobData=file.get_as_text()
	mobModel=parse_json(mobData)
