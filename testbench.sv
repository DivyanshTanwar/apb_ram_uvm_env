`timescale 1ns/1ns

`include "uvm_macros.svh"
import uvm_pkg :: *;

class apb_config extends uvm_object; // configeration of ENV
  
  `uvm_object_utils(apb_config)
  
  function new(string inst = "apb_config");
    super.new(inst);
  endfunction
  
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
endclass

typedef enum bit [1:0] {wr = 0, rd = 1, rst = 2} oper_mode;

class transaction extends uvm_sequence_item;
    
  function new (string inst = "transaction");
    super.new(inst);
  endfunction
  
  oper_mode op;
  rand bit [31:0] paddr;
  rand bit [31:0] pwdata;
  bit [31:0] prdata;
  bit pwrite;
  bit penable;
  bit pready;
  bit psel;
  bit pslverr;
  
  `uvm_object_utils_begin(transaction)
  `uvm_field_int(paddr, UVM_ALL_ON)
  `uvm_field_int(pwrite, UVM_ALL_ON)
  `uvm_field_int(penable, UVM_ALL_ON)
  `uvm_field_int(pready, UVM_ALL_ON)
  `uvm_field_int(prdata, UVM_ALL_ON)
  `uvm_field_int(pwdata, UVM_ALL_ON)
  `uvm_field_int(psel, UVM_ALL_ON)
  `uvm_field_int(pslverr, UVM_ALL_ON)
  `uvm_field_enum(oper_mode,op, UVM_DEFAULT)
  `uvm_object_utils_end
  
  
  constraint addr_c { paddr < 64; }
  constraint addr_c_err { paddr >= 64; }
  
endclass

class write_data extends uvm_sequence#(transaction);
  
  `uvm_object_utils(write_data)
  
  transaction trans;
  
  function new(string inst = "write_data");
    super.new(inst);
  endfunction
  
  virtual task body();
    
    trans = transaction :: type_id :: create ("trans");

    repeat(15) begin
      trans.addr_c.constraint_mode(1);
      trans.addr_c_err.constraint_mode(0);
      start_item(trans);
      assert(trans.randomize()) else `uvm_error("SEQ","Assertion Failed");
      trans.op = wr;
      finish_item(trans);
      
    end
    
  endtask
  
endclass

class read_data extends uvm_sequence#(transaction);
  
  `uvm_object_utils(read_data)
  
  transaction trans;
  
  function new(string inst = "read_data");
    super.new(inst);
  endfunction
  
  virtual task body();
    trans = transaction :: type_id :: create ("trans");
    repeat(15) begin
      
      trans.addr_c.constraint_mode(1);
      trans.addr_c_err.constraint_mode(0);
      start_item(trans);
      assert(trans.randomize()) else `uvm_error("SEQ","Assertion Failed");
      trans.op = rd;
      finish_item(trans);
      
    end
    
  endtask
  
endclass

class write_read extends uvm_sequence#(transaction);
  
  `uvm_object_utils(write_read)
  
  transaction trans;
  
  function new(string inst = "write_read");
    super.new(inst);
  endfunction
  
  virtual task body();
    trans = transaction :: type_id :: create ("trans");
    repeat(15) begin

      
      trans.addr_c.constraint_mode(1);
      trans.addr_c_err.constraint_mode(0);
      
      start_item(trans);
      assert(trans.randomize()) else `uvm_error("SEQ","Assertion Failed");
      trans.op = wr;
      finish_item(trans);
      
      start_item(trans);
      assert(trans.randomize()) else `uvm_error("SEQ","Assertion Failed");
      trans.op = rd;
      finish_item(trans);
      
    end
    
  endtask
  
endclass

class writeb_readb extends uvm_sequence#(transaction);
  
  `uvm_object_utils(writeb_readb)
  
  transaction trans;
  
  function new(string inst = "writeb_readb");
    super.new(inst);
  endfunction
  
  virtual task body();
    trans = transaction :: type_id :: create ("trans");
    repeat(15) begin
      
      trans.addr_c.constraint_mode(1);
      trans.addr_c_err.constraint_mode(0);
      
      start_item(trans);
      assert(trans.randomize()) else `uvm_error("SEQ","Assertion Failed");
      trans.op = wr;
      finish_item(trans);
      
    end
    
    repeat(15) begin
     
      trans.addr_c.constraint_mode(1);
      trans.addr_c_err.constraint_mode(0);
      
      start_item(trans);
      assert(trans.randomize()) else `uvm_error("SEQ","Assertion Failed");
      trans.op = rd;
      finish_item(trans);

      
    end
    
  endtask
  
endclass

class write_err extends uvm_sequence#(transaction);
  
  `uvm_object_utils(write_err)
  
  transaction trans;
  
  function new(string inst = "write_err");
    super.new(inst);
  endfunction
  
  virtual task body();
    trans = transaction :: type_id :: create ("trans");
    repeat(15) begin
      
      trans.addr_c.constraint_mode(0);
      trans.addr_c_err.constraint_mode(1);
      start_item(trans);
      assert(trans.randomize()) else `uvm_error("SEQ","Assertion Failed");
      trans.op = wr;
      finish_item(trans);
      
    end
    
  endtask
  
endclass

class read_err extends uvm_sequence#(transaction);
  
  `uvm_object_utils(read_err)
  
  transaction trans;
  
  function new(string inst = "read_err");
    super.new(inst);
  endfunction
  
  virtual task body();
    trans = transaction :: type_id :: create ("trans");
    repeat(15) begin
      
      trans.addr_c.constraint_mode(0);
      trans.addr_c_err.constraint_mode(1);
      start_item(trans);
      assert(trans.randomize()) else `uvm_error("SEQ","Assertion Failed");
      trans.op = rd;
      finish_item(trans);
      
    end
    
  endtask
  
endclass

class reset_dut extends uvm_sequence#(transaction);
  
  `uvm_object_utils(reset_dut)
  
  transaction trans;
  
  function new(string inst = "reset_dut");
    super.new(inst);
  endfunction
  
  virtual task body();
    trans = transaction :: type_id :: create ("trans");
    repeat(15) begin
      
      trans.addr_c.constraint_mode(1);
      trans.addr_c_err.constraint_mode(0);
      start_item(trans);
      assert(trans.randomize()) else `uvm_error("SEQ","Assertion Failed");
      trans.op = rst;
      finish_item(trans);
      
    end
    
  endtask
  
endclass

class driver extends uvm_driver #(transaction);
  
  `uvm_component_utils(driver)
  
  transaction trans;
  virtual apb_if aif;
  
  function new(string inst = "driver", uvm_component parent = null);
    super.new(inst,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    trans = transaction :: type_id :: create("trans");
    if(!uvm_config_db#(virtual apb_if) :: get(this,"","aif",aif))
      `uvm_error("Driver", "Unable to Access Interface");
  endfunction
  
  virtual task reset_dut();
    repeat(5) begin
      
      aif.presetn <= 1'b0;
      aif.paddr <= 'h0;
      aif.pwrite <= 'b0;
      aif.penable <= 'b0;
      aif.pwdata <= 'h0;
      aif.psel <= 'b0;
      `uvm_info("driver", "System Reset : Start of Simulation", UVM_NONE);
      @(posedge aif.pclk);
      
    end
    
  endtask
  
  
  virtual task drive();
    reset_dut();
    forever begin
      
      seq_item_port.get_next_item(trans);
      
      if(trans.op == rst) begin
        
        aif.presetn <= 1'b0;
        aif.paddr <= 'h0;
      	aif.pwrite <= 'b0;
      	aif.penable <= 'b0;
      	aif.pwdata <= 'h0;
      	aif.psel <= 'b0;
        @(posedge aif.pclk);
        
      end
      
      else if(trans.op == wr) begin
        
        aif.presetn <= 1'b1;
        aif.paddr <= trans.paddr;
      	aif.pwrite <= 1'b1;
      	aif.pwdata <= trans.pwdata;
      	aif.psel <= 1'b1;
        @(posedge aif.pclk);
      	aif.penable <= 1'b1;
        `uvm_info("driver", $sformatf("mode : %s, addr:%0d, wdata:%0d, rdata:%0d, slverr:%0d",trans.op.name(), trans.paddr, trans.pwdata, trans.prdata, trans.pslverr), UVM_NONE);
        @(negedge aif.pready);
        aif.penable <= 1'b0;
        trans.pslverr <= aif.pslverr;
          
      end
      
      else if(trans.op == rd) begin
        
        aif.presetn <= 1'b1;
        aif.paddr <= trans.paddr;
      	aif.pwrite <= 1'b0;
      	aif.psel <= 1'b1;
        @(posedge aif.pclk);
      	aif.penable <= 1'b1;
        `uvm_info("driver", $sformatf("mode : %s, paddr:%0d, rdata:%0d, slverr:%0d",trans.op.name(), trans.paddr, trans.prdata, trans.pslverr), UVM_NONE);
        @(negedge aif.pready);
        aif.penable <= 1'b0;
        trans.prdata <= aif.prdata;
        trans.pslverr <= aif.pslverr;
     
      end
      
      seq_item_port.item_done();
      
    end
    
  endtask
  
  virtual task run_phase(uvm_phase phase);
    
    drive();
    
  endtask
  

endclass

class monitor extends uvm_monitor;
  
  `uvm_component_utils(monitor)
  
  virtual apb_if aif;
  transaction trans;
  uvm_analysis_port #(transaction) send;
   
  function new (string inst = "monitor", uvm_component parent = null);
    super.new(inst, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    trans = transaction :: type_id :: create("trans");
    if(!uvm_config_db#(virtual apb_if) :: get(this, "", "aif", aif))
      `uvm_error("Monitor", "Unable to Access Interface");   
    send = new("send",this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    
    forever begin
      @(posedge aif.pclk);
      if(!aif.presetn) begin
        
        trans.op = rst;
        `uvm_info("Monitor", "SYSTEM RESET DETECTED", UVM_NONE);
        send.write(trans);
        
      end
      
      else if(aif.pwrite && aif.presetn) begin
        @(negedge aif.pready);
        trans.op = wr;
        trans.pwdata = aif.pwdata;
        trans.pslverr = aif.pslverr;
        trans.paddr = aif.paddr;
        `uvm_info("Monitor", $sformatf("DATA WRITE mode : %s, addr : %0d,  wdata:%0d, slverr:%0d",trans.op.name(), trans.paddr, trans.pwdata, trans.pslverr), UVM_NONE);
        send.write(trans);
      end
      
      else if(!aif.pwrite && aif.presetn) begin
        
        @(negedge aif.pready);
        trans.op = rd;
        trans.prdata = aif.prdata;
        trans.pslverr = aif.pslverr;
        trans.paddr = aif.paddr;
        `uvm_info("Monitor", $sformatf("DATA READ mode : %s, addr : %0d,  rdata:%0d, slverr:%0d",trans.op.name(), trans.paddr, trans.prdata, trans.pslverr), UVM_NONE);        
        send.write(trans);
      end
    end
    
  endtask
  
endclass

class scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp #(transaction,scoreboard) rcvd;
  bit [31:0] mem[64] = '{default : 0};
  
  
  function new(string inst = "scoreboard", uvm_component parent = null);
    super.new(inst, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rcvd = new("rcvd",this);
  endfunction
  
  virtual function void write(transaction trans);

    if(trans.op == rst) begin
      
      `uvm_info("SCO", "System Reset Detected", UVM_NONE);
      
    end
    
    else if(trans.op == wr) begin
      
      if(trans.pslverr == 1'b1) begin
        `uvm_info("SCO", "SLV ERROR during WRITE OP", UVM_NONE);
      end
      
      else begin 
        mem[trans.paddr] = trans.pwdata;
        `uvm_info("SCO", $sformatf("DATA WRITE OP  addr:%0d, wdata:%0d arr_wr:%0d",trans.paddr, trans.pwdata, mem[trans.paddr]), UVM_NONE);
      end
      
    end
    
    else if(trans.op == rd) begin
      
      if(trans.pslverr == 1'b1) begin
        `uvm_info("SCO", "SLV ERROR during READ OP", UVM_NONE);
      end
      
      else begin
        if(mem[trans.paddr] == trans.prdata) begin
          `uvm_info("SCO", $sformatf("DATA MATCHED : addr:%0d, rdata:%0d",trans.paddr,trans.prdata), UVM_NONE)
        end
        
        else begin
          `uvm_info("SCO",$sformatf("TEST FAILED : addr:%0d, rdata:%0d,  data_rd_arr:%0d",trans.paddr,trans.prdata,mem[trans.paddr]), UVM_NONE) 
        end
      end
       
    end
    $display("----------------------------------------------------------------");
    
  endfunction
  
  
endclass

class agent extends uvm_agent;

  `uvm_component_utils(agent);
  
  uvm_sequencer #(transaction) seqr;
  driver drv;
  monitor mon;
  apb_config cfg;
  
  function new(string inst = "agent", uvm_component parent = null);
    super.new(inst, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cfg = apb_config :: type_id :: create("cfg");
    mon = monitor :: type_id :: create("mon",this);

    if(cfg.is_active == UVM_ACTIVE) begin
      seqr = uvm_sequencer #(transaction) :: type_id :: create("seqr",this);
      drv = driver :: type_id :: create("drv",this);
    end
    
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(cfg.is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
    
  endfunction
  
  
endclass


class env extends uvm_env;
  
  `uvm_component_utils(env);
  scoreboard sco;
  agent a;
  
  function new(string inst = "env", uvm_component parent = null);
    super.new(inst, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent :: type_id :: create("agent", this);
    sco = scoreboard :: type_id :: create("sco", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    
    super.connect_phase(phase);
      a.mon.send.connect(sco.rcvd);
    
  endfunction  
  
endclass

class test extends uvm_test;
  
  `uvm_component_utils(test);
  env e;
  write_read wrrd;
  writeb_readb wrrdb;
  write_data wdata;  
  read_data rdata;
  write_err werr;
  read_err rerr;
  reset_dut rstdut; 
  
  function new(string inst = "test", uvm_component parent = null);
    super.new(inst, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env :: type_id :: create("env",this);
    wrrd =  write_read :: type_id :: create("wrrd");
    wdata = write_data :: type_id :: create("wdata");
  	rdata = read_data :: type_id :: create("rdata");
  	wrrdb = writeb_readb :: type_id :: create("wrrdb");
 	werr = write_err :: type_id :: create("werr");
  	rerr = read_err :: type_id :: create("rerr");
  	rstdut = reset_dut :: type_id :: create("rstdut");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    fork
      wrrd.start(e.a.seqr,null,100);
      wrrdb.start(e.a.seqr, null, 200);
      wdata.start(e.a.seqr, null, 300);
      rdata.start(e.a.seqr, null, 400);
      werr.start(e.a.seqr, null, 500);
      rerr.start(e.a.seqr, null, 600);
//       rstdut.start(e.a.seqr, null, 700);
    join 
    phase.drop_objection(this);
  endtask
  
endclass

module tb_top;
  
  apb_if aif();
  apb_ram dut(aif);
  
  initial aif.pclk <= 0;
  
  always #10 aif.pclk <= ~aif.pclk;
  
  initial begin
    
    uvm_config_db #(virtual apb_if) :: set(null, "*", "aif", aif);
    run_test("test");
    
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
  end
  
  
endmodule










