divert(-1)

changequote(`{-', `-}')
changecom({--}, {--})

dnl --- parameters ---
define({-PARAM_MAX_WIDTH-}, 80)
define({-PARAM_MAX_HEIGHT-}, 25)

dnl --- FUNCTIONS ---
dnl literal2int(char):
dnl   returns ASCII code point
dnl   not destructive
define({-literal2int-}, {-dnl
ifelse({-$1-},{- -},32,dnl
{-index({- 	
 !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~ ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ-},{-$1-})-})-})

dnl stack_reverse(from, to):
dnl   reverse pushdef stack
dnl   destructive
define({-stack_reverse-}, {-
    ifdef({-$1-}, {-
        pushdef({-$2-}, defn({-$1-}))
        popdef({-$1-})
        stack_reverse({-$1-}, {-$2-})-})-})

dnl stack_peek(stack):
define({-stack_peek-}, {-ifelse(defn({-$1-}), {--}, {-0-}, defn({-$1-}))-})

dnl stack_pop(stack):
dnl   pop from pushdef stack {-stack-} to p
dnl   destructive
define({-stack_pop-}, {-dnl
stack_peek({-$1-})dnl
popdef({-$1-})dnl
-})

dnl pick_matrix(stack, row, col, result):
dnl   pick character to result from stack<string>
dnl   not destructive
define({-pick_matrix-}, {-
    dnl __STACK__Gw55gQM1UQ2N: tmp stack
    pushdef({-cnt-}, 0)
    pushdef({-restore-}, {-
        ifdef({-__STACK__Gw55gQM1UQ2N-}, {-
            pushdef({-$1-}, defn({-__STACK__Gw55gQM1UQ2N-}))
            popdef({-__STACK__Gw55gQM1UQ2N-})
            restore()-})-})
    pushdef({-pick-}, {-
        ifelse(defn({-cnt-}), $2, {-
            pushdef({-column-}, defn({-$1-}))
            restore()-}, {-
            define({-cnt-}, incr(defn({-cnt-})))
            pushdef({-__STACK__Gw55gQM1UQ2N-}, defn({-$1-}))
            popdef({-$1-})
            pick()-})-})
    pick()
    pushdef({-char_raw-}, substr(defn({-column-}), {-$3-}, 1))
    ifelse(defn({-char_raw-}), {--},
        {-pushdef({-$4-}, {- -})-},
        {-pushdef({-$4-}, defn({-char_raw-}))-})

    popdef({-char_raw-})
    popdef({-column-})
    popdef({-pick-})
    popdef({-restore-})
    popdef({-cnt-})
-})

dnl modify_matrix(stack, row, col, char):
dnl   stack<string>[row][col] = char
dnl   destructive
define({-modify_matrix-}, {-
    dnl __STACK__Gw55gQM1UQ2N: tmp stack
    pushdef({-cnt-}, 0)
    pushdef({-restore-}, {-
        ifdef({-__STACK__Gw55gQM1UQ2N-}, {-
            pushdef({-$1-}, defn({-__STACK__Gw55gQM1UQ2N-}))
            popdef({-__STACK__Gw55gQM1UQ2N-})
            restore()-})-})
    pushdef({-modify-}, {-
        ifelse(defn({-cnt-}), $2, {-
            pushdef({-before-}, substr(defn({-$1-}), 0, $3))
            pushdef({-after-}, substr(defn({-$1-}), incr($3)))
            define({-$1-}, defn({-before-})$4{--}defn({-after-}))
            popdef({-before-})
            popdef({-after-})
            restore()-}, {-
            define({-cnt-}, incr(defn({-cnt-})))
            pushdef({-__STACK__Gw55gQM1UQ2N-}, defn({-$1-}))
            popdef({-$1-})
            modify()-})-})

    modify()

    popdef({-modify-})
    popdef({-restore-})
    popdef({-cnt-})
-})


dnl --- eval modules ---
dnl __eval_module_control(program_char)
dnl char: <>^v
define({-__eval_module_control-}, {-
    ifelse(
    {-$1-}, {-<-},
        {-set_direction(-1, 0)-},
    {-$1-}, {->-},
        {-set_direction(1, 0)-},
    {-$1-}, {-^-},
        {-set_direction(0, -1)-},
    dnl {-$1-}, {-v-},
        {-set_direction(0, 1)-})
-})

dnl __eval_module_branch(program_char, stack_name)
dnl char: _|
define({-__eval_module_branch-}, {-
    ifelse(stack_pop({-$2-}), 0,
        {-ifelse({-$1-}, {-_-},
            {-set_direction(1, 0)-},
            {-set_direction(0, 1)-})-},
        {-ifelse({-$1-}, {-_-},
            {-set_direction(-1, 0)-},
            {-set_direction(0, -1)-})-})
-})

dnl __eval_module_random(stack_name)
dnl char: ?
define({-__eval_module_random-}, {-
    errprint({-FIXME: ? is not implemented. setting direction to right.-})
    pushdef({-rand-}, 0)
    ifelse(
    defn({-rand-}), {-0-},
        {-set_direction(1, 0)-},
    defn({-rand-}), {-1-},
        {-set_direction(0, 1)-},
    defn({-rand-}), {-2-},
        {-set_direction(-1, 0)-},
    dnl default
        {-set_direction(0, -1)-})
    popdef({-rand-})
-})

dnl __eval_module_arithmetic(program_char, stack_name)
dnl char: +-*/%
define({-__eval_module_arithmetic-}, {-
    pushdef({-y-}, stack_pop({-$2-}))
    pushdef({-x-}, stack_pop({-$2-}))
    pushdef({-$2-}, eval(defn({-x-}) $1 defn({-y-})))
    popdef({-x-})
    popdef({-y-})
-})

dnl __eval_module_logical_lt(stack_name)
dnl char: `
define({-__eval_module_logical_lt-}, {-
    pushdef({-y-}, stack_pop({-$1-}))
    pushdef({-x-}, stack_pop({-$1-}))
    pushdef({-$1-}, eval(defn({-x-}) > defn({-y-})))
    popdef({-x-})
    popdef({-y-})
-})

dnl __eval_module_logical_eq(stack_name)
dnl char: !
define({-__eval_module_logical_eq-}, {-
    pushdef({-$1-}, eval(stack_pop({-$1-}) == 0))
-})

dnl __eval_module_literalPush(program_char, stack_name)
dnl char: STATUS_STRING mode
define({-__eval_module_pushStack_char-}, {-
    pushdef({-$2-}, literal2int({-$1-}))
-})

dnl __eval_module_intPush(program_char, stack_name)
dnl char: 0-9
define({-__eval_module_pushStack_int-}, {-
    pushdef({-$2-}, {-$1-})
-})


dnl __eval_module_output(program_char, stack_name)
dnl char: .(, -> ;)
define({-__eval_module_output-}, {-
divert(0)dnl
ifelse({-$1-}, {-.-},
{-format({-%d -}, stack_pop({-$2-}))-},
{-format({-%c-}, stack_pop({-$2-}))-}){--}dnl
divert(-1)
-})

dnl __eval_module_input(program_char, stack_name)
dnl char: &~
define({-__eval_module_input-}, {-
divert(0)
ifelse({-$1-}, {-&-},
    {-int (^D^D to commit)>-},
    {-char (^D^D to commit)>-})
divert(-1)
pushdef({-raw_char-}, include({-/dev/stdin-}))
ifelse(defn({-raw_char-}, {--},
    {-define({-raw_char-}, {-0-})-}, {--}))
ifelse({-$1-}, {-&-},
    {-pushdef({-$2-}, defn({-raw_char-}))-},
    {-pushdef({-$2-}, literal2int(defn({-raw_char-})))-})
divert(0)
divert(-1)
-})

dnl __eval_module_modifyStack(program_char, stack_name)
dnl char: :\$
define({-__eval_module_modifyStack-}, {-
    ifelse(
    {-$1-}, {-:-},
        {-pushdef({-$2-}, stack_peek({-$2-}))-},
    {-$1-}, {-$-},
        {-popdef({-$2-})-},
    dnl default {-\-}
        {-pushdef({-y-}, stack_pop({-$2-}))
        pushdef({-x-}, stack_pop({-$2-}))
        pushdef({-$2-}, defn({-y-}))
        pushdef({-$2-}, defn({-x-}))
        popdef({-x-})
        popdef({-y-})-})
-})

dnl __eval_module_getCharFromProgram(stack_name, program_matrix)
dnl char: g
define({-__eval_module_getCharFromProgram-}, {-
    pushdef({-y-}, stack_pop({-$1-}))
    pushdef({-x-}, stack_pop({-$1-}))
    pick_matrix({-$2-}, defn({-y-}), defn({-x-}), {-c-})
    pushdef({-$1-}, literal2int(defn({-c-})))
    popdef({-y-})
    popdef({-x-})
    popdef({-c-})
-})

dnl __eval_module_modifyProgram(stack_name, program_matrix_name)
dnl char: p
define({-__eval_module_modifyProgram-}, {-
    pushdef({-y-}, stack_pop({-$1-}))
    pushdef({-x-}, stack_pop({-$1-}))
    pushdef({-c-}, stack_pop({-$1-}))
    modify_matrix({-$2-}, defn({-y-}), defn({-x-}), format({-%c-}, defn({-c-})))
    popdef({-y-})
    popdef({-x-})
    popdef({-c-})
-})

dnl &: int
dnl ~: ascii -> int
dnl __eval_normalState(program_char, env_state_name, stack_name, program_matrix_name)
dnl {- -> ; because of m4 limitation
define({-__eval_normalState-}, {-
    ifelse(
    {-$1-}, {-#-},
        {-define({-$2-}, defn({-STATUS_SKIP-}))-},
    {-$1-}, {-@-},
        {-define({-$2-}, defn({-STATUS_HALT-}))-},
    {-$1-}, {-"-},
        {-define({-$2-}, defn({-STATUS_STRING-}))-},
    {-$1-}, {-!-},
        {-__eval_module_logical_eq({-$3-})-},
    {-$1-}, {-`-},
        {-__eval_module_logical_lt({-$3-})-},
    {-$1-}, {-g-},
        {-__eval_module_getCharFromProgram({-$3-}, {-$4-})-},
    {-$1-}, {-p-},
        {-__eval_module_modifyProgram({-$3-}, {-$4-})-},
    eval(index({-.;-}, {-$1-}) > -1), 1,
        {-__eval_module_output({-$1-}, {-$3-})-},
    eval(index({-&~-}, {-$1-}) > -1), 1,
        {-__eval_module_input({-$1-}, {-$3-})-},
    eval(index({-<>^v-}, {-$1-}) > -1), 1,
        {-__eval_module_control({-$1-})-},
    eval(index({-_|-}, {-$1-}) > -1), 1,
        {-__eval_module_branch({-$1-}, {-$3-})-},
    eval(index({-+-*/%-}, {-$1-}) > -1), 1,
        {-__eval_module_arithmetic({-$1-}, {-$3-})-},
    eval(index({-1234567890-}, {-$1-}) > -1), 1,
        {-__eval_module_pushStack_int({-$1-}, {-$3-})-},
    eval(index({-:\$-}, {-$1-}) > -1), 1,
        {-__eval_module_modifyStack({-$1-}, {-$3-})-},
    dnl default
        {--})
-})

dnl __eval_stringState(program_char, env_state_name, stack_name)
define({-__eval_stringState-}, {-
    ifelse({-$1-}, {-"-},
        {-define({-$2-}, STATUS_NORMAL)-},
        {-__eval_module_pushStack_char({-$1-}, {-$3-})-})
-})

dnl --- ENV / PARAMS ---
dnl > direction <
dnl direction global vars
define({-__current_col-}, 0)
define({-__current_row-}, 0)
define({-__step_col-}, 1)
define({-__step_row-}, 0)

dnl set_direction(x, y)
define({-set_direction-}, {-
    define({-__step_col-}, {-$1-})
    define({-__step_row-}, {-$2-})-})

dnl get_position()
define({-get_position-}, {-defn({-__current_row-}), defn({-__current_col-})-})

dnl step_position()
define({-step_position-}, {-
    define({-__current_col-}, eval(defn({-__current_col-}) + defn({-__step_col-})))
    define({-__current_row-}, eval(defn({-__current_row-}) + defn({-__step_row-})))
    ifelse(
    eval(defn({-__current_col-}) > defn({-PARAM_MAX_WIDTH-})), 1,
        {-define({-__current_col-}, 0)-},
    eval(defn({-__current_col-}) < 0), 1,
        {-define({-__current_col-}, defn({-PARAM_MAX_WIDTH-}))-},
    dnl default
        {--})
    ifelse(
    eval(defn({-__current_row-}) > defn({-PARAM_MAX_HEIGHT-})), 1,
        {-define({-__current_row-}, 0)-},
    eval(defn({-__current_row-}) < 0), 1,
        {-define({-__current_row-}, defn({-PARAM_MAX_HEIGHT-}))-},
    dnl default
        {--})
-})

dnl > interpreter <
dnl . status enum .
define({-STATUS_NORMAL-}, 0)
define({-STATUS_STRING-}, 1)
define({-STATUS_SKIP-}, 2)
define({-STATUS_HALT-}, 3)

dnl . evaluation function .
dnl evaluation(program_matrix_name, status_var, stack_var)
define({-evaluation-}, {-
    pick_matrix({-$1-}, get_position(), {-program_char-})

dnl divert(0)dnl
dnl defn({-program_char-})/get_position()/stack_peek({-__env_stack-})
dnl divert(-1)
    ifelse(
    defn({-program_char-}), {--},
        ,
    defn({-$2-}), defn({-STATUS_STRING-}),
        {-__eval_stringState(defn({-program_char-}), {-$2-}, {-$3-})-},
    defn({-$2-}), defn({-STATUS_NORMAL-}),
        {-__eval_normalState(defn({-program_char-}), {-$2-}, {-$3-}, {-$1-})-},
    defn({-$2-}), defn({-STATUS_SKIP-}),
        {-define({-$2-}, defn({-STATUS_NORMAL-}))-},
    dnl __env_status = STATUS_HALT
        {--})

    popdef({-program_char-})

    step_position()

    ifelse(defn({-$2-}), defn({-STATUS_HALT-}), {--},
        {-evaluation({-$1-}, {-$2-}, {-$3-})-})
-})

dnl start_program(program_matrix_name, matrix_width, matrix_height)
dnl   initialize env and start interpreter
define({-start_program-}, {-
    define({-PARAM_MAX_WIDTH-}, {-$2-})
    define({-PARAM_MAX_HEIGHT-}, {-$3-})
    define({-__env_status-}, defn({-STATUS_NORMAL-}))
    dnl __env_stack is automatically initialized
    evaluation({-$1-}, {-__env_status-}, {-__env_stack-})
-})

