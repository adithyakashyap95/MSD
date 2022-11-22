`include "Cache_defines.sv"

typedef enum logic[1:0]
{
  M = 2'b11,             // Modified
  E = 2'b10,             // Exclusive
  S = 2'b01,             // Shared     
  I = 2'b00              // Invalidate // reset state hence assigned the value 00
} mesi_t;

typedef struct packed
{
  mesi_t  mesi;                      // MESI state replacing valid and dirty
  logic [(INDEX-1):0] tag;           // REPLACE TAG 
  logic [(BYTE-1):0]  byte_select;   // Byte select
} line_t;

typedef struct packed
{
  logic  [(WAYS-1-1):0]  plru;  // n-1 way Pseudo LRU ; -1 as we are considering 0
  line_t [(WAYS-1):0]    line;  // MESI + TAG 
} sets_nway_t;




