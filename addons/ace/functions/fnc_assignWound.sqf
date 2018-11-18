#include "script_component.hpp"
/*
 * Author: TheMagnetar
 * Assigns a wound manually.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Body part <STRING>
 * 2: Damage <NUMBER>
 * 3: Injury type <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "leg_r", 0.8, "bullet"] call umfx_ace_fnc_assignWound;
 *
 * Public: Yes
 */

params [
    ["_unit", objNull, [objNull]],
    ["_bodyPart", "", [""]],
    ["_damage", 0.0, [0]],
    ["_injuryType", "", [""]]
];

if (!local _unit) exitWith {};

// Assign the wound
private _acceptedBodyParts = ["head","body","hand_l","hand_r","leg_l","leg_r"];
if ((_acceptedBodyParts find _bodyPart) == -1) exitWith {
    ERROR_2("Invalid body part selection. Available %1, used %2", _acceptedBodyParts, _bodyPart);
};

private _acceptedInjuryTypes = ["bullet", "grenade", "explosive", "shell", "stab", "vehiclecrash"];
if ((_acceptedInjuryTypes find _injuryType) == -1) exitWith {
    ERROR_2("Invalid intjury type. Available %1, used %2", _acceptedBodyParts, _bodyPart);
};

if (CBA_missionTime > 0) then {
    [_unit, _damage, _bodyPart, _injuryType] call ace_medical_fnc_addDamageToUnit;
} else {
    [{CBA_missionTime > 0}, {
        params ["_unit", "_bodyPart", "_damage", "_injuryType"];
        [_unit, _damage, _bodyPart, _injuryType] call ace_medical_fnc_addDamageToUnit;
    }, [_unit, _bodyPart, _damage, _injuryType]] call CBA_fnc_waitUntilAndExecute;
};
