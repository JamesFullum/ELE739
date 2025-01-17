--------------------------------------------------------------------------------
-- Titre    : MEF PROJET 1
-- Projet   : ELE739 Phase 1
--------------------------------------------------------------------------------
-- Fichier  : MEF_PROJET_1.vhd
-- Auteur   : Guillaume et James
-- Cr�ation : 2024-01-28
--------------------------------------------------------------------------------
-- Description : Machine � �tat Fini qui permet de contr�ler le comportement de 
--               feu de traffiques
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MEF_Projet_1 is
  -- D�claration des g�n�riques
  generic (
    G_DELAI       : positive := 6;
    G_DELAI_JAUNE : positive := 3;
    G_DELAI_SIZE  : positive := 7
  );

  -- D�claration des ports d'entr�es et sorties du M�F
  port (
    i_clk    : in  std_logic;
    i_bi     : in  std_logic;
    i_bap    : in  std_logic;  -- Bouton � pi�tons
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

    -- D�claration du composant pour les feu de traffiques
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
        o_feu_r : out std_logic
      );
    end component;
    
       -- D�claration du composant pour les feu de traffiques
    component Feu_PTP is
      generic (
        G_DELAI       : positive;
        G_DELAI_JAUNE : positive;
        G_DELAI_SIZE  : positive
      );
      port (
        i_clk   : in  std_logic;
        i_rst   : in  std_logic;
        i_cen   : in  std_logic;
        o_feu   : out std_logic;
        o_fin   : out std_logic
      );
    end component;

    -- datatype pour g�r�es les �tats du M�F
    type traffic_state is (INIT, FP, FS, FPTP); 
    
    -- signals pour le pr�sent et prochaine �tat
    signal current_state : traffic_state;
    signal next_state    : traffic_state;
    
    -- signals pour contr�ler les feu de traffiques
    signal en_fp   : std_logic;
    signal en_fs   : std_logic;
    signal en_fptp : std_logic;
    
    -- signals pour signifier la fin du feu de traffique
    signal fin_fp   : std_logic;
    signal fin_fs   : std_logic;
    signal fin_fptp : std_logic;

begin

    -- Assignation des feu rouge vers les outputs
    o_fp_r <= fin_fp;
    o_fs_r <= fin_fs;

    -------------------------------------
    -- Current State Logic
    -------------------------------------
    process(i_clk)
    begin
       if rising_edge(i_clk) then
          if i_bi = '1' then
          -- Si le M�F est initialiser, remet les valeurs au d�faut
             o_err         <= '0';
             en_fp         <= '0';
             en_fs         <= '0';
             en_fptp       <= '0';
          else
            case next_state is
              when INIT =>
              -- Pour INIT, tous les chips sont d�sactiv�s
                 en_fp      <= '0';
                 en_fs      <= '0';
                 en_fptp    <= '0';  
              when FP   =>
              -- Pour FP, le chip FP est activ�, et la valeur du dernier �tat est m�j
                 en_fp      <= '1';
                 en_fs      <= '0';
                 en_fptp    <= '0';              
              when FS   =>
              -- Pour FP, le chip FS est activ�, et la valeur du dernier �tat est m�j
                 en_fp      <= '0';
                 en_fs      <= '1';
                 en_fptp    <= '0'; 
              when FPTP =>
              -- Pour FPTP, le chip FPTP est activ�
                 en_fp      <= '0';
                 en_fs      <= '0';
                 en_fptp    <= '1'; 
              when others =>
                 -- Pour tous autres cas, tous les chips sont d�sactiv�s
                 en_fp      <= '0';
                 en_fs      <= '0';
                 en_fptp    <= '0';  
            end case;     
          end if;
          -- M�J l'�tat pr�sent
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
          -- Lors du INIT, va directement � FP
             next_state <= FP;
          when FP =>
             if fin_fp = '1' then
             -- Si le cycle FP est termin�
                if i_bap = '1' then
                -- Si le BAP � �t� peser, va au FPTP
                   next_state <= FPTP;
                else
                -- Sinon, va au FS
                   next_state <= FS;
                end if;
             else
             -- Sinon, rester � FP
                next_state <= FP;
             end if; 
          when FS =>
             if fin_fs = '1' then
             -- Si le cycle FS est termin�
                if i_bap = '1' then
                -- Si le BAP � �t� peser, va au FPTP
                   next_state <= FPTP;
                else
                -- Sinon, va au FP
                   next_state <= FP;
                end if;
             else
             -- Sinon, rester � FS
                next_state <= FS;
             end if; 
          when FPTP =>
             if fin_fptp = '1' then
             -- Si le cycle FPTP est termin�
                next_state <= FP;
             else
             -- Sinon, rester � FPTP
                next_state <= FPTP;
             end if; 
          when others =>     
             o_err <= '1';
       end case;
    end process;

-----------------------------------------------------------
-- D�claration des entit�es
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
           o_feu_v => o_fp_v,  
           o_feu_j => o_fp_j,  
           o_feu_r => fin_fp);  

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
           o_feu_r => fin_fs); 
           
           
    -- Instantiation du Feu Priorite a Travers des Pietons (FPTP)
<<<<<<< HEAD
    FEU_FPTP : Feu_Traffique
=======
    FEU_PTP : Feu_PTP
>>>>>>> 3ff4e00f3792938f15ff6ab892c62a48d7137d88
        generic map(
           G_DELAI       => G_DELAI,
           G_DELAI_JAUNE => G_DELAI_JAUNE,
           G_DELAI_SIZE  => G_DELAI_SIZE)
        port map (
           i_clk => i_clk,
           i_rst => i_bi,
           i_cen => en_fptp,
<<<<<<< HEAD
           o_fin => fin_fptp,
           o_feu_FPTP => o_feu_FPTP
          ); 
=======
           o_feu => fin_fptp);
>>>>>>> 3ff4e00f3792938f15ff6ab892c62a48d7137d88

end rtl;
