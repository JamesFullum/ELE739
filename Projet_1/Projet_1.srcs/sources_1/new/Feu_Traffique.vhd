--------------------------------------------------------------------------------
-- Titre    : Feu Traffique
-- Projet   : ELE739 Phase 1
--------------------------------------------------------------------------------
-- Fichier  : Feu_Traffique.vhd
-- Auteur   : Guillaume et James
-- Création : 2024-01-23
--------------------------------------------------------------------------------
-- Description : Feu de traffique paramétrable avec signal d'activation
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all; -- Pour les types std_logic et std_logic_vector
use ieee.numeric_std.all; -- Pour les types signed et unsigned

entity feu_traffique is
  -- La section generic contient les paramètres de configuration du module.
  generic (
    delai        : positive; -- valeur maximum pour le délai
    taille_cmptr : positive  -- taille en bits du registre du compteur
  );

  -- La section port contient les entrées-sorties du module.
  port (
    clk     : in  std_logic;
    reset   : in  std_logic;
    enable  : in  std_logic;
    fini    : out std_logic
  );
end;

architecture rtl of feu_traffique is
   signal delai_sig: unsigned(delai-1 downto 0);
begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        delai_sig <= (others => '0');
      else
        if enable = '1' then
          if delai_sig = delai then
            delai_sig <= (others => '0');
          else
            delai_sig <= delai_sig + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

end architecture;