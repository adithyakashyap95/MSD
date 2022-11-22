
localparam WAYS         = 8;                                // 8 WAY ASSOCIATIVE
localparam CAPACITY     = 16000000;                         // 16MB capacity
localparam LINE_SIZE    = 64;                               // LINE size
localparam INDEX        = (CAPACITY/(LINE_SIZE/WAYS));      // 16MB/64/8 = 2^(15) 
localparam BYTE         = $clog2(64);                       // log(64) where 64B is byte line 
localparam TAG          = (32 - INDEX - BYTE);              // 32 is because of unsigned integer  
localparam NUM_OF_LINES = (2**(INDEX))*WAYS;                // 2^(15+8)
localparam NUM_OF_SETS  = (2**(INDEX));                     // 2^(15)
