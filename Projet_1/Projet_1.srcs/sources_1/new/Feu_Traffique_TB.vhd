--------------------------------------------------------------------------------
-- Titre      : Banc d'essai Phase 1
-- Projet     : ELE739 - Phase 1
--------------------------------------------------------------------------------
-- Fichier    : Feu_Traffique.vhd
-- Auteur     : Guillaume et James
-- Création   : 2024-01-28
--------------------------------------------------------------------------------
-- Description : Banc d'essai pour la phase 1
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;  -- Pour les types std_logic et std_logic_vector
use ieee.numeric_std.all;     -- Pour les types signed et unsigned

-- L'entité d'un banc d'essai est toujours vide
entity Feu_Traffique_TB is
end entity Feu_Traffique_TB;

architecture testbench of Feu_Traffique_TB is

  -- Définition des paramètres génériques du module testé en constantes
  constant G_DELAI       : positive := 4;
  constant G_DELAI_JAUNE : positive := 3;
  constant G_DELAI_SIZE  : positive := 12;

  -- Déclaration du composant à tester
  component MEF_PROJET_1 is
    generic (
      G_DELAI       : positive := 6;
      G_DELAI_JAUNE : positive := 4;
      G_DELAI_SIZE  : positive := 7
    );
    port (
      i_clk      : in  std_logic;
      i_bi       : in  std_logic;
      i_bap      : in  std_logic;
      o_sa       : out std_logic;
      o_feu_fp   : out std_logic;
      o_feu_fs   : out std_logic;
      o_feu_fptp : out std_logic;
      o_err      : out std_logic);
  end component;

  -- Définition des ports du module testé en signaux
  signal clk      : std_logic;
  signal reset    : std_logic;     

begin

--------------------------------------------------------------------------------
-- Simulation de l'horloge et du reset
--------------------------------------------------------------------------------
  clk_gen : process
  begin
    -- Simulation d'une horloge de 50MHz avec un taux de charge de 50%
    clk <= '1';
    wait for 10 ns;
    clk <= '0';
    wait for 10 ns;
  end process clk_gen;

  reset_gen : process
  begin
    reset <= '1',
             '0' after 100 ns;
    wait;
  end process;

--------------------------------------------------------------------------------
-- Simulation des stimuli
--------------------------------------------------------------------------------
  main : process
  begin
     
     wait for 100 ns;

  end process;

--------------------------------------------------------------------------------
-- Configuration du module à tester
--------------------------------------------------------------------------------
 DUT : MEF_Projet_1
    generic map (
      G_DELAI       => G_DELAI,
      G_DELAI_JAUNE => G_DELAI_JAUNE,
      G_DELAI_SIZE  => G_DELAI_SIZE)
    port map (
      i_clk      => clk,
      i_bi       => reset,
      i_bap      => i_bap,
      o_sa       => o_sa,
      o_feu_fp   => o_feu_fp,
      o_feu_fs   => o_feu_fs,
      o_feu_fptp => o_feu_fptp,
      o_err      => o_err);

end architecture testbench;
