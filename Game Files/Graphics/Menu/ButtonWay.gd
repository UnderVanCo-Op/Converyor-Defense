extends Path2D

var newButton:=preload("res://Game Files/Graphics/Menu/MenyButton.tscn")
var velocity=4
var newButtonWay
func _ready():
	pass

func _physics_process(delta):
	newButtonWay=newButton.instance()
	add_child(newButtonWay)

