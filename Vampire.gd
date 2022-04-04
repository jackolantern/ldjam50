extends AnimatedSprite

signal dead
signal speed_up
signal slow_down
signal inventory_update(item, count)

const CellSize: int = 32

var coins = 0

var dead: bool = false
var speed: float = 3.0
var moving: bool = false
var velocity: Vector2
var map_position: Vector2 = Vector2(0, 0)
var destination: Vector2 = Vector2(0, 0)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize(pos):
	map_position = pos
	global_position = (pos * CellSize) + Vector2(1, 1) * (CellSize / 2.0  - 1.0)
	destination = global_position
	say("I have you now Van Helsing!")

func move(direction):
	moving = true
	map_position += direction
	destination = global_position + (direction * CellSize)
	velocity = speed * (destination - global_position)
	$Dialog.visible = false

func say(text, timeout=5):
	$Dialog.say(text, timeout)

func _physics_process(delta):
	if not moving or dead:
		return
	if global_position.distance_to(destination) < 1.0:
		global_position = destination
		destination = global_position
		moving = false
	else:
		global_position += delta * velocity

func _on_Area2D_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.is_in_group("item"):
		var item = area.get_parent().item
		area.get_parent().queue_free()
		if item == "Coin":
			coins += 1
			emit_signal("inventory_update", item, coins)
			say("$", 1)
		elif item == "Garlic":
			emit_signal("slow_down")
			say("Gross!", 1)
		elif item == "Mirror":
			emit_signal("slow_down")
			say(":(", 1)
		elif item.substr(0, len("Person")) == "Person":
			emit_signal("speed_up")
			say("Yum!", 1)
	elif area.is_in_group("sun"):
		say("Curses!", 10000)
		$Dialog.visible = true
		flip_v = true
		dead = true
		emit_signal("dead")
