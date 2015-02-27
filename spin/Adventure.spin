VAR
   long tst

PUB main    
   repeat

CON
  
  PRINT = 0
  WTH = 1
  FEED_KEVIN = 2
  GET_BREAD = 3

  _MSG_QUALITY = 0
  _MSG_WESTHALL = 1
  _MSG_ELEVATOR = 2   
  _MSG_EASTHALL = 3
  _MSG_KITCHEN = 4
  _MSG_EXIT = 5

  _MSG_KEVIN = 6
   


PUB doStuff(i)
   repeat

DAT

    byte "--Quality--", PRINT, _MSG_QUALITY
        byte  ">>west<<",  "--WestHall-"
        byte  ">>*<<",     "--Quality--",  WTH  

    byte "--WestHall--", PRINT, _MSG_WESTHALL
        byte ">>east<<",   "--Quality--"
        byte ">>north<<",  "--Elevator--"
        byte ">>T<<",200,  "--Quality--",  PRINT, _MSG_KEVIN
        byte ">>*<<",      "--WestHall--", WTH         
             
    byte "--Elevator--", PRINT, _MSG_ELEVATOR
        byte ">>west<<",   "--WestHall--"   
        byte ">>east<<",   "--EastHall--"
        byte ">>north<<",  "--Exit--",     FEED_KEVIN
        byte ">>T<<",200,  "--Quality--",  PRINT, _MSG_KEVIN
        byte ">>*<<",      "--Elevator--", WTH
        
    byte "--EastHall--", PRINT, _MSG_EASTHALL
        byte ">>north<<",  "--Elevator--"
        byte ">>west<<",   "--Kitchen--"
        byte ">>T<<",200,  "--Quality--",  PRINT, _MSG_KEVIN
        byte ">>*<<",      "--EastHall--", WTH
        
    byte "--Kitchen--",  PRINT, _MSG_KITCHEN
        byte ">>get bread<<",  "--Kitchen",    GET_BREAD
        byte ">>east<<",       "--EastHall--"
        byte ">>T<<",200,      "--Quality--",  PRINT, _MSG_KEVIN
        byte ">>*<<",          "--Kitchen--",  WTH
        
    byte "--Exit--",     PRINT, _MSG_EXIT

    byte "--END--"
