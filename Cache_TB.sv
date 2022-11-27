module cache_TB;

logic  clk;
logic  rstb;
int    event_open,ref_file_h;
int    file_read,ref_file_read_h;
string line,ref_result;
string all_ref_results[$];
string filename;
logic  [15:0] idx_counter;
logic  [31:0] address;
logic  [3:0] n;
logic  valid;
logic  [15:0] miss_cntr;
logic  [15:0] hit_cntr;
static int i = 0;
static logic [15:0] current_idx;
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
	current_idx = 0;

	ref_file_h = $fopen("./filecompare.txt","r"); //opens the file
	while(!$feof(ref_file_h)) //up until end of file, this loop will run
	begin
		ref_file_read_h = $fscanf(ref_file_h,"%s",ref_result); //scaning the file and taking its contents in ref_result
		all_ref_results.insert(i,ref_result); //taking a queue to take the data from the file using insert 
		i = i + 1; //gives us the queue number (index)
	end 
	$fclose(ref_file_h); //closes the file

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
/*$display(" ");
$display("n address \n");
    for (int i=0;i<6;i=i+1)
	begin
		$fgets(line,event_open);
		$display("%s ",line);
	end*/
 	
	while(!$feof(event_open)) //up until end of file, this loop will run, event_open is the filename variable
    	begin
        	valid = 1'b1; //valid set to 1
		file_read = $fscanf(event_open,"%h %h\n",n,address); // each line will get scanned and n=mode and address will get seperated
		$display("Valid = %0b, n = %0d, address = %h, Hit = %0d, Miss = %0d",valid,n,address,hit_cntr,miss_cntr); 
		repeat(1) @(posedge clk) valid = 1'b0; //valid set to 0
		$display("Valid = %0b, n = %0d, address = %h, Hit = %0d, Miss = %0d",valid,n,address,hit_cntr,miss_cntr);
		repeat(100) @(posedge clk);     //valid that is set to 0 will be repeated for 100 clock cycles
		compare_tracefiles(hit_cntr,miss_cntr,current_idx,all_ref_results);//remove current_idx once DUT hits/misses are working //task is being called
		current_idx = current_idx + 1;//remove this line if hits/misses from DUT are working    
    	end
	$fclose(event_open); //closes the file
	//#10 $stop;
end
initial
begin
	clk = 0;
	forever #5 clk = ~clk;
end

endmodule

task compare_tracefiles(
	input [15:0] hit_cntr, [15:0] miss_cntr, [15:0] current_idx, input string all_ref_results[$]//remove current_idx once DUT hits/misses are working
	);
	
	int ref_file_h,ref_file_read_h;
        string ref_result;
	static int i = 0;	
	static logic  [15:0] misses = 0;
	static logic  [15:0] hits = 0;
	//logic [16:0] current_idx;//add this back after hits/misses from DUT are working
	begin
		//add this line when hits/misses from DUT are working
		//current_idx = hit_cntr + miss_cntr;
		if(all_ref_results[current_idx] == "hit")  //comparing that when the refrence value with the index matches 'hit' the hit counter will increment 
		begin
			hits = hits + 1;
			all_ref_results.delete(current_idx); //clearing the queue so it doesn't take that value again
		end
		else
			misses = misses + 1;	//or else it'll increment the miss counter
		//while(!(hits == 0 && misses == 0))//add this while when hits/misses from DUT are working
		//begin
		if((hits == hit_cntr) && (misses == miss_cntr)) //when output and refrence output matches
				$display("Output matches with the expected. H=%0d, M=%0d, IDX=%0d",hits,misses,current_idx);
			else  //when output and refrence output doesn't matche
				$display("Mismatch!!! H=%0d, M=%0d, IDX = %0d",hits,misses,current_idx);
		//end
		//-----------------------------------------------------------
	end
endtask
