extends InteractableButton

@onready var hm = $HoldManager
@onready var disabled_timer = $DisabledTimer

var can_grab: bool = true

func _ready():
	hm.held_changed.connect(released)

func _process(_delta):
	super(_delta)
	for body in detection.get_overlapping_bodies():
		if can_grab:
			if body.hm.holder == null:
				if body in get_tree().get_nodes_in_group("Player") and not active: return
				hm.pick_up(body)

func released():
	if hm.held_object == null:
		can_grab = false
		disabled_timer.start()


func _on_disabled_timer_timeout():
	can_grab = true
