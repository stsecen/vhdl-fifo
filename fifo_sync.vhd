library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity fifo_sync is
generic(
    M : integer := 8;    --> width 
    N : integer := 32;   --> depth 
    AF: integer := 30;   --> almost full 
    AE: integer := 2    --> almost empty
);
port(
    rst,clk         :  in std_logic;
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

architecture rtl of fifo_sync is
    type fifo_type is array(0 to N-1) of std_logic_vector(N-1 downto 0);
    signal r_fifo     : fifo_type := (others => (others => '0'));
    signal s_counter  : integer range 0 to N   := 0;
    signal s_wr_cnt   : integer range 0 to N-1 := 0;
    signal s_rd_cnt   : integer range 0 to N-1 := 0;
    signal s_full, s_empty, s_aempty, s_afull : std_logic := '0';
begin
    o_data <= r_fifo(s_rd_cnt);
    o_full <= s_full;
    o_empty <= s_empty;
    o_afull <= s_afull;
    o_aempty <= s_aempty;
    write: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
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

    read: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
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
    end process read;
    
    count: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                s_counter <= 0;
            else
            --> Keeps track of the total number of words in the FIFO
                if (i_we = '1' and i_re = '0') then
                    if s_full = '0' then
                        s_counter <= s_counter + 1;
                    end if;
                elsif (i_we = '0' and i_re = '1') then
                    if s_empty = '0' then 
                        s_counter <= s_counter - 1;
                    end if;
                end if;
            end if;
        end if;
    end process count;

    s_empty <= '1' when s_counter = 0 else '0';
    s_full  <= '1' when s_counter = N else '0';
    s_aempty <= '1' when s_counter <= AE else '0';
    s_afull <= '1' when s_counter >= AF else '0';
    
end architecture rtl;
