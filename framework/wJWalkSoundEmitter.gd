extends AudioStreamPlayer3D

class_name wjWalkSoundEmitter


var transition_duration = 0.2
var transition_type = 1 # TRANS_SINE
var volume_min = -80

func fade_in_play():
	volume_db = volume_min
	play()
	var _tween_out = create_tween()
	_tween_out.tween_property(self, "volume_db", 0, transition_duration)


func fade_out_stop():
	var _tween_out = create_tween()
	_tween_out.tween_property(self, "volume_db", volume_min, transition_duration)
	_tween_out.tween_callback(stop)
