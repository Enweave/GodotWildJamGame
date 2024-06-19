extends wjAbilityBase

func activate():
    var success = false
    if user != null:
        if user.controller_direction:
            success = super.activate()
            if success:
                var dash_vector = user.controller_direction * ability_range_meters
                user.position += dash_vector
    return success