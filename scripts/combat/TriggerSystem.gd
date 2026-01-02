extends Node
class_name TriggerSystem

static func process_event(state: BattleState, event: Dictionary) -> Array:
    var actions := []
    for trigger in state.mission.triggers:
        if state.triggered_ids.has(trigger.get("id", "")):
            continue
        if _matches(trigger.get("when", {}), event, state):
            state.triggered_ids.append(trigger.get("id", ""))
            for action in trigger.get("do", []):
                actions.append(action)
            if trigger.get("once", false):
                continue
    return actions

static func _matches(when: Dictionary, event: Dictionary, state: BattleState) -> bool:
    if when.get("type", "") != event.get("type", ""):
        return false
    match when.get("type", ""):
        "TURN_START":
            return when.get("phase", "") == state.phase and when.get("turn", 0) == state.turn
        "UNIT_ENTERS_TILE":
            return when.get("unit_side", "") == event.get("unit_side", "") and when.get("tile_id", "") == event.get("tile_id", "")
        "UNIT_TARGETS_UNIT":
            return when.get("unit_side", "") == event.get("unit_side", "") and when.get("target_tag", "") == event.get("target_tag", "")
        _:
            return false
