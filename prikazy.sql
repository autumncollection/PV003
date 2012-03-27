/* CREATE TABLE BAND */
DROP TABLE TRACKS CASCADE CONSTRAINTS;
DROP TABLE ALBUM CASCADE CONSTRAINTS;
DROP TABLE BAND CASCADE CONSTRAINTS;
DROP TABLE TRACKS PURGE;
DROP TABLE ALBUM PURGE;
DROP TABLE BAND PURGE;


DROP SEQUENCE SEQ_BAND;
DROP SEQUENCE SEQ_ALBUM;
DROP SEQUENCE NEW_TRACKS;
DROP TRIGGER TR_BAND;
DROP TRIGGER TR_ALBUM;
DROP TRIGGER TR_TRACKS;

/


CREATE TABLE Band (
  id_band        NUMBER NOT NULL,
  band           VARCHAR2(255) NOT NULL,
  band_from      DATE NOT NULL,
  band_to       DATE,
  CONSTRAINT Band_PK
    PRIMARY KEY ( id_band )
);

/

CREATE SEQUENCE SEQ_BAND
INCREMENT BY 1
START WITH 1
NOMAXVALUE
MINVALUE 0;

/

CREATE OR REPLACE TRIGGER TR_BAND
BEFORE INSERT ON BAND
FOR EACH ROW
begin
  select SEQ_BAND.nextval into :new.id_band from dual;
END;

/

/* CREATE TABLE ALBUM */

CREATE TABLE Album (
  id_album        NUMBER NOT NULL,
  id_band         NUMBER NOT NULL,
  album      VARCHAR2(255) NOT NULL,
  year       DATE,
  CONSTRAINT Album_PK
    PRIMARY KEY ( id_album )
  , CONSTRAINT fk_Album_Band
  FOREIGN KEY (id_band)
  REFERENCES BAND(id_band)
);

/

CREATE SEQUENCE SEQ_ALBUM
INCREMENT BY 1
START WITH 1
NOMAXVALUE
MINVALUE 0;

/

CREATE OR REPLACE TRIGGER TR_ALBUM
BEFORE INSERT ON ALBUM
FOR EACH ROW
begin
  select SEQ_ALBUM.nextval into :new.id_album from dual;
END;

/

/* CREATE ALBUM TRACKS */
CREATE TABLE TRACKS (
  id_tracks        NUMBER NOT NULL,
  id_album         NUMBER NOT NULL,
  tracks      VARCHAR2(255) NOT NULL,
  length     VARCHAR2(15) NULL,
  CONSTRAINT TRACKS_PK
    PRIMARY KEY ( id_tracks )
  , CONSTRAINT FK_TRACKS_ALBUM
  FOREIGN KEY (ID_ALBUM)
  REFERENCES ALBUM(ID_ALBUM)
);

/

CREATE SEQUENCE NEW_TRACKS
INCREMENT BY 1
START WITH 1
NOMAXVALUE
MINVALUE 0;

/

CREATE OR REPLACE TRIGGER TR_TRACKS
BEFORE INSERT ON TRACKS
FOR EACH ROW
begin
  select NEW_TRACKS.nextval into :new.id_tracks from dual;
END;

/

ALTER TABLE TRACKS
ADD ( CONSTRAINT tracks_length
   CHECK(REGEXP_LIKE(length, '^[[:digit:]]{1,2}:[[:digit:]]{1,2}$')));

/

insert into band(id_band, band, band_from) VALUES (NULL, 'Nirvana', '12/03/2006');
insert into album(id_album, id_band, album, year) VALUES (NULL, 1, 'Nevermind', '11/05/1991');
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 1, 'Smells Like Teen Spirit', '5:00');
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 1, 'In Bloom', '5:12');
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 1, 'Come As You Are', '3:00');
