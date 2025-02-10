library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SP_adder_unit is
    generic (
        WIDTH : integer := 16
    );
    port (
		  Rst : in std_logic;
        SP_old : in  std_logic_vector(WIDTH-1 downto 0);  
        SP_sel : in  std_logic_vector(1 downto 0);         
        SP_new : out std_logic_vector(WIDTH-1 downto 0)     
    );
end SP_adder_unit;

architecture SP_adder_unit_arch of SP_adder_unit is
    signal mux_out : std_logic_vector(WIDTH-1 downto 0); -- Value to add/subtract
    signal SP_internal : std_logic_vector(WIDTH-1 downto 0); -- Internal register for SP
    signal add_result : std_logic_vector(WIDTH-1 downto 0); -- Temporary adder result
begin
    process(Rst, SP_old)
    begin
        if Rst = '1' then
            SP_internal <= std_logic_vector(to_unsigned(2**12 - 1, WIDTH)); -- Initialize SP to 4095
        else
            SP_internal <= SP_old; -- Use the external SP_old after reset
        end if;
    end process;

    process(SP_sel)
    begin
        case SP_sel is
            when "00" =>
                mux_out <= (others => '0');  -- Select 0
            when "01" =>
                mux_out <= std_logic_vector(to_signed(-1, WIDTH));  -- Select -1
            when "10" =>
                mux_out <= std_logic_vector(to_signed(1, WIDTH)); -- Select +1
            when others =>
                mux_out <= (others => '0');  -- Default case
        end case;
    end process;

    adder_inst: entity work.n_BitsAdder
        generic map (
            WIDTH => WIDTH
        )
        port map (
            A    => SP_internal, 
            B    => mux_out,   
            Cin  => '0',       
            Sum  => add_result, -- temporary result for wrap-around case
            Cout => open       
        );

    process(SP_sel, SP_internal, add_result)
    begin
        if SP_sel = "01" and SP_internal = "0000000000000000" then
            SP_new <= std_logic_vector(to_unsigned(2**12 - 1, WIDTH)); -- Wrap around to 4095
        else
            SP_new <= add_result; 
        end if;
    end process;

end SP_adder_unit_arch;
