module Cache_opr_ctrl (
	input  logic 	clk,
	input  logic 	rstb,
	input  logic 	valid,
	input  logic 	opr_finished,
	output logic    valid_2d,
	output logic 	opr_1,
	output logic 	opr_2,
	output logic 	opr_3,
	output logic 	opr_4,
	output logic 	opr_5,
	output logic 	opr_6,
	output logic 	opr_7,
	output logic 	opr_8,
	output logic    opr_1_pulse,
	output logic    opr_2_pulse,
	output logic    opr_3_pulse,
	output logic    opr_4_pulse,
	output logic    opr_5_pulse,
	output logic    opr_6_pulse,
	output logic    opr_7_pulse,
	output logic    opr_8_pulse
);

logic [8:0]			cntr_opr;  // Counter for operation
logic 				opr_1_d;
logic 				opr_2_d;
logic 				opr_3_d;
logic 				opr_4_d;
logic 				opr_5_d;
logic 				opr_6_d;
logic 				opr_7_d;
logic 				opr_8_d;
logic 				valid_d;

// generating valid delayed by 2 cycles
always_ff@(posedge clk or negedge rstb)
begin
	if(rstb==0)
	begin
		valid_d  <= 0;
		valid_2d <= 0;
	end
	else
	begin
		valid_d  <= valid;
		valid_2d <= valid_d;
	end
end

// Generating pulses so that the modules work in series fashion.

always_ff@(posedge clk or negedge rstb)
begin
	if(rstb==0)
	begin
		cntr_opr <= 0;
	end
	else if((valid)|(cntr_opr>0))
	begin
		cntr_opr <= cntr_opr + 1;
	end
	else if(opr_finished)
	begin
		cntr_opr <= 0;
	end
	else
	begin
		cntr_opr <= cntr_opr;
	end
end

always_ff@(posedge clk or negedge rstb)
begin
	if(rstb==0)
	begin
		opr_1_d <= 0;
		opr_2_d <= 0;
		opr_3_d <= 0;
		opr_4_d <= 0;
		opr_5_d <= 0;
		opr_6_d <= 0;
		opr_7_d <= 0;
		opr_8_d <= 0;
	end
	else
	begin
		opr_1_d <= opr_1;
		opr_2_d <= opr_2;
		opr_3_d <= opr_3;
		opr_4_d <= opr_4;
		opr_5_d <= opr_5;
		opr_6_d <= opr_6;
		opr_7_d <= opr_7;
		opr_8_d <= opr_8;
	end
end

always_comb opr_1_pulse = opr_1 & (~opr_1_d);
always_comb opr_2_pulse = opr_2 & (~opr_2_d);
always_comb opr_3_pulse = opr_3 & (~opr_3_d);
always_comb opr_4_pulse = opr_4 & (~opr_4_d);
always_comb opr_5_pulse = opr_5 & (~opr_5_d);
always_comb opr_6_pulse = opr_6 & (~opr_6_d);
always_comb opr_7_pulse = opr_7 & (~opr_7_d);
always_comb opr_8_pulse = opr_8 & (~opr_8_d);

// FIXME: opr_finished must come from the last operation

always_comb
begin
	if(cntr_opr==0)
	begin
		opr_1 = 0;
		opr_2 = 0;
		opr_3 = 0;
		opr_4 = 0;
		opr_5 = 0;
		opr_6 = 0;
		opr_7 = 0;
		opr_8 = 0;
	end
	else if(cntr_opr>2)
	begin
		opr_1 = 1;
		opr_2 = 0;
		opr_3 = 0;
		opr_4 = 0;
		opr_5 = 0;
		opr_6 = 0;
		opr_7 = 0;
		opr_8 = 0;
	end	
	else if(cntr_opr>4)
	begin
		opr_1 = 1;
		opr_2 = 1;
		opr_3 = 0;
		opr_4 = 0;
		opr_5 = 0;
		opr_6 = 0;
		opr_7 = 0;
		opr_8 = 0;
	end	
	else if(cntr_opr>6)
	begin
		opr_1 = 1;
		opr_2 = 1;
		opr_3 = 1;
		opr_4 = 0;
		opr_5 = 0;
		opr_6 = 0;
		opr_7 = 0;
		opr_8 = 0;
	end	
	else if(cntr_opr>8)
	begin
		opr_1 = 1;
		opr_2 = 1;
		opr_3 = 1;
		opr_4 = 1;
		opr_5 = 0;
		opr_6 = 0;
		opr_7 = 0;
		opr_8 = 0;
	end	
	else if(cntr_opr>10)
	begin
		opr_1 = 1;
		opr_2 = 1;
		opr_3 = 1;
		opr_4 = 1;
		opr_5 = 1;
		opr_6 = 0;
		opr_7 = 0;
		opr_8 = 0;
	end	
	else if(cntr_opr>12)
	begin
		opr_1 = 1;
		opr_2 = 1;
		opr_3 = 1;
		opr_4 = 1;
		opr_5 = 1;
		opr_6 = 1;
		opr_7 = 0;
		opr_8 = 0;
	end	
	else if(cntr_opr>14)
	begin
		opr_1 = 1;
		opr_2 = 1;
		opr_3 = 1;
		opr_4 = 1;
		opr_5 = 1;
		opr_6 = 1;
		opr_7 = 1;
		opr_8 = 0;
	end	
	else if(cntr_opr>16)
	begin
		opr_1 = 1;
		opr_2 = 1;
		opr_3 = 1;
		opr_4 = 1;
		opr_5 = 1;
		opr_6 = 1;
		opr_7 = 1;
		opr_8 = 1;
	end	
	else
	begin
		opr_1 = 0;
		opr_2 = 0;
		opr_3 = 0;
		opr_4 = 0;
		opr_5 = 0;
		opr_6 = 0;
		opr_7 = 0;
		opr_8 = 0;
	end	
end


endmodule
