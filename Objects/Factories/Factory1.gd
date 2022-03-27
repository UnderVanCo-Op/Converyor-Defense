extends Node2D

onready var objMenu := $ObjectMenu
var isShowed := false
#var sprNamesList := ["but1", "but2", "but3"]
#enum s {but1, but2, but3}


func _ready() -> void:
	objMenu.hide()
	isShowed = false
	var t = get_node_or_null("ObjectMenu")					# привязка к Кнопкам внутри менюхи
	var counter = 0											# for sprite name
	if(t):
		for rndbut in t.get_children():
			counter += 1
			rndbut.connect("FactoryButPressed", self, "s_FactoryButPressed")		# signal connection
			rndbut.texture_normal = load("res://UI/but" + str(counter) + ".png")
			rndbut.set_sprite(str(counter))
	else:
		print("ERROR: failed to get ObjectMenu in Factory!")


# incoming signal from RoundBut.gd
func s_FactoryButPressed(spriteNumber) -> void:		
	#print("signal received")
	#print("button " + _spriteName + " was pressed")
	if int(spriteNumber) == 1:
		# build tower
		pass
	pass

# Pressing on a Factory area
func _on_TextureButton_pressed() -> void:
	#print("click on tb")
	if(isShowed):
		objMenu.hide()
		isShowed = false
	else:
		objMenu.show()
		isShowed = true
