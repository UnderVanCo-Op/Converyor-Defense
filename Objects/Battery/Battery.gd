extends Node2D
# This is Battery.gd

var listOfLafets := []		#


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for laf in $Lafets.get_children():
		listOfLafets.append(laf)
	$"Point".isBatteryP = true


# Gets called from point
func ReceiveCannon(cannon) -> void:
	listOfLafets[0].add_child(cannon)
	pass
