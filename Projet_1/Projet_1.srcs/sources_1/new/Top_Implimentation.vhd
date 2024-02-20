--------------------------------------------------------------------------------
-- Titre    : MEF PROJET 1
-- Projet   : ELE739 Phase 1
--------------------------------------------------------------------------------
-- Fichier  : MEF_PROJET_1.vhd
-- Auteur   : Guillaume et James
-- Création : 2024-01-28
--------------------------------------------------------------------------------
-- Description : TOP pour implementation sur la carte
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TOP is
  -- Déclaration des génériques
  generic (
    G_DELAI       : positive := 6;
    G_DELAI_JAUNE : positive := 3;
    G_DELAI_SIZE  : positive := 27
  );

  -- Déclaration des ports d'entrées et sorties du MÉF
  port (
    clk  : in std_logic;
    btnC : in std_logic;
    btnU : in std_logic;
    led  : out std_logic_vector(7 downto 0)
  );
  
    -- Définition des ports du module testé en signaux
  signal clk_int    : std_logic;
  signal bi_int     : std_logic;  
  signal bap_int    : std_logic;
  signal sa_int     : std_logic;
  signal fp_v_int   : std_logic;
  signal fp_j_int   : std_logic;
  signal fp_r_int   : std_logic;
  signal fp_f_int   : std_logic;
  signal fs_v_int   : std_logic;
  signal fs_j_int   : std_logic;
  signal fs_r_int   : std_logic;
  signal fs_f_int   : std_logic;
  signal fptp_int   : std_logic;   
  signal fptp_f_int : std_logic;
  
  signal cen  : std_logic;
  
end TOP;

architecture rtl of TOP is

    -- Declaration du prescalar
    component PRESCALAR is
      generic (
        G_DELAI          : positive;
        G_DELAI_SIZE     : positive
      );
      port (
        i_clk      : in  std_logic;
        i_rst      : in  std_logic;
        i_cen      : in  std_logic;
        o_fin      : out std_logic
      );
    end component;  


  component MEF_Projet_1 is
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
        i_cen    : in  std_logic;
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
        probe0 : in std_logic;
        probe1 : in std_logic;
        probe2 : in std_logic;
        probe3 : in std_logic;
        probe4 : in std_logic;
        probe5 : in std_logic;
        probe6 : in std_logic;
        probe7 : in std_logic;
        probe8 : in std_logic;
        probe9 : in std_logic;
        probe10 : in std_logic;
        probe11 : in std_logic;
        probe12 : in std_logic      
     );
  end component;
  
begin

 clk_int <= clk;
 bi_int  <= btnC;
 bap_int <= btnU;
 led(0)  <= fp_v_int;
 led(1)  <= fp_j_int;
 led(2)  <= fp_r_int;
 led(3)  <= fs_v_int;
 led(4)  <= fs_j_int;
 led(5)  <= fs_r_int;
 led(6)  <= fptp_int;
 led(7)  <= sa_int;
 
 DUT : MEF_Projet_1
    generic map (
      G_DELAI       => G_DELAI,
      G_DELAI_JAUNE => G_DELAI_JAUNE,
      G_DELAI_SIZE  => G_DELAI_SIZE)
    port map (
      i_clk      => clk_int,
      i_bi       => bi_int,
      i_bap      => bap_int,
      i_cen      => cen,
      o_sa       => sa_int,
      o_fp_v     => fp_v_int,
      o_fp_j     => fp_j_int,
      o_fp_r     => fp_r_int,
      o_fp_f     => fp_f_int,
      o_fs_v     => fs_v_int,
      o_fs_j     => fs_j_int,
      o_fs_r     => fs_r_int,
      o_fs_f     => fs_f_int,
      o_fptp     => fptp_int,
      o_fptp_f   => fptp_f_int);   
      
      PRESCALAR_PTP: PRESCALAR
        generic map(
         G_DELAI      => 99999999,
         G_DELAI_SIZE => G_DELAI_SIZE)
        port map(
         i_clk => clk_int,
         i_rst => bi_int,
         i_cen => '1',
         o_fin => cen);  
   
     ILA : ila_0
     port map(
        clk     => clk_int,
        probe0  => bi_int,
        probe1  => bap_int,
        probe2  => sa_int,
        probe3  => fp_v_int,
        probe4  => fp_j_int,
        probe5  => fp_r_int,
        probe6  => fp_f_int,
        probe7  => fs_v_int,
        probe8  => fs_j_int,
        probe9  => fs_r_int,
        probe10 => fs_f_int,
        probe11 => fptp_int,
        probe12 => fptp_f_int    
        );
   
end rtl;