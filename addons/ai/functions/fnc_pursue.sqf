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

/*
    persigue.sqf v1.1 2009/10/17 -  Boreas, TheMagnetar
    Sencillo script que sirve para que una unidad persiga a otra. Para usarlo invocar la siguiente instruccion:

    nullvar=[unidadPerseguidora,unidadPerseguida] execVm "persigue.sqf";

    Se le pueden pasar mas parametros para acotar mas el modo de persecución:

    nullvar=[unidadPerseguidora,unidadPerseguida,radio,tiempo] execVm "persigue.sqf";

    Los parametros signigican lo siguiente:
        -unidadPerseguidora: La IA que  persigue
        -unidadPerseguida: La IA o el player que va aser perseguido
        -radio: radio alrededor de la unidad perseguida en el que la IA persegidora intetnara moverse buscando.(25m por defecto)
        -timpo: tiempo en segundos en que la IA perseguidora actualiza su movimiento para dirigirse a la nueva aera de busqueda(60s por defecto)

    Ejemplo1:
        nullvar=[cazador,presa] execvm "persigue.sqf";
    Ejemplo2:
        nullvar=[cazador,presa,40,30] execvm "persigue.sqf";
        //60 son los metros de radio alrededor de la presa donde el cazador se movera
        //30 es el intervalo de tiempo que el cazador utiliza para dirigirse a la nueva zona de busqueda de la presa
*/

params [
    ["_pursuer", objNull, [objNull, grpNull]],
    ["_pursued", objNull, [objNull, grpNull]],
    ["_radio", 240, [0]],
    ["_timeout", 30, [0]]
];

private _follow = true;

private _grpPursuer = grpnull;
private _grpPursued = grpnull;
if (_pursuer isEqualType grpNull)then{
    _grpPursuer = _pursuer;
} else {
    _grpPursuer = group _pursuer;
};

if(_pursued isEqualType grpNull)then{
    _grpPursued =  _pursued;
} else {
    _grpPursued = group _grpPursued;
};

while {_follow} do{

    private _leaderPursuer = leader _grpPursuer;
    private _leaderPursued = leader _grpPursued;

    if (units _grpPursuer isEqualTo []) then {
        _follow = false;
    };
    if (units _grpPursued isEqualTo []) then {
        _follow = false;
    };

    private _dir = _leaderPursued getDir _leaderPursuer;
    private _pos= _leaderPursued getPos [_radio, _dir];

    if ((_leaderPursued distance _leaderPursuer) > _radio ) then {
        _leaderPursuer move _pos;
    };

    sleep 1;
    private _time2 = time + _timeout;
    waitUntil {
        sleep 0.5;
        moveToCompleted _leaderPursuer || {moveToFailed _leaderPursuer} || {!alive _leaderPursuer} || {_time2 < time}
    };
};


