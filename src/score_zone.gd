class_name ScoreZone extends Obstacle

signal scored

const SCOREZONE_SCENE = preload("res://src/score_zone.tscn");

func _on_player_collider_body_entered(_body: Node2D) -> void:
	scored.emit();

static func create_scorezone(parent : Node2D, pos : Vector2 = Vector2.ZERO, vel : Vector2 = Vector2.ZERO) -> ScoreZone:
	var scorezone = SCOREZONE_SCENE.instantiate();
	parent.add_child(scorezone);
	scorezone.position = pos;
	scorezone.velocity = vel;
	
	return scorezone;
