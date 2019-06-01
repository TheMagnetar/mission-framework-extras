/**
FAST RECOMPILING
**/
// #define DISABLE_COMPILE_CACHE
// To Use: [] call MFX_PREP_RECOMPILE;

#ifdef DISABLE_COMPILE_CACHE
    #define LINKFUNC(x) {_this call FUNC(x)}
    #define PREP_RECOMPILE_START    if (isNil "MFX_PREP_RECOMPILE") then {MFX_RECOMPILES = []; MFX_PREP_RECOMPILE = {{call _x} forEach MFX_RECOMPILES;}}; private _recomp = {
    #define PREP_RECOMPILE_END      }; call _recomp; MFX_RECOMPILES pushBack _recomp;
#else
    #define LINKFUNC(x) FUNC(x)
    #define PREP_RECOMPILE_START /* disabled */
    #define PREP_RECOMPILE_END /* disabled */
#endif


/**
STACK TRACING
**/
//#define ENABLE_CALLSTACK
//#define ENABLE_PERFORMANCE_COUNTERS
//#define DEBUG_EVENTS

#ifdef ENABLE_CALLSTACK
    #define CALLSTACK(function) {private ['_ret']; if (MFX_IS_ERRORED) then { ['AUTO','AUTO'] call MFX_DUMPSTACK_FNC; MFX_IS_ERRORED = false; }; MFX_IS_ERRORED = true; MFX_STACK_TRACE set [MFX_STACK_DEPTH, [diag_tickTime, __FILE__, __LINE__, MFX_CURRENT_FUNCTION, 'ANON', _this]]; MFX_STACK_DEPTH = MFX_STACK_DEPTH + 1; MFX_CURRENT_FUNCTION = 'ANON'; _ret = _this call ##function; MFX_STACK_DEPTH = MFX_STACK_DEPTH - 1; MFX_IS_ERRORED = false; _ret;}
    #define CALLSTACK_NAMED(function, functionName) {private ['_ret']; if (MFX_IS_ERRORED) then { ['AUTO','AUTO'] call MFX_DUMPSTACK_FNC; MFX_IS_ERRORED = false; }; MFX_IS_ERRORED = true; MFX_STACK_TRACE set [MFX_STACK_DEPTH, [diag_tickTime, __FILE__, __LINE__, MFX_CURRENT_FUNCTION, functionName, _this]]; MFX_STACK_DEPTH = MFX_STACK_DEPTH + 1; MFX_CURRENT_FUNCTION = functionName; _ret = _this call ##function; MFX_STACK_DEPTH = MFX_STACK_DEPTH - 1; MFX_IS_ERRORED = false; _ret;}
    #define DUMPSTACK ([__FILE__, __LINE__] call MFX_DUMPSTACK_FNC)

    #define FUNC(var1) {private ['_ret']; if (MFX_IS_ERRORED) then { ['AUTO','AUTO'] call MFX_DUMPSTACK_FNC; MFX_IS_ERRORED = false; }; MFX_IS_ERRORED = true; MFX_STACK_TRACE set [MFX_STACK_DEPTH, [diag_tickTime, __FILE__, __LINE__, MFX_CURRENT_FUNCTION, 'TRIPLES(ADDON,fnc,var1)', _this]]; MFX_STACK_DEPTH = MFX_STACK_DEPTH + 1; MFX_CURRENT_FUNCTION = 'TRIPLES(ADDON,fnc,var1)'; _ret = _this call TRIPLES(ADDON,fnc,var1); MFX_STACK_DEPTH = MFX_STACK_DEPTH - 1; MFX_IS_ERRORED = false; _ret;}
    #define EFUNC(var1,var2) {private ['_ret']; if (MFX_IS_ERRORED) then { ['AUTO','AUTO'] call MFX_DUMPSTACK_FNC; MFX_IS_ERRORED = false; }; MFX_IS_ERRORED = true; MFX_STACK_TRACE set [MFX_STACK_DEPTH, [diag_tickTime, __FILE__, __LINE__, MFX_CURRENT_FUNCTION, 'TRIPLES(DOUBLES(PREFIX,var1),fnc,var2)', _this]]; MFX_STACK_DEPTH = MFX_STACK_DEPTH + 1; MFX_CURRENT_FUNCTION = 'TRIPLES(DOUBLES(PREFIX,var1),fnc,var2)'; _ret = _this call TRIPLES(DOUBLES(PREFIX,var1),fnc,var2); MFX_STACK_DEPTH = MFX_STACK_DEPTH - 1; MFX_IS_ERRORED = false; _ret;}
#else
    #define CALLSTACK(function) function /* disabled */
    #define CALLSTACK_NAMED(function, functionName) function /* disabled */
    #define DUMPSTACK /* disabled */
#endif


/**
PERFORMANCE COUNTERS
**/
//#define ENABLE_PERFORMANCE_COUNTERS

#ifdef ENABLE_PERFORMANCE_COUNTERS
    #define ADDPFH(function, timing, args) call { _ret = [function, timing, args] call CBA_fnc_addPerFrameHandler; if (isNil "MFX_PFH" ) then { MFX_PFH=[]; }; MFX_PFH pushBack [[_ret, __FILE__, __LINE__], [function, timing, args]];  _ret }

    #define CREATE_COUNTER(x) if (isNil "MFX_COUNTERS" ) then { MFX_COUNTERS=[]; }; GVAR(DOUBLES(x,counter))=[]; GVAR(DOUBLES(x,counter)) set[0, QGVAR(DOUBLES(x,counter))];  GVAR(DOUBLES(x,counter)) set[1, diag_tickTime]; MFX_COUNTERS pushBack GVAR(DOUBLES(x,counter));
    #define BEGIN_COUNTER(x) if (isNil QGVAR(DOUBLES(x,counter))) then { CREATE_COUNTER(x) }; GVAR(DOUBLES(x,counter)) set[2, diag_tickTime];
    #define END_COUNTER(x) GVAR(DOUBLES(x,counter)) pushBack [(GVAR(DOUBLES(x,counter)) select 2), diag_tickTime];

    #define DUMP_COUNTERS ([__FILE__, __LINE__] call MFX_DUMPCOUNTERS_FNC)
#else
    #define ADDPFH(function, timing, args) [function, timing, args] call CBA_fnc_addPerFrameHandler

    #define CREATE_COUNTER(x) /* disabled */
    #define BEGIN_COUNTER(x) /* disabled */
    #define END_COUNTER(x) /* disabled */
    #define DUMP_COUNTERS  /* disabled */
#endif
