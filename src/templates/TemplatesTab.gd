extends Control

var search_query: String setget set_search_query, get_search_query


func set_search_query(new_search_query: String) -> void:
	search_query = new_search_query

func get_search_query() -> String:
	return search_query
