
72000000 variable clock-hz


: baud ( u -- u ) 
  clock-hz @ swap / ;


0 variable ticks


: ++ticks ( -- ) 1 ticks +! ;


: systick-hz ( u -- )
  ['] ++ticks irq-systick !
  clock-hz @ swap /  1- $E000E014 !  7 $E000E010 ! ;


: systick-hz? ( -- u ) 
  clock-hz @  $E000E014 @ 1+  / ;


: micros ( -- n )  
\ assumes systick is running at 1000 Hz, overhead is about 1.8 us @ 72 MHz
\ get current ticks and systick, spinloops if ticks changed while we looked
  begin ticks @ $E000E018 @ over ticks @ <> while 2drop repeat
  $E000E014 @ 1+ swap -  \ convert down-counter to remaining
  clock-hz @ 1000000 / ( ticks systicks mhz )
  / swap 1000 * + ;


: millis ( -- u ) 
    ticks @ ;


: us ( n -- )  
  2 -  \ adjust for approximate overhead of this code itself
  micros +  begin dup micros - 0< until  drop ;


: ms ( n -- )  
    millis +  begin millis over - 0< while pause repeat  drop ;

