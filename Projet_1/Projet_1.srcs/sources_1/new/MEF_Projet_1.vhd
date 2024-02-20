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
    G_DELAI_SIZE  : positive := 27
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
    
    -- Déclaration du composant pour le feu de priorite travers au pieton
    component Feu_FPTP is
      generic (
        G_DELAI_CONTINU  : positive;
        G_DELAI_CLIGNOTE : positive;
        G_DELAI_SIZE     : positive
      );
      port (
        i_clk      : in  std_logic;
        i_rst      : in  std_logic;
        i_cen      : in  std_logic;
        o_feu_FPTP : out std_logic;
        o_fin      : out std_logic
      );
    end component;

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

    -- datatype pour gérées les états du MÉF
    type traffic_state is (INIT, FP, FS, FPTP); 
    
    -- signals pour le présent et prochaine état
    signal current_state : traffic_state;
    signal next_state    : traffic_state;
    
    -- signals pour contrôler les feu de traffiques
    signal en_fp   : std_logic;
    signal en_fs   : std_logic;
    signal en_fptp : std_logic;
    
    -- signals pour contrôler les prescalars
    signal en_fp_p   : std_logic;
    signal en_fs_p   : std_logic;
    signal en_fptp_p : std_logic;
    
    -- signals pour signifier la fin du feu de traffique
    signal fin_fp   : std_logic;
    signal fin_fs   : std_logic;
    signal fin_fptp : std_logic;

    -- Signal pour controller le témoin SA
    signal s_sa     : std_logic;
begin

    assert G_DELAI > G_DELAI_JAUNE report "G_DELAI_JAUNE ne peut pas être plus gros que G_DELAI" severity failure;
    assert 2**G_DELAI_SIZE > G_DELAI report "La taille du delai a besoin d'accomoder le valeur du délai" severity failure;
    
    
    -- Assignation des signaux fin vers les outputs
    o_fp_f <= fin_fp;
    o_fs_f <= fin_fs;
    o_fptp_f <= fin_fptp;

    -------------------------------------
    -- Current State Logic
    -------------------------------------
    process(i_clk)
    begin
       if rising_edge(i_clk) then
          if i_bi = '1' then
          -- Si le MÉF est initialiser, remet les valeurs au défaut
             en_fp_p         <= '0';
             en_fs_p         <= '0';
             en_fptp_p       <= '0';
             s_sa            <= '0';
             current_state   <= INIT;
          else
            if i_cen = '1' then
            case next_state is
              when INIT =>
              -- Pour INIT, tous les chips sont désactivés
                 en_fp_p      <= '0';
                 en_fs_p      <= '0';
                 en_fptp_p    <= '0';  
                 if i_bap = '1' then 
                    s_sa <= '1';
                 end if; 
              when FP   =>
              -- Pour FP, le chip FP est activé, et la valeur du dernier état est màj
                 en_fp_p      <= '1';
                 en_fs_p      <= '0';
                 en_fptp_p    <= '0';
                 if i_bap = '1' then 
                    s_sa <= '1';
                 end if;              
              when FS   =>
              -- Pour FP, le chip FS est activé, et la valeur du dernier état est màj
                 en_fp_p      <= '0';
                 en_fs_p      <= '1';
                 en_fptp_p    <= '0'; 
                 if i_bap = '1' then 
                    s_sa <= '1';
                 end if;   
              when FPTP =>
              -- Pour FPTP, le chip FPTP est activé
                 en_fp_p      <= '0';
                 en_fs_p      <= '0';
                 en_fptp_p    <= '1';
                 if fin_fptp = '0' then
                    s_sa         <= '0';
                 end if;
              when others =>
                 -- Pour tous autres cas, tous les chips sont désactivés
                 en_fp_p      <= '0';
                 en_fs_p      <= '0';
                 en_fptp_p    <= '0'; 
                 s_sa         <= '0'; 
            end case;
            -- MÀJ l'état présent
            current_state <= next_state;
            end if;     
          end if;
       end if;    
    end process;

    o_sa <= s_sa;

    --------------------------------------
    -- Next State Logic
    --------------------------------------
    process(fin_fp, fin_fs, fin_fptp, current_state, s_sa)
    begin
       case current_state is
          when INIT =>
          -- Lors du INIT, va directement à FP
             next_state <= FP;
          when FP =>
             if fin_fp = '1' then
             -- Si le cycle FP est terminé
                if s_sa = '1' then
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
                if s_sa = '1' then
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
             if fin_fptp = '1' and s_sa = '0' then
             -- Si le cycle FPTP est terminé
                next_state <= FP;
             else
             -- Sinon, rester à FPTP
                next_state <= FPTP;
             end if; 
          when others =>     
             next_state <= INIT;
       end case;
    end process;

-----------------------------------------------------------
-- Déclaration des entitées
-----------------------------------------------------------

    -- Instantiation du Feu Primaire (FP)
    FEU_PRIMAIRE : Feu_Traffique
        generic map(
           G_DELAI       => G_DELAI,
           G_DELAI_JAUNE => G_DELAI_JAUNE,
           G_DELAI_SIZE  => G_DELAI_SIZE)
        port map (
           i_clk => i_clk,
           i_rst => i_bi,
           i_cen => en_fp,
           o_feu_v => o_fp_v,  
           o_feu_j => o_fp_j,  
           o_feu_r => o_fp_r,
           o_fin   => fin_fp);
           
    PRESCALAR_PRIMAIRE: PRESCALAR
        generic map(
           G_DELAI      => 100000000,
           G_DELAI_SIZE => G_DELAI_SIZE)
        port map(
           i_clk => i_clk,
           i_rst => i_bi,
           i_cen => en_fp_p,
           o_fin => en_fp);
           
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
           o_feu_v => o_fs_v, 
           o_feu_j => o_fs_j, 
           o_feu_r => o_fs_r,
           o_fin   => fin_fs); 
     
    PRESCALAR_SECONDAIRE: PRESCALAR
        generic map(
           G_DELAI      => 100000000,
           G_DELAI_SIZE => G_DELAI_SIZE)
        port map(
           i_clk => i_clk,
           i_rst => i_bi,
           i_cen => en_fs_p,
           o_fin => en_fs);
           
    -- Instantiation du Feu Priorite a Travers des Pietons (FPTP)
    FEU_PTP : Feu_FPTP
        generic map(
           G_DELAI_CONTINU  => G_DELAI_JAUNE,
           G_DELAI_CLIGNOTE => G_DELAI,
           G_DELAI_SIZE     => G_DELAI_SIZE)
        port map (
           i_clk      => i_clk,
           i_rst      => i_bi,
           i_cen      => en_fptp,
           o_feu_FPTP => o_fptp,
           o_fin      => fin_fptp);

    PRESCALAR_PTP: PRESCALAR
        generic map(
           G_DELAI      => 100000000,
           G_DELAI_SIZE => G_DELAI_SIZE)
        port map(
           i_clk => i_clk,
           i_rst => i_bi,
           i_cen => en_fptp_p,
           o_fin => en_fptp);

end rtl;