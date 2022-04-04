extends CanvasLayer


var step = 0
var text = [
	"""Van Helsing has stolen your coffin!  The sun is rising, but there may still
be enough time to catch him!

Press [color=red]space[/color] to start!

[u]Instructions:[/u]

Use arrow keys or ASDF to move.

Drinking blood will speed you up.

Avoid garlic [img]assets/garlic.png[/img] and mirrors [img]assets/mirror.png[/img], they will slow you down!
Collect coins [img]assets/coin.png[/img] for no particular reason!
"""]


func _ready():
	$CenterContainer/Panel/Text.bbcode_text = text[step]
	pass # Replace with function body.


func _unhandled_input(event):
	if Input.is_key_pressed(KEY_S) or step >= len(text):
		get_tree().change_scene("res://Main.tscn")
	elif Input.is_key_pressed(KEY_SPACE):
		$CenterContainer/Panel/Text.bbcode_text = text[step]
		step += 1
