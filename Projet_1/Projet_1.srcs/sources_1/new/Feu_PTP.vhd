----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/30/2024 12:10:28 PM
-- Design Name: 
-- Module Name: FEU_FPTP - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FEU_FPTP is
  -- La section generic contient les paramètres de configuration du module.
  generic (
    G_DELAI_CONTINU       : positive := 6; -- valeur maximum pour le délai
    G_DELAI_CLIGNOTE      : positive := 3; -- Seuil ou la lumière va devenir jaune
    G_DELAI_SIZE          : positive := 7 -- taille en bits du registre du compteur
  );

Port (
    i_clk   : in  std_logic;
    i_rst   : in  std_logic;
    i_cen   : in  std_logic;
    o_feu_FPTP : out std_logic;
    o_fin   : out std_logic
);
end FEU_FPTP;

architecture rtl of FEU_FPTP is
   signal delai_sig     : unsigned(G_DELAI_SIZE-1 downto 0);
   signal clk_counter   : natural range 0 to 10000 := 0;
   signal blinker       : std_logic := '0';
   
   
   type cmptr_state is (CONTINU, CLIGNOTE, ETEINT);
   
   signal current_state : cmptr_state;
   signal next_state    : cmptr_state;
   
begin
-------------------------------------
  -- Current State Logic
  -------------------------------------
  process(i_clk)
  begin
     if rising_edge(i_clk) then
        -- Réinitialiser le compteur et éteindre la lumière
        if i_rst = '1' then
           delai_sig    <= (others => '0');
           o_feu_FPTP   <= '0';
           o_fin        <= '0';
        else
           case next_state is
              when ETEINT =>
                 o_feu_FPTP <= '0';
                 o_fin   <= '1';
                 
              when CLIGNOTE =>
                if rising_edge(i_clk) then 
                    clk_counter <= clk_counter + 1; 
                if clk_counter >= 10000 then 
                    blinker <= not blinker;
                    o_feu_FPTP <= blinker;
                    clk_counter <= 0;
                end if; 
                end if; 
                 o_fin   <= '0';
                 
              when CONTINU  =>
                 o_feu_FPTP <= '1';
                 o_fin   <= '0';
                          
              when others =>
                 o_feu_FPTP <= '0';
       
                 o_fin   <= '0';
               end case;
               
            delai_sig <= delai_sig + 1;
         end if;
      end if;
   end process;
      

end rtl;