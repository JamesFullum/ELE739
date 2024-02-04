--------------------------------------------------------------------------------
-- Titre    : Feu Priorité de la Traverse au Piétons
-- Projet   : ELE739 Phase 1
--------------------------------------------------------------------------------
-- Fichier  : Feu_PTP.vhd
-- Auteur   : Guillaume et James
-- Création : 2024-01-23
--------------------------------------------------------------------------------
-- Description : Feu de traffique pour piétons paramétrable avec signal d'activation
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FEU_FPTP is
  -- La section generic contient les paramètres de configuration du module.
  generic (
    G_DELAI_CONTINU       : positive := 6; -- valeur maximum pour le délai
    G_DELAI_CLIGNOTE      : positive := 3; -- Seuil ou la lumière va devenir jaune
    G_DELAI_SIZE          : positive := 7 -- taille en bits du registre du compteur
  );

Port (
    i_clk      : in  std_logic;
    i_rst      : in  std_logic;
    i_cen      : in  std_logic;
    o_feu_FPTP : out std_logic;
    o_fin      : out std_logic
);
end FEU_FPTP;

architecture rtl of FEU_FPTP is
   signal delai_sig     : unsigned(G_DELAI_SIZE-1 downto 0);
   
   type cmptr_state is (ETEINT, CLIGNOTE, CONTINU, DONE);
   
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
           delai_sig  <= (others => '0');
           o_feu_FPTP <= '0';
           o_fin      <= '0';
        else
           case next_state is
              when ETEINT =>
                 o_feu_FPTP <= '0';
                 o_fin      <= '0';
                 delai_sig  <= (others => '0');
              when DONE =>
                 o_feu_FPTP <= '0';
                 o_fin      <= '1';
                 delai_sig  <= (others => '0');
              when CLIGNOTE =>
                 o_feu_FPTP <= delai_sig(0);
                 o_fin      <= '0';
                 delai_sig <= delai_sig + 1;
              when CONTINU  =>
                 o_feu_FPTP <= '1';
                 o_fin      <= '0';
                 delai_sig <= delai_sig + 1;        
              when others =>
                 o_feu_FPTP <= '0';
                 o_fin      <= '0';
              end case;
            current_state <= next_state;
         end if;
      end if;
   end process;
   
   
   -------------------------------------
  -- Next State Logic
  -------------------------------------  
  process(delai_sig, current_state, i_cen)
  begin
     case current_state is
        when ETEINT =>
           if i_cen = '1' then
              next_state <= CONTINU;
           else
              next_state <= ETEINT;
           end if;
        when DONE =>
           next_state <= ETEINT;
        when CLIGNOTE =>
           if delai_sig >= G_DELAI_CLIGNOTE then
              next_state <= DONE;
           else
              next_state <= CLIGNOTE;
           end if;
        when CONTINU =>
           if delai_sig >= G_DELAI_CONTINU then
              next_state <= CLIGNOTE;
           else
              next_state <= CONTINU;
           end if;
        when others =>
           next_state <= ETEINT;
     end case;
  end process;
      

end rtl;