
Serial

: multi-key ( -- n )
    BEGIN 
       pause Serial.available 
    UNTIL 
    0 >r rp@ 1 Serial.readBytes drop r> 
;

Forth


Serial

: multi-type ( a n -- ) 
    pause Serial.write drop ;

Forth


: ms ( u -- ) 
    BEGIN pause dup WHILE  1 ms   1-   REPEAT drop ;


internals

: single ( -- )
     ['] arduino-key is key
     ['] arduino-type is type
;

forth


: multi ( -- )
   ['] multi-key is key
   ['] multi-type is type
;

