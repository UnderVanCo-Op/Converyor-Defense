extends Node2D

onready var objMenu := $ObjectMenu
onready var isShowed := false
var sprNamesList := ["but1", "but2", "but3"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	objMenu.hide()
	isShowed = false
	var t = get_node_or_null("ObjectMenu")					# привязка к Кнопкам внутри менюхи
	if(t):
		for rndbut in t.get_children():
			rndbut.connect("FactoryButPressed", self, "s_FactoryButPressed")	# signal connection
	else:
		print("ERROR: failed to get ObjectMenu in Factory!")

func s_FactoryButPressed(_spriteName) -> void:
	#print("signal received")
	
	pass

func _on_TextureButton_pressed() -> void:
	#print("click on tb")
	if(isShowed):
		objMenu.hide()
		isShowed = false
	else:
		objMenu.show()
		isShowed = true
