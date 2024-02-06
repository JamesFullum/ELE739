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
  constant G_DELAI       : positive := 10;
  constant G_DELAI_JAUNE : positive := 5;
  constant G_DELAI_SIZE  : positive := 8;

  -- Déclaration du composant à tester
  component MEF_PROJET_1 is
    generic (
      G_DELAI       : positive := 6;
      G_DELAI_JAUNE : positive := 4;
      G_DELAI_SIZE  : positive := 7
    );
    port (
      i_clk    : in  std_logic;
      i_bi     : in  std_logic;
      i_bap    : in  std_logic;  -- Bouton à piétons
      o_sa     : out std_logic;
      o_fp_v   : out std_logic;  -- Feu vert pour le FP
      o_fp_j   : out std_logic;  -- Feu jaune pour le FP
      o_fp_r   : out std_logic;  -- Feu rouge pour le FP
      o_fp_f   : out std_logic;  -- Signal Fini FP
      o_fs_v   : out std_logic;  -- Feu vert pour le FS
      o_fs_j   : out std_logic;  -- Feu jaune pour le FS
      o_fs_r   : out std_logic;  -- Feu rouge pour le FS
      o_fs_f   : out std_logic;  -- Signal Fini FS
      o_fptp_f : out std_logic;  -- Signal fin FPTP
      o_fptp   : out std_logic);   -- Feu pour le FPTP
    end component;

  -- Définition des ports du module testé en signaux
  signal clk      : std_logic;
  signal reset    : std_logic;  
  signal i_bap    : std_logic;
  signal o_sa     : std_logic;
  signal o_fp_v   : std_logic;
  signal o_fp_j   : std_logic;
  signal o_fp_r   : std_logic;
  signal o_fp_f   : std_logic;
  signal o_fs_v   : std_logic;
  signal o_fs_j   : std_logic;
  signal o_fs_r   : std_logic;
  signal o_fs_f   : std_logic;
  signal o_fptp   : std_logic;   
  signal o_fptp_f : std_logic;

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
     reset <= '0';
     wait for 1400 ns;
     reset <= '1';
     wait for 100 ns;
     reset <= '0';
--     wait for 1800 ns;
--     reset <= '1';
--     wait for 100 ns;
--     reset <= '0';
     wait for 1100 ns;
     reset <= '1';
     wait for 100 ns;
     reset <= '0';
     wait for 300 ns;
     reset <= '1';
     wait for 100 ns;
     reset <= '0';
     wait;
    
  end process;

--------------------------------------------------------------------------------
-- Simulation des stimuli
--------------------------------------------------------------------------------
  main : process
  begin
     i_bap <= '0';
     wait for 1000 ns;
     i_bap <= '1';
     wait for 100 ns;
     i_bap <= '0';
     wait for 1000 ns;
     i_bap <= '1';
     wait for 100 ns;
      i_bap <= '0';
     wait for 1000 ns;
     i_bap <= '1';
     wait for 100 ns;
     i_bap <= '0';
     wait for 100000 ns;
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
      o_fp_v     => o_fp_v,
      o_fp_j     => o_fp_j,
      o_fp_r     => o_fp_r,
      o_fp_f     => o_fp_f,
      o_fs_v     => o_fs_v,
      o_fs_j     => o_fs_j,
      o_fs_r     => o_fs_r,
      o_fs_f     => o_fs_f,
      o_fptp     => o_fptp,
      o_fptp_f   => o_fptp_f);

end architecture testbench;