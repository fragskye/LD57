extends Node

signal players_initialized()
signal player_turn_started(player_data: PlayerData)

signal score_event(name: String, score: int)

signal throw_area_entered()

signal crowd_cheer()
