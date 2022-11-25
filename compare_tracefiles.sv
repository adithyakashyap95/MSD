task compare_tracefiles(
	input counter, hit_counter, miss_counter
	);
	
	//int output_file_h,ref_file_h;
	int ref_file_h;
	logic [31:0] ref_values [30:0];
	logic [31:0] output_values [30:0];
	bit ref_result;
	int j;
	static int i = 0; 

	begin
		//output_file_h = $fopen("./Compare_file_hitmiss.txt","r");
		ref_file_h = $fopen("./filecompare.txt","r");
		while(!$feof(ref_file_h))
		//for(i=0; i<30; i++)
		begin
			//output_result = $fscanf(output_file_h,"%0s",output_result);
			//ref_result = $fscanf(ref_file_h,"%0s",ref_result);
			//$fgets(output_result,output_file_h);
			$fgets(ref_result,ref_file_h);
			ref_values[i] = ref_result;
			i = i + 1;
		end
		//$fclose(output_file_h);
		$fclose(ref_file_h);
		counter = hit_counter + miss_counter; 
		for(j = 0; j < 30; j++)
		begin
			if(ref_values[j] == output_values[counter])
				$display("Output matches!");
			else
				$display("Mismatch!!!");
		end
	end
endtask 
