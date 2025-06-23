extends CharacterBody2D

@export var speed: float = 350.0
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()

	update_animation()

func update_animation() -> void:
	var sprite = $AnimatedSprite2D

	if direction != Vector2.ZERO:
		sprite.play("walk")
		
		# Opcional: flip para dirección horizontal
		sprite.flip_h = direction.x < 0
	else:
		sprite.play("idle")
