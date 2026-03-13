extends CharacterBody2D

signal death

const flapBoost : float = -3;
const gravity : float = 9.8;
const terminal_gravity : float = 20;

const rotation_multiplier : float = PI / 30;

@export var death_velocity : Vector2 = Vector2(1, -1); # Velocity upon death

@onready var starting_position = self.position;

var dead : bool = true;
var hurt_count : int = 0;
const explode_at_hit_count : int = 5;

func _physics_process(delta) -> void:
	if not exploded():
		self.move_and_collide(self.velocity);
		self.velocity = self.velocity.move_toward(
			Vector2(0, terminal_gravity), gravity * delta);
		
func _process(_delta: float) -> void:
	$BirdSprite.rotation = self.velocity.y * rotation_multiplier;
	
	if not dead and Input.is_action_just_pressed("Flap"):
		self.velocity.y = flapBoost;
		
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.stop();
		
		$AnimationPlayer.play("Flap");
		
		$FlapSound.pitch_scale = 1.5 - $BirdSprite.rotation_degrees / 180;
		$FlapSound.play();

func animate_death(die_vel : Vector2 = self.death_velocity) -> void:
	hurt_count += 1;
	
	if hurt_count == explode_at_hit_count:
		animate_explosion();
	else:
		if hurt_count <= 4:
			$HurtSound.pitch_scale = 1.2 - 0.2 * hurt_count;
		$HurtSound.play();
		self.velocity = die_vel;
		$AnimationPlayer.play("Die");

func animate_explosion():
	$Explode.visible = true;
	$BirdSprite.visible = false;
	$Explode.play("explode");
	$ExplodeSound.play();
	self.velocity = Vector2.ZERO;

func exploded() -> bool:
	return hurt_count >= explode_at_hit_count;

func die(die_vel : Vector2 = self.death_velocity) -> void:
	animate_death(die_vel);
	dead = true;
	death.emit();

func _on_danger_collider_area_entered(_area: Area2D) -> void:
	die();

func disable_danger_collider():
	$ObstacleCollider.monitoring = false;

func reset() -> void:
	self.position = starting_position;
	self.velocity = Vector2.ZERO;
	$BirdSprite.rotation = 0;
	
	$ObstacleCollider.monitoring = true;
	
	$AnimationPlayer.play("RESET");
	$Explode.visible = false
	$BirdSprite.visible = true
	
	dead = false;
	hurt_count = 0;
