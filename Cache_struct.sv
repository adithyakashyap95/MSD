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
  logic  [(INDEX-1):0] tag;          // REPLACE TAG 
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

typedef enum logic[2:0]
{
  READ       = 3'd1,       /* Bus Read */
  WRITE      = 3'd2,       /* Bus Write */
  INVALIDATE = 3'd3,       /* Bus Invalidate */
  RWIM       = 3'd4        /* Bus Read With Intent to Modify */
} bus_func_t;

typedef enum logic[1:0]
{
  NOHIT     = 2'd0,        /* No hit */
  HIT       = 2'd1,        /* Hit */
  HITM      = 2'd2         /* Hit to modified line */
} hit_miss_t;

typedef enum logic[2:0]
{
  GETLINE        = 2'd1,   /* Request data for modified line in L1 */
  SENDLINE       = 2'd2,   /* Send requested cache line to L1 */
  INVALIDATELINE = 2'd3,   /* Invalidate a line in L1 */
  EVICTLINE      = 2'd4    /* Evict a line from L1 */
} l2_to_l1_msg_t;

// this is when L2's replacement policy causes eviction of a line that
// may be present in L1. It could be done by a combination of GETLINE
// (if the line is potentially modified in L1) and INVALIDATELINE.