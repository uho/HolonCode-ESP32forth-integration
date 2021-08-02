
: make-defer ( xt -- )
   >r  ['] key 2@  r@ 2!  0 r> >body ! ;


: patch ( new old -- )
   dup make-defer >body ! ;


internals

: xt-reveal ( xt -- )
   current @ @ over >link& !   current @ ! 
;

forth


internals

: revise ( -- )  
   current @ @   dup xt-hide   dup >name find   dup IF  patch  ELSE  drop  xt-reveal  THEN ;
;

forth

