library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CCR is
    port(
	 
			clk            : in STD_LOGIC;
			asyncRest		: in STD_LOGIC;
			
		  unconditional_branching : in STD_LOGIC; -- if = 1 do not change flags
		
        flags_in_ALU    : in STD_LOGIC_VECTOR(2 downto 0);
        flags_in_RTI    : in STD_LOGIC_VECTOR(2 downto 0);
        reset_Z         : in STD_LOGIC;
        reset_N         : in STD_LOGIC;
        reset_C         : in STD_LOGIC;
        
        ALU_F_enable    : in STD_LOGIC;
        restore_WB      : in STD_LOGIC;
        
        flags_out       : out STD_LOGIC_VECTOR(2 downto 0)
    );
end CCR;

architecture Behavioral of CCR is

    SIGNAL flags: STD_LOGIC_VECTOR(2 downto 0):=(others => '0');

begin

    process(clk, asyncRest, restore_WB)
    begin
	 
		if asyncRest = '1' then
			flags <= (others => '0');
	 
		elsif rising_edge(clK) then
			  
			  if restore_WB = '1' then
					flags <= flags_in_RTI;
			  elsif ALU_F_enable = '1' then
					flags <= flags_in_ALU;
					
				elsif unconditional_branching = '1' then
					 -- Do nothing
					
			  else
						
					  -- Handle individual reset signals
					  if reset_Z = '1' then
							flags(0) <= '0'; -- Reset Zero flag
					  end if;

					  if reset_N = '1' then
							flags(1) <= '0'; -- Reset Negative flag
					  end if;

					  if reset_C = '1' then
							flags(2) <= '0'; -- Reset Carry flag
							
					  end if;
			  
			  end if;
		end if;

    end process;
	  -- Assign to output
     flags_out <= flags;

end Behavioral;
