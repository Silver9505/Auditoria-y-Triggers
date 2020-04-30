drop table if exists auditoria cascade;
drop table if exists detalles_orden cascade;
drop table if exists orden cascade;
drop table if exists pago cascade;
drop table if exists cliente cascade;
drop table if exists genero_juego cascade;
drop table if exists idioma_juego cascade;
drop table if exists mod_juego cascade;
drop table if exists juego cascade;
drop table if exists modalidad cascade;
drop table if exists idioma cascade;
drop table if exists genero cascade;

  CREATE TABLE genero(
  gen_id varchar(5) PRIMARY KEY,
  gen_nombre varchar(50))

  CREATE TABLE idioma(
  idi_id varchar(5) PRIMARY KEY,
  idi_nombre varchar(50))

  CREATE TABLE modalidad(
  mod_id varchar(5) PRIMARY KEY,
  mod_nombre varchar(50))

   CREATE TABLE juego(
  jue_id varchar(5) PRIMARY KEY,
  jue_titulo varchar(50),
  jue_desarrollador varchar(200),
  jue_editor varchar(200),
  jue_franquicia varchar(50),
  jue_precio float,
  jue_precio_des float)

CREATE TABLE genero_juego(
  gxj_gen_id varchar(5),
  gxj_jue_id varchar(5),
  PRIMARY KEY (gxj_gen_id, gxj_jue_id),
  FOREIGN KEY (gxj_gen_id) REFERENCES genero (gen_id),
  FOREIGN KEY (gxj_jue_id) REFERENCES juego (jue_id))

  CREATE TABLE idioma_juego(
  ixj_idi_id varchar(5),
  ixj_jue_id varchar(5),
  PRIMARY KEY (ixj_idi_id, ixj_jue_id),
  FOREIGN KEY (ixj_idi_id) REFERENCES idioma (idi_id),
  FOREIGN KEY (ixj_idi_id) REFERENCES juego (jue_id))

  CREATE TABLE mod_juego(
  mxj_mod_id varchar(5),
  mxj_jue_id varchar(5),
  PRIMARY KEY (mxj_mod_id, mxj_jue_id),
  FOREIGN KEY (mxj_mod_id) REFERENCES modalidad (mod_id),
  FOREIGN KEY (mxj_mod_id) REFERENCES juego (jue_id))
  
CREATE TABLE cliente(
  cli_id varchar(20) PRIMARY KEY,
  cli_nom varchar(50),
  cli_ape varchar(50),
  cli_pais varchar(50),
  cli_email varchar(50),
  cli_pass varchar(50),
  cli_tc varchar(20),
  cli_tcn varchar(20),
  cli_tcmes varchar(2),
  cli_tcanio varchar(4))

  CREATE TABLE pago(
  pag_id varchar(5) PRIMARY KEY,
  pag_tipo varchar(20),
  pag_permitido boolean)

  CREATE TABLE orden(
  ord_id varchar(5) PRIMARY KEY,
  ord_cli_id varchar(20),
  ord_pag_id varchar(5),
  ord_fecha_ord date,
  ord_fecha_pago date,
  FOREIGN KEY (ord_cli_id) REFERENCES cliente (cli_id),
  FOREIGN KEY (ord_cli_id) REFERENCES pago (pag_id))

  CREATE TABLE detalles_orden(
  do_id varchar(5) PRIMARY KEY,
  do_jue_id varchar(5),
  do_ord_id varchar(5),
  FOREIGN KEY (do_jue_id) REFERENCES juego (jue_id), 
  FOREIGN KEY (do_ord_id) REFERENCES orden (ord_id))

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------
--1.
  CREATE TABLE auditoria
(
  pk_audit serial NOT NULL,
  "NombreTabla" character(45) NOT NULL,
  "Operacion" character(100) NOT NULL,
  "ValorAnterior" text,
  "ValorNuevo" text,
  "Fecha" timestamp without time zone NOT NULL,
  "Usuario" character(45) NOT NULL,
  CONSTRAINT pk_audit PRIMARY KEY (pk_audit)
) 


CREATE OR REPLACE FUNCTION fn_auditoria() RETURNS trigger AS
$$
BEGIN
  IF (TG_OP='DELETE')THEN
  INSERT INTO auditoria ("NombreTabla","Operacion","ValorAnterior","ValorNuevo","Fecha","Usuario")
  VALUES (TG_TABLE_NAME,'Eliminar',OLD,NULL,now(),USER);
  RETURN OLD;

  ELSIF(TG_OP='UPDATE')THEN
  INSERT INTO auditoria ("NombreTabla","Operacion","ValorAnterior","ValorNuevo","Fecha","Usuario")
  VALUES (TG_TABLE_NAME,'Actualizar',OLD,NEW,now(),USER);
  RETURN NEW;

  ELSIF(TG_OP='INSERT')THEN
  INSERT INTO auditoria ("NombreTabla","Operacion","ValorAnterior","ValorNuevo","Fecha","Usuario")
  VALUES (TG_TABLE_NAME,'Insertar',NULL,NEW,now(),USER);
  RETURN NEW;

  END IF;
  RETURN NULL;
  END;
  $$
  LANGUAGE 'plpgsql';



  CREATE TRIGGER cliente_tg_audit
  AFTER INSERT OR UPDATE OR DELETE
  ON cliente
  FOR EACH ROW
  EXECUTE PROCEDURE fn_auditoria();

  CREATE TRIGGER detalles_tg_audit
  AFTER INSERT OR UPDATE OR DELETE
  ON detalles_orden
  FOR EACH ROW
  EXECUTE PROCEDURE fn_auditoria();

  CREATE TRIGGER genero_tg_audit
  AFTER INSERT OR UPDATE OR DELETE
  ON genero
  FOR EACH ROW
  EXECUTE PROCEDURE fn_auditoria();

 CREATE TRIGGER idioma_tg_audit
  AFTER INSERT OR UPDATE OR DELETE
  ON idioma
  FOR EACH ROW
  EXECUTE PROCEDURE fn_auditoria();

  CREATE TRIGGER juego_tg_audit
  AFTER INSERT OR UPDATE OR DELETE
  ON juego
  FOR EACH ROW
  EXECUTE PROCEDURE fn_auditoria();

  CREATE TRIGGER modalidad_tg_audit
  AFTER INSERT OR UPDATE OR DELETE
  ON modalidad
  FOR EACH ROW
  EXECUTE PROCEDURE fn_auditoria();

  CREATE TRIGGER orden_tg_audit
  AFTER INSERT OR UPDATE OR DELETE
  ON orden
  FOR EACH ROW
  EXECUTE PROCEDURE fn_auditoria();

  CREATE TRIGGER pago_tg_audit
  AFTER INSERT OR UPDATE OR DELETE
  ON pago
  FOR EACH ROW
  EXECUTE PROCEDURE fn_auditoria();

-- ------------------------------------------------------------------------------------------------------------------------------------ 
--2   
  CREATE OR REPLACE FUNCTION aiidioma() RETURNS trigger AS
$$
    begin
         if(new.idi_id='')then
          raise exception 'El codigo de el idioma no puede estar vacio';
         end if;

         if(new.idi_nombre='')then
          raise exception 'El idioma no es valido';
         end if;

         if exists(select * from idioma where idi_nombre=new.idi_nombre)then
             raise exception 'El idioma ya se encuentra registrado';
         end if;
    end;
  $$
  LANGUAGE 'plpgsql'; 


  CREATE TRIGGER tg_idioma
  BEFORE INSERT OR UPDATE
  ON idioma
  FOR EACH ROW
  EXECUTE PROCEDURE aiidioma();



  CREATE OR REPLACE FUNCTION aijuego() RETURNS trigger AS
$$
    begin
         if(new.jue_id='')then
          raise exception 'El codigo de el juego no puede estar vacio';
         end if;

         if(new.jue_titulo='')then
          raise exception 'El juego no es valido';
         end if;

         return new;
    end;
  $$
  LANGUAGE 'plpgsql'; 


  CREATE TRIGGER tg_juego
  BEFORE INSERT OR UPDATE
  ON juego
  FOR EACH ROW
  EXECUTE PROCEDURE aijuego();

  



  CREATE OR REPLACE FUNCTION aigenero() RETURNS trigger AS
$$
    begin
         if(new.gen_id='')then
          raise exception 'El codigo de el genero no puede estar vacio';
         end if;

         if(new.gen_titulo='')then
          raise exception 'El genero no es valido';
         end if;

         if exists(select * from genero where gen_titulo=new.gen_titulo)then
             raise exception 'El genero ya se encuentra registrado';
         end if;
    end;
  $$
  LANGUAGE 'plpgsql'; 

    CREATE TRIGGER tg_genero
  BEFORE INSERT OR UPDATE
  ON genero
  FOR EACH ROW
  EXECUTE PROCEDURE aigenero();

  select * from auditoria

--creamos una tabla de respaldo de juegos y hacemos un trigger que luego de insertar un juego en la tabla juego, tambien guarde los datos en la tabla de respaldo
CREATE TABLE resp_juego(
  r_jue_id varchar(5) PRIMARY KEY,
  r_jue_titulo varchar(50),
  r_jue_desarrollador varchar(200),
  r_jue_editor varchar(200),
  r_jue_franquicia varchar(50),
  r_jue_precio float,
  r_jue_precio_des float)

  CREATE OR REPLACE FUNCTION resp_juego()
  RETURNS trigger AS
$$
    
    begin 
         IF(TG_OP='INSERT')THEN
            insert into resp_juego (r_jue_id,r_jue_titulo,r_jue_desarrollador,r_jue_editor,r_jue_franquicia,r_jue_precio) 
            values (new.jue_id,new.jue_titulo,new.jue_desarrollador,new.jue_editor,new.jue_franquicia,new.jue_precio,new.jue_precio_des);
         end if;
         RETURN NEW;
     end;
$$
  LANGUAGE 'plpgsql';

  CREATE TRIGGER tgd_juego
  AFTER INSERT OR UPDATE
  ON juego
  FOR EACH ROW
  EXECUTE PROCEDURE resp_juego();


--creamos un trigger q cuando se elimine un juego en la tabla de respaldo guarda el descuento correspondiente en ese juego
  CREATE OR REPLACE FUNCTION eli_juego()
  RETURNS trigger AS
$$
    
    begin 
         IF(TG_OP='DELETE')THEN
            update resp_juego set r_jue_precio_des=r_jue_precio-(r_jue_precio*0.2) where r_jue_precio>200000;
         end if;
         RETURN NEW;
     end;
$$
  LANGUAGE 'plpgsql';

  CREATE TRIGGER tgdi_juego
  AFTER DELETE
  ON juego
  FOR EACH ROW
  EXECUTE PROCEDURE eli_juego();


  -- --------------------------------------------------------------------------------------------------------------------------------------------
--3. 
--un trigger que despues de insertar un juego guarda en el campo juego_des un descuento del 20% si el juego tiene un precio mayor a 200000
   CREATE OR REPLACE FUNCTION di3juego()RETURNS trigger AS
$$
    
    begin 
         IF(TG_OP='INSERT')THEN
            update juego set jue_precio_des=jue_precio-(jue_precio*0.2) where jue_precio>200000;
         end if;
         RETURN NEW;
     end;
$$
LANGUAGE 'plpgsql';

  CREATE TRIGGER tg3_juego
  AFTER INSERT OR UPDATE
  ON juego
  FOR EACH ROW
  EXECUTE PROCEDURE di3juego();

  INSERT INTO juego (jue_id,jue_titulo,jue_desarrollador,jue_editor,jue_franquicia,jue_precio) VALUES ('1','DOOM Eternal','id Software','Bethesda Softworks','DOOM',250000) 

-- hacemos la consulta para verificar
select * from juego

 select* from auditoria
  