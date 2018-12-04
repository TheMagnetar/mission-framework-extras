#include "script_component.hpp"
/*
 * Author: TheMagnetar (original script by Columdrum)
 * Assigns a wond manually.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Body part <STRING>
 * 2: Damage <NUMBER>
 * 3: Ammo <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget, player , 12, 8, 0.2, 1.2, "", "ACE_556x45_Ball_Mk318"] call umfx_ai_fnc_suppressiveFire
 *
 * Public: Yes
 */

if (!isServer) exitwith{};

params [
    ["_entity", objNull, [objNull]],
    ["_target", objNull, [objNull, grpNull, "", locationNull, taskNull, [], 0]], // Same as CBA_fnc_getPos
    ["_horizontalRange", 0, [0]],
    ["_verticalRange", 0, [0]],
    "_speed", "_delay",
    ["_fireMode", "", [""]],
    ["_ammoType", "", ["", 0]]
];

private _customAmmo = false;
private _gunner = _entity;
private _crew = [];
private _onFoot = vehicle _entity isEqualTo _entity;
systemChat format ["On foot %1", _onFoot];

private _isFiring = _entity getvariable [QGVAR(suppressiveFire), false];
if (_isFiring) exitWith {
    WARNING_1("Machinegun target has changed to %1", _entity);
    _entity setVariable [QGVAR(isFiring), false];

    [{!(_entity getVariable [QGVAR(suppressiveFire), false])}, {
        _this call FUNC(suppressiveFire);
    }, _this] call CBA_fnc_waitUntilAndExecute;
};

private _weapon = "";
if (_onFoot) then {
    _weapon = primaryWeapon _entity;
} else {
    _weapon = currentWeapon _entity;
    _gunner = gunner _entity;
    _crew = crew _entity;
};

if (_weapon isEqualTo "") exitwith {
    ERROR_2("No weaponAmmetralladora no iniciada", _entity, typeof _entity);
};

if !(_ammoType isEqualTo "") then {
    private _weaponMagazines = (getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines")) apply {toLower _x};
    if !(_weaponMagazines isEqualTo []) then {
        if (_ammoType isEqualType 0) then {
            if (_ammoType < 0 || {_ammoType >= (count _weaponMagazines)}) exitWith {
                ERROR_2("Unsupported ammo type. Ammo type should be positive and no greather than %1, current %2",count _weaponMagazines - 1,_ammoType);
            };
            _ammoType = _weaponMagazines select _ammoType
        } else {
            _ammoType = toLower _ammoType;
            if !(_ammoType in _weaponMagazines) then {
                if (_debug) then {"ERROR" hintc parseText format["SCRIPT rafagas MG :<br />El tipo de municion no es apropiado para este arma.<br />Opciones validas: <t color='#f000ff00'>%1</t>.<br />Actual NO VALIDO: <t color='#f0ff0000'>%2</t>",str _weaponMagazines,_ammoType]};
            };
        };
        _customAmmo = true;
    };
} else {
    _ammoType = currentMagazine _entity;
};

private _availableModes = (getArray (configFile >> "CfgWeapons" >> _weapon >> "modes")) apply {toLower _x};
if (_fireMode isEqualTo "") then {
    _fireMode = _availableModes select 0;
} else {
    _fireMode = toLower _fireMode;

    if (_availableModes isEqualTo [] || {!(_fireMode in _availableModes)}) exitWith {
        ERROR("Invalid weapon modes");
    };
};

private _targetPos = [_target] call CBA_fnc_getPos;
if (((_targetPos select 0) == 0) && {(_targetPos select 1) == 0}) exitWith {
    ERROR_1("Target %1 does not exist",_target);
};

_targetPos = ATLToASL _targetPos;

if (_onFoot) then {
    // Aim
    _entity lookAt _targetPos;
    _entity disableAI "TARGET";
    _entity disableAI "AUTOTARGET";
    _entity disableAI "FSM";
} else {
    {
        _x lookAt _targetPos;
        _x disableAI "TARGET";
        _x disableAI "AUTOTARGET";
        _x disableAI "FSM";
    } foreach _crew;
};

{
    if ((_customAmmo && {_ammoType !=_x}) || {!_customAmmo}) then {
        _entity removemagazine _x
    };
} foreach magazines _entity;

_entity addMagazine _ammoType;
_entity setVariable [QGVAR(suppressiveFire),true];
_entity setBehaviour "COMBAT";

private _nextTime = CBA_missionTime;

[{
    params ["_handleArray", "_handleId"];
    _handleArray params ["_entity", "_gunner", "_targetPos", "_delay", "_horizontalRange"];

    if (!alive _entity || {!alive _gunner} || {!(_gunner getVariable [QGVAR(suppressiveFire), false])}) exitWith {
        systemChat format ["remove"];
        [_handleId] call CBA_fnc_removePerFrameHandler;
        _gunner setVariable [QGVAR(suppressiveFire), false];
        if ((vehicle _entity) isEqualTo _entity) then {
            if (alive _entity) then {
                _entity enableAI "TARGET";
                _entity enableAI "AUTOTARGET";
                _entity enableAI "FSM";
            };
        } else {
            {
                _x enableAI "TARGET";
                _x enableAI "AUTOTARGET";
                _x enableAI "FSM";
            } foreach (_crew select {alive _x});
        };
    };
/*
    // Do not fire since time since last call is not enough.
    if (CBA_missionTime < _nextTime) exitWith {};
    _nextTime = CBA_missionTime + random _delay;
    _handleArray set [6, _nextTime];
*/
    if (count (magazines _entity) < 6) then {
        _entity addMagazine _ammoType;
    };

    if (unitReady _entity) then {
         // Move the target
        private _tempPos = _targetPos getPos [random _horizontalRange, random 360];
        _entity lookAt _tempPos;
        systemChat format ["_tempOs %1", _tempPos];
        _entity doSuppressiveFire _tempPos;
    };
}, 2, [_entity, _gunner, _targetPos, _delay, _nextTime, _horizontalRange]] call CBA_fnc_addPerFrameHandler;
