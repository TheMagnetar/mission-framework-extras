#include "script_component.hpp"
/*
 * Author: TheMagnetar
 * Deletes a vehicle and all its crew.
 *
 * Arguments:
 * 0: Vehicle <OBJECT> (default: objNull)
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget] call mfx_core_fnc_deleteVehicle
 *
 * Public: Yes
 */

params [
    ["_vehicle", objNull, [objNull]]
];

if (isNull _vehicle) exitWith {};

{
    _vehicle deleteVehicleCrew _x;
} forEach crew _vehicle;

deleteVehicle _vehicle;
