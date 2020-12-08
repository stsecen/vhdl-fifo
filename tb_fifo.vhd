library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fifo is
end tb_fifo;

architecture rtl of tb_fifo is
    constant  M : integer := 8;
    constant N  : integer := 32;
    constant AF : integer := 30;
    constant AE : integer := 2;

    signal uut_rst,uut_clk, uut_clk_rd, uut_clk_wr, uut_we, uut_re : std_logic := '0';
    signal uut_data_in, uut_data_async, uut_data_sync : std_logic_vector(M-1 downto 0) := (others => '0');
    signal uut_empty_async, uut_full_async: std_logic := '0';
    signal uut_aempty_async, uut_afull_async: std_logic := '0';
    signal uut_empty_sync, uut_full_sync: std_logic := '0';
    signal uut_aempty_sync, uut_afull_sync: std_logic := '0';
    constant uut_clk_we_time: time 100 ns;
    constant uut_clk_rd_time: time 50 ns;
    constant uut_clk_time: time := 10 ns;
begin
    async: entity work.fifo_async(rtl)
           generic map(
                M => M,
                N => N,
                AF=> AF,
                AE=> AE
            );
           port map(
            rst_w => uut_rst,
            clk_w => uut_clk_wr, 
            rst_r => uut_rst,
            clk_r => uut_clk_rd, 
            i_we =>  uut_we,        
            i_data => uut_data_in,       
            i_re => uut_re,         
            o_data => uut_data_async,       
            o_afull => uut_afull_async,      
            o_aempty =>uut_aempty_async,    
            o_empty =>uut_empty_async,     
            o_full => uut_full_async   
           );
    sync:  entity work.fifo_sync(rtl)
           generic map(
                M => M,
                N => N,
                AF=> AF,
                AE=> AE
           );
           port map(
            rst => uut_rst,
            clk => uut_clk,
            i_we => uut_we,   
            i_data => uut_data_in,   
            i_re => uut_re,
            o_data => uut_data_sync,  
            o_afull => uut_afull_sync,
            o_aempty => uut_aempty_sync,
            o_empty => uut_empty_sync,
            o_full => uut_full_sync
           );
    
    gen_wr_clk: process
    begin
        for i in 0 to 100 loop
            wait for uut_clk_we_time/2;
            uut_clk_wr <= '1';
            wait for uut_clk_we_time/2;
            uut_clk_wr <= '0';
        end loop;
        wait;
    end process;

    gen_rd_clk: process
    begin
        for i in 0 to 200 loop
            wait for uut_clk_rd_time/2;
            uut_clk_rd <= '1';
            wait for uut_clk_rd_time/2;
            uut_clk_rd <= '0';
        end loop;
        wait;
    end process;

    gen_sync_clk: process
    begin
        for i in 0 to 200 loop
            wait for uut_clk_time/2;
            uut_clk <= '1';
            wait for uut_clk_time/2;
            uut_clk <= '0';
        end loop;
        wait;
    end process;

    uut: process
    begin
        uut_rst <= '1';
        wait for 20 * uut_clk_rd;
        uut_rst <= '0';

        for i in 1 to 20 loop
            uut_data_in <= std_logic_vector(to_unsigned(i, M));
            wait for uut_clk_we_time;
            uut_we <= '1';
            wait for uut_clk_we_time;
            uut_we <= '0';
        end loop;

        wait until clk_rd = '0';
        rd_en <= '1';
        wait for 30 * uut_clk_rd;
        rd_en <= '0';

        for i in 1 to 50 loop
            uut_data_in <= std_logic_vector(to_unsigned(i, M));
            wait for uut_clk_wr;
            uut_we <= '1';
            wait for uut_clk_wr;
            uut_we <= '0';
        end loop;

        wait until clk_rd = '0';

        for i in 1 to 20 loop
            uut_we <= '1';
            wait for uut_clk_rd_time;
        end loop;
        wait;
    end process uut;
end architecture rtl;