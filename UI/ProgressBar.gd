extends ProgressBar
func _ready():
	value=100
func ProgresBarHP():  #for Enemy
	value-=10
	print(value)
	if (value<=0):
		print("endGame")
func AnotherProgresBarHP():
	value-=45
	print(value)
	if (value<=0):
		print("endGame")
		


