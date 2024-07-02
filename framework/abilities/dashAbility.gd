extends wjAbilityBase

@onready var ray: RayCast3D = $RayCast3D


func activate(_callback: Callable = Callable(), _args: Array = []):
    var success = false
    if user != null:
        if user.controller_direction:
            success = super.activate()
            if success:
                var dash_vector = ray_dash_limit(user.controller_direction * ability_range_meters)
                user.position += dash_vector
    return success


func ray_dash_limit(dash_vector: Vector3) -> Vector3:
    rotation = -user.rotation
    ray.global_position = user.global_position + Vector3(0, 1, 0)
    ray.target_position = -dash_vector * 1.1
    ray.force_raycast_update()

    if ray.is_colliding():
        var inwards_offset: Vector3 = (ray.get_collision_point() - user.global_position) * Vector3(0.2, 0, 0.2)
        return (ray.get_collision_point() - user.global_position - inwards_offset) * Vector3(1, 0, 1)
    return dash_vector