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


DROP TRIGGER TR_STATS_CREATE;
DROP TRIGGER TR_STATS_ONE_ROW;
DROP TRIGGER TR_STATS_INSERT;
DROP TRIGGER TR_STATS_UPDATE_DELETE;
  
DROP FUNCTION find_sht_track_id;
DROP FUNCTION find_lng_track_id;
DROP TABLE statistics CASCADE CONSTRAINTS;
DROP TABLE statistics PURGE;

SET SERVEROUTPUT ON;

/


/* CREATE TABLE BAND */
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
   CHECK(REGEXP_LIKE(length, '^([0-9]|[1-5][0-9]):([0-5][0-9])$')));

/

ALTER TABLE TRACKS
ADD ( CONSTRAINT tracks_length_not_zero
   CHECK(NOT (length = '0:00')));
   
/

insert into band(id_band, band, band_from) VALUES (NULL, 'Nirvana', '12/03/2006');
/
insert into album(id_album, id_band, album, year) VALUES (NULL, 1, 'Nevermind', '11/05/1991');
/
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 1, 'Smells Like Teen Spirit', '5:00');
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 1, 'In Bloom', '5:12');
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 1, 'Come As You Are', '3:00');
/
insert into band(id_band, band, band_from) VALUES (NULL, 'Foo Fighters', '01/10/1994');
insert into band(id_band, band, band_from, band_to) VALUES (NULL, 'The Beatles', '01/01/1960', '10/04/1970');
/
insert into album(id_album, id_band, album, year) VALUES(NULL, 1, 'Bleach', '15/06/1989');
insert into album(id_album, id_band, album, year) VALUES(NULL, 2, 'Echoes, Silence, Patience & Grace', '24/09/2007');
insert into album(id_album, id_band, album, year) VALUES(NULL, 2, 'Wasting Light', '12/04/2011');
set scan on;
insert into album(id_album, id_band, album) VALUES(NULL, 3, 'A Hard Day'||chr(39)||'s Night');
set scan off;
insert into album(id_album, id_band, album, year) VALUES(NULL, 3, 'Abbey Road', '26/09/1969');
/
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 2, 'About a Girl', '2:48'); 
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 1, 'Lithium', '4:17');
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 3, 'The Pretender', '4:29');
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 3, 'Let it Die', '4:05');
insert into TRACKS(id_tracks, id_album, tracks) VALUES (NULL, 4, 'Arlandria');
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 4, 'These Days', '4:58');
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 4, 'Walk', '4:16');
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 5, 'And I Love Her', '2:30');
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 5, 'When I Get Home', '2:17');
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 6, 'Come Together', '4:20');
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 6, 'Here Comes the Sun', '3:05');
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 6, 'The End', '2:05');

insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 6, 'Just break it...', '12:05');
insert into TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 6, 'Just break it 2...', '0:05');
/
insert into album(id_album, id_band, album) VALUES(NULL, 3, 'Break the Querries! - Empty album');

-- Just simple statistics
CREATE TABLE statistics (
  id_stat NUMBER NOT NULL,
  longest_track VARCHAR(15),
  longest_track_id NUMBER,
  shortest_track VARCHAR(15),
  shortest_track_id NUMBER,  
  CONSTRAINT STATS_PK
    PRIMARY KEY(id_stat)
);

/

-- Finds the id of the shortest track. Returns only a single id. In case of more
-- shortest tracks, only one of them is returned.
CREATE OR REPLACE FUNCTION find_sht_track_id RETURN NUMBER AS
  CURSOR c1 IS SELECT * FROM TRACKS;
  curr_len_row TRACKS%ROWTYPE;
  sht_len_row TRACKS%ROWTYPE;
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO curr_len_row;
    EXIT WHEN c1%NOTFOUND;
    IF sht_len_row.length IS NULL THEN
      sht_len_row.length := curr_len_row.length;
    END IF;
    IF sht_len_row.id_tracks IS NULL THEN
      sht_len_row.id_tracks := curr_len_row.id_tracks;
    END IF;
    IF LENGTH(sht_len_row.length) > LENGTH(curr_len_row.length) 
    AND curr_len_row.length IS NOT NULL THEN
      sht_len_row.length := curr_len_row.length;
      sht_len_row.id_tracks := curr_len_row.id_tracks;
    ELSE
      IF curr_len_row.length IS NOT NULL THEN
        IF sht_len_row.length > curr_len_row.length AND 
        LENGTH(sht_len_row.length) = LENGTH(curr_len_row.length) THEN
          sht_len_row.length := curr_len_row.length;
          sht_len_row.id_tracks := curr_len_row.id_tracks;
        END IF;
      END IF;
    END IF;
  END LOOP;
  CLOSE c1;
  RETURN sht_len_row.id_tracks;
END;

/

-- Same as above, only with longest tracks.
CREATE OR REPLACE FUNCTION find_lng_track_id RETURN NUMBER AS
  CURSOR c2 IS SELECT * FROM TRACKS;
  curr_len_row TRACKS%ROWTYPE;
  lng_len_row TRACKS%ROWTYPE;
BEGIN
  OPEN c2;
  LOOP
    FETCH c2 INTO curr_len_row;
    EXIT WHEN c2%NOTFOUND;
    IF lng_len_row.length IS NULL THEN
      lng_len_row.length := curr_len_row.length;
    END IF;
    IF lng_len_row.id_tracks IS NULL THEN
      lng_len_row.id_tracks := curr_len_row.id_tracks;
    END IF;
    IF LENGTH(lng_len_row.length) < LENGTH(curr_len_row.length) 
    AND curr_len_row.length IS NOT NULL THEN
      lng_len_row.length := curr_len_row.length;
      lng_len_row.id_tracks := curr_len_row.id_tracks;
    ELSE
      IF curr_len_row.length IS NOT NULL THEN
        IF lng_len_row.length < curr_len_row.length AND 
        LENGTH(lng_len_row.length) = LENGTH(curr_len_row.length) THEN
          lng_len_row.length := curr_len_row.length;
          lng_len_row.id_tracks := curr_len_row.id_tracks;
        END IF;
      END IF;
    END IF;
  END LOOP;
  CLOSE c2;
  RETURN lng_len_row.id_tracks;
END;

/

-- Computes statistics before the insertion of the first row into statistics
-- table.
CREATE OR REPLACE TRIGGER TR_STATS_CREATE
BEFORE INSERT ON statistics
FOR EACH ROW
BEGIN    
  SELECT find_lng_track_id INTO :new.longest_track_id FROM DUAL;
  SELECT length INTO :new.longest_track FROM TRACKS 
    WHERE id_tracks = :new.longest_track_id;
  SELECT find_sht_track_id INTO :new.shortest_track_id FROM DUAL;
  SELECT length INTO :new.shortest_track FROM TRACKS
    WHERE id_tracks = :new.shortest_track_id;
END;

/

-- Statistics table is only allowed to have a single row. This trigger enforces
-- that contraint.
CREATE OR REPLACE TRIGGER TR_STATS_ONE_ROW
BEFORE INSERT OR UPDATE OR DELETE ON statistics
FOR EACH ROW
BEGIN
  IF DELETING THEN
    DBMS_OUTPUT.PUT_LINE('No.');
    ROLLBACK;
  END IF;
  IF INSERTING OR UPDATING THEN
    IF :new.id_stat != 1 THEN
      DBMS_OUTPUT.PUT_LINE('You cannot have more than one row in that table.');
      RAISE VALUE_ERROR; 
    END IF;
  END IF;
END;

/

-- This trigger adjusts the statistics after insert on the tracks table.
CREATE OR REPLACE TRIGGER TR_STATS_INSERT
AFTER INSERT ON TRACKS
FOR EACH ROW
DECLARE
  sht_len statistics.shortest_track%TYPE;
  lng_len statistics.longest_track%TYPE;
BEGIN
  SELECT shortest_track INTO sht_len FROM statistics;
  SELECT longest_track INTO lng_len FROM statistics;
  IF :new.length IS NOT NULL AND ((LENGTH(:new.length) < LENGTH(sht_len)) OR (
  LENGTH(:new.length) = LENGTH(sht_len) AND :new.length < sht_len)) THEN
    UPDATE statistics SET shortest_track = :new.length, shortest_track_id =
    :new.id_tracks WHERE id_stat = 1; 
  END IF;
  IF :new.length IS NOT NULL AND ((LENGTH(:new.length) > LENGTH(lng_len)) OR (
  LENGTH(:new.length) = LENGTH(lng_len) AND :new.length > lng_len)) THEN
    UPDATE statistics SET longest_track = :new.length, longest_track_id =
    :new.id_tracks WHERE id_stat = 1; 
  END IF;
END;

/

-- This trigger recalculates the statistics after update or delete on the tracks
-- table.
CREATE OR REPLACE TRIGGER TR_STATS_UPDATE_DELETE
AFTER DELETE OR UPDATE ON TRACKS
DECLARE
  sht_len statistics.shortest_track%TYPE;
  lng_len statistics.longest_track%TYPE;
  lng_id TRACKS.id_tracks%TYPE;
  sht_id TRACKS.id_tracks%TYPE;
BEGIN
  SELECT shortest_track INTO sht_len FROM statistics;
  SELECT longest_track INTO lng_len FROM statistics;
  SELECT longest_track_id INTO lng_id FROM statistics;
  SELECT shortest_track_id INTO sht_id FROM statistics;
  
  SELECT find_lng_track_id INTO lng_id FROM DUAL;
  SELECT length INTO lng_len FROM TRACKS WHERE id_tracks = lng_id;
  UPDATE statistics SET longest_track_id = lng_id, longest_track = lng_len WHERE id_stat = 1;
  
  SELECT find_sht_track_id INTO sht_id FROM DUAL;
  SELECT length INTO sht_len FROM TRACKS WHERE id_tracks = sht_id;
  UPDATE statistics SET shortest_track_id = sht_id, shortest_track = sht_len WHERE id_stat = 1;
END;

/

-- testing inserts/updates/deletes
INSERT INTO statistics (id_stat) VALUES (1);
INSERT INTO TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 6, 'Just break it 3...', '0:01');
INSERT INTO TRACKS(id_tracks, id_album, tracks, length) VALUES (NULL, 6, 'Just break it 4...', '25:01');
UPDATE TRACKS SET length = '27:00' WHERE id_tracks = 19;
DELETE FROM TRACKS WHERE id_tracks = 19;


--------------------------------- SELECTS -----------------------------

-- Selects name of band, album, track and its length that currently hold the
-- record in track length (shortest/longest). (and orders them... wow) 
SELECT band, album, tracks, length 
FROM statistics, tracks, album, band 
WHERE album.id_band = band.id_band 
  AND tracks.id_album = album.id_album 
  AND (tracks.id_tracks = shortest_track_id OR tracks.id_tracks = longest_track_id)
ORDER BY band DESC, album DESC, tracks DESC;

-- Counts number of tracks for each album. Prints only those that have more
-- than 3 songs.
SELECT cnt, album FROM 
  (SELECT id_album, count(*) AS cnt FROM tracks GROUP BY id_album HAVING count(*) > 3) A 
INNER JOIN album ON A.id_album = album.id_album; 

-- Prints the number of songs for each album for every band older than 1/1/1990.
SELECT album.album, T.cnt FROM
(SELECT A.id_album, count(tracks.id_tracks) AS cnt FROM
(SELECT id_album FROM
(SELECT id_band FROM band WHERE band_from < TO_DATE('01/01/1990', 'DD/MM/YYYY')) B
INNER JOIN album ON album.id_band = B.id_band) A
LEFT OUTER JOIN tracks ON A.id_album = tracks.id_album GROUP BY A.id_album) T
INNER JOIN album ON album.id_album = T.id_album;


-- Prints the statistics with its name
-- maximum
select 'The longest song is "'|| tracks || '" from album "' || album || '". Time : ' || longest_track as Najdlhsi_album from (
     select s.longest_track, t.tracks, t.id_album from statistics s INNER JOIN tracks t ON s.longest_track_id = t.id_tracks WHERE s.ID_STAT = 1
     ) f INNER JOIN ALBUM s ON f.ID_ALBUM = s.ID_ALBUM;
-- minimum
select 'The shortest song is "'|| tracks || '" from album "' || album || '". Time : ' || shortest_track as Najkratsi_album from (
     select s.shortest_track, t.tracks, t.id_album from statistics s INNER JOIN tracks t ON s.shortest_track_id = t.id_tracks WHERE s.ID_STAT = 1
     ) f INNER JOIN ALBUM s ON f.ID_ALBUM = s.ID_ALBUM;

-- Gets the number of albums for each band
create view album_numbers as 
SELECT b.id_band,b.band,COUNT(*) as Albums
FROM band b,album a 
WHERE b.id_band = a.id_band 
GROUP BY b.id_band,b.band;

-- Writes the number of albums and tracks for each band
SELECT s.id_band,s.band,s.Albums, COUNT(*) as Tracks FROM 
album_numbers s, album a, tracks t
WHERE a.ID_band = s.id_band AND t.id_album=a.id_album
GROUP BY s.id_band,s.band,s.Albums;

-- Writes the number of tracks for each year
SELECT album.year, COUNT(tracks.tracks) FROM album,tracks WHERE album.ID_ALBUM = tracks.ID_ALBUM GROUP BY album.year HAVING album.year IS NOT NULL;

-- Writes the number of lines in each table (band,album,statistics,tracks)
SELECT bands_rows,album_rows,statistics_rows, tracks_rows  FROM 
(SELECT COUNT(*) as bands_rows FROM band),
(SELECT COUNT(*) as album_rows FROM album),
(SELECT COUNT(*) as statistics_rows FROM statistics),
(SELECT COUNT(*) as tracks_rows FROM tracks)




/*
CREATE OR REPLACE FUNCTION AVG_LEN(?) RETURN VARCHAR2(15) AS
BEGIN

END;

-- Counts average length of tracks for each album, prints only those that have
-- average length below 3:00.
SELECT AVG_LEN(length) AS al, T.id_album 
  FROM tracks T INNER JOIN album A ON T.id_album = A.id_album 
  GROUP BY T.id_album 
  HAVING LENGTH(AVG_LEN(length)) <= 4 AND AVG_LEN(length) < '3:00'; 
*/
