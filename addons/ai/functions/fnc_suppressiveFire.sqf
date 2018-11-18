/*
 * Author: TheMagnetar
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
 * [player, "leg_r", 0.8, "ACE_556x45_Ball_Mk318", 0.8] execVM "assignWound.sqf";
 *
 * Public: Yes
 */

if (!isServer) exitwith{};

params [
    ["_entity", objNull, [objNull]],
    ["_target", objNull, [objNull, grpNull, "", locationNull, taskNull, [], 0]], // Same as CBA_fnc_getPos
    ["_hRange", 0, [0]],
    "_altura", "_speed", "_sleepT",
    ["_fireMode", "", [""]],
    ["_ammoType", "", ["", 0]],
    ["_debug", false, [true]]
];

private _customAmmo = false;
private _gunner = _entity;
private _crew = [];
private _onFoot = false;
_hRange = ceil (_hRange/_speed);

private _isFiring = _entity getvariable [QGVAR(rafagas), false];
if (_isFiring) then {
    WARNING_1("Se ha cambiado el objetivo de la ametralladora", _entity);
    _entity setVariable [QGVAR(rafagas), false];

    waituntil {sleep 1; _entity getvariable ["colum_rafagas_stop",false]}; // si esta disparando esperar a q pare
};

private _weapon = "";
if (vehicle _entity == _entity) then {
    _onFoot = true;
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

private _pos = [_pos] call CBA_fnc_getPos;
if (((_pos select 0) == 0) && {(_pos select 1) ==0}) exitWith {
    ERROR_1("Target %1 does not exist",_target);
};

private _positionTarget = [1, 0, _altura];
private _AlturaActualRafaga= 0 - _hRange;

private _pos1 = getpos _entity;
private _reldir = ((_pos select 0) - (_pos1 select 0)) atan2 ((_pos select 1) - (_pos1 select 1));
private _reldir = _reldir % 360;


private _TargetInv = "ACE_Target_CInf" createvehicleLocal _pos;
private _debug_obj = if (_debug) then {"Sign_circle_EP1" createvehicleLocal _pos} else {nil};
private _TmpLogic = "Logic" createvehicleLocal _pos;
_TmpLogic setdir _reldir;
_TmpLogic setpos _pos;
_TmpLogic setvectorup [0,0,1];

{
    _x reveal _TargetInv;
    _x doTarget _TargetInv;
    _x disableAI "TARGET";
    _x disableAI "AUTOTARGET";
    _x disableAI "FSM";
} foreach _crew;

{
    if ((_customAmmo && {_ammoType !=_x}) || {!_customAmmo}) then {
        _entity removemagazine _x
    };
} foreach magazines _entity;

_entity addMagazine _ammoType;
_entity setVariable [QGVAR(rafagas),true];
_entity setVariable ["colum_rafagas_stop",false];
_entity setBehaviour "COMBAT";
_entity doTarget _TargetInv;

while {alive _entity && {alive _gunner} && {_entity getvariable [QGVAR(rafagas),true]}} do {
    if (count (magazines _entity) < 6) then {
        _entity addMagazine _ammoType;
    };

    if (_onFoot) then {
        _entity doTarget _TargetInv;
        _entity doFire _TargetInv;
    } else {
        if !(_fireMode isEqualTo "") then {
            _entity fire [_weapon, _fireMode];
        } else {
            _entity fire _weapon;
        };
    };

    _AlturaActualRafaga = _AlturaActualRafaga + _speed;
    _positionTarget set [0,_AlturaActualRafaga];
    _pos =_TmpLogic modelToWorld _positionTarget;
    _TargetInv setposATL _pos;
    if (_debug) then {_debug_obj setdir (_reldir +180); _debug_obj setposATL _pos;};
    _gunner lookAt _TargetInv;
    //(commander _entity) lookAt _TargetInv;

    if (_AlturaActualRafaga > _hRange) then {_AlturaActualRafaga= 0 -_hRange;};
    sleep (random _sleepT);
};

_entity setVariable [QGVAR(rafagas), false];
_entity setVariable ["colum_rafagas_stop", true];

{
    if ((!isnull _x) && {alive _x}) then
    {
        _x enableAI "TARGET";
        _x enableAI "AUTOTARGET";
        _x enableAI "FSM";
    };
} foreach _crew;

deletevehicle _TargetInv;
deletevehicle _TmpLogic;
if (_debug) then {deletevehicle _debug_obj};
