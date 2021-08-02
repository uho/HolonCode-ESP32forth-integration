
: hello ( -- ) 
    ." Hello, HolonCode and ESP32forth world! " ;


: goodbye ( -- )
   ." Good bye!" ;


Variable occurrences    0 occurrences !


: welcome ( -- )
    cr hello ." --> "  goodbye   
    ."    " occurrences @ .    
    1 occurrences +! 
;


: do-greeting ( -- )
    BEGIN welcome 300 ms pause AGAIN ;


' do-greeting 100 100 Task greeting


: start-greeting ( -- )
    greeting start-task  ;


: init ( -- ) 
    init
    0 occurances !
    start-greeting
;

init

