extends Trampoline

var default_color: Color = Color(1, 1, 1, 0.4):
	set(value): line.default_color = value
	get: return line.default_color