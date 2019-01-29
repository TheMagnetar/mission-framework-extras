#include "script_component.hpp"
/*
 * Author: TheMagnetar
 * Reveals a playable unit.
 *
 * Arguments:
 * 0: Player unit <OBJECT>
 * 1: AI unit <OBJECT>
 * 2: Reveal amount <NUMBER> (default: 4)
 *
 * Return Value:
 * Player revealed <BOOL>
 *
 * Example:
 * [player, cursorTarget, 1.4] call umfx_ai_fnc_onRevealUnit
 *
 * Public: Yes
 */

params ["_player", "_unit", ["_revealAccuracy", 4]];

if (!local _unit) exitWith {false};

_unit reveal [_player, _revealAccuracy];

true
