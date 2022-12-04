`ifndef LOCALPARAM
localparam WAYS           = 'h8;                              // 8 WAY ASSOCIATIVE
localparam WAYS_REP       = $clog2(WAYS);                     // log(8) WAY ASSOCIATIVE to represent
localparam CAPACITY       = 'h1000000;                        // 16MB capacity
localparam LINE_SIZE      = 'h40;                             // 64B LINE size
localparam INDEX          = 'd15;                             //$clog2((CAPACITY/(LINE_SIZE/WAYS))); // 16MB/64/8 = 2^(15) 
localparam BYTE           = 'h6;                              //$clog2(64);                          // log(64) where 64B is byte line 
localparam TAG            = 'hB;                              //(32 - INDEX - BYTE);                 // 32 is because of unsigned integer  
localparam NUM_OF_LINES   = 'h40000;                          //(2**(INDEX))*WAYS;                   // 2^(15+8)
localparam NUM_OF_SETS    = 'h8000;                           //(2**(INDEX));                        // 2^(15)

`endif