// The testbench for the timing measurement of an invertor
// This code is purely digital code, using SystemVerilog language.
// This code mimics what can be done with a real breadboard using
// signal generators and oscilloscopes.

`timescale 1ns / 100fs

module testbench;

  // The testbench will generate "events" for the breadboard. We define here the time interval
  // between two events. The time interval should be long enough to be sure that the DUT (Device
  // Under Test) signals are stable when a measurement is asked to the breadboard.
  // Warning: a two long time interval may lead to very slow simulations...
  parameter real digital_tick = 10;  // (ns) Time between two events on the DUT inputs.

  // Logical signals
  logic clk;  // The clock signal
  logic din;  // The logic input of the invertor.
  wire dout;  // The logic output of the invertor
  // Real signals used send values to the breadboard
  real load_capacitor_val ; // The choosen value of a load capacitor loading the output of the invertor
  real clk_tt_val;  // The choosen value of the transition time of the clock input
  real din_tt_val;  // The choosen value of the transition time of the input
  real clk_delay_val = 0.0;  // An arbitrary incremental delay added to the clock transition
  real din_delay_val = 0.0;  // An arbitrary incremental delay added to the input transition
  // Real signals used receive measured values from the breadboard
  real propagation_time;  // The measured output propagation time for a rising output

  // Breadboard instanciation, using connected signals
  board bdut (
      .clk_logic(clk),
      .din_logic(din),
      .dout_electrical(dout),
      .clk_tt_val(clk_tt_val),
      .din_tt_val(din_tt_val),
      .clk_delay_val(clk_delay_val),
      .din_delay_val(din_delay_val),
      .load_capacitor_val(load_capacitor_val),
      .propagation_time(propagation_time)
  );

  // The list of measurement points is defined by 2 parameters tables extracted from the Liberty 
  // files of the gcslib045 library.
  // The input slope should no excess the max_input_transition of the library : 200ps
  localparam NBSLOPES = 7;
  localparam NBCAPA = 7;
  localparam real slope_values[0:NBSLOPES-1] = '{0.001, 0.03, 0.07, 0.10, 0.13, 0.17, 0.20};  // ns
  localparam real capa_values[0:NBCAPA-1] = '{0.02, 1.25, 2.5, 5, 11, 21, 42};  // fF

  // Defines a file name for storing output results
  string outfilename;
  // Define a file pointer for the file.
  int outfile;
  // Define the standard error channel.
  integer STDERR = 32'h8000_0002;

  localparam real CLK_MIN_PS = 0.0;  // search lower bound in ps
  localparam real CLK_MAX_PS = 100.0;  // search upper bound in ps (adapt if needed)
  localparam real ACCURACY_PS = 0.5;  // stop criterion on clk delay (ps)
  localparam int MAX_ITERS = 50;  // safety cap

  // A reference output to check the DUT behavior
  logic dout_ref;
  always @(posedge clk) dout_ref <= din;

  // ---------------------------------------------------------
  // Measure total delay (ns) for a given clk delay (ps)
  // total_ns = propagation(ns) + clk_delay(ps)/1000
  // This reproduces your stimulus/quieting/check sequence.
  // ---------------------------------------------------------
  task automatic measure_total_ns(input real clk_delay_ps, output real total_ns);
    real prop_ns;

    // program the delay (convert ps -> s)
    clk_delay_val = clk_delay_ps * 1.0e-12;

    // ensure DUT is quiet
    #(digital_tick);

    // Stimulus sequence (same as your loop body)
    clk = 1'b1;
    #(digital_tick);

    clk = 1'b0;
    #(digital_tick);

    clk = 1'b1;
    din = 1'b1;
    #(digital_tick);

    // Check expected behavior (invertor reference)
    if (dout != dout_ref) begin
      $fdisplay(STDERR, "\033[91m testbench: at time %0t: din:%0d, dout:%0d \033[0m", $realtime,
                din, dout);
      $fdisplay(STDERR, "\033[92m testbench: ERROR detected from testbench\033[0m");
      $fflush(STDERR);
      $finish;
    end

    // propagation_time provided by the breadboard (in seconds)
    prop_ns  = propagation_time / 1.0e-9;

    total_ns = prop_ns + (clk_delay_ps / 1000.0);

    // Quiet + reset inputs back to 0 for next measurement
    #(digital_tick);
    clk = 1'b0;
    din = 1'b0;
  endtask

  initial begin : simu
    // loop indices
    int slope_index, capa_index;

    // dichotomy / search variables
    int iter;
    real L_ps, R_ps, delta_ps, mid_ps, midp_ps;
    real f_mid_ns, f_midp_ns;
    real best_ps, best_ns, other_ns;
    real best_prop_ns;

    din_tt_val    = 0.10e-9;
    din_delay_val = 0.0;
    clk_delay_val = 0.0;

    // Output file
    $swrite(outfilename, "results/TSPCFF_setup_min_dichotomy.dat");
    outfile = $fopen(outfilename, "w");

    // Header: now we store setup and propagation at the optimum
    $fwrite(outfile, "islope(ns)  capa(fF)  setup(ps)  propagation(ns)  total(ns)\n");

    // Init
    din = 1'b0;
    clk = 1'b0;

    // ---- Sweep all slopes & capacitances (you can restrict if too slow) ----
    for (slope_index = 3; slope_index < 4; slope_index++) begin
      #(digital_tick);
      clk_tt_val = slope_values[slope_index] * 1.0e-9;

      for (capa_index = 0; capa_index < NBCAPA; capa_index++) begin
        #(digital_tick);
        load_capacitor_val = capa_values[capa_index] * 1.0e-15;

        // --- Dichotomy search on clk_delay(ps) ---
        L_ps               = CLK_MIN_PS;
        R_ps               = CLK_MAX_PS;
        delta_ps           = ACCURACY_PS;
        iter               = 0;

        while ((R_ps - L_ps) > ACCURACY_PS && iter < MAX_ITERS) begin
          mid_ps  = 0.5 * (L_ps + R_ps);
          midp_ps = mid_ps + delta_ps;
          if (midp_ps > CLK_MAX_PS) midp_ps = CLK_MAX_PS;

          measure_total_ns(mid_ps, f_mid_ns);
          measure_total_ns(midp_ps, f_midp_ns);

          if (f_midp_ns > f_mid_ns) R_ps = mid_ps;  // minimum on the left
          else L_ps = mid_ps;  // minimum on the right

          iter = iter + 1;
        end

        // Choose the best of the final bracket ends
        measure_total_ns(L_ps, best_ns);
        best_ps = L_ps;
        measure_total_ns(R_ps, other_ns);
        if (other_ns < best_ns) begin
          best_ns = other_ns;
          best_ps = R_ps;
        end

        // Recover propagation at the optimum:
        // total = prop + clk_delay_ns  =>  prop = total - clk_delay_ns
        best_prop_ns = best_ns - (best_ps / 1000.0);

        // Write one line per (slope, cap)
        $fwrite(outfile, "%010.6f %010.6f %010.6f %010.6f %010.6f\n",
                slope_values[slope_index],  // islope(ns)
                capa_values[capa_index],  // capa(fF)
                best_ps,  // setup ≈ min clk delay (ps)
                best_prop_ns,  // propagation(ns) at that point
                best_ns);  // total(ns) = setup_ns + prop_ns
      end
    end

    $fclose(outfile);
    $stop;
  end

endmodule
