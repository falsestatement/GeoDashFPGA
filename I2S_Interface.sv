module I2S_Interface (
	 input logic[1:0] PLAYPLEASE,
    input logic LRCLK, SCLK,
    output logic D_OUT
);

	 logic[15:0] D_IN, DINDEAD, DINJMP;
	 logic[15:0] addrDed, addrMax;
	 logic[13:0] addrJmp;
	 logic LRS0, LRS1, LRS2;
					
	 
	 deadRAM dedRM(.clk(SCLK), .w(0), .addr(addrDed), .Din(0), .Dout(DINDEAD));
	 jumpRAM jmpRM(.clk(SCLK), .w(0), .addr(addrJmp), .Din(0), .Dout(DINJMP));
	 
	 
    logic [63:0] lshiftreg;
    assign D_OUT = lshiftreg[63];
	 
    
    always_ff @ (posedge LRCLK)
    begin
        LRS0 <= ~LRS0; 
		  if((PLAYPLEASE == 2'b10 || addrDed > 0) && addrDed < 16384) begin
					addrDed <= addrDed + 1;
					D_IN <= DINDEAD;
		  end
		  else if ((PLAYPLEASE == 2'b01 || addrJmp > 0) && addrJmp < 4096) begin
					addrJmp <= addrJmp + 1;
					D_IN <= DINJMP;
		  end
		  else if(PLAYPLEASE == 0)
		  begin
					addrJmp <= 14'b0;
					addrDed <= 16'b0;
					D_IN <= 0;
		  end
		  else
					D_IN <= 0;

//		  if ((PLAYPLEASE != 2'b00 || addrDed > 0) && addrDed < addrMax) begin
//					addrDed <= addrDed + 1;
//		  end
//		  else
//					addrDed <= 0;
//										
//    end
//	 
//	 always_comb begin
//		if(PLAYPLEASE == 2'b10) begin
//			addrMax = 4096;
//			D_IN = DINJMP;
//		end
//		else if (PLAYPLEASE == 2'b01) begin
//			addrMax = 16384;
//			D_IN = DINDEAD;
//		end
//		else begin
//			D_IN = 0;
//			addrMax = 0;
//		end
	 end
    
    always_ff @ (posedge SCLK) 
    begin
        
        lshiftreg <= lshiftreg << 1;
		  lshiftreg[0] <= 0;
		  LRS1 <= LRS0;
		  LRS2 <= LRS1;
		  if(LRS1 ^ LRS2)
		  begin
				lshiftreg[63] <= 0;
				lshiftreg[62:47] <= D_IN;
				lshiftreg[46:32] <= 47'd0;
				lshiftreg[31:16] <= D_IN;
				lshiftreg[15:0] <= 47'd0;
				
		  end
    end
	 
endmodule

// RAM Modules for Sound Samples

module deadRAM (
    input logic clk, w, 
    input logic[16:0] addr, 
    input logic[15:0] Din, 
    output logic[15:0] Dout);
    
    logic [15:0] mem [32768:0];
    
	 initial begin
		$readmemh("dead.txt", mem);
	 end
	 
    always @ (posedge clk) begin
        if (w)
            mem[addr] <= Din;
        Dout <= mem[addr];
    end
    
endmodule

module jumpRAM (
    input logic clk, w, 
    input logic[13:0] addr, 
    input logic[15:0] Din, 
    output logic[15:0] Dout);
    
    logic [15:0] mem [4095:0];
    
	 initial begin
		$readmemh("jump.txt", mem);
	 end
	 
    always @ (posedge clk) begin
        if (w)
            mem[addr] <= Din;
        Dout <= mem[addr];
    end
    
endmodule