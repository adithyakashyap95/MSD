
module cache_TB;

logic  clk;
logic  rst;
int    event_open;
string line;

cache #(
	.WIDTH		(1)
) DUT (
	.clk		(clk),
	.rst		(rst)
);

initial 
begin
	clk = 0;
	rst = 1;

	event_open = $fopen("./event.txt","r");

	if($test$plusargs ("silent"))
		$display("silent Mode is  used");
	else if($test$plusargs ("Silent"))
		$display("silent Mode is  used");
	else if($test$plusargs ("s"))
		$display("silent Mode is  used");
	else if($test$plusargs ("S"))
		$display("silent Mode is  used");
	
	if($test$plusargs ("normal"))
		$display("normal Mode is  used");
	else if($test$plusargs ("Normal"))
		$display("normal Mode is  used");
	else if($test$plusargs ("n"))
		$display("normal Mode is  used");
	else if($test$plusargs ("N"))
		$display("normal Mode is  used");

$display(" ");
$display("n address \n");
	for (int i=0;i<6;i=i+1)
	begin
		$fgets(line,event_open);
		$display("%s ",line);
	end

end

endmodule