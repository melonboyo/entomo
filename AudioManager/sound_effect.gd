extends AudioStreamPlayer

func _on_finished():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "pitch_scale", 0.01, 0.3)
	tween.tween_property(self, "volume_db", -40, 0.1)
	await tween.finished
	queue_free()
	pitch_scale = 1
