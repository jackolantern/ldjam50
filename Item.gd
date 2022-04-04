extends Sprite

var item: String = "Garlic"
var desc: String = ""
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Dialog.say(desc, -1)
	$Dialog.visible = false


func initialize(pos: Vector2, item: String, desc: String):
	self.item = item
	self.desc = desc
	global_position = pos * 32 + Vector2(16, 16)
	texture = load("res://assets/%s.png" % item.to_lower())
	$Dialog.say(desc, -1)
	return self

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_mouse_exited():
	$Dialog.visible = false


func _on_Area2D_mouse_entered():
	$Dialog.visible = true
