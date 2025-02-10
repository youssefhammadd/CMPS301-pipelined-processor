library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY Reg_File IS 
GENERIC( 
	address_bits : integer := 3 ; 
	data_bits : integer := 16 ); 
PORT( 
	clk,rst,we 		: in std_logic; 
	Rsrc1,Rsrc2 : in std_logic_vector(address_bits-1 downto 0); 
	Rdst : in std_logic_vector(address_bits-1 downto 0);
	write_data : in std_logic_vector(data_bits-1 downto 0);
	read_data1, read_data2 : out std_logic_vector(data_bits-1 downto 0)
	);
END ENTITY;
	

ARCHITECTURE Arch_Reg_File of Reg_File IS 
	TYPE reg_array IS ARRAY((2**address_bits)-1 downto 0) of std_logic_vector(data_bits-1 downto 0); -- 8 registers, each 8-bits wide
	SIGNAL registers : reg_array:= (others => (others => '0')); -- Initialize all to 0
BEGIN 
    PROCESS(clk, rst) 
    BEGIN 
        IF(rst = '1') THEN
            registers <= (others => (others => '0')); -- Reset all registers to 0
        ELSIF falling_edge(clk) THEN 
            IF we = '1' THEN 
                registers(to_integer(unsigned(Rdst))) <= write_data; 
            END IF; 
        END IF;
    END PROCESS; 

    read_data1 <= registers(to_integer(unsigned(Rsrc1)));
    read_data2 <= registers(to_integer(unsigned(Rsrc2)));

END ARCHITECTURE;
