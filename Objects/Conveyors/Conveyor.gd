extends Path2D
# This is Conveyor.gd

var ConvCell := preload("res://Objects/Conveyors/ConvCell.tscn")


func AddCell() -> void:
	var ref = ConvCell.instance()
	add_child(ref)
	

func FullWithCells() -> void:
	for i in range(4):
		AddCell()
		yield(get_tree().create_timer(0.5), "timeout")
	

func _physics_process(delta: float) -> void:
	pass
