// Wishbone (16-bit) -> AXI4-Lite (32-bit) bridge for Zet on Zynq-7010
// Zet addr 19:1 (byte addr 19:0, word aligned) -> AXI 32-bit word
`timescale 1ns/1ps
module wb2axi (
  input  wire        clk,
  input  wire        rst_n,
  // Wishbone slave
  input  wire [19:1] wb_adr_i,
  input  wire [15:0] wb_dat_i,
  output reg  [15:0] wb_dat_o,
  input  wire        wb_we_i,
  input  wire [1:0]  wb_sel_i,
  input  wire        wb_stb_i,
  input  wire        wb_cyc_i,
  input  wire        wb_tga_i,   // 1=io, 0=mem
  output reg         wb_ack_o,
  // AXI4-Lite master
  output reg  [31:0] axi_awaddr,
  output reg         axi_awvalid,
  input  wire        axi_awready,
  output reg  [31:0] axi_wdata,
  output reg  [3:0]  axi_wstrb,
  output reg         axi_wvalid,
  input  wire        axi_wready,
  input  wire [1:0]  axi_bresp,
  input  wire        axi_bvalid,
  output reg         axi_bready,
  output reg  [31:0] axi_araddr,
  output reg         axi_arvalid,
  input  wire        axi_arready,
  input  wire [31:0] axi_rdata,
  input  wire [1:0]  axi_rresp,
  input  wire        axi_rvalid,
  output reg         axi_rready
);
  localparam IDLE=0, RD=1, WR=2, DONE=3;
  reg [1:0] st;
  reg [15:0] rdata_r;
  reg io_r;

  // map: byte addr = {wb_adr_i,1'b0} -> 20-bit; io space -> 0x8000_0000|port, mem -> 0x1000_0000|addr
  wire [31:0] mem_addr = {12'h100, wb_adr_i, 1'b0};           // 0x10000000|byte_addr
  wire [31:0] io_addr  = {16'h8000, wb_adr_i, 2'b0};          // 0x8000_0000|port

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st<=IDLE; wb_ack_o<=0; wb_dat_o<=0;
      axi_awvalid<=0; axi_wvalid<=0; axi_bready<=0;
      axi_arvalid<=0; axi_rready<=0;
      axi_awaddr<=0; axi_araddr<=0; axi_wdata<=0; axi_wstrb<=0;
    end else begin
      wb_ack_o<=0;
      case(st)
        IDLE: if (wb_cyc_i && wb_stb_i) begin
          io_r <= wb_tga_i;
          if (wb_we_i) begin
            axi_awaddr <= wb_tga_i ? io_addr : mem_addr;
            axi_wdata  <= {wb_dat_i, wb_dat_i};
            axi_wstrb  <= {wb_sel_i, wb_sel_i};
            axi_awvalid<=1; axi_wvalid<=1; axi_bready<=1;
            st<=WR;
          end else begin
            axi_araddr <= wb_tga_i ? io_addr : mem_addr;
            axi_arvalid<=1; axi_rready<=1;
            st<=RD;
          end
        end
        RD: begin
          if (axi_arready) axi_arvalid<=0;
          if (axi_rvalid) begin
            axi_rready<=0;
            wb_dat_o <= axi_rvalid ? (wb_sel_i[0] ? axi_rdata[15:0] : axi_rdata[31:16]) : 16'h0;
            wb_ack_o <=1;
            st<=DONE;
          end
        end
        WR: begin
          if (axi_awready) axi_awvalid<=0;
          if (axi_wready)  axi_wvalid<=0;
          if (axi_bvalid) begin
            axi_bready<=0;
            wb_ack_o<=1;
            st<=DONE;
          end
        end
        DONE: if (!wb_stb_i) st<=IDLE; else st<=IDLE;
        default: st<=IDLE;
      endcase
    end
  end
endmodule
