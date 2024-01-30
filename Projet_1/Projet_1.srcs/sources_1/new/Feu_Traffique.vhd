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
use ieee.numeric_std.all;    -- Pour les types signed et unsigned

entity Feu_Traffique is
  -- La section generic contient les paramètres de configuration du module.
  generic (
    G_DELAI       : positive := 6; -- valeur maximum pour le délai
    G_DELAI_JAUNE : positive := 3; -- Seuil ou la lumière va devenir jaune
    G_DELAI_SIZE  : positive := 7 -- taille en bits du registre du compteur
  );

  -- La section port contient les entrées-sorties du module.
  port (
    i_clk : in  std_logic;
    i_rst : in  std_logic;
    i_cen : in  std_logic;
    o_feu : out std_logic;
    o_fin : out std_logic
  );
end;

architecture rtl of feu_traffique is
   -- Compteur pour la durée du feu
   signal delai_sig: unsigned(G_DELAI_SIZE-1 downto 0);
begin

  process(i_clk)
  begin
    if rising_edge(i_clk) then
      -- Réinitialiser le compteur et éteindre la lumière
      if i_rst = '1' then
        delai_sig <= (others => '0');
        o_feu     <= '0';
        o_fin     <= '0';
      else
        if i_cen = '1' then
        -- Si le feu est activer
          if delai_sig >= G_DELAI then
          -- Si le délai est atteint
            delai_sig <= (others => '0');
            o_feu     <= '0';
            o_fin     <= '1';
          else
            if delai_sig >= G_DELAI_JAUNE then
            -- Si le délai est supérieure que le seuil du delai jaune
               -- Comportement jaune
            else
            -- Sinon la lumière reste vert
               o_feu <= '1';
            end if;
          -- Sinon, augmente la compteur et assurer que o_fin == 0
            delai_sig <= delai_sig + 1;
            o_fin     <= '0';
          end if;
        else
        -- Sinon, désactiver tout
           o_fin     <= '0';
           o_feu     <= '0';
           delai_sig <= (others => '0');
        end if;
      end if;
    end if;
  end process;

end architecture;