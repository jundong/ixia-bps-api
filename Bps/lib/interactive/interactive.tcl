package provide interactive 0.2

package require Itcl

if {$tcl_platform(platform) != "windows" } {
  package require Expect
}

namespace eval interactive {;
  namespace export \
        interaction \
	interact
}; # end of nameespace installer

itcl::class interactive::Interaction {
  public variable inchan     stdin   ;# channel input will come in on
  public variable outchan    stdout  ;# channel output will go out on
  public variable editmode   emacs   ;# edit mode
  public variable onclose    {}      ;# command to run when the input is closed
  public variable prompt1    {% }    ;# first level prompt
  public variable prompt2    {}      ;# second level prompt
  public variable interp     {}      ;# interpreter to interact with
  public variable telnet     0       ;# send telnet codes
  public variable historylen 256     ;# number of historical commands to save
  public variable historyfile {}     ;# filename used to save history

  protected variable _oldinchan  {}  ;# channel that has the read fileevent
  protected variable _commandbuf {}  ;# variable to store partial commands
  protected variable _history    {}  ;# history of commands
  protected variable _historyindex {} ;# current index into the history when
                                     ;#scrolling through it
  protected variable _linebuf    {}  ;# variable to store partial line
  protected variable _lineindex  {}  ;# current index into the line
  protected variable _savedline  {}  ;# contents of linebuf before we started
                                     ;# cruising through history
  protected variable _sub_mode   {}  ;# variable indicating whether vi in insert
                                     ;# mode
  protected variable _emacs_         ;# array of key bindings
  protected variable _vi_insert      ;# array of key bindings
  protected variable _vi_command     ;# array of key bindings
  protected variable _partial_sequence {} ;# stores partially complete multikey
                                     ;# sequences
  protected variable _flush_history_task ;# task to save history to file

  protected common _telnet           ;# array of telnet codes
  protected common _editmodes        ;# array of allowed edit modes
  protected common _defaults-emacs    ;# array of bindings
  protected common _defaults-vi-insert ;# array of bindings
  protected common _defaults-vi-command ;# array of bindings

  constructor {args} {}
  destructor {}

  protected method _incoming {}
  protected method _trycallback {cb}
  protected method _init_telnet {sock}
  protected method _prompt {}
  protected method _move_in_history {incr}
  protected method _move_left {incr}
  protected method _move_right {incr}
  protected method _erase {amount}

  protected method _insert {string {lastindex {}}}
  protected method _get_possibles {}
  protected method _show_possibles {possibles}
  protected method _prev_word_start {}
  protected method _flush_history {{returnerror false}}
  protected method _onexit {command op}

  # The method below here (beginning with "__") may be used as key bindings
  protected method __backward-char {char}
  protected method __backward-delete-char {char}
  protected method __backward-delete-word {char}
  protected method __backward-kill-line {char}
  protected method __backward-word {char}
  protected method __beginning-of-line {char}
  protected method __beginning-of-text {char}
  protected method __capitalize-word {char}
  protected method __change-case {char}
  protected method __change-till-end-of-line {char}
  protected method __clear-screen {char}
  protected method __complete-word {char}
  protected method __complete-word-back {char}
  protected method __complete-word-fwd {char}
  protected method __complete-word-raw {char}
  protected method __copy-prev-word {char}
  protected method __copy-region-as-kill {char}
  protected method __dabbrev-expand {char}
  protected method __delete-char {char}
  protected method __delete-char-or-eof {char}
  protected method __delete-char-or-list {char}
  protected method __delete-char-or-list-or-eof {char}
  protected method __delete-word {char}
  protected method __digit-argument {char}
  protected method __digit {char}
  protected method __downcase-word {char}
  protected method __down-history {char}
  protected method __end-of-line {char}
  protected method __end-of-file {char}
  protected method __end-of-history {char}
  protected method __exchange-point-and-mark {char}
  protected method __expand-glob {char}
  protected method __expand-history {char}
  protected method __expand-line {char}
  protected method __expand-variables {char}
  protected method __forward-char {char}
  protected method __forward-word {char}
  protected method __history-search-backward {char}
  protected method __history-search-forward {char}
  protected method __i-search-back {char}
  protected method __i-search-fwd {char}
  protected method __insert-last-word {char}
  protected method __kill-line {char}
  protected method __kill-region {char}
  protected method __kill-whole-line {char}
  protected method __list-choices {char}
  protected method __list-choices-raw {char}
  protected method __list-glob {char}
  protected method __list-or-eof {char}
  protected method __magic-space {char}
  protected method __newline {char}
  protected method __normalize-command {char}
  protected method __normalize-path {char}
  protected method __overwrite-mode {char}
  protected method __quoted-insert {char}
  protected method __redisplay {char}
  protected method __run-help {char}
  protected method __self-insert-command {char}
  protected method __sequence-lead-in {char}
  protected method __spell-line {char}
  protected method __spell-word {char}
  protected method __toggle-literal-history {char}
  protected method __transpose-chars {char}
  protected method __tty-sigintr {char}
  protected method __undefined-key {char}
  protected method __upcase-word {char}
  protected method __up-history {char}
  protected method __vi-add {char}
  protected method __vi-add-at-eol {char}
  protected method __vi-beginning-of-next-word {char}
  protected method __vi-char-back {char}
  protected method __vi-char-fwd {char}
  protected method __vi-charto-back {char}
  protected method __vi-charto-find {char}
  protected method __vi-chg-meta {char}
  protected method __vi-cmd-mode {char}
  protected method __vi-cmd-mode-complete {char}
  protected method __vi-del-meta {char}
  protected method __vi-endword {char}
  protected method __vi-eword {char}
  protected method __vi-insert {char}
  protected method __vi-insert-at-bol {char}
  protected method __vi-repeat-char-back {char}
  protected method __vi-repeat-char-fwd {char}
  protected method __vi-repeat-search-back {char}
  protected method __vi-repeat-search-fwd {char}
  protected method __vi-replace-mode {char}
  protected method __vi-replace-char {char}
  protected method __vi-search-back {char}
  protected method __vi-search-fwd {char}
  protected method __vi-substitute-char {char}
  protected method __vi-substitute-mode {char}
  protected method __vi-undo {char}
  protected method __vi-word-back {char}
  protected method __vi-word-find {char}
  protected method __vi-zero {char}
  protected method __which-command {char}
  protected method __yank {char}
}

proc interactive::interaction {args} {
  uplevel interactive::Interaction $args
}

proc interactive::interact {args} {
  set name [eval [list interactive::Interaction #auto \
    -inchan stdin -outchan stdout \
    -prompt2 "? " \
    -onclose "set forever 1" \
    -telnet 0] \
    $args]

  global ::editmode
  set ::editmode emacs
  trace variable ::editmode w "interactive::change_edit_mode $name"

  vwait forever
}


proc interactive::change_edit_mode {interaction name1 name2 op} {
  global ::editmode
  $interaction configure -editmode [set ::editmode]
}


namespace eval interactive::Interaction {
  set _telnet(IAC) 255
  set _telnet(DONT) 254
  set _telnet(DO) 253
  set _telnet(WONT) 252
  set _telnet(WILL) 251
  set _telnet(TELOPT_ECHO)    1
  set _telnet(TELOPT_RCP)     2
  set _telnet(TELOPT_SGA)     3
  set _telnet(TELOPT_NAMS)    4
  set _telnet(TELOPT_STATUS)  5
  set _telnet(TELOPT_TM)      6
  set _telnet(TELOPT_RCTE)    7
  set _telnet(TELOPT_NAOL)    8
  set _telnet(TELOPT_NAOP)    9
  set _telnet(TELOPT_NAOCRD) 10
  set _telnet(TELOPT_NAOHTS) 11
  set _telnet(TELOPT_NAOHTD)   12
  set _telnet(TELOPT_NAOFFD)   13
  set _telnet(TELOPT_NAOVTS)   14
  set _telnet(TELOPT_NAOVTD)   15
  set _telnet(TELOPT_NAOLFD)   16
  set _telnet(TELOPT_XASCII)   17
  set _telnet(TELOPT_LOGOUT)   18
  set _telnet(TELOPT_BM)       19
  set _telnet(TELOPT_DET)      20
  set _telnet(TELOPT_SUPDUP)   21
  set _telnet(TELOPT_SUPDUPOUTPUT) 22
  set _telnet(TELOPT_SNDLOC)   23
  set _telnet(TELOPT_TTYPE)    24
  set _telnet(TELOPT_EOR)      25
  set _telnet(TELOPT_TUID)     26
  set _telnet(TELOPT_OUTMRK)   27
  set _telnet(TELOPT_TTYLOC)   28
  set _telnet(TELOPT_3270REGIME) 29
  set _telnet(TELOPT_X3PAD)    30
  set _telnet(TELOPT_NAWS)     31
  set _telnet(TELOPT_TSPEED)   32
  set _telnet(TELOPT_LFLOW)    33
  set _telnet(TELOPT_LINEMODE) 34
  set _telnet(TELOPT_XDISPLOC) 35
  set _telnet(TELOPT_OLD_ENVIRON) 36
  set _telnet(TELOPT_AUTHENTICATION) 37
  set _telnet(TELOPT_ENCRYPT)  38
  set _telnet(TELOPT_NEW_ENVIRON) 39
  set _telnet(TELOPT_EXOPL)    255

  set _editmodes {emacs vi}

  array set _defaults-emacs {
    "" beginning-of-line
    "" backward-char
    "" tty-sigintr
    "" delete-char-or-list-or-eof
    "" end-of-line
    "" forward-char
    "" backward-delete-char
    "	" complete-word
    "\n" newline
    "" kill-line
    "" clear-screen
    "\r" newline
    "" down-history
    "" up-history
    "" i-search-back
    "" transpose-chars
    "" kill-whole-line
    "" quoted-insert
    "" kill-region
    "" sequence-lead-in
    ""  yank
    "" sequence-lead-in
    " " self-insert-command
    ! self-insert-command
    "\"" self-insert-command
    "#" self-insert-command
    "$" self-insert-command
    "%" self-insert-command
    "&" self-insert-command
    "'" self-insert-command
    "(" self-insert-command
    ")" self-insert-command
    "*" self-insert-command
    "+" self-insert-command
    "," self-insert-command
    "-" self-insert-command
    "." self-insert-command
    "/" self-insert-command
    "0"  digit
    "1"  digit
    "2"  digit
    "3"  digit
    "4"  digit
    "5"  digit
    "6"  digit
    "7"  digit
    "8"  digit
    "9"  digit
    ":" self-insert-command
    ";" self-insert-command
    "<" self-insert-command
    "=" self-insert-command
    ">" self-insert-command
    "?" self-insert-command
    "@" self-insert-command
    A self-insert-command
    B self-insert-command
    C self-insert-command
    D self-insert-command
    E self-insert-command
    F self-insert-command
    G self-insert-command
    H self-insert-command
    I self-insert-command
    J self-insert-command
    K self-insert-command
    L self-insert-command
    M self-insert-command
    N self-insert-command
    O self-insert-command
    P self-insert-command
    Q self-insert-command
    R self-insert-command
    S self-insert-command
    T self-insert-command
    U self-insert-command
    V self-insert-command
    W self-insert-command
    X self-insert-command
    Y self-insert-command
    Z self-insert-command
    [ self-insert-command
    \\ self-insert-command
    ] self-insert-command
    ^ self-insert-command
    _ self-insert-command
    ` self-insert-command
    a self-insert-command
    b self-insert-command
    c self-insert-command
    d self-insert-command
    e self-insert-command
    f self-insert-command
    g self-insert-command
    h self-insert-command
    i self-insert-command
    j self-insert-command
    k self-insert-command
    l self-insert-command
    m self-insert-command
    n self-insert-command
    o self-insert-command
    p self-insert-command
    q self-insert-command
    r self-insert-command
    s self-insert-command
    t self-insert-command
    u self-insert-command
    v self-insert-command
    w self-insert-command
    x self-insert-command
    y self-insert-command
    z self-insert-command
    "\{" self-insert-command
    "|" self-insert-command
    "\}" self-insert-command
    "~" self-insert-command
    ""  backward-delete-char
    "¡" self-insert-command
    "¢" self-insert-command
    "£" self-insert-command
    "¤" self-insert-command
    "¥" self-insert-command
    "¦" self-insert-command
    "§" self-insert-command
    "¨" self-insert-command
    "©" self-insert-command
    "ª" self-insert-command
    "«" self-insert-command
    "¬" self-insert-command
    "­" self-insert-command
    "®" self-insert-command
    "¯" self-insert-command
    "°" self-insert-command
    "±" self-insert-command
    "²" self-insert-command
    "³" self-insert-command
    "´" self-insert-command
    "µ" self-insert-command
    "¶" self-insert-command
    "·" self-insert-command
    "¸" self-insert-command
    "¹" self-insert-command
    "º" self-insert-command
    "»" self-insert-command
    "¼" self-insert-command
    "½" self-insert-command
    "¾" self-insert-command
    "¿" self-insert-command
    "À" self-insert-command
    "Á" self-insert-command
    "Â" self-insert-command
    "Ã" self-insert-command
    "Ä" self-insert-command
    "Å" self-insert-command
    "Æ" self-insert-command
    "Ç" self-insert-command
    "È" self-insert-command
    "É" self-insert-command
    "Ê" self-insert-command
    "Ë" self-insert-command
    "Ì" self-insert-command
    "Í" self-insert-command
    "Î" self-insert-command
    "Ï" self-insert-command
    "Ð" self-insert-command
    "Ñ" self-insert-command
    "Ò" self-insert-command
    "Ó" self-insert-command
    "Ô" self-insert-command
    "Õ" self-insert-command
    "Ö" self-insert-command
    "×" self-insert-command
    "Ø" self-insert-command
    "Ù" self-insert-command
    "Ú" self-insert-command
    "Û" self-insert-command
    "Ü" self-insert-command
    "Ý" self-insert-command
    "Þ" self-insert-command
    "ß" self-insert-command
    "à" self-insert-command
    "á" self-insert-command
    "â" self-insert-command
    "ã" self-insert-command
    "ä" self-insert-command
    "å" self-insert-command
    "æ" self-insert-command
    "ç" self-insert-command
    "è" self-insert-command
    "é" self-insert-command
    "ê" self-insert-command
    "ë" self-insert-command
    "ì" self-insert-command
    "í" self-insert-command
    "î" self-insert-command
    "ï" self-insert-command
    "ð" self-insert-command
    "ñ" self-insert-command
    "ò" self-insert-command
    "ó" self-insert-command
    "ô" self-insert-command
    "õ" self-insert-command
    "ö" self-insert-command
    "÷" self-insert-command
    "ø" self-insert-command
    "ù" self-insert-command
    "ú" self-insert-command
    "û" self-insert-command
    "ü" self-insert-command
    "ý" self-insert-command
    "þ" self-insert-command
    "ÿ" self-insert-command

    {[A} up-history
    {[B} down-history
    {[C} forward-char
    {[D} backward-char
    "\[H" beginning-of-line
    "\[F" end-of-line
    "\[1~" beginning-of-line
    "\[4~" end-of-line
    "OA" up-history
    "OB" down-history
    "OC" forward-char
    "OD" backward-char
    "OH" beginning-of-line
    "OF" end-of-line
    "" list-choices
    "" backward-delete-word
    "	" complete-word
    "" clear-screen
    "" complete-word
    "" copy-prev-word
    " "  expand-history
    "!" expand-history
    "$" spell-line
    "/" dabbrev-expand
    "0" digit-argument
    "1" digit-argument
    "2" digit-argument
    "3" digit-argument
    "4" digit-argument
    "5" digit-argument
    "6" digit-argument
    "7" digit-argument
    "8" digit-argument
    "9" digit-argument
    "?" which-command
    "B" backward-word
    "C" capitalize-word
    "D" delete-word
    "F" forward-word
    "H" run-help
    "L" downcase-word
    "N" history-search-forward
    "P" history-search-backward
    "R" toggle-literal-history
    "S" spell-word
    "U" upcase-word
    "W" copy-region-as-kill
    "_" insert-last-word
    "b" backward-word
    "c" capitalize-word
    "d" delete-word
    "f" forward-word
    "h" run-help
    "l" downcase-word
    "n" history-search-forward
    "p" history-search-backward
    "r" toggle-literal-history
    "s" spell-word
    "u" upcase-word
    "w" copy-region-as-kill
    "" backward-delete-word
    "" exchange-point-and-mark
    "*" expand-glob
    "$" expand-variables
    "G" list-glob
    "g" list-glob
    "n" normalize-path
    "N" normalize-path
    "?" normalize-command
    "	" complete-word-raw
    "" list-choices-raw
  }

  array set _defaults-vi-insert {
    ""  beginning-of-line
    ""  backward-char
    ""  tty-sigintr
    ""  list-or-eof
    ""  end-of-line
    ""  forward-char
    ""  list-glob
    ""  backward-delete-char
    "	"  complete-word
    "\n" newline
    ""  kill-line
    ""  clear-screen
    "
"  newline
    ""  down-history
    ""  up-history
    ""  redisplay
    ""  transpose-chars
    ""  backward-kill-line
    ""  quoted-insert
    ""  backward-delete-word
    ""  expand-line
    ""  vi-cmd-mode
    " " self-insert-command
    "!" self-insert-command
    "\"" self-insert-command
    "#" self-insert-command
    "$" self-insert-command
    "%" self-insert-command
    "&" self-insert-command
    "'" self-insert-command
    "(" self-insert-command
    ")" self-insert-command
    "*" self-insert-command
    "+" self-insert-command
    "," self-insert-command
    "-" self-insert-command
    "." self-insert-command
    "/" self-insert-command
    0 self-insert-command
    1 self-insert-command
    2 self-insert-command
    3 self-insert-command
    4 self-insert-command
    5 self-insert-command
    6 self-insert-command
    7 self-insert-command
    8 self-insert-command
    9 self-insert-command
    : self-insert-command
    ";" self-insert-command
    < self-insert-command
    = self-insert-command
    > self-insert-command
    ? self-insert-command
    @ self-insert-command
    A self-insert-command
    B self-insert-command
    C self-insert-command
    D self-insert-command
    E self-insert-command
    F self-insert-command
    G self-insert-command
    H self-insert-command
    I self-insert-command
    J self-insert-command
    K self-insert-command
    L self-insert-command
    M self-insert-command
    N self-insert-command
    O self-insert-command
    P self-insert-command
    Q self-insert-command
    R self-insert-command
    S self-insert-command
    T self-insert-command
    U self-insert-command
    V self-insert-command
    W self-insert-command
    X self-insert-command
    Y self-insert-command
    Z self-insert-command
    \[ self-insert-command
    \\ self-insert-command
    \] self-insert-command
    "^" self-insert-command
    "_" self-insert-command
    "`" self-insert-command
    a self-insert-command
    b self-insert-command
    c self-insert-command
    d self-insert-command
    e self-insert-command
    f self-insert-command
    g self-insert-command
    h self-insert-command
    i self-insert-command
    j self-insert-command
    k self-insert-command
    l self-insert-command
    m self-insert-command
    n self-insert-command
    o self-insert-command
    p self-insert-command
    q self-insert-command
    r self-insert-command
    s self-insert-command
    t self-insert-command
    u self-insert-command
    v self-insert-command
    w self-insert-command
    x self-insert-command
    y self-insert-command
    z self-insert-command
    "\{" self-insert-command
    "|" self-insert-command
    "\}" self-insert-command
    ~ self-insert-command
     backward-delete-char
    ¡ self-insert-command
    ¢ self-insert-command
    £ self-insert-command
    ¤ self-insert-command
    ¥ self-insert-command
    ¦ self-insert-command
    § self-insert-command
    ¨ self-insert-command
    © self-insert-command
    ª self-insert-command
    « self-insert-command
    ¬ self-insert-command
    ­ self-insert-command
    ® self-insert-command
    ¯ self-insert-command
    ° self-insert-command
    ± self-insert-command
    ² self-insert-command
    ³ self-insert-command
    ´ self-insert-command
    µ self-insert-command
    ¶ self-insert-command
    · self-insert-command
    ¸ self-insert-command
    ¹ self-insert-command
    º self-insert-command
    » self-insert-command
    ¼ self-insert-command
    ½ self-insert-command
    ¾ self-insert-command
    ¿ self-insert-command
    À self-insert-command
    Á self-insert-command
    Â self-insert-command
    Ã self-insert-command
    Ä self-insert-command
    Å self-insert-command
    Æ self-insert-command
    Ç self-insert-command
    È self-insert-command
    É self-insert-command
    Ê self-insert-command
    Ë self-insert-command
    Ì self-insert-command
    Í self-insert-command
    Î self-insert-command
    Ï self-insert-command
    Ð self-insert-command
    Ñ self-insert-command
    Ò self-insert-command
    Ó self-insert-command
    Ô self-insert-command
    Õ self-insert-command
    Ö self-insert-command
    × self-insert-command
    Ø self-insert-command
    Ù self-insert-command
    Ú self-insert-command
    Û self-insert-command
    Ü self-insert-command
    Ý self-insert-command
    Þ self-insert-command
    ß self-insert-command
    à self-insert-command
    á self-insert-command
    â self-insert-command
    ã self-insert-command
    ä self-insert-command
    å self-insert-command
    æ self-insert-command
    ç self-insert-command
    è self-insert-command
    é self-insert-command
    ê self-insert-command
    ë self-insert-command
    ì self-insert-command
    í self-insert-command
    î self-insert-command
    ï self-insert-command
    ð self-insert-command
    ñ self-insert-command
    ò self-insert-command
    ó self-insert-command
    ô self-insert-command
    õ self-insert-command
    ö self-insert-command
    ÷ self-insert-command
    ø self-insert-command
    ù self-insert-command
    ú self-insert-command
    û self-insert-command
    ü self-insert-command
    ý self-insert-command
    þ self-insert-command
    ÿ self-insert-command
  }

  array set _defaults-vi-command {
    ""  beginning-of-line
    ""  tty-sigintr
    ""  list-choices
    ""  end-of-line
    ""  list-glob
    ""  backward-char
    "	"  vi-cmd-mode-complete
    "\n" newline
    ""  kill-line
    ""  clear-screen
    "
"  newline
    ""  down-history
    ""  up-history
    ""  redisplay
    ""  backward-kill-line
    ""  backward-delete-word
    ""  expand-line
    ""  sequence-lead-in
    " " forward-char
    ! expand-history
    $ end-of-line
    * expand-glob
    + down-history
    , vi-repeat-char-back
    - up-history
    / vi-search-fwd
    0  vi-zero
    1  digit-argument
    2  digit-argument
    3  digit-argument
    4  digit-argument
    5  digit-argument
    6  digit-argument
    7  digit-argument
    8  digit-argument
    9  digit-argument
    \; vi-repeat-char-fwd
    ? vi-search-back
    A vi-add-at-eol
    B vi-word-back
    C change-till-end-of-line
    D kill-line
    E vi-endword
    F vi-char-back
    G end-of-history
    I vi-insert-at-bol
    J history-search-forward
    K history-search-backward
    N vi-repeat-search-back
    O sequence-lead-in
    R vi-replace-mode
    S vi-substitute-mode
    T vi-charto-back
    V expand-variables
    W vi-word-fwd
    X backward-delete-char
    \[ sequence-lead-in
    ^ beginning-of-text
    a vi-add
    b backward-word
    c vi-chg-meta
    d vi-del-meta
    e vi-eword
    f vi-char-fwd
    h backward-char
    i vi-insert
    j down-history
    k up-history
    l forward-char
    n vi-repeat-search-fwd
    r vi-replace-char
    s vi-substitute-char
    t vi-charto-fwd
    u vi-undo
    v expand-variables
    w vi-beginning-of-next-word
    x delete-char-or-eof
    ~ change-case
     backward-delete-char
    ¿ run-help
    Ï sequence-lead-in
    Û sequence-lead-in

    \[A up-history
    \[B down-history
    \[C forward-char
    \[D backward-char
    \[H beginning-of-line
    \[F end-of-line
    \[1~ beginning-of-line
    \[4~ end-of-line
    OA up-history
    OB down-history
    OC forward-char
    OD backward-char
    OH beginning-of-line
    OF end-of-line
    ? run-help
    {[A} up-history
    {[B} down-history
    {[C} forward-char
    {[D} backward-char
    {[H} beginning-of-line
    {[F} end-of-line
    OA up-history
    OB down-history
    OC forward-char
    OD backward-char
    OH beginning-of-line
    OF end-of-line
  }
}

itcl::body interactive::Interaction::constructor {args} {
  eval configure $args
  array set _emacs_ [array get _defaults-emacs]
  array set _vi_insert [array get _defaults-vi-insert]
  array set _vi_command [array get _defaults-vi-command]
  puts -nonewline $outchan $prompt1
  trace add execution ::exit enter [namespace code [list $this _onexit]]
}
proc echo {args} { puts $args }

itcl::body interactive::Interaction::destructor {} {
    trace remove execution ::exit enter [namespace code [list $this _onexit]]
    if {[info exists _flush_history_task]} {
        after cancel $_flush_history_task
    }
}

itcl::configbody interactive::Interaction::inchan {
  if {[string compare $inchan $_oldinchan] == 0} {
    return
  }
  if {[catch {fileevent $inchan readable [namespace code "$this _incoming"]} err]} {
    error $err
  }
  if {"" != $_oldinchan} {
    fileevent $_oldinchan readable ""
  }
  set _oldinchan $inchan
  fconfigure $inchan -blocking no -buffering none -translation auto
  global tcl_platform
  if {$tcl_platform(platform) != "windows" } {
  		fconfigure $inchan -encoding binary
  }
  if {$tcl_platform(platform) != "windows" 
  		&& [string compare $inchan "stdin"] == 0} {
    stty raw -echo
  }
}

itcl::configbody interactive::Interaction::outchan {
  if {[catch {fileevent $outchan writable} err]} {
    error $err
  }
  fconfigure $outchan -buffering none
  global tcl_platform
  if {$tcl_platform(platform) != "windows" } {
  		fconfigure $outchan -encoding binary
  }
  if {[string compare $outchan "stdout"] == 0} {
    fconfigure $outchan -translation crlf
  }
}

itcl::configbody interactive::Interaction::editmode {
  if {[lsearch $_editmodes $editmode] == -1} {
    error "-editmode must be one of: $_editmodes"
  }
  if {[string compare $editmode vi] == 0} {
    set _sub_mode insert
  } else {
    set _sub_mode {}
  }
}

itcl::configbody interactive::Interaction::telnet {
  if {![string is boolean $telnet]} {
    error "value for -telnet must be boolean"
  }
  _init_telnet $outchan
}

itcl::configbody interactive::Interaction::historyfile {
  if {$historyfile != ""} {
    if {[file readable $historyfile]} {
        # try to pick up history from the file
        set f [open $historyfile]
        set code [catch {
            eval lappend _history [lrange [split [read $f] \n] 0 end-1]
            if {[llength $_history] > $historylen} {
              set _history [lreplace $_history 0 [expr [llength $_history] - $historylen - 1]]
            }
        } ret]
        close $f
        if {$code} {
            global errorCode errorInfo
puts $errorInfo
            return -code $code -errorcode $errorCode -errorinfo $errorInfo $ret
        }
    }
    _flush_history true
  }
}

itcl::body interactive::Interaction::_incoming {} {
  if {[eof $inchan]} {
    _trycallback $onclose
    fileevent $inchan readable {}
    _flush_history
    return
  }
  set data [read $inchan]
  if {[string match "[format %c* $_telnet(IAC)]" $data]} {
    return
  }
  set data [split $data {}]

  while {[llength $data] > 0} {
    set char [lindex $data 0]
    set data [lreplace $data 0 0]

    binary scan $char H* foo
    if {$foo == 00} {
      continue
    }
    if {[string length $_partial_sequence] == 0} {
      if {[catch {__[set _[set editmode]_[set _sub_mode]($char)] $char} err]} {
        __undefined-key $char
      }
    } else {
      # building a multi-key sequence
      append _partial_sequence $char
      if {[info exists _[set editmode]_[set _sub_mode]($_partial_sequence)]} {
        # found this sequence
        if {[catch {__[set _[set editmode]_[set _sub_mode]($_partial_sequence)] $_partial_sequence} err]} {
puts $err
          __undefined-key $_partial_sequence
        }
        set _partial_sequence {}
      } elseif {[lsearch -glob [array names _[set editmode]_[set _sub_mode]] \
              [string map {[ \\[ ] \\] * \\* ? \\?} [set _partial_sequence]]*] \
                 == -1} {
        # no such sequence exists
        __undefined-key $_partial_sequence
        set _partial_sequence {}
      }
      # otherwise, still need more chars, just wait...
    }
  }
  return
}

itcl::body interactive::Interaction::_trycallback {cb} {
  if {"" == $cb} return
  catch {uplevel #0 $cb}
}

itcl::body interactive::Interaction::_init_telnet {sock} {
  if {$telnet && "" != $outchan} {
    puts -nonewline $outchan [format "%c%c%c" $_telnet(IAC) $_telnet(WILL) $_telnet(TELOPT_SGA)]
    puts -nonewline $outchan [format "%c%c%c" $_telnet(IAC) $_telnet(WILL) $_telnet(TELOPT_ECHO)]
    puts -nonewline $outchan [format "%c%c%c" $_telnet(IAC) $_telnet(DONT) $_telnet(TELOPT_LINEMODE)]
  }
}

itcl::body interactive::Interaction::_prompt {} {
  if {"" == $_commandbuf} {
    return $prompt1
  }
  return $prompt2
}

itcl::body interactive::Interaction::_move_in_history {incr} {
  if {$incr > 0 \
      && "" == $_historyindex} {
    return
  }
  if {$incr < 0 \
      && "" == $_historyindex} {
    set _historyindex [llength $_history]
    set _savedline $_linebuf
  }
  incr _historyindex $incr

  set eraseme [string length $_linebuf]

  if {$_historyindex < 0} {
    set _historyindex 0
  }
  if {$_historyindex > [expr [llength $_history] -1]} {
    set _historyindex ""
    set _linebuf $_savedline
    set _lineindex ""
  } else {
    set _lineindex ""
    set _linebuf [lindex $_history $_historyindex]
  }
  puts -nonewline $outchan "\r[_prompt]$_linebuf"
  _erase [expr $eraseme - [string length $_linebuf]]
}

itcl::body interactive::Interaction::_move_left {amount} {
  if {[string length $_lineindex] == 0} {
    set _lineindex [string length $_linebuf]
  }
  set oldindex $_lineindex
  incr _lineindex -$amount
  if {$_lineindex < 0} {
    set _lineindex 0
    puts -nonewline $outchan "\r[_prompt]"
    return
  }
  for {set x 0} {$x < $amount} {incr x} {
    puts -nonewline $outchan ""
  }
}

itcl::body interactive::Interaction::_move_right {amount} {
  if {[string length $_lineindex] == 0} {
    return
  }
  set oldindex $_lineindex
  incr _lineindex $amount
  if {$_lineindex >= [string length $_linebuf]} {
    puts -nonewline $outchan [string range $_linebuf $oldindex end]
    set _lineindex ""

    return
  }
  puts -nonewline $outchan [string range $_linebuf $oldindex [expr $_lineindex -1]]
}

itcl::body interactive::Interaction::_erase {amount} {
  for {set x 0} {$x < $amount} {incr x} {
    puts -nonewline $outchan " "
  }
  for {set x 0} {$x < $amount} {incr x} {
    puts -nonewline $outchan ""
  }
}

itcl::body interactive::Interaction::_insert {string {lastindex {}}} {
  if {$_lineindex == ""} {
    append _linebuf $string
    puts -nonewline $outchan $string
  } else {
    set eraseme [string length $_linebuf]
    if {$lastindex == ""} {
      set remainder $string[string range $_linebuf $_lineindex end]
    } else {
      set remainder $string[string range $_linebuf [expr $lastindex + 1]  end]
    }
    set _linebuf [string range $_linebuf 0 [expr $_lineindex -1]]$remainder
    puts -nonewline $outchan $remainder

    set extra [expr $eraseme - [string length $_linebuf]]
    if {$extra > 0} {
      _erase $extra
    }

    for {set x [string length $string]} {$x < [string length $remainder]} {incr x} {
      puts -nonewline $outchan ""
    }
    incr _lineindex [string length $string]
    if {$_lineindex >= [string length $_linebuf]} {
      set _lineindex ""
    }
  }
}

itcl::body interactive::Interaction::_get_possibles {} {
  if {"" == $_lineindex} {
    set portion $_linebuf
  } else {
    set portion [string range $_linebuf 0 [expr $_lineindex-1]]
  }
  if {1 || $portion == [string trimright $portion]} {
    # try to find a variable
    if {[string match {*\$*} [lindex $portion end]]} {
      regexp {\$([^\$]*)$} [lindex $portion end] var varname
      if {"" == $interp} {
	set possibles [uplevel #0 info vars $varname*]
      } else {
	set possibles [$interp eval info vars $varname*]
      }
      set munged {}
      foreach possible $possibles {
	lappend munged "\$$possible "
      }
      return [list $portion $munged]
    } elseif {[llength [string range $portion \
                          [expr [string last {[} $portion] +1] \
		        end] ] <= 1} {
      set cmdpart [string trimleft \
               [string range $portion [expr [string last {[} $portion]+1] end]]
      if {[string index $cmdpart 0] == "\["} {
	set cmdpart [string range $cmdpart 1 end]
	set bracketp \[
      } else {
	set bracketp {}
      }
      #set cmdpart [string trimleft $portion]
      set lastqual [string last $cmdpart ::]
      set namespace [string range $cmdpart 0 $lastqual]
      if {"" == $namespace} {
	set namespace ::
	set partial $cmdpart
      } else {
	set partial [string range $cmdpart [expr $lastqual+2] end]
      }
      if {"" == $interp} {
	set possibles [uplevel #0 info commands $cmdpart*]
	set namespaces [uplevel #0 namespace children $namespace $partial*]
      } else {
	set possibles [$interp eval info commands $cmdpart*]
	set namespaces [$interp eval namespace children $namespace $partial*]
      }
      set munged {}
      foreach possible $possibles {
	if {[string match ::* $cmdpart]} {
	  lappend munged "$bracketp$possible "
	} else {
	  lappend munged "$bracketp[string trimleft $possible ::] "
	}
      }
      foreach nspc $namespaces {
	if {[string match ::* $cmdpart]} {
	  lappend munged $bracketp${namespace}::${nspc}::
	} else {
	  lappend munged $bracketp[string trimleft ${namespace}::${nspc}:: ::]
	}
      }
    }
    return [list $portion $munged]
  }
  return
}

itcl::body interactive::Interaction::_show_possibles {possibles} {
  puts $outchan ""
  foreach possible $possibles {
    puts -nonewline $outchan [string trimright $possible]
    puts -nonewline $outchan " "
  }
  puts $outchan ""
  puts -nonewline $outchan [_prompt]$_linebuf
  if {"" != $_lineindex} {
    for {set x $_lineindex} {$x < [string length $_linebuf]} {incr x} {
      puts -nonewline $outchan ""
    }
  }
}

itcl::body interactive::Interaction::_prev_word_start {} {
  if {[string compare $_lineindex ""] == 0} {
    set ws [expr [string length $_linebuf] - 1]
  } else {
    set ws $_lineindex
  }
  
  if {$ws == [string wordstart $_linebuf $ws]} {
    incr ws -1
    while {![string is alnum [string index $_linebuf $ws]]} {
      incr ws -1
    }
  }
  set ws [string wordstart $_linebuf $ws]
  return $ws
}

itcl::body interactive::Interaction::_flush_history {{returnerror false}} {
    if {[info exists _flush_history_task]} {
        after cancel $_flush_history_task
        unset _flush_history_task
    }
    if {$historyfile != ""} {
        set code [catch {
            set dir [file dirname $historyfile]
            if {![file isdirectory $dir]} {
                file mkdir $dir
            }
            set f [open $historyfile w]
            set code [catch {
                foreach line $_history {
                    puts $f $line
                }
            } ret]
            close $f
            if {$code} {
                global errorCode errorInfo
                return -code $code -errorcode $errorCode -errorinfo $errorInfo $ret
            }
        } ret]
        if {$code && $returnerror} {
            global errorCode errorInfo
            return -code $code -errorcode $errorCode -errorinfo $errorInfo $ret
        }
    }
}

itcl::body interactive::Interaction::_onexit {command op} {
    _flush_history
}

itcl::body interactive::Interaction::__backward-char {char} {
  _move_left 1
}

itcl::body interactive::Interaction::__backward-delete-char {char} {
  _move_left 1
  _insert "" $_lineindex
}

itcl::body interactive::Interaction::__backward-delete-word {char} {
  __backward-word $char
  __delete-word $char
}

itcl::body interactive::Interaction::__backward-kill-line {char} {
  puts -nonewline $outchan "\r[_prompt]"
  if {[string compare $_lineindex ""] == 0} {
    set end [string length $_linebuf]
  } else {
    set end [expr $_lineindex - 1]
  }
  set _lineindex 0
  _insert "" $end
}

itcl::body interactive::Interaction::__backward-word {char} {
  if {[string length $_linebuf] == 0
      || [string compare $_lineindex 0] == 0} {
    return
  }
  set ws [_prev_word_start]
  if {[string compare $_lineindex ""] == 0} {
    _move_left [expr [string length $_linebuf] - $ws]
  } else {
    _move_left [expr $_lineindex - $ws]
  }
}

itcl::body interactive::Interaction::__beginning-of-line {char} {
  if {[string length $_linebuf] > 0} {
    set _lineindex 0
    puts -nonewline $outchan "\r[_prompt]"
  }
}

itcl::body interactive::Interaction::__beginning-of-text {char} {
  set firstnonblank [string index [string trimleft $_linebuf] 0]
  set firstnonblank [string first $firstnonblank $_linebuf]
  __beginning-of-line $char
  _move_right $firstnonblank
}

itcl::body interactive::Interaction::__capitalize-word {char} {
  if {[string compare $_lineindex ""] == 0} {
    return
  }
  while {![string is alnum [string index $_linebuf $_lineindex]]} {
    _move_right 1
  }
  set _linebuf [string replace $_linebuf $_lineindex $_lineindex \
                      [string toupper [string index $_linebuf $_lineindex]] ]
  __forward-word $char
}

itcl::body interactive::Interaction::__change-case {char} {
  if {[string compare $_lineindex ""] == 0} {
    __undefined-key $char
    return
  }
  if {[string is upper [string index $_linebuf $_lineindex]]} {
    set _linebuf [string replace $_linebuf $_lineindex $_lineindex \
                      [string tolower [string index $_linebuf $_lineindex]] ]
  } else {
    set _linebuf [string replace $_linebuf $_lineindex $_lineindex \
                      [string toupper [string index $_linebuf $_lineindex]] ]
  }
  _move_right 1
}

itcl::body interactive::Interaction::__change-till-end-of-line {char} {
  __kill-line $char
  __end-of-line $char
  set _sub_mode insert
}

itcl::body interactive::Interaction::__clear-screen {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__complete-word {char} {
  foreach {portion possibles} [_get_possibles] {break}
  if {![info exists possibles]} {
    return
  }
  if {[llength $possibles] == 1} {
    _insert [string range [lindex $possibles 0] \
                          [string length [lindex $portion end]] end] 
    return
  }
  # determine if there is a substring that we know goes there...
  set common [string range [lindex $possibles 0] \
               [string length [lindex $portion end]] end]
  foreach x $possibles {
    set x [string range $x [string length [lindex $portion end]] end]
    if {![string match $common* $x]} {
      set y 0
      while {$y < [string length $common]} {
        if {[string compare [string index $common $y] [string index $x $y]]
            != 0} {
          set common [string range $common 0 [expr $y -1]]
          break
        }
        incr y
      }
    }
  }
  if {"" != $common} {
    _insert $common
    return
  }
  _show_possibles $possibles
}

#               Like complete-word-fwd, but steps up from the  end
#               of the list.
#
itcl::body interactive::Interaction::__complete-word-back {char} {
#???????????????????????????????
}

#               Replaces  the  current word with the first word in
#               the list of possible completions.  May be repeated
#               to  step down through the list.  At the end of the
#               list, beeps and reverts to the incomplete word.
#
itcl::body interactive::Interaction::__complete-word-fwd {char} {
#???????????????????????????????
}

#               Like complete-word, but ignores user-defined  com-
#               pletions.
#
itcl::body interactive::Interaction::__complete-word-raw {char} {
  __complete-word $char
}

#               Copies  the previous word in the current line into
#               the input buffer.  See also insert-last-word.
#
itcl::body interactive::Interaction::__copy-prev-word {char} {
  set ws [_prev_word_start]
  if {[string compare $_lineindex ""] == 0} {
     _insert [string range $_linebuf $ws end]
  } else {
    _insert [string range $_linebuf $ws [expr $_lineindex-1]]
  }
}

itcl::body interactive::Interaction::__copy-region-as-kill {char} {
#???????????????????????????????
}

#               Expands the current word to the most  recent  pre-
#               ceding one for which the current is a leading sub-
#               string, wrapping around the history list (once) if
#               necessary.   Repeating  dabbrev-expand without any
#               intervening typing changes to  the  next  previous
#               word  etc.,  skipping  identical matches much like
#               history-search-backward does.
#
itcl::body interactive::Interaction::__dabbrev-expand {char} {
}

#               Deletes the character under the cursor.  See  also
#               delete-char-or-list-or-eof.
#
itcl::body interactive::Interaction::__delete-char {char} {
  _insert "" $_lineindex
}

#               Does delete-char if there is a character under the
#               cursor or end-of-file on an empty line.  See  also
#               delete-char-or-list-or-eof.
#
itcl::body interactive::Interaction::__delete-char-or-eof {char} {
  if {[string length $_linebuf] == 0} {
    __end-of-file $char
  } else {
    __delete-char $char
  }
}

#               Does delete-char if there is a character under the
#               cursor or list-choices at the  end  of  the  line.
#               See also delete-char-or-list-or-eof.
#
itcl::body interactive::Interaction::__delete-char-or-list {char} {
  if {$_lineindex == ""} {
    if {[string length $_linebuf] != 0} {
      __list-choices $char
    }
  } else {
    __delete-char $char
  }
}

#               Does delete-char if there is a character under the
#               cursor, list-choices at the end  of  the  line  or
#               end-of-file  on  an  empty  line.   See also those
#               three commands, each of which does only  a  single
#               action,  and  delete-char-or-eof,  delete-char-or-
#               list and list-or-eof, each of which does a differ-
#               ent two out of the three.
#
itcl::body interactive::Interaction::__delete-char-or-list-or-eof {char} {
  if {$_lineindex == ""} {
    if {[string length $_linebuf] == 0} {
      __end-of-file $char
    } else {
      __list-choices $char
    }
  } else {
    __delete-char $char
  }
}

itcl::body interactive::Interaction::__delete-word {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__digit-argument {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__digit {char} {
  _insert $char
}

itcl::body interactive::Interaction::__downcase-word {char} {
#???????????????????????????????
}

#               Like  up-history,  but steps down, stopping at the
#               original input line.
#
itcl::body interactive::Interaction::__down-history {char} {
  _move_in_history 1
}

itcl::body interactive::Interaction::__end-of-line {char} {
  if {[string length _lineindex] > 0} {
    set _lineindex ""
    puts -nonewline $outchan "\r[_prompt]"
    puts -nonewline $outchan $_linebuf
  }
}

#               Signals an end of file, causing the shell to  exit
#               unless  the ignoreeof shell variable (q.v.) is set
#               to prevent this.  See also delete-char-or-list-or-
#               eof.
#
itcl::body interactive::Interaction::__end-of-file {char} {
  if {[string compare $inchan stdin] == 0} {
    exit
  }
  after idle "close $inchan"
  if {[string compare $inchan $outchan] != 0} {
    after idle "close $outchan"
  }
}

itcl::body interactive::Interaction::__end-of-history {char} {
  _move_in_history $historylen
}

itcl::body interactive::Interaction::__exchange-point-and-mark {char} {
#???????????????????????????????
}

#               Expands the glob-pattern to the left of  the  cur-
#               sor.  See Filename substitution.
#
itcl::body interactive::Interaction::__expand-glob {char} {
#???????????????????????????????
}

#               Expands history substitutions in the current word.
#               See History substitution.  See  also  magic-space,
#               toggle-literal-history  and  the  autoexpand shell
#               variable.
#
itcl::body interactive::Interaction::__expand-history {char} {
#???????????????????????????????
}

#               Like expand-history, but expands history substitu-
#               tions in each word in the input buffer,
#
itcl::body interactive::Interaction::__expand-line {char} {
#???????????????????????????????
}

#               Expands the variable to the left  of  the  cursor.
#               See Variable substitution.
#
itcl::body interactive::Interaction::__expand-variables {char} {
  set ws [_prev_word_start]
  if {[string index $_linebuf [expr $ws - 1]] != "$"} {
    __undefined-key $char
    return
  }
  if {[string compare $_lineindex ""] == 0} {
    set varname [string range $_linebuf $ws end]
  } else {
    set varname [string range $_linebuf $ws $_lineindex]
  }
  if {![uplevel #0 info exists $varname]} {
    __undefined-key $char
    return
  }
  if {[string compare $_lineindex ""] == 0} {
    set end [string length $_linebuf]
    _move_left [expr [string length $_linebuf] - $ws]
  } else {
    set end $_lineindex
    _move_left [expr $_lineindex - $ws]
  }
  _insert [uplevel #0 set $varname] $end
}

itcl::body interactive::Interaction::__forward-char {char} {
  _move_right 1
}

itcl::body interactive::Interaction::__forward-word {char} {
  if {[string compare $_lineindex ""] == 0} {
    return
  }
  set we $_lineindex
  while {![string is alnum [string index $_linebuf $we]]} {
    incr we
  }
  set we [string wordend $_linebuf $we]
  _move_right [expr $we - $_lineindex]
}

#               Searches  backwards through the history list for a
#               command beginning with the current contents of the
#               input  buffer  up to the cursor and copies it into
#               the input buffer.  The  search  string  may  be  a
#               glob-pattern  (see Filename substitution) contain-
#               ing `*', `?', `[]' or `{}'.  up-history and  down-
#               history will proceed from the appropriate point in
#               the history list.  Emacs mode only.  See also his-
#               tory-search-forward and i-search-back.
#
itcl::body interactive::Interaction::__history-search-backward {char} {
#???????????????????????????????
}

#               Like  history-search-backward,  but  searches for-
#               ward.
#
itcl::body interactive::Interaction::__history-search-forward {char} {
#???????????????????????????????
}

#               Searches  backward  like  history-search-backward,
#               copies  the first match into the input buffer with
#               the cursor positioned at the end of  the  pattern,
#               and  prompts  with  `bck:  '  and the first match.
#               Additional characters may be typed to  extend  the
#               search,  i-search-back  may  be  typed to continue
#               searching with the same pattern,  wrapping  around
#               the history list if necessary, (i-search-back must
#               be bound to a single character for this  to  work)
#               or  one of the following special characters may be
#               typed:
#
#                   ^W      Appends the rest of the word under the
#                           cursor to the search pattern.
#                   delete (or any character bound to backward-
#                   delete-char)
#                           Undoes the effect of the last  charac-
#                           ter typed and deletes a character from
#                           the search pattern if appropriate.
#                   ^G      If the previous search was successful,
#                           aborts  the  entire  search.   If not,
#                           goes  back  to  the  last   successful
#                           search.
#                   escape  Ends  the  search, leaving the current
#                           line in the input buffer.
#
#               Any other character not bound to  self-insert-com-
#               mand  terminates  the  search, leaving the current
#               line in the input buffer, and is then  interpreted
#               as normal input.  In particular, a carriage return
#               causes the current line  to  be  executed.   Emacs
#               mode  only.   See  also  i-search-fwd and history-
#               search-backward.
#
itcl::body interactive::Interaction::__i-search-back {char} {
#???????????????????????????????
}

#               Like i-search-back, but searches forward.
#
itcl::body interactive::Interaction::__i-search-fwd {char} {
#???????????????????????????????
}

#               Inserts the last word of the previous  input  line
#               (`!$') into the input buffer.  See also copy-prev-
#               word.
#
itcl::body interactive::Interaction::__insert-last-word {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__kill-line {char} {
  _insert "" [string length $_linebuf]
}

itcl::body interactive::Interaction::__kill-region {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__kill-whole-line {char} {
  puts -nonewline $outchan "\r[_prompt]"
  set _lineindex 0
  _insert "" [string length $_linebuf]
}

#               Lists completion possibilities as described  under
#               Completion  and listing.  See also delete-char-or-
#               list-or-eof and list-choices-raw.
#
itcl::body interactive::Interaction::__list-choices {char} {
  foreach {portion possibles} [_get_possibles] {break}
  if {![info exists possibles]} {
    return
  }
  _show_possibles $possibles
}

#               Lists  (via the ls-F builtin) matches to the glob-
#               pattern (see Filename substitution) to the left of
#               the cursor.
#
itcl::body interactive::Interaction::__list-choices-raw {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__list-glob {char} {
#???????????????????????????????
}

#               Does list-choices or end-of-file on an empty line.
#               See also delete-char-or-list-or-eof.
#
itcl::body interactive::Interaction::__list-or-eof {char} {
#???????????????????????????????
}

#               Expands history substitutions in the current line,
#               like  expand-history, and appends a space.  magic-
#               space is designed to be bound to  the  space  bar,
#               but is not bound by default.
#
itcl::body interactive::Interaction::__magic-space {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__newline {char} {
  global tcl_platform
  puts -nonewline $outchan "\n"
  set _historyindex {}
  if {[string length [string trim $_linebuf]] != 0} {
#    Don't enforce uniqueness, it can cause unexpected results when using the
#    history to execute a previous series of commands.
#    if {[set ix [lsearch -exact $_history $_linebuf]] != -1} {
#      set _history [lreplace $_history $ix $ix]
#    }
    lappend _history $_linebuf
    if {[llength $_history] > $historylen} {
      set _history [lreplace $_history 0 [expr [llength $_history] - $historylen - 1]]
    }
    if {![info exists _flush_history_task]} {
      set _flush_history_task [after 5000 [namespace code [list \
         $this _flush_history] ] ]
    }
  }

  append _commandbuf "$_linebuf\n"
  set _linebuf ""
  set _savedline ""
  set _lineindex ""
  if {[info complete $_commandbuf]} {
    set cmd $_commandbuf
    set _commandbuf ""
    # suspend input processing while the command runs
    fileevent $inchan readable {}
    # reinstate ctrl-c processing
    if {$tcl_platform(platform) != "windows" 
  		    && [string compare $inchan "stdin"] == 0} {
        stty cooked
    }
    if {"" == $interp} {
      catch {uplevel #0 $cmd} ret
    } else {
      catch {$interp eval $cmd} ret
    }
    # retake full control
    if {$tcl_platform(platform) != "windows" 
  		    && [string compare $inchan "stdin"] == 0} {
        stty raw
    }
    fileevent $inchan readable [namespace code "$this _incoming"]
    if {"" != $ret} {
      puts $outchan $ret
    }
    puts -nonewline $outchan $prompt1
  } else {
    puts -nonewline $outchan $prompt2
  }
  if {[string compare $editmode "vi"] == 0} {
    set _sub_mode insert
  }
}

#               Searches  for  the current word in PATH and, if it
#               is found, replaces it with the full  path  to  the
#               executable.    Special   characters   are  quoted.
#               Aliases  are  expanded  and  quoted  but  commands
#               within  aliases  are  not.  This command is useful
#               with commands that  take  commands  as  arguments,
#               e.g., `dbx' and `sh -x'.
#
itcl::body interactive::Interaction::__normalize-command {char} {
}

#               Expands  the  current  word as described under the
#               `expand' setting of the symlinks shell variable.
#
itcl::body interactive::Interaction::__normalize-path {char} {
#???????????????????????????????
}

#               Toggles between input and overwrite modes.
#
itcl::body interactive::Interaction::__overwrite-mode {char} {
#???????????????????????????????
}

# ctrl-V
itcl::body interactive::Interaction::__quoted-insert {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__redisplay {char} {
#???????????????????????????????
}

#               Searches for documentation on the current command,
#               using  the same notion of `current command' as the
#               completion routines, and prints it.  There  is  no
#               way to use a pager; run-help is designed for short
#               help files.  If the special alias  helpcommand  is
#               defined, it is run with the command name as a sole
#               argument.  Else, documentation should be in a file
#               named  command.help,  command.1,  command.6,  com-
#               mand.8 or command, which should be in one  of  the
#               directories  listed in the HPATH environment vari-
#               able.  If there is more than one  help  file  only
#               the first is printed.
#
itcl::body interactive::Interaction::__run-help {char} {
#???????????????????????????????
}

#               In  insert  mode  (the default), inserts the typed
#               character into the input line after the  character
#               under the cursor.  In overwrite mode, replaces the
#               character under the cursor with the typed  charac-
#               ter.  The input mode is normally preserved between
#               lines, but the inputmode shell variable can be set
#               to  `insert'  or  `overwrite' to put the editor in
#               that mode at the beginning of each line.  See also
#               overwrite-mode.
#
itcl::body interactive::Interaction::__self-insert-command {char} {
  _insert $char
}

#               Indicates  that  the following characters are part
#               of a multi-key sequence.  Binding a command  to  a
#               multi-key  sequence  really  creates two bindings:
#               the first character to  sequence-lead-in  and  the
#               whole  sequence  to  the  command.   All sequences
#               beginning with a character bound to sequence-lead-
#               in  are  effectively bound to undefined-key unless
#               bound to another command.
#
itcl::body interactive::Interaction::__sequence-lead-in {char} {
  set _partial_sequence $char
}

#               Attempts to correct the spelling of each  word  in
#               the  input  buffer,  like  spell-word, but ignores
#               words whose first character is one  of  `-',  `!',
#               `^'  or  `%', or which contain `\', `*' or `?', to
#               avoid problems with  switches,  substitutions  and
#               the like.  See Spelling correction.
#
itcl::body interactive::Interaction::__spell-line {char} {
#???????????????????????????????
}

#               Attempts  to  correct  the spelling of the current
#               word  as  described  under  Spelling   correction.
#               Checks  each  component of a word which appears to
#               be a pathname.
#
itcl::body interactive::Interaction::__spell-word {char} {
#???????????????????????????????
}

#               Expands or `unexpands'  history  substitutions  in
#               the input buffer.  See also expand-history and the
#               autoexpand shell variable.
#
itcl::body interactive::Interaction::__toggle-literal-history {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__transpose-chars {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__tty-sigintr {char} {
  set _commandbuf {}
  set _linebuf {}
  puts $outchan ""
  puts -nonewline $outchan $prompt1
  if {[string compare $editmode "vi"] == 0} {
    set _sub_mode insert
  }
}

#               Beeps.
#
itcl::body interactive::Interaction::__undefined-key {char} {
  puts -nonewline $outchan 
}

itcl::body interactive::Interaction::__upcase-word {char} {
#???????????????????????????????
}

#               Copies the previous entry in the history list into
#               the  input  buffer.   If  histlit is set, uses the
#               literal form of the entry.   May  be  repeated  to
#               step  up through the history list, stopping at the
#               top.
#
itcl::body interactive::Interaction::__up-history {char} {
  _move_in_history -1
}

itcl::body interactive::Interaction::__vi-add {char} {
  _move_right 1
  set _sub_mode insert
}

itcl::body interactive::Interaction::__vi-add-at-eol {char} {
  __end-of-line $char
  set _sub_mode insert
}

itcl::body interactive::Interaction::__vi-beginning-of-next-word {char} {
  if {[string compare $_lineindex ""] == 0} {
    return
  }
  set we [string wordend $_linebuf $_lineindex]
  incr we
  while {![string is alnum [string index $_linebuf $we]]} {
    incr we
  }
  _move_right [expr $we - $_lineindex]
}

itcl::body interactive::Interaction::__vi-char-back {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-char-fwd {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-charto-back {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-charto-find {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-chg-meta {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-cmd-mode {char} {
  set _sub_mode command
}

itcl::body interactive::Interaction::__vi-cmd-mode-complete {char} {
  __complete-word $char
}

itcl::body interactive::Interaction::__vi-del-meta {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-endword {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-eword {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-insert {char} {
  set _sub_mode insert
}

itcl::body interactive::Interaction::__vi-insert-at-bol {char} {
  __beginning-of-line $char
  set _sub_mode insert
}

itcl::body interactive::Interaction::__vi-repeat-char-back {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-repeat-char-fwd {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-repeat-search-back {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-repeat-search-fwd {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-replace-mode {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-replace-char {char} {
#???????????????????????????????
}

#               Prompts with `?' for a search string (which may be
#               a  glob-pattern, as with history-search-backward),
#               searches for it  and  copies  it  into  the  input
#               buffer.   The  bell  rings  if  no match is found.
#               Hitting return ends the search and leaves the last
#               match  in  the  input buffer.  Hitting escape ends
#               the search and executes the match.  vi mode  only.
#
itcl::body interactive::Interaction::__vi-search-back {char} {
#???????????????????????????????
}

#               Like vi-search-back, but searches forward.
#
itcl::body interactive::Interaction::__vi-search-fwd {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-substitute-char {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-substitute-mode {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-undo {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-word-back {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__vi-word-find {char} {
#???????????????????????????????
}

# This needs to be smart enough to know whether we're supposed to move to the
# beginning of the line, or append the zero to the repition number
itcl::body interactive::Interaction::__vi-zero {char} {
#???????????????????????????????
}

#               Does  a  which (see the description of the builtin
#               command) on the first word of the input buffer.
#
itcl::body interactive::Interaction::__which-command {char} {
#???????????????????????????????
}

itcl::body interactive::Interaction::__yank {char} {
#???????????????????????????????
}
