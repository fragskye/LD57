class_name Util extends Node

static func temporal_lerp(from: float, to: float, weight: float, delta: float) -> float:
	return lerpf(from, to, 1.0 - pow(1.0 - weight, delta * 60.0))

static func temporal_lerp_v3(from: Vector3, to: Vector3, weight: float, delta: float) -> Vector3:
	return from.lerp(to, 1.0 - pow(1.0 - weight, delta * 60.0))
