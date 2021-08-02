
$40010800 constant GPIO-BASE


$00 constant GPIO.CRL


$04 constant GPIO.CRH


$08 constant GPIO.IDR

 
$0C constant GPIO.ODR


$10 constant GPIO.BSRR


$14 constant GPIO.BRR


: bit ( u -- u ) 
  1 swap lshift  1-foldable ;


: io ( port# pin# -- pin ) 
  swap 8 lshift or  2-foldable ;


: io# ( pin -- u )  
  $1F and  1-foldable ;


: io-mask ( pin -- u )  
  io# bit  1-foldable ;


: io-port ( pin -- u )  
  8 rshift  1-foldable ;


: io-base ( pin -- addr )  
  $F00 and 2 lshift GPIO-BASE +  1-foldable ;


: 'f ( -- flags ) token find nip ;


: (io@)  (   pin -- pin* addr )
    dup io-mask swap io-base GPIO.IDR  +   1-foldable ;


: (ioc!) (   pin -- pin* addr )
    dup io-mask swap io-base GPIO.BRR  +   1-foldable ;


: (ios!) (   pin -- pin* addr )
  dup io-mask swap io-base GPIO.BSRR +   1-foldable ;


: (iox!) (   pin -- pin* addr )
    dup io-mask swap io-base GPIO.ODR  +   1-foldable ;


: (io!)  ( f pin -- pin* addr )
    swap 0= $10 and + dup io-mask swap io-base GPIO.BSRR +   2-foldable ;


: io@ ( pin -- f )  \ get pin value (0 or -1)
  (io@)  bit@ exit [ $1000 setflags 2 h, ' (io@)  ,
  'f (io@)  h, ' bit@ , 'f bit@ h, ] ;


: ioc! ( pin -- )  
  (ioc!)    ! exit [ $1000 setflags 2 h, ' (ioc!) ,
  'f (ioc!) h, '    ! , 'f    ! h, ] ;


: ios! ( pin -- )
  (ios!)    ! exit [ $1000 setflags 2 h, ' (ios!) ,
  'f (ios!) h, '    ! , 'f    ! h, ] ;


: iox! ( pin -- ) 
  (iox!) xor! exit [ $1000 setflags 2 h, ' (iox!) ,iox! ( pin -- ) 
  'f (iox!) h, ' xor! , 'f xor! h, ] ;


: io! ( f pin -- )  
  (io!) ! exit
  [ $1000 setflags
    7 h,
    ' (ios!) , 'f  (ios!) h,
    ' rot    , 'f  rot    h,
    ' 0=     , 'f  0=     h,
      4      ,     $2000  h,
    ' and    , 'f  and    h,
    ' +      , 'f  +      h,
    ' !      , 'f  !      h, ] ;


%0000 constant IMODE-ADC


%0100 constant IMODE-FLOAT


%1000 constant IMODE-PULL


%0001 constant OMODE-PP


%0101 constant OMODE-OD


%1001 constant OMODE-AF-PP


%1101 constant OMODE-AF-OD


%01 constant OMODE-SLOW


%10 constant OMODE-FAST


: io-mode! ( mode pin -- )
  dup io-base GPIO.CRL + over 8 and shr + >r ( R: crl/crh )
  io# 7 and 4 * ( mode shift )
  $F over lshift not ( mode shift mask )
  r@ @ and -rot lshift or r> ! ;


: io-modes! ( mode pin mask -- ) 
  16 0 do
    i bit over and if
      >r  2dup ( mode pin mode pin R: mask ) $F bic i or io-mode!  r>
    then
  loop 2drop drop ;


: io. ( pin -- )  \ display readable GPIO registers associated with a pin
  cr
    ." PIN " dup io#  dup .  10 < if space then
   ." PORT " dup io-port [char] A + emit
  io-base
  ."   CRL " dup @ hex. 4 +
   ."  CRH " dup @ hex. 4 +
   ."  IDR " dup @ h.4  4 +
  ."   ODR " dup @ h.4 drop ;

