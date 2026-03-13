class_name Obstacle extends Node2D


@export var velocity : Vector2 = Vector2.ZERO;

func set_velocity(val : Vector2) -> void:
	velocity = val;

func stop():
	set_velocity(Vector2.ZERO);

enum KillType {
	DISABLED,
	LEFT,
	RIGHT,
	BELOW,
	ABOVE
}
@export var kill_type : KillType = KillType.DISABLED;
@export var kill_pos : Vector2 = Vector2.ZERO;

func set_kill_type(val : KillType) -> void:
	kill_type = val;

func is_past_kill_pos(pos : Vector2 = self.position) -> bool:
	return (
		(kill_type == KillType.LEFT  and pos.x <= kill_pos.x) or
		(kill_type == KillType.RIGHT and pos.x >= kill_pos.x) or
		(kill_type == KillType.BELOW and pos.y >= kill_pos.y) or
		(kill_type == KillType.ABOVE and pos.y <= kill_pos.y)
		);

func _process(delta: float) -> void:
	self.position += velocity * delta;
	
	if is_past_kill_pos() and not self.is_queued_for_deletion():
		self.queue_free()
