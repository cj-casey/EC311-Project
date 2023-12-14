`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2023 11:17:35 AM
// Design Name: 
// Module Name: VGA_Main
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VGA_Main(
    input wire in_clk,
    input [9:0] movementData,
    input wire reset,
    input wire posr,
    input wire dark_souls_mode,
    output reg [3:0] VGA_RB,
    output reg [3:0] VGA_GB,
    output reg [3:0] VGA_BB,
    output [7:0] anode,
    output [6:0] cathode,
    output [1:0] col,
    output wire hs,
    output wire vs
    );
    
    wire clk_pix,clk_mvm;
    wire w1,w2;
    wire [10:0] vga_hcnt, vga_vcnt;
    reg signed [15:0] x = 0,y = 0;
    wire vga_blank;
    wire [31:0] sseg_number;
    
    
    //movement_clock VGA_Move_Gen(in_clk,clk_mvm);
    clock_gen VGA_Clock_Gen(in_clk,clk_pix);
    signal_generation VGA_Signal_Gen(
.pixel_clk(clk_pix),
.HS(hs),
.VS(vs),
.hcounter(vga_hcnt),
.vcounter(vga_vcnt),
.blank(vga_blank));

wire fast_clock;
wire fast_clock2;
wire fsec;
wire sec_clock;
wire hsec_clock;
wire rand_enable;


 fsm fsm1(fast_clock,sseg_number,cathode,anode);
 
 Clock_divider cd1(in_clk,fast_clock);
 defparam cd1.number = 50000;
 
 Clock_divider cd2(in_clk,fast_clock2);
 defparam cd2.number = 40000;
 
  Clock_divider cd3(in_clk,hsec_clock);
  defparam cd3.number = 50000000/2;
  
  Clock_divider cd4(in_clk,fsec);
  defparam cd4.number = 50000000*5;
  
  


  
  Clock_divider cd5(in_clk,sec_clock);

parameter pcount = 420;

//parameter b_length = 94;
//parameter b_width = 94;

//parameter y_dimensions = 5;
//parameter x_dimensions = 5;

parameter horizontal_n = 5;
parameter vertical_n = 5;
parameter hline_length = pcount/horizontal_n;
parameter hline_width = 2;
parameter vline_length = 2;
parameter vline_width = pcount/vertical_n;

wire [10:0] x1_h [horizontal_n*(vertical_n):0];
wire [10:0] x2_h [horizontal_n*(vertical_n):0];
wire [10:0] y1_h [horizontal_n*(vertical_n):0];
wire [10:0] y2_h [horizontal_n*(vertical_n):0];

wire [10:0] x1_v [horizontal_n*(vertical_n):0];
wire [10:0] x2_v [horizontal_n*(vertical_n):0];
wire [10:0] y1_v [horizontal_n*(vertical_n):0];
wire [10:0] y2_v [horizontal_n*(vertical_n):0];
wire [horizontal_n*(vertical_n):0] random_h;
wire [horizontal_n*(vertical_n):0] random_v;


reg [horizontal_n*(vertical_n):0] wall_on;

reg direction_x,direction_y;
reg signed [11:0] movement_x,movement_y;
reg [11:0] vx,vy;

reg [10:0] h_min,  v_min; 
wire [10:0] h_max, v_max;



// Clock divider. Generate 25MHz pixel_clk from 100MHz clock.



//integer num = 0;
//generate
//for (i = 0; i<x_dimensions; i=i+1) begin
//	for (j=0; j<y_dimensions; j=j+1) begin
//		block #(.length(b_length), .width(b_width)) b1 (.pixel_clk(clk_pix), .ix(i*b_length+81), .iy(j*b_width), .x1(x1[5*i+j]), .x2(x2[5*i+j]), .y1(y1[5*i+j]), .y2(y2[5*i+j]), .on(random[5*i+j]));
//	end
//end
//endgenerate
genvar i; // x
genvar j; // y

generate
for (i = 0; i<horizontal_n; i=i+1) begin
for (j = 0; j<vertical_n; j=j+1) begin
		hline #(.length(hline_length), .width(hline_width)) h1 (.pixel_clk(clk_pix), .ix(i*hline_length+((640-pcount)/2)+3), .iy(j*vline_width+vline_width), .x1(x1_h[horizontal_n*i+j]), 
		.x2(x2_h[horizontal_n*i+j]), .y1(y1_h[horizontal_n*i+j]), .y2(y2_h[horizontal_n*i+j]));
	end
end
endgenerate

generate
for (i = 0; i<vertical_n; i=i+1) begin
for (j = 0; j<horizontal_n; j=j+1) begin
		vline #(.length(vline_length), .width(vline_width)) v1 (.pixel_clk(clk_pix), .ix(i*hline_length+((640-pcount)/2)+1+pcount/horizontal_n), .iy(j*vline_width), .x1(x1_v[horizontal_n*i+j]), 
		.x2(x2_v[horizontal_n*i+j]), .y1(y1_v[horizontal_n*i+j]), .y2(y2_v[horizontal_n*i+j]));
	end
end
endgenerate


parameter left_bar = ((640-pcount)/2)+1;
parameter right_bar = ((640-pcount)/2)+pcount;
parameter top_bar = 2;
parameter bottom_bar = pcount;


reg [7:0] timer;
parameter pwidth = 16;
parameter h_start = ((640-pcount)/2)+10;
parameter v_start = pcount - vline_width +10;
initial begin
h_min = h_start;
v_min = v_start;
end

assign h_max = h_min + pwidth;
assign v_max = v_min + pwidth;

parameter START = 30504031;
reg [15:0] score;

 assign sseg_number = {score,8'b00000000,timer};
 
 assign rand_enable = ~reset;
 
LFSR  lfsrh
            (.i_Clk(fast_clock2),
            .i_Enable(rand_enable),
            .i_Seed_DV(),
            .i_Seed_Data(START), // Replication
            .o_LFSR_Data(random_h),
            .o_LFSR_Done()
            );
 defparam lfsrh.NUM_BITS = horizontal_n*(vertical_n);
 
 LFSR  lfsrv
            (.i_Clk(fast_clock),
            .i_Enable(rand_enable),
            .i_Seed_DV(),
            .i_Seed_Data(START), // Replication
            .o_LFSR_Data(random_v),
            .o_LFSR_Done()
            );
 defparam lfsrv.NUM_BITS = horizontal_n*(vertical_n);

//parameter length = 94;
//parameter width = 95;



reg [horizontal_n*(vertical_n):0] random_hr;
reg [horizontal_n*(vertical_n):0] random_vr;
reg line_change;

//init

//always@(posedge sec_clock)begin
    
//	   if(count == number) begin
//	       out_clk = ~out_clk;
//	       count = 0;
//	    end
//end

always@(posedge sec_clock) begin
        
        random_hr = random_h;
        random_vr = random_v;
        
     end 

always@(posedge clk_pix) begin
        x <= x - 1;
     end 


wire refresh_tick;
assign refresh_tick = ((vga_vcnt == 481 ) && (vga_hcnt == 0)) ? 1:0;



always @(*) begin
        movement_x = (movementData[9] == 1'b0) ? {{7{1'b0}}, movementData[8:5]} : -(16-movementData[8:5]);
        movement_y = (movementData[4] == 1'b0) ? {{7{1'b0}}, movementData[3:0]} : -(16-movementData[3:0]);
        
//        if (movement_y[11] == 1) begin
//        movement_y = ~(movement_y-1);
//        movement_y = movement_y*-1;
//        end
        
//        if (movement_x[11] == 1) begin
//        movement_x = ~(movement_x-1);
//        movement_x = movement_x*-1;
//        end
        if (movement_y <= -3)
        vx = 2;
        else if (movement_y >= 3)
        vx = -2;
        else if (movement_y >= -1 && movement_y <= 1)
        vx = 0;
        else if (movement_y < -1 && movement_y > -3)
        vx = 1;
        else 
        vx = -1;
        
        
        
        if (movement_x <= -3)
        vy = -2;
        else if (movement_x >= 3)
        vy = 2;
        else if (movement_x >= -1 && movement_x <= 1)
        vy = 0;
        else if (movement_x < -1 && movement_x > -3)
        vy = -1;
        else
        vy = 1;
        
       
end
reg timer_reset = 0;
reg collision;
reg time_collision;
reg collision_x,collision_y;
reg end_flag;
reg[8:0] count;
reg [10:0] t_bar;
reg [10:0] b_bar;
reg [10:0] l_bar;
reg [10:0] r_bar;
reg w_collision;
initial begin
score = 0;
timer = horizontal_n*(vertical_n);
count = 0;
w_collision = 0;
timer_reset = 0;
t_bar = 1;
b_bar = pcount;
l_bar = (640-pcount)/2+3;
r_bar = (640-pcount)/2+3+pcount-2;
end
parameter cnt_num = 120;

always @(posedge sec_clock) begin
 if(timer_reset) begin
        timer = horizontal_n*(vertical_n);
        
  end else begin
        if(~reset) begin
               timer = timer -1;
               if (timer == 0)
                    timer = horizontal_n*(vertical_n);
              end
          
       end
end

assign col = {collision, dark_souls_mode};

always@(*) begin
    if(dark_souls_mode)
        w_collision = collision;
end
//assign w_collision = dark_souls_mode ? collision: 0;

integer k;
always @ (posedge refresh_tick) begin

     if ( l_bar >= h_min || r_bar <= h_max || b_bar <= v_max || t_bar >= v_min ) begin
        collision = 1;
    end
    
        
    if(timer == horizontal_n*(vertical_n)) begin
        time_collision = 1;
        end
    
        // Check collision with horizontal lines 
        for (k=0; k<horizontal_n*(vertical_n); k=k+1) begin
            if(~random_hr[k]) begin

                if(h_min <= x2_h[k] && h_max >= x1_h[k] && v_max >= y1_h[k] && v_min <=  y2_h[k]) begin
                 collision = 1;
                end           
            end
            end
         // Check collision with vertical lines 
        for (k=0; k<horizontal_n*(vertical_n); k=k+1) begin    
            if(~random_vr[k]) begin
                if(h_min <= x2_v[k] && h_max >= x1_v[k] && v_max >= y1_v[k] && v_min <=  y2_v[k]) begin
                 collision = 1;
                end           
            end
         
        end
      
      // End flag collision
        if(h_min <= (x1_h[0]+pcount-2-(pcount/(horizontal_n*4))) && h_max >= (x1_h[0]+pcount-5-(3*pcount/(horizontal_n*4))) &&
           v_max >= (pcount/(vertical_n*5)) && v_min <=  ((pcount/vertical_n) - pcount/(vertical_n*5))) begin
                 end_flag = 1;
        end 
        
      if(~dark_souls_mode)
        collision = 0;
        
      // Reset player position to start if collision or end flag
        if(posr || time_collision || end_flag || timer == 0 || collision) begin
            timer_reset = 1;
            
            h_min = h_start;
            v_min = v_start;
             if (end_flag) begin
                score  = score + 1;
                if(dark_souls_mode)
                     score  = score + 1;
             end
            
         end else begin
                        
                for (k=0; k<horizontal_n*(vertical_n); k=k+1) begin
                    if(~random_hr[k]) begin
                        
                        if(h_min + vx <= x2_h[k] && h_max + vx >= x1_h[k] && v_max >= y1_h[k] && v_min <=  y2_h[k]) begin
                        collision_x = 1;
                        end
                        
                        if(h_min <= x2_h[k] && h_max >= x1_h[k] && v_max + vy >= y1_h[k] && v_min + vy <=  y2_h[k]) begin
                        collision_y = 1;
                        end
                                      
                    end
                end
            
                for (k=0; k<horizontal_n*(vertical_n); k=k+1) begin    
                    if(~random_vr[k]) begin
                    
                        if(h_min + vx <= x2_v[k] && h_max + vx >= x1_v[k] && v_max >= y1_v[k] && v_min <=  y2_v[k]) begin
                        collision_x = 1;
                        end           
                        
                        if(h_min <= x2_v[k] && h_max >= x1_v[k] && v_max + vy >= y1_v[k] && v_min + vy <=  y2_v[k]) begin
                        collision_y = 1;
                        end   
                        
                    end
                end
                
                if ((h_min + vx) <= l_bar || (h_max + vx) >= r_bar) 
                    collision_x = 1;
                
                
                if ((v_min + vy) <= t_bar || (v_max + vy) >= b_bar) 
                    collision_y = 1;
                

                if(~dark_souls_mode) begin
                    if (collision_y == 0) 
                        v_min = v_min + vy;
                    
                    
                    if (collision_x == 0) 
                        h_min = h_min + vx;
                    
                end else begin
                    v_min = v_min + vy;
                    h_min = h_min + vx;
                end
                
                
            
            end
          
        
          if (timer ==horizontal_n*(vertical_n)) 
            timer_reset = 0;
            
        end_flag = 0;
        collision = 0;
         time_collision = 0;
        collision_x = 0;
        collision_y = 0;
    end 


always @(*) begin
    // Set pixels to black during Sync. Failure to do so will result in dimmed colors or black screens.
    if (vga_blank) begin 
        VGA_RB = 0;
        VGA_GB = 0;
        VGA_BB = 0;
    end
    else begin  // Image to be displayed
        // Default values for the checkerboard background
        VGA_RB = 0;
        VGA_GB = 0;
        VGA_BB = 0;
                      

            // Horizontal Lines
            for(k=0; k<horizontal_n*(vertical_n); k=k+1) begin
                if(~random_hr[k]) begin
		 		if ((vga_hcnt >= x1_h[k]) && (vga_hcnt <=  x2_h[k]) &&
         		((vga_vcnt >=  y1_h[k]) && vga_vcnt <=  y2_h[k])) begin
	               VGA_RB = 0;
                    VGA_GB = 255;
                    VGA_BB = 0;
		 		end
		 		end
         	end
         	// Vertical Lines
         	for(k=0; k<horizontal_n*(vertical_n); k=k+1) begin
                if(~random_vr[k]) begin
		 		if ((vga_hcnt >= x1_v[k]) && (vga_hcnt <=  x2_v[k]) &&
         		((vga_vcnt >=  y1_v[k]) && vga_vcnt <=  y2_v[k])) begin
	               VGA_RB = 0;
                    VGA_GB = 255;
                    VGA_BB = 0;
		 		end
		 		end
         	end
         	      //left bar
            if ((vga_hcnt >= (x1_h[0]-1)) && (vga_hcnt <= (x1_h[0]+1)) && (vga_vcnt >= (0)) && (vga_vcnt <= (pcount))) begin
            VGA_RB = 255;
            VGA_GB = 255;
            VGA_BB = 255;
            end  
//         	  //right bar
            if ((vga_hcnt >= (x1_h[0]+pcount-2)) && (vga_hcnt <= (x1_h[0]+pcount)) && (vga_vcnt >= (0)) && (vga_vcnt <= (pcount))) begin
            VGA_RB = 255;
            VGA_GB = 255;
            VGA_BB = 255;
            end
//             top bar
            if ((vga_hcnt >= (x1_h[0])) && (vga_hcnt <= (x1_h[0]+pcount)) && (vga_vcnt == (0))) begin
            VGA_RB = 255;
            VGA_GB = 255;
            VGA_BB = 255;
            end
////bottom bar
             if ((vga_hcnt >= (x1_h[0]-1)) && (vga_hcnt <= (x1_h[0]+pcount)) && (vga_vcnt >= (pcount)) && (vga_vcnt <= (pcount+2))) begin
            VGA_RB = 255;
            VGA_GB = 255;
            VGA_BB = 255;
            end
            
          //flag pole
             if ((vga_hcnt >= x1_h[0]+pcount-5-(3*pcount/(horizontal_n*4))) && (vga_hcnt <= x1_h[0]+pcount-3-(3*pcount/(horizontal_n*4))) &&
         		((vga_vcnt >= pcount/(vertical_n*5))) && vga_vcnt <=  (pcount/vertical_n) - pcount/(vertical_n*5)) begin
            VGA_RB = 255;
            VGA_GB = 255;
            VGA_BB = 255;
            end
            
            // end flag
             if ((vga_hcnt >= x1_h[0]+pcount-(3*pcount/(horizontal_n*4))) && (vga_hcnt <= x1_h[0]+pcount-2-(pcount/(horizontal_n*4))) &&
         		((vga_vcnt >= pcount/(vertical_n*5))) && vga_vcnt <=  pcount/(vertical_n*5)+((pcount/vertical_n)-vertical_n)/3) begin
            VGA_RB = 255;
            VGA_GB = 0;
            VGA_BB = 0;
            end

            
           

        
        // purple square at the center
        if ((vga_hcnt >= (h_min) && vga_hcnt <= (h_max )) &&
            (vga_vcnt >= (v_min) && vga_vcnt <= (v_max))) begin
            VGA_RB = 4'hf;
            VGA_BB = 4'hf;
        end

        end
    end


endmodule