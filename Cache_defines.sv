`ifndef LOCALPARAM
localparam WAYS           = 8;                                // 8 WAY ASSOCIATIVE
localparam WAYS_REP       = $clog2(WAYS);                     // log(8) WAY ASSOCIATIVE to represent
localparam CAPACITY       = 16777216;                         // 16MB capacity
localparam LINE_SIZE      = 64;                               // LINE size
localparam INDEX          = $clog2((CAPACITY/(LINE_SIZE/WAYS))); // 16MB/64/8 = 2^(15) 
localparam BYTE           = $clog2(64);                       // log(64) where 64B is byte line 
localparam TAG            = (32 - INDEX - BYTE);              // 32 is because of unsigned integer  
localparam NUM_OF_LINES   = (2**(INDEX))*WAYS;                // 2^(15+8)
localparam NUM_OF_SETS    = (2**(INDEX));                     // 2^(15)

/* Bus Operation types */
localparam READ           = 1;                                /* Bus Read */
localparam WRITE          = 2;                                /* Bus Write */
localparam INVALIDATE     = 3;                                /* Bus Invalidate */
localparam RWIM           = 4;                                /* Bus Read With Intent to Modify */

/* Snoop Result types */
localparam NOHIT          = 0;                                /* No hit */
localparam HIT            = 1;                                /* Hit */
localparam HITM           = 2;                                /* Hit to modified line */

/* L2 to L1 message types */
localparam GETLINE        = 1;                                /* Request data for modified line in L1 */
localparam SENDLINE       = 2;                                /* Send requested cache line to L1 */
localparam INVALIDATELINE = 3;                                /* Invalidate a line in L1 */
localparam EVICTLINE      = 4;                                /* Evict a line from L1 */

// this is when L2's replacement policy causes eviction of a line that
// may be present in L1. It could be done by a combination of GETLINE
// (if the line is potentially modified in L1) and INVALIDATELINE.

`endif