// Zet (x86-16) minimal SoC for Zynq-7010 PL
// Memory: PS DDR @0x1C000000 via HP0 (safe high CMA window), BIOS in BRAM @0xFF000 (real mode high mem)
// IO: PS accesses via GP0 -> 0x8000_xxxx IO window; uart console via PS UART
`timescale 1ns/1ps
module zet_soc_top (
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_aclk CLK" *)
  (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF s_axi:m_axi, ASSOCIATED_RESET s_axi_aresetn" *)
  input  wire        s_axi_aclk,
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *)
  input  wire        s_axi_aresetn,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWADDR" *)
  input  wire [31:0] s_axi_awaddr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWVALID" *)
  input  wire        s_axi_awvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWREADY" *)
  output wire        s_axi_awready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WDATA" *)
  input  wire [31:0] s_axi_wdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WSTRB" *)
  input  wire [3:0]  s_axi_wstrb,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WVALID" *)
  input  wire        s_axi_wvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WREADY" *)
  output wire        s_axi_wready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BRESP" *)
  output wire [1:0]  s_axi_bresp,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BVALID" *)
  output wire        s_axi_bvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BREADY" *)
  input  wire        s_axi_bready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARADDR" *)
  input  wire [31:0] s_axi_araddr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARVALID" *)
  input  wire        s_axi_arvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARREADY" *)
  output wire        s_axi_arready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RDATA" *)
  output wire [31:0] s_axi_rdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RRESP" *)
  output wire [1:0]  s_axi_rresp,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RVALID" *)
  output wire        s_axi_rvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RREADY" *)
  input  wire        s_axi_rready,
  // HP0 master
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi AWADDR" *)
  output wire [31:0] m_axi_awaddr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi AWVALID" *)
  output wire        m_axi_awvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi AWREADY" *)
  input  wire        m_axi_awready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi WDATA" *)
  output wire [31:0] m_axi_wdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi WSTRB" *)
  output wire [3:0]  m_axi_wstrb,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi WVALID" *)
  output wire        m_axi_wvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi WREADY" *)
  input  wire        m_axi_wready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi BRESP" *)
  input  wire [1:0]  m_axi_bresp,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi BVALID" *)
  input  wire        m_axi_bvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi BREADY" *)
  output wire        m_axi_bready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi ARADDR" *)
  output wire [31:0] m_axi_araddr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi ARVALID" *)
  output wire        m_axi_arvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi ARREADY" *)
  input  wire        m_axi_arready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi RDATA" *)
  input  wire [31:0] m_axi_rdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi RRESP" *)
  input  wire [1:0]  m_axi_rresp,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi RVALID" *)
  input  wire        m_axi_rvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi RREADY" *)
  output wire        m_axi_rready,
  input  wire        uart_rxd,
  output wire        uart_txd,
  output wire        led
);
  wire clk = s_axi_aclk;
  wire rst_n = s_axi_aresetn;

  // ==== Zet core (Wishbone) ====
  wire [19:1] z_adr;
  wire [15:0] z_dat_i, z_dat_o;
  wire        z_we, z_tga, z_stb, z_cyc;
  wire [1:0]  z_sel;
  wire        z_ack;
  wire        z_tgc_i, z_tgc_o, nmi, nmia;
  wire [19:0] z_pc;

  zet zet_i (
    .wb_clk_i(clk), .wb_rst_i(~rst_n),
    .wb_dat_i(z_dat_i), .wb_dat_o(z_dat_o),
    .wb_adr_o(z_adr), .wb_we_o(z_we), .wb_tga_o(z_tga),
    .wb_sel_o(z_sel), .wb_stb_o(z_stb), .wb_cyc_o(z_cyc),
    .wb_ack_i(z_ack),
    .wb_tgc_i(1'b0), .wb_tgc_o(z_tgc_o),
    .nmi(1'b0), .nmia(nmia),
    .pc(z_pc)
  );

  // ==== BIOS BRAM: 8KB @0xFE000-0xFFFFF (real-mode BIOS area) ====
  // decoded in the wb arbiter below; implemented with a simple ROM for now
  wire bios_sel = (z_adr >= 19'h7F000);  // 0xFE000>>1 = 0x7F000
  reg  [15:0] bios_rom [0:4095];
  wire [15:0] bios_rdata = bios_rom[z_adr[12:1]];
  initial $readmemh("bios.hex", bios_rom);

  // ==== WB->AXI to DDR ====
  wire [15:0] ddr_dat_o;
  wire        ddr_ack;
  wb2axi wb2axi_i (
    .clk(clk), .rst_n(rst_n),
    .wb_adr_i(z_adr), .wb_dat_i(z_dat_o), .wb_dat_o(ddr_dat_o),
    .wb_we_i(z_we), .wb_sel_i(z_sel),
    .wb_stb_i(z_stb & ~bios_sel), .wb_cyc_i(z_cyc & ~bios_sel),
    .wb_tga_i(z_tga),
    .wb_ack_o(ddr_ack),
    .axi_awaddr(m_axi_awaddr), .axi_awvalid(m_axi_awvalid), .axi_awready(m_axi_awready),
    .axi_wdata(m_axi_wdata), .axi_wstrb(m_axi_wstrb), .axi_wvalid(m_axi_wvalid), .axi_wready(m_axi_wready),
    .axi_bresp(m_axi_bresp), .axi_bvalid(m_axi_bvalid), .axi_bready(m_axi_bready),
    .axi_araddr(m_axi_araddr), .axi_arvalid(m_axi_arvalid), .axi_arready(m_axi_arready),
    .axi_rdata(m_axi_rdata), .axi_rresp(m_axi_rresp), .axi_rvalid(m_axi_rvalid), .axi_rready(m_axi_rready)
  );

  // ==== WB mux: bios rom or ddr ====
  assign z_dat_i = bios_sel ? bios_rdata : ddr_dat_o;
  assign z_ack   = bios_sel ? 1'b1       : ddr_ack;

  assign led = z_cyc;
  assign uart_txd = 1'b1;   // uart not wired in minimal version
  // stub AXI-lite slave (PS control/status) - just ack reads with pc
  assign s_axi_awready=1'b1; assign s_axi_wready=1'b1;
  assign s_axi_bresp=2'b0;   assign s_axi_bvalid=s_axi_awvalid & s_axi_bready;
  assign s_axi_arready=1'b1; assign s_axi_rdata={12'h0,z_pc}; assign s_axi_rresp=2'b0; assign s_axi_rvalid=s_axi_arvalid & s_axi_rready;
endmodule
