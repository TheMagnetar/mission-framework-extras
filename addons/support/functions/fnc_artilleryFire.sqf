#include "script_component.hpp"
/*
 * Author: TheMagnetar
 * Funtions that simulates artillery fire in a zone. This script can be used in order to avoid hitting units of a specific
 * side if a wide enough danger zone area is given. With Danger Area radius parameter set to 0, all units will be hit, independently
 * of the unit's side.
 *
 * Arguments:
 * 0: Ammo class name. If an array is given, each strike will select the ammo randomly <STRING><ARRAY> (default: "")
 * 1: Position <ARRAY><OBJECT><LOCATION><GROUP> (default: [])
 * 2: Radius in meters <NUMBER> (default: 50)
 * 3: Danger Area (area that will be avoided around a unit that complies with parameter 6) <NUMBER> (default: 0)
 * 4: Number of rounds <NUMBER> (default: 4)
 * 5: Average delay between rounds in seconds <NUMBER> (default: 0.5)
 * 6: Side that will be avoided by the artillery rounds (rounds will be avoided in the danger area) <SIDE><ARRAY> (default west)
 * 7: Ammo Type. It can be "explosive", "flare" or "smoke" <STRING> (default: "explosive")
 * 8: Make a unit on the map fire the rounds <OBJECT> (default: ojectNull)
 *
 * Return Value:
 * None
 *
 * Example:
 * ["8Rnd_82mm_Mo_shells", player, 100, 35, 4, 0.5, west, "explosive"] call umfx_support_fnc_artilleryFire
 * [["8Rnd_82mm_Mo_shells", "Sh_120mm_HE"], player, 100, 35, 4, 0.5, [west, civillian], "explosive"] call umfx_support_fnc_artilleryFire

 * Public: Yes
 */

params [
    ["_ammo", "", ["", []]],
    ["_targetPos", [], [objNull, grpNull, "", locationNull, taskNull, [], 0]], // Same as CBA_fnc_getPos
    ["_radius", 50, [0]],
    ["_dangerArea", 0, [0]],
    ["_numRounds", 3, [0]],
    ["_delay", 0.1, [0]],
    ["_side", west, [sideUnknown, []]],
    ["_ammoType", "explosive", [""]],
    ["_artilleryUnit", objNull, [objNull]]
];

if (!isServer) exitWith {};

private _acceptedAmmoTypes =  ["explosive", "flare", "smoke"];
if !(_ammoType in _acceptedAmmoTypes) exitWith {
    ERROR_2("Unknown ammoType specfied %1. Allowed %2",_ammoType,_acceptedAmmoTypes);
};

if !(_side isEqualType []) then {
    _side = [_side];
};

private _invalidSide = false;
{
    if !(_x in [west, east, resistance, civilian, sideUnknown]) exitWith {
        _invalidSide = true;
    }
} forEach _side;

private _acceptedSides = [west, east, resistance, civilian, sideUnknown];
if (_invalidSide) exitWith {
    ERROR_2("Invalid side specified in position %1. Accepted sides %2",_forEachIndex,_acceptedSides);
};

if (_ammo isEqualType "") then {
    _ammo = [_ammo];
};

_targetPos = [_targetPos] call CBA_fnc_getPos;
private _nextTime = CBA_missionTime;

[{
    params ["_handleArray", "_handleId"];
    _handleArray params ["_ammo", "_targetPos", "_radius", "_dangerArea", "_numRounds", "_side", "_ammoType", "_artilleryUnit", "_delay", "_nextTime"];

    if (_numRounds < 1) exitWith {
        [_handleId] call CBA_fnc_removePerFrameHandler;
    };

    if (CBA_missionTime < _nextTime) exitWith {};

    private _i = 0;
    private _objectiveLocked = false;
    private _tempPos = [0, 0, 0];
    private _units = allUnits select {side _x in _side};
    private _selectedAmmo = selectRandom _ammo;

    while {(_i < MAX_TRIES) && {!_objectiveLocked}} do {
        _tempPos = [_targetPos, _radius] call CBA_fnc_randPos;
        _units = _units inAreaArray [_tempPos, _dangerArea*2, _dangerArea*2];
        if (_units isEqualTo []) then {
            _objectiveLocked = true;

            if !(isNull _artilleryUnit) then {
                _artilleryUnit doArtilleryFire [_tempPos, _selectedAmmo, 1];
            } else {
                _tempPos = _tempPos vectorAdd [0, 0, 37.5 + random 25];

                private _selectedAmmo = _selectedAmmo createVehicle _tempPos;
                if (_ammoType isEqualTo "explosive") then {
                    _selectedAmmo setVelocity [0, 0, -500];
                };
            };
            _numRounds = _numRounds - 1;
            _nextTime = CBA_missionTime + random (2*_delay) - _delay;
            _handleArray set [4, _numRounds];
            _handleArray set [9, _nextTime];
        } else {
            _i = _i + 1;
        };
    };
}, 0, [_ammo, _targetPos, _radius, _dangerArea, _numRounds, _side, _ammoType, _artilleryUnit, _delay, _nextTime]] call CBA_fnc_addPerFrameHandler;
