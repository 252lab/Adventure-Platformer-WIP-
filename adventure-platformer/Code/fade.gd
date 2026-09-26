extends CanvasLayer

# node saved as a variable for use
@onready var color_rect: ColorRect = $ColorRect


# sets the alpha of the colour rect to 0.0 as default
func _ready() -> void:
	color_rect.color.a = 0.0

# controls the fade and duration
# target alpha is the end transparency of the colour rect
func fade(target_alpha: float, duration: float = 2.5):
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", target_alpha, duration)
	return tween
