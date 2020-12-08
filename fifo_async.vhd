library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

generic(
    M : integer := 8;    --> width 
    N : integer := 32;   --> depth 
    AF: integer := 30;   --> almost full 
    AE: integer := 2;    --> almost empty
);
port(
    rst_w,clk_w     :  in std_logic;
    rst_r,clk_r     :  in std_logic;
    i_we            :  in std_logic;
    i_data          :  in std_logic_vector(M-1 downto 0);
    i_re            :  in std_logic;
    o_data          : out std_logic_vector(M-1 downto 0);
    o_afull         : out std_logic;
    o_aempty        : out std_logic;
    o_empty         : out std_logic;
    o_full          : out std_logic
);
end fifo_sync;

architecture rtl of fifo_async is
    type fifo_type is array(0 to N-1) of std_logic_vector(N-1 downto 0);
    signal r_fifo     : fifo_type := (others => (others => '0'));
    signal s_wr_cnt   : integer range 0 to N-1 := 0;
    signal s_rd_cnt   : integer range 0 to N-1 := 0;
    signal s_full, s_empty, s_aempty, s_afull  : std_logic := '0';
begin
    o_data <= r_fifo(s_rd_cnt);
    o_empty <= s_empty;
    o_full <= s_full;
    o_aempty <= s_aempty;
    o_afull <= s_afull;
    write: process(clk_w)
    begin
        if rising_edge(clk_w) then
            if rst_w = '1' then
                s_wr_cnt <= 0;
            else
                if i_we = '1' then 
                    if s_full = '0' then 
                        r_fifo(s_wr_cnt) <= i_data;
                        if s_wr_cnt = N-1 then
                            s_wr_cnt <= 0;
                        else 
                            s_wr_cnt <= s_wr_cnt+1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process write;
    write: process(clk_r)
    begin
        if rising_edge(clk_r) then
            if rst_r = '1' then
                s_rd_cnt <= 0;
            else
                if i_re = '1' then 
                    if s_empty = '0' then 
                        if s_rd_cnt = N-1 then
                            s_rd_cnt <= 0;
                        else 
                            s_rd_cnt <= s_rd_cnt+1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process write;
    s_empty <= '1' when s_wr_cnt-s_rd_cnt=0 else '0';
    s_full  <= '1' when s_wr_cnt=N and s_rd_cnt=0 else '0';
    s_aempty <= '1' when s_wr_cnt-s_rd_cnt <= AE  else '0';
    s_afull <= '0'; --> i will think about that
end architecture rtl;