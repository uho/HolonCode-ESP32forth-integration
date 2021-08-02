DEFINED? LED 0= [IF]  2 Constant LED  [THEN]


: set-led   ( -- )  LED -1 digitalWrite ;


: reset-led ( -- )  LED  0 digitalWrite ;


: blink ( -- )
    BEGIN set-led   700 ms   reset-led   700 ms    AGAIN ;


' blink 100 100 task blinky


: start-blinky ( -- )
    blinky start-task  ;

DEFINED? init 0= [IF] : init ; [THEN]

: init ( -- ) 
    init
    LED output pinMode
    multi
    start-blinky
;

