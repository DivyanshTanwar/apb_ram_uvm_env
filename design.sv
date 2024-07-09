module apb_ram(apb_if aif);
  
  typedef enum {idle = 0, setup = 1, access = 2, transfer = 3} state_type;
  
  reg [31 : 0] mem [64];
  
  state_type state = idle;
  
  always @(posedge aif.pclk) begin
    
    if(aif.presetn == 1'b0) begin
      
      state <= idle;
      aif.prdata <= 32'h00000000;
      aif.pready <= 1'b0;
      aif.pslverr <= 1'b0;
      
      for(int i = 0; i< 64; i++) begin
        mem[i] <= 0;
      end
      
    end
    
    else begin
      
      case(state)
        
        idle : 
          
          begin
            
            aif.prdata <= 32'h00000000;
            aif.pslverr <= 1'b0;
            aif.pready <= 1'b0;
            state <= setup;
            
          end
        
        setup :
          
          begin
            
            if(aif.psel == 1'b1)
              state <= access;
            
            else
              state <= setup;
            
          end
        
        access :
          
          begin
            
            if(aif.pwrite && aif.penable) begin
              
              if(aif.paddr < 64) begin
                
                mem[aif.paddr] <= aif.pwdata;
                aif.pready <= 1'b1;
                aif.pslverr <= 1'b0;
                state <= transfer;
                
              end
              
              else begin
                
                aif.pready <= 1'b1;
                aif.pslverr <= 1'b1;
                state <= transfer;
                
              end
              
            end
            
            else if(!aif.pwrite && aif.penable) begin
              
              if(aif.paddr < 64) begin
                
                aif.prdata <= mem[aif.paddr];
                aif.pready <= 1'b1;
                aif.pslverr <= 1'b0;
                state <= transfer;
                
              end
              
              else begin
                
                aif.pready <= 1'b1;
                aif.pslverr <= 1'b1;
                aif.prdata <= 32'hxxxxxxxx;
                state <= transfer;                
                
              end
              
            end
            
            else 
              state <= setup;
            
          end
        
        transfer :
          begin
            
            aif.pslverr <= 1'b0;
            aif.pready <= 1'b0;
            state <= setup;
            
          end
        
        default : state <= idle;
        
      endcase
        
      
    end
    
  end
  
  
endmodule



interface apb_if();
  
  logic 				pclk;
  logic 				presetn;
  logic [31 : 0] 		paddr;
  logic 				pwrite;
  logic 				penable;
  logic 				pready;
  logic [31 : 0] 		pwdata;
  logic [31 : 0] 		prdata;
  logic 				psel;
  logic 				pslverr;
  
  modport dut(input pclk, presetn, paddr, pwrite, penable, pwdata, psel, output prdata, pready, pslverr);
  
  modport tb_top(output pclk, presetn, paddr, pwrite, penable, pwdata, psel, input prdata, pready, pslverr);
  
endinterface
