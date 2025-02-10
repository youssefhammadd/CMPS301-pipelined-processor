library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Data_Memory is
    generic (
        WIDTH : integer := 16
    );
    port (
        clk, rst, re, we : in std_logic;
        address, write_data : in std_logic_vector(WIDTH-1 downto 0);
        memory_out : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity Data_Memory;

architecture Data_Memory_arch of Data_Memory is
	 type mem is array (0 to 4095) of std_logic_vector(WIDTH-1 downto 0);
    signal memory : mem := (others => (others => '0'));
	
	SIGNAL Temp_address : STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
	
	SIGNAL Write_enable : std_logic;
	SIGNAL Read_enable : STD_LOGIC;
    signal address_int : integer;

	SIGNAL valid_address : BOOLEAN;
begin

	valid_address <= (to_integer(unsigned(address)) < 2 ** 12);
	
	
	--out of range ADDRESS when valid_address = 0 if the address is not valid let the address be the first place in the memory
	Temp_address <= 
	address WHEN valid_address ELSE 
	"0000111111111111" ;
	
	address_int <= to_integer(unsigned(Temp_address));
	Write_enable <= 
	we WHEN valid_address ELSE 
	'0';
	
	Read_enable <=
	re WHEN valid_address ELSE
	'0';
	
	



process(clk, rst)
begin
    if rst = '1' then
        memory <= (others => (others => '0')); -- Reset memory to zeros
		memory_out <= (others => '0'); 		  -- Default output
    elsif falling_edge(clk) then
        if Write_enable = '1' then
            memory(address_int) <= write_data; -- Write data to memory
		end if;
		if Read_enable = '1' then
			memory_out <= memory(address_int); -- Read data from memory
		else
			memory_out <= (others => '0'); -- Default output
        end if;
    end if;
end process;

end architecture;
