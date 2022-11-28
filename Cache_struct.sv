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
  mesi_t mesi;
} mesi_struct;

typedef struct packed
{
  mesi_t  mesi;                      // MESI state replacing valid and dirty
  logic  [(INDEX-1):0] tag;           // REPLACE TAG 
//  logic  [(BYTE-1):0]  byte_select;   // Byte select
} line_t;

typedef struct packed
{
  logic  [(WAYS-1-1):0]  plru;  // n-1 way Pseudo LRU ; -1 as we are considering 0
  line_t [(WAYS-1):0]    line;  // MESI + TAG 
} sets_nway_t;

typedef enum logic[3:0]
{
  READ_REQ_L1_D     = 4'd0,  // read request from L1 data cache
  WRITE_REQ_L1_D    = 4'd1,  // write request from L1 data cache
  READ_REQ_L1_I     = 4'd2,  // read request from L1 instruction cache
  SNOOP_INVALID_CMD = 4'd3,  // snooped invalidate command
  SNOOP_READ_REQ    = 4'd4,  // snooped read request
  SNOOP_WRITE_REQ   = 4'd5,  // snooped write request
  SNOOP_READ_WITH_M = 4'd6,  // snooped read with intent to modify request
  CLR_CACHE_RST     = 4'd8,  // clear the cache and reset all state
  PRINT_CONTENTS    = 4'd9   // print contents and state of each valid cache line (doesn?t end simulation!)
} n_t;