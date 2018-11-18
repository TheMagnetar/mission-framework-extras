#include "script_component.hpp"
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
 * ["Rocket_03_HE_F", player, 100, 35, 0, 4, 0.5, "west"] call umfx_support_fnc_artilleryFire
 * Public: Yes
 */

//Este escript realiza fuego de artilleria en una zona sin golpear ningun objetivo del bando indicado.
/****************************************************************************************************/
// PARAMETROS:
/*
    1-) Tipo de proyectil, es un numero de 0 a 4 dependiendo de la potencia deseada. Cualquier otro numero, como -1 lanzara humo. -2, ... , -5 vengalas de colores
    2-) Vector de posicion central donde caera la artilleria. Debe ser de al menos 2 elementos. Si se marca con objetos/logicas usar el getpos, y getmarkerpos para marcadores
    3-) Area alrededor de la posicion central a bombardear, en metros..
    4-) OPCIONAL: descanso entre cada disparo en segundos.
    5-) OPCIONAL: bando de los jugadores a los que evitara la artilleria.  Si no se pone, evitara a todos los bandos menos civiles.

*/

params [
    ["_ammo", "", [""]],
    ["_targetPos", objNull, [objNull, grpNull, "", locationNull, taskNull, [], 0]], // Same as CBA_fnc_getPos
    ["_radius", 50, [0]],
    ["_dangerArea", 0, [0]],
    ["_numRounds", 0, [0]],
    ["_delay", 0.1, [0]],
    ["_side", "", [""]],
    ["_ammoType", "explosive", [""]],
    ["_artilleryUnit", objNull, [objNull]]
];

systemChat format ["_pos %1", _targetPos];
if (!isServer) exitWith {};
if !(_side in ["civilian", "east", "resistance", "west"]) exitWith {
    //ERROR_2("Unknown side specfied %1. Allowed %2",_side,["civilian", "east", "resistance", "west"]);
};

if !(_ammoType in ["explosive", "flare", "smoke"]) exitWith {
    //ERROR_2("Unknown ammoType specfied %1. Allowed %2",_ammoType,["explosive", "flare", "smoke"]);
};

systemChat format ["_pos %1", _targetPos];
_targetPos = [_targetPos] call CBA_fnc_getPos;
_side = switch (_side) do {
    case "east": {east};
    case "resistance": {resistance};
    case "west": {west};
    case "civilian": {civilian};
    default {sideUnknown};
};

[{
    params ["_handleArray", "_handleId"];
    _handleArray params ["_ammo", "_targetPos", "_radius", "_dangerArea", "_numRounds", "_side", "_artilleryUnit"];

    if (_numRounds <= 1) then {
        _handleId call CBA_fnc_removePerFrameHandler;
    };

    private _i = 0;
    private _objectiveLocked = false;
    private _tempPos = [0, 0, 0];
    private _units = allUnits select {side _x isEqualTo _side};

    while {(_i < MAX_TRIES) && {!_objectiveLocked}} do {
        _tempPos = [_targetPos, _radius] call CBA_fnc_randPos;
        _units = _units inAreaArray [_tempPos, _dangerArea*2, _dangerArea*2];
        if (_units isEqualTo []) then {
            _objectiveLocked = true;

            if !(isNull _artilleryUnit) then {
                _artilleryUnit doArtilleryFire [_tempPos, _ammo, 1];
            } else {
                _tempPos = _tempPos vectorAdd [0, 0, 50];

                private _ammo = _ammo createVehicle _tempPos;
                if (_ammo isEqualTo "explosive") then {
                    _ammo setVelocity [0, 0, -500];
                };
            };
            _numRounds = _numRounds - 1;
            _handleArray set [4, _numRounds];
        } else {
            _i = _i + 1;
        };
    };
}, _delay, [_ammo, _targetPos, _radius, _dangerArea, _numRounds, _side, _artilleryUnit]] call CBA_fnc_addPerFrameHandler;
