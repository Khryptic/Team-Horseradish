extends Node

## Calculates the intersection between a line and a horizontal line at a given Y value
func intersection_with_horizontal_line(point_a: Vector2, point_b: Vector2, y: float) -> Vector2:
	
	# Two point formula for a line solved for X. Since the Y is known, we can calculate the X to get the intercept.
	var x: float = (y - point_a.y) * (point_b.x - point_a.x) / (point_b.y - point_a.y) + point_a.x
	
	return Vector2(x, y)

## Calculates the nearest point that lays on the line from 'a' to 'b'
func closest_point_on_line(a: Vector2, b: Vector2, point: Vector2, is_clamped: bool) -> Vector2:
	var ab: Vector2 = b - a
	var ax: Vector2 = point - a
		
	var ab_length_squared: float = ab.length_squared()
	if ab_length_squared == 0.0:
		return a  # The line degenerates to a point

	var t: float = ax.dot(ab) / ab_length_squared

	if(is_clamped):
		t = clamp(t, 0.0, 1.0)
		
	return a + ab * t