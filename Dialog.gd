extends Panel

const FontSize = 8


func say(text, timeout=5):
	var size = FontSize * (2 + len(text))
	rect_size = Vector2(size, 3 * FontSize)
	rect_position.x = -size / 2
	$RichTextLabel.rect_size[0] = size
	$RichTextLabel.text = " " + text + " "
	if 0 < timeout:
		$Timer.wait_time = timeout
		$Timer.start()
		visible = true


func _on_Timer_timeout():
	visible = false
