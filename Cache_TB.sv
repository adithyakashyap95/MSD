
module cache_TB;

logic  clk;
logic  rstb;
int    event_open;
string line;
string filename;
logic [31:0] address;
logic [3:0] n;
logic valid;
logic [15:0] miss_cntr;
logic [15:0] hit_cntr;

cache #(
	
) DUT (
	.clk		(clk   		),
	.rstb		(rstb		),
	.address        (address	),
	.n		(n		),
	.valid 		(valid		),
	.hit_cntr	(hit_cntr	),
	.miss_cntr	(miss_cntr	)
);

initial 
begin
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

end

initial
begin
	clk = 0;
	forever #5 clk = ~clk;
end

initial
begin
	rstb = 0;
	n = 8;
	valid = 0;
	address = 0;
	#20
	rstb = 1;
	#50
	n = 0;
	address = 0;
end

endmodule