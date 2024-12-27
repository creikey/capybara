extends ColorRect

@export var capybara: Capybara

func _process(delta: float) -> void:
	modulate.a = lerp(modulate.a, 1.0 if capybara.killed else 0.0, (delta / Engine.time_scale) * 9.0)
