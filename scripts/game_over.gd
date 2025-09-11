extends Button

func _ready():
	get_tree().root.content_scale_factor = 1.0

	
func _pressed():
	get_tree().change_scene_to_file("res://scenes/world.tscn")
	
	
func _process(delta):
	pass
