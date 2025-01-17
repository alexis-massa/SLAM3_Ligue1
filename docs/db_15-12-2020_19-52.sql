PGDMP     %    4                x            Ligue1    12.5    13.0                0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false                       0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false                       1262    16393    Ligue1    DATABASE     d   CREATE DATABASE "Ligue1" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'French_France.1252';
    DROP DATABASE "Ligue1";
                postgres    false            �            1255    16408 E   ajout_equipe(character varying, character varying, character varying)    FUNCTION     d  CREATE FUNCTION public.ajout_equipe(p_nom character varying, p_stade character varying, p_ville character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	nb_equipe int;
	nb_passee int;
	query1 text;
BEGIN
	query1 := 'select * from ajouter_equipe(%, %, %)', p_nom, p_stade, p_ville;
	
	select count(*)
	into nb_equipe
	from equipe;
	
	select count(*)
	into nb_passee
	from rencontre
	where etat = 'passée';
	
	if nb_equipe = 22 then
		raise notice 'Il y a déjà 22 équipes !';
	elsif nb_passee > 0 then
		raise notice 'La saison est déjà débutée !';
	else
		execute query1;
	end if;
END;
$$;
 r   DROP FUNCTION public.ajout_equipe(p_nom character varying, p_stade character varying, p_ville character varying);
       public          postgres    false            �            1255    16407 G   ajouter_equipe(character varying, character varying, character varying)    FUNCTION     ]  CREATE FUNCTION public.ajouter_equipe(p_nom character varying, p_stade character varying, p_ville character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	query1 text;
BEGIN
	query1 := 'insert into equipe(nom, stade, ville, points, buts_pour, buts_contre) values(%, %, %, 0, 0, 0)', p_nom, p_stade, p_ville;
	execute query1;
END;
$$;
 t   DROP FUNCTION public.ajouter_equipe(p_nom character varying, p_stade character varying, p_ville character varying);
       public          postgres    false            �            1255    16471    initrencontre(date)    FUNCTION     �  CREATE FUNCTION public.initrencontre(dateren date) RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE

lesRencontres integer Array;
lesRencontres2 integer Array;
val integer;
val2 integer;
longTab integer;
dateIni date =  dateRen;

BEGIN

lesRencontres2 := Array(
    SELECT equipe.id_equipe
    FROM equipe
    order by random()
);

SELECT array_length(LesRencontres2, 1) INTO longTab ;
val = lesRencontres2[longTab];
SELECT array_remove(LesRencontres2, val) INTO lesRencontres2 ;
LesRencontres[1]=LesRencontres2[1];
lesRencontres[2]=val;

FOR i in 2..longTab LOOP
     lesRencontres[i+1]=  lesRencontres2[i];
     i=i+1;
END LOOP;
SELECT array_remove(LesRencontres, NULL) INTO lesRencontres ;
raise notice '1: %',lesRencontres;
--ALGORITHME (pasoufMaisCaVa) pour avoir le tableau "lesRencontres" 

FOR i in 1..longTab LOOP
    dateIni = dateRen;
    for j in 1..longTab loop
    dateIni:=dateIni+7;
    if lesRencontres[longTab-i] is not null AND lesRencontres[j] != lesRencontres[longTab-i]  then
        INSERT INTO rencontre VALUES (lesRencontres[j],lesRencontres[longTab-i],dateIni,0,0,'','à venir');
    end if;
    end loop;
END LOOP;


END;
$$;
 2   DROP FUNCTION public.initrencontre(dateren date);
       public          postgres    false            �            1255    16404    initrencontres(date)    FUNCTION     }  CREATE FUNCTION public.initrencontres(firstday date) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	arrEq int array;
	i int;
	j int;
	tmp int;
	nbDecal int;
	eqA int;
	eqB int;
	stmtRencontre text;
	stmt text;
begin
	arrEq := array(
	select id_equipe
	from equipe
	order by random());
	
	stmt:='';
	stmtRencontre:='';
	nbDecal:=1;
	--raise notice '%', arrEq;
	--BOUCLE DECALAGE
	while nbDecal < array_length(arrEq, 1) loop
		--raise notice '----------------- % --------------------', nbDecal;
		i:=1;
		j:= array_length(arrEq,1);
		while i < j loop
			while i < array_length(arrEq, 1) loop		
				eqA := arrEq[i];
				eqB := arrEq[j];
				--raise notice '%, %, %', eqA, eqB, firstDay;
				stmtRencontre := 'insert into rencontre (id_domicile, id_visiteur, date_match,score_domicile, score_visiteur, arbitre, etat) values (' || eqA || ',' || eqB || ',''' ||  firstDay || ''', 0, 0, '''', ''à venir'');';
				--raise notice '%', stmtRencontre;
				execute stmtRencontre;
				stmt := stmt || chr(10) || stmtRencontre;
				i:=i+1;
				j:=j-1;
			end loop;
		end loop;
		--DECALAGE
		tmp := arrEq[array_length(arrEq,1)];
		for i in reverse array_length(arrEq, 1)..2 loop
			arrEq[i] := arrEq[i-1];
		end loop;
		arrEq[2] := tmp;
		--raise notice '%', arrEq;
		nbDecal:=nbDecal+1;
		firstDay := firstDay+7;
	end loop;
	--REDEMMARAGE + FIN BOUCLE DECALAGE
	--raise notice '%', stmt;
	execute stmt;
end
$$;
 4   DROP FUNCTION public.initrencontres(firstday date);
       public          postgres    false            �            1255    16405    resetsaison()    FUNCTION     �  CREATE FUNCTION public.resetsaison() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE 
  v_tab_equipe text;
  v_tab_rencontre text;
  query1 text;
  query2 text;
  query3 text;
 BEGIN
 	SELECT Concat('save_', 'equipe_', date_part('year', now())) 
 	INTO   v_tab_equipe
 	FROM   equipe;
	 SELECT Concat('save_', 'rencontre_', date_part('year', now())) 
 	INTO   v_tab_rencontre
 	FROM   rencontre;
	query1 := format('create table if not exists %I as (select * from equipe)', lower(v_tab_equipe));
	query2 := format('create table if not exists %I as (select * from rencontre)', lower(v_tab_rencontre));
	query3 := format('truncate equipe, rencontre');
	EXECUTE query1;
	EXECUTE query2;
	EXECUTE query3;
  end;
$$;
 $   DROP FUNCTION public.resetsaison();
       public          postgres    false            �            1255    16406    saisonterminee()    FUNCTION     �  CREATE FUNCTION public.saisonterminee() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	termine int;
	nb_rencontre int;
	query text;
BEGIN

	select count(*)
	into nb_rencontre
	from rencontre;
	
	select count(*)
	into termine
	from rencontre
	where etat = 'passée';	
	
	query := 'select * from resetsaison()';
		
	if termine <> nb_rencontre then
		raise notice 'saison non terminée !';
	elsif termine = nb_rencontre then
		raise notice 'saison terminée !';
		execute (query);
	end if;
END;
$$;
 '   DROP FUNCTION public.saisonterminee();
       public          postgres    false            �            1255    16470    updatescore()    FUNCTION     �  CREATE FUNCTION public.updatescore() RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
    i record;
    vis int;
    dom int;
    score1 int;
    score2 int;
    stmt text;
begin
	execute 'update score set played=0, points=0, won=0, draw=0, lost=0, scored=0, taken=0 where 1=1;';
    for i in select * from rencontre where etat = 'passé' loop
        select i.score_domicile into score1 from rencontre;
        select i.score_visiteur into score2 from rencontre;
        select i.id_domicile into dom from rencontre;
        select i.id_visiteur into vis from rencontre;
        if score1 > score2 then
            --raise notice '% : dom > vis : %', dom, vis;
            execute 'update score set points = points+3, won = won+1  where id_equipe = ' || dom || ';';
            execute 'update score set lost = lost + 1 where id_equipe = ' || vis || ';';
        elsif score1 < score2 then
            --raise notice '% : dom < vis : %', dom, vis;
            execute 'update score set points = points+3, won = won+1 where id_equipe = ' || vis || ';';
            execute 'update score set lost = lost + 1 where id_equipe = ' || dom || ';';
        elsif score1 = score2 then
            --raise notice '% : dom = vis : %', dom, vis;
            execute 'update score set points = points + 1, draw = draw+1 where id_equipe = ' || dom || ';';
            execute 'update score set points = points + 1, draw = draw+1 where id_equipe = ' || vis || ';';
        end if;
        execute 'update score set played = played+1, scored = scored + '|| score1 ||', taken = taken+'||score2||' where id_equipe = ' || dom || ';';
        execute 'update score set played = played+1, scored = scored + '|| score2 ||', taken = taken+'||score1||' where id_equipe = ' || vis || ';';
    end loop;
end;
$$;
 $   DROP FUNCTION public.updatescore();
       public          postgres    false            �            1259    16394    equipe    TABLE     �   CREATE TABLE public.equipe (
    id_equipe integer NOT NULL,
    nom character varying(50),
    stade character varying(50),
    ville character varying(15)
);
    DROP TABLE public.equipe;
       public         heap    postgres    false            �            1259    16454 	   rencontre    TABLE     �   CREATE TABLE public.rencontre (
    id_domicile integer NOT NULL,
    id_visiteur integer NOT NULL,
    date_match date,
    score_domicile integer,
    score_visiteur integer,
    arbitre character varying(15),
    etat character varying(10)
);
    DROP TABLE public.rencontre;
       public         heap    postgres    false            �            1259    16472    score    TABLE     �   CREATE TABLE public.score (
    id_equipe integer NOT NULL,
    played integer,
    points integer,
    won integer,
    draw integer,
    lost integer,
    scored integer,
    taken integer
);
    DROP TABLE public.score;
       public         heap    postgres    false                      0    16394    equipe 
   TABLE DATA           >   COPY public.equipe (id_equipe, nom, stade, ville) FROM stdin;
    public          postgres    false    202   j1                 0    16454 	   rencontre 
   TABLE DATA           x   COPY public.rencontre (id_domicile, id_visiteur, date_match, score_domicile, score_visiteur, arbitre, etat) FROM stdin;
    public          postgres    false    203   Z3                 0    16472    score 
   TABLE DATA           Z   COPY public.score (id_equipe, played, points, won, draw, lost, scored, taken) FROM stdin;
    public          postgres    false    204   -8       �
           2606    16398    equipe pk_equipe 
   CONSTRAINT     U   ALTER TABLE ONLY public.equipe
    ADD CONSTRAINT pk_equipe PRIMARY KEY (id_equipe);
 :   ALTER TABLE ONLY public.equipe DROP CONSTRAINT pk_equipe;
       public            postgres    false    202            �
           2606    16458    rencontre pk_rencontre 
   CONSTRAINT     j   ALTER TABLE ONLY public.rencontre
    ADD CONSTRAINT pk_rencontre PRIMARY KEY (id_domicile, id_visiteur);
 @   ALTER TABLE ONLY public.rencontre DROP CONSTRAINT pk_rencontre;
       public            postgres    false    203    203            �
           2606    16476    score pk_score 
   CONSTRAINT     S   ALTER TABLE ONLY public.score
    ADD CONSTRAINT pk_score PRIMARY KEY (id_equipe);
 8   ALTER TABLE ONLY public.score DROP CONSTRAINT pk_score;
       public            postgres    false    204            �
           2606    16459    rencontre fk_dom_equipe    FK CONSTRAINT     �   ALTER TABLE ONLY public.rencontre
    ADD CONSTRAINT fk_dom_equipe FOREIGN KEY (id_domicile) REFERENCES public.equipe(id_equipe);
 A   ALTER TABLE ONLY public.rencontre DROP CONSTRAINT fk_dom_equipe;
       public          postgres    false    203    2701    202            �
           2606    16477    score fk_equipe    FK CONSTRAINT     x   ALTER TABLE ONLY public.score
    ADD CONSTRAINT fk_equipe FOREIGN KEY (id_equipe) REFERENCES public.equipe(id_equipe);
 9   ALTER TABLE ONLY public.score DROP CONSTRAINT fk_equipe;
       public          postgres    false    2701    202    204            �
           2606    16464    rencontre fk_vis_equipe    FK CONSTRAINT     �   ALTER TABLE ONLY public.rencontre
    ADD CONSTRAINT fk_vis_equipe FOREIGN KEY (id_visiteur) REFERENCES public.equipe(id_equipe);
 A   ALTER TABLE ONLY public.rencontre DROP CONSTRAINT fk_vis_equipe;
       public          postgres    false    2701    203    202               �  x�MR�n�0</��?�I��b�A%˰��zYK�)�U)2��G���XW����˙�Na[�E���{��fPw��%͠���d��9���J]:]0�#�#��0�Q�
�=�;�u����3;����ʣ;����n��ܑ��������3�1""�֠��y3�Ƣ�N`�t�&�"X�Ѹ#v=�8��>Kj:�:�`��]�|�!b?����n�t�iL��-�Ax�.�9�b��9�Z��x:���i1��#$�KX��4�=�cu{��EUg��m<%%��3׵�_�U]R�@�ƅ�>w���!cU�&F�����E�%�fsB���)�Q���Li�G	㕍'؈[���ϥJ�'��G#��I�:�����z�I� �|����ه>M�����A5[�Em6vӰwf'�� �������%�ǻ�x2��;�3a�e����(z=I��~~QJ�4O�;         �  x���M��@F��)�@���I�܅lb$�Ösp1� �*��+��^%q����{���M���_�����ׇ�_�}�q�G��vx����c�����i�r�~ۿ:a;��E�|�����o�/�{��ۼ��6����0v}
_mܦ��{���f���?nm�������x��?\�e���9`�L�iZ����:�T�V%.��\y�+be��OԊ­��\)Bٵ��{�p�����W�¯��~mX���+a�WP~m\����+r�W�¯��_?�+�"�~�����tEzZ�y�ʯ �z^	��a�\;��d�+�R��,h�r�-(�R�P-q�Z8�-E�?<�ՃqRS��-(�R�0n�n�\$�@�)6د�r4k�V�$�@��4�=z>��ˢ7X���g�;뵓=�>��=paQ�ʣ [�?��#WM|ಋ\���>�ŅU#�N=F�V�p֫� �V�ʮ��r���.G���rT����r��Y+g��rp��K�ßWJya�B9��NN6qc�]�Ta�E�������?�͸��F�貸�����+�Zn�3a���S��U�R�GMvP��a�22+R���	Xe)c��Y�С�U��s����f�Q�*KY!R�Y�X��e�2�)pe/������r��݂�j�x�`�X��UQ㵁[å�U;���Ӧ���7
V,�	�69��h��M�6ya��M6�{N^C9��l�69��M^��M�6ya��MV�{<��W�z<�U�zk�)�b��)��`�{�;�d�WMxՀW�w�x���(�j"W�'>������j>H/�d�T�D.�M|�\8UG11@��V+Eȭ�<�R�,Fm���� �jhW#���Ыvn��z��5t��Q}jdSC���ȣVX�ء�5���=��1^n��F�?-R]�x�7��'���`�D*+]�0�X��b;`�z�x?`ł�pC�u�Ը���JX�c��W7�m\ٰ�qU+jV���լ�e\Ɋ:�U�X.��3_��v�E�$�9�Sg L@���٧J>E�)Rg�"�;�T����tԧ�t��A���PG�:[��:z�+�zaR/T��R/d��6-�{��y��پ���py���~����'�j�/��b��i��a�o�״kg>��������_+ll-poQ��T�?���z���;�]         f   x�e�Q
� C���c[uw��ϱ�l����{�C��PI
�P���tuY҇��2���>�-�p<	�:޴DGX~�zΟ`OF��n} �]���#�)�     