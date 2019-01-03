#include "script_component.hpp"
/*
 * Author: TheMagnetar
 * Checks if a unit has a weapon ready.
 *
 * Arguments:
 * 0: Pursuer <OBJECT><GROUP>
 * 1: Pursued <OBJECT><GROUP>
 * 2: Radius around the pursued where the pursuer will move at. The smaller, the more precise the pursuer will hunt <NUMBER> (default: 240)
 * 3: Timeout used by the pursuer to move to a new position <NUMBER> (default: 30)
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget, player, 45, 20] call umfx_ai_fnc_pursue
 *
 * Public: Yes
 */

params ["_unit"];

private _weaponReady = false;
if (vehicle _unit != _unit) then {

} else {

};

_weaponReady
