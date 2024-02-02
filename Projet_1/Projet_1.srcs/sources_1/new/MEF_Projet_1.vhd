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

entity MEF_Projet_1 is
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
    o_fs_v   : out std_logic;  -- Feu vert pour le FS
    o_fs_j   : out std_logic;  -- Feu jaune pour le FS
    o_fs_r   : out std_logic;  -- Feu rouge pour le FS
    o_fptp   : out std_logic;  -- Feu pour le FPTP
    o_err    : out std_logic
  );
end MEF_Projet_1;

architecture rtl of MEF_Projet_1 is

    -- Déclaration du composant pour les feu de traffiques
    component Feu_Traffique is
      generic (
        G_DELAI       : positive;
        G_DELAI_JAUNE : positive;
        G_DELAI_SIZE  : positive
      );
      port (
        i_clk   : in  std_logic;
        i_rst   : in  std_logic;
        i_cen   : in  std_logic;
        o_feu_v : out std_logic;
        o_feu_j : out std_logic;
        o_feu_r : out std_logic;
        o_fin   : out std_logic
      );
    end component;

    -- datatype pour gérées les états du MÉF
    type traffic_state is (INIT, FP, FS, FPTP); 
    
    -- signals pour le présent et prochaine état
    signal current_state : traffic_state;
    signal next_state    : traffic_state;
    
    -- signals pour contrôler les feu de traffiques
    signal en_fp   : std_logic;
    signal en_fs   : std_logic;
    signal en_fptp : std_logic;
    
    -- signals pour signifier la fin du feu de traffique
    signal fin_fp   : std_logic;
    signal fin_fs   : std_logic;
    signal fin_fptp : std_logic;

begin

    -------------------------------------
    -- Current State Logic
    -------------------------------------
    process(i_clk)
    begin
       if rising_edge(i_clk) then
          if i_bi = '1' then
          -- Si le MÉF est initialiser, remet les valeurs au défaut
             o_err         <= '0';
             en_fp         <= '0';
             en_fs         <= '0';
             en_fptp       <= '0';
          else
            case next_state is
              when INIT =>
              -- Pour INIT, tous les chips sont désactivés
                 en_fp      <= '0';
                 en_fs      <= '0';
                 en_fptp    <= '0';  
              when FP   =>
              -- Pour FP, le chip FP est activé, et la valeur du dernier état est màj
                 en_fp      <= '1';
                 en_fs      <= '0';
                 en_fptp    <= '0';              
              when FS   =>
              -- Pour FP, le chip FS est activé, et la valeur du dernier état est màj
                 en_fp      <= '0';
                 en_fs      <= '1';
                 en_fptp    <= '0'; 
              when FPTP =>
              -- Pour FPTP, le chip FPTP est activé
                 en_fp      <= '0';
                 en_fs      <= '0';
                 en_fptp    <= '1'; 
              when others =>
                 -- Pour tous autres cas, tous les chips sont désactivés
                 en_fp      <= '0';
                 en_fs      <= '0';
                 en_fptp    <= '0';  
            end case;     
          end if;
          -- MÀJ l'état présent
          current_state <= next_state;
       end if;    
    end process;

    --------------------------------------
    -- Next State Logic
    --------------------------------------
    process(i_bap, fin_fp, fin_fs, fin_fptp, current_state)
    begin
       case current_state is
          when INIT =>
          -- Lors du INIT, va directement à FP
             next_state <= FP;
          when FP =>
             if fin_fp = '1' then
             -- Si le cycle FP est terminé
                if i_bap = '1' then
                -- Si le BAP à été peser, va au FPTP
                   next_state <= FPTP;
                else
                -- Sinon, va au FS
                   next_state <= FS;
                end if;
             else
             -- Sinon, rester à FP
                next_state <= FP;
             end if; 
          when FS =>
             if fin_fs = '1' then
             -- Si le cycle FS est terminé
                if i_bap = '1' then
                -- Si le BAP à été peser, va au FPTP
                   next_state <= FPTP;
                else
                -- Sinon, va au FP
                   next_state <= FP;
                end if;
             else
             -- Sinon, rester à FS
                next_state <= FS;
             end if; 
          when FPTP =>
             if fin_fptp = '1' then
             -- Si le cycle FPTP est terminé
                next_state <= FP;
             else
             -- Sinon, rester à FPTP
                next_state <= FPTP;
             end if; 
          when others =>     
             o_err <= '1';
       end case;
    end process;

-----------------------------------------------------------
-- Déclaration des entitées
-----------------------------------------------------------

    -- Instantiation du Feu Primaire (FP)
    FEU_PRIMAIRE: Feu_Traffique
        generic map(
           G_DELAI       => G_DELAI,
           G_DELAI_JAUNE => G_DELAI_JAUNE,
           G_DELAI_SIZE  => G_DELAI_SIZE)
        port map (
           i_clk => i_clk,
           i_rst => i_bi,
           i_cen => en_fp,
           o_fin => fin_fp,
           o_feu_v => o_feu_fp_v,  
           o_feu_j => o_feu_fp_j,  
           o_feu_r => o_feu_fp_r);  

    -- Instantiation du Feu Secondaire (FS)
    FEU_SECONDAIRE : Feu_Traffique
        generic map(
           G_DELAI       => G_DELAI,
           G_DELAI_JAUNE => G_DELAI_JAUNE,
           G_DELAI_SIZE  => G_DELAI_SIZE)
        port map (
           i_clk   => i_clk,
           i_rst   => i_bi,
           i_cen   => en_fs,
           o_fin   => fin_fs,
           o_feu_v => o_feu_fs_v, 
           o_feu_j => o_feu_fs_j, 
           o_feu_r => o_feu_fs_r); 
           
           
    -- Instantiation du Feu Priorite a Travers des Pietons (FPTP)
    FEU_FPTP : Feu_Traffique
        generic map(
           G_DELAI       => G_DELAI,
           G_DELAI_JAUNE => G_DELAI_JAUNE,
           G_DELAI_SIZE  => G_DELAI_SIZE)
        port map (
           i_clk => i_clk,
           i_rst => i_bi,
           i_cen => en_fptp,
           o_fin => fin_fptp,
           o_feu_FPTP => o_feu_FPTP
          ); 

end rtl;
