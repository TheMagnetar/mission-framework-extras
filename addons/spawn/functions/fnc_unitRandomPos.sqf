#include "script_component.hpp"
/*
 * Author: TheMagnetar
 * Make the position of a unit to be randomly selected from an array of points
 *
 * Arguments:
 * 0: Unit <OBJECT> (default: objNull)
 * 1: Random locations. Accepted values are arrays, tasks, locations, objects or markers <ARRAY> (default: [])
 *
 * Return Value:
 * None
 *
 * Example:
 * [this, [p1, p2, p3, p4]] call umfx_spawn_fnc_unitRandomPos
 *
 * Public: Yes
 */

params [
    ["_unit", objNull, [objNull]],
    ["_randomPoints", [], [[]]]
];

if !(isServer) exitWith {};
if (isNull _unit || {_randomPoints isEqualTo []}) exitWith {
    WARNING_2("Invalid parameters. Unit %1, Points %2",_unit,_randomPoints);
};

private _selectedPoint = selectRandom _randomPoints;
private _pos = [_selectedPoint] call CBA_fnc_getPos;
_unit setPos _pos;
