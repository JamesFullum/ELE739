--------------------------------------------------------------------------------
-- Titre    : MEF PROJET 1
-- Projet   : ELE739 Phase 1
--------------------------------------------------------------------------------
-- Fichier  : MEF_PROJET_1.vhd
-- Auteur   : Guillaume et James
-- Création : 2024-01-28
--------------------------------------------------------------------------------
-- Description : Machine à État Fini qui permet de contrôler le comportement de 
--               feu de traffiques
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TOP is
  -- Déclaration des génériques
  generic (
    G_DELAI       : positive := 6;
    G_DELAI_JAUNE : positive := 3;
    G_DELAI_SIZE  : positive := 7
  );

  -- Déclaration des ports d'entrées et sorties du MÉF
  port (
    i_clk    : in  std_logic;
    i_bi     : in  std_logic;
    i_bap    : in  std_logic;  -- Bouton à piétons
    o_sa     : out std_logic;
    o_fp_v   : out std_logic;  -- Feu vert pour le FP
    o_fp_j   : out std_logic;  -- Feu jaune pour le FP
    o_fp_r   : out std_logic;  -- Feu rouge pour le FP
    o_fp_f   : out std_logic;
    o_fs_v   : out std_logic;  -- Feu vert pour le FS
    o_fs_j   : out std_logic;  -- Feu jaune pour le FS
    o_fs_r   : out std_logic;  -- Feu rouge pour le FS
    o_fs_f   : out std_logic;  
    o_fptp   : out std_logic;   -- Feu pour le FPTP
    o_fptp_f : out std_logic
  );
end TOP;

architecture rtl of TOP is

  component MEF is
      -- Déclaration des génériques
      generic (
        G_DELAI       : positive;
        G_DELAI_JAUNE : positive;
        G_DELAI_SIZE  : positive
      );
    
      -- Déclaration des ports d'entrées et sorties du MÉF
      port (
        i_clk    : in  std_logic;
        i_bi     : in  std_logic;
        i_bap    : in  std_logic;  -- Bouton à piétons
        o_sa     : out std_logic;
        o_fp_v   : out std_logic;  -- Feu vert pour le FP
        o_fp_j   : out std_logic;  -- Feu jaune pour le FP
        o_fp_r   : out std_logic;  -- Feu rouge pour le FP
        o_fp_f   : out std_logic;
        o_fs_v   : out std_logic;  -- Feu vert pour le FS
        o_fs_j   : out std_logic;  -- Feu jaune pour le FS
        o_fs_r   : out std_logic;  -- Feu rouge pour le FS
        o_fs_f   : out std_logic;  
        o_fptp   : out std_logic;   -- Feu pour le FPTP
        o_fptp_f : out std_logic
      );
  end component;
  
  
  component ila_0
     port(
        clk : in std_logic;
        probe_0 : in std_logic;
        probe_1 : in std_logic;
        probe_2 : in std_logic;
        probe_3 : in std_logic;
        probe_4 : in std_logic;
        probe_5 : in std_logic;
        probe_6 : in std_logic;
        probe_7 : in std_logic;
        probe_8 : in std_logic;
        probe_9 : in std_logic;
        probe_10 : in std_logic;
        probe_11 : in std_logic;
        probe_12 : in std_logic;
        probe_13 : in std_logic;
        probe_14 : in std_logic;
        probe_15 : in std_logic;
        probe_16 : in std_logic      
     );
  end component;
  
  
 
begin
   
   
   
   
   
end rtl;