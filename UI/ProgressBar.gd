extends ProgressBar
func _ready():
	value=100
func ProgresBarHP():
	value-=10
	print(value)
	if (value<=0):
		print("endGame")
		


