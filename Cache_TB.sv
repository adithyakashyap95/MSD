module cache_TB;

logic  clk;
logic  rstb;
int    event_open;
int    file_read;
string line;
string filename;
logic  [31:0] address;
logic  [3:0] n;
logic  valid;
logic  [15:0] miss_cntr;
logic  [15:0] hit_cntr;

cache #(
	
) DUT (
	.clk		(clk   		),
	.rstb		(rstb		),
	.address    	(address	),
    	.n		(n		),
	.valid 		(valid		),
	.hit_cntr	(hit_cntr	),
	.miss_cntr	(miss_cntr	)
);

initial 
begin
  	rstb = 0; 
	$value$plusargs("FILENAME=%s",filename);
	event_open = $fopen(filename,"r");

	if(event_open)
		$display("trace file is opened");
	else
		$display("trace file cannot be opened");

	if($test$plusargs ("silent"))
		$display("silent Mode is  used");
	else if($test$plusargs ("Silent"))
		$display("silent Mode is  used");
	else if($test$plusargs ("s"))
		$display("silent Mode is  used");
	else if($test$plusargs ("S"))
		$display("silent Mode is  used");
	else if($test$plusargs ("SILENT"))
		$display("silent Mode is  used");
	
	if($test$plusargs ("normal"))
		$display("normal Mode is  used");
	else if($test$plusargs ("Normal"))
		$display("normal Mode is  used");
	else if($test$plusargs ("n"))
		$display("normal Mode is  used");
	else if($test$plusargs ("N"))
		$display("normal Mode is  used");
	else if($test$plusargs ("NORMAL"))
		$display("normal Mode is  used");
$display(" ");
$display("n address \n");
  for (int i=0;i<6;i=i+1)
	begin
		$fgets(line,event_open);
		$display("%s ",line);
	end
 	while(!$feof(event_open))
    	begin
        	valid = 1'b1;
	    	file_read = $fscanf(event_open,"%h %h\n",n,address);
		$display("Valid = %0b, n = %0d, address = %0h",valid,n,address);
   		repeat(5) @(posedge clk) valid = 1'b0;
		$display("Valid = %0b, n = %0d, address = %0h",valid,n,address);
	        repeat(100) @(posedge clk);        
		compare_tracefiles(hit_cntr,miss_cntr);      
    	end
end
initial
begin
	clk = 0;
	forever #5 clk = ~clk;
end

endmodule
