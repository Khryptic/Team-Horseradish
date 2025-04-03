extends Peg

@onready var peg_sensor: Area2D = $peg_sensor
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sensor_shape: CollisionShape2D = $peg_sensor/CollisionShape2D
@onready var circle_pulse_shader: Sprite2D = $CircleShader

func _ready():

    super()

    var circle: CircleShape2D = collision_shape.shape
    var sensor_circle: CircleShape2D = sensor_shape.shape

    peg_sensor.points_worth = 50
    sprite.scale *= 2.5
    circle.radius = 25
    circle_pulse_shader.scale *= 2.5
    sensor_circle.radius = 25
    animation_player.speed_scale = 0.3