#include "script_component.hpp"
/*
 * Author: TheMagnetar
 * Makes a suicide unit.
 *
 * Arguments:
 * 0: Suicider <OBJECT> (default: objNull)
 * 1: Target side <SIDE> (default: west)
 * 2: Target acquisition distance <NUMBER> (default: 100)
 * 3: Minimum attack distance <NUMBER> (default: 10)
 * 4: Explosive type <STRING> (default: "IEDLandSmall_Remote_Ammo")
 * 5: Dead man switch (default: false)
 * 6: Sound defined in CfgSounds <STRING> (default: "allahu")
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget, west, 100, 10, "IEDLandSmall_Remote_Ammo", true] call umfx_ai_fnc_suicider
 *
 * Public: Yes
 */

params [
    ["_unit", objNull, [objNull, []]],
    ["_side", west, [west]],
    ["_targetDist", 100, [0]],
    ["_attackDist", 10, [0]],
    ["_explosive", "IEDLandSmall_Remote_Ammo", [""]],
    ["_deadManSwitch", false, [false]],
    ["_sound", QGVAR(allahu), [""]]
];

private _suicider = objNull;

if (_unit isEqualType []) then {
    if !(_unit isEqualTo []) then {suicider = selectRandom _unit;}
} else {
    _suicider = _unit;
};

if (isNil "_suicider" || {isNull _suicider}) exitWith {
    ERROR("Undefined unit");
};

if (!local _suicider) exitWith {
    [
        QGVAR(suiciderChangeLocality),
        [_suicider, _side, _targetDist, _attackDist, _explosive, _deadManSwitch, _sound],
        _suicider
    ] call CBA_fnc_targetEvent;
};

private _time = CBA_missionTime;
private _target = objNull;

_unit setVariable [QGVAR(deadManSwitch), _deadManSwitch];
_unit setVariable [QGVAR(explosive), _explosive];

_unit addEventHandler ["Hit", {
    params ["_unit", "", "_damage", ""];

    if (_damage < 0.2) exitWith {};

    // Deactivate Dead Man Switch
    _unit setVariable [QGVAR(deadManSwitch), false];
    private _explosive = _unit getVariable [QGVAR(explosive), ""];
    private _bomb = _explosive createVehicle [0, 0, 0];
    _bomb setPosATL (getPosATL _unit);
    _bomb setDamage 1;
}];

[{
    params ["_args", "_handleId"];
    _args params ["_unit", "_side", "_targetDist", "_attackDist", "_sound", "_time", "_target"];

    // Account for locality changes
    if (!local _unit) exitWith {
        [_handleId] call CBA_fnc_removePerFrameHandler;
        [
            QGVAR(suiciderChangeLocality),
            [_unit, _side, _targetDist, _attackDist, _unit getVariable QGVAR(explosive), _unit getVariable QGVAR(deadManSwitch), _sound],
            _unit
        ] call CBA_fnc_targetEvent;
    };

    private _playerUnits = ([] call CBA_fnc_players) select {alive _x};
    if ((_playerUnits findIf {(_x distance _unit) < _targetDist}) == -1) exitWith {};

    // Acquire or reaquire target for maximum damage
    if (CBA_missionTime >= _time) then {
        _target = [_unit, _side, _targetDist] call FUNC(suiciderGetTarget);
        _args set [5, CBA_missionTime + 5];
        _args set [6, _target];
    };

    if (!alive _unit) exitWith {
        if (_unit getVariable QGVAR(deadManSwitch)) then {
            private _explosive = _unit getVariable QGVAR(explosive);
            private _bomb = _explosive createVehicle [0, 0, 0];
            _bomb setPosATL (getPosATL _unit);
            _bomb setDamage 1;
        };
        [_handleId] call CBA_fnc_removePerFrameHandler;
    };

    if (isNull _target) exitWith {};

    _unit doMove (getPos _target);

    if (_unit distance _target < _attackDist) then {
        if !(_unit getVariable [QGVAR(finalSprint), false]) then {
            [QGVAR(suicider), [_unit, _sound]] call CBA_fnc_globalEvent;
            _unit SetUnitPos "Up";
            _unit SetSpeedMode "Full";
            _unit SetCombatMode "Red";
            _unit SetBehaviour "Careless";
            _unit setVariable [QGVAR(finalSprint), true];
        };

        if (_unit distance _target < 3) then {
            private _explosive = _unit getVariable QGVAR(explosive);
            private _bomb = _explosive createVehicle [0, 0, 0];
            _bomb setPosATL (getPosATL _unit);
            _bomb setDamage 1;
            [_handleId] call CBA_fnc_removePerFrameHandler;
        };
    };
}, 1, [_suicider, _side, _targetDist, _attackDist, _sound, _time, _target]] call CBA_fnc_addPerFrameHandler;
