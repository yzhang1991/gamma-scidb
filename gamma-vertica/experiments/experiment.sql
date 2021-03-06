-- DROP LIBRARY IF EXISTS toCoordPoint CASCADE;
-- \set libfile '\''`pwd`'/toCoordPoint.so\'';
-- CREATE LIBRARY toCoordPoint AS :libfile;
-- CREATE FUNCTION toCoordPoint AS LANGUAGE 'C++'
-- NAME 'toCoordPointFactory' LIBRARY toCoordPoint NOT FENCED;

-- DROP LIBRARY IF EXISTS extractCoordPointValue CASCADE;
-- \set libfile '\''`pwd`'/extractCoordPointValue.so\'';
-- CREATE LIBRARY extractCoordPointValue AS :libfile;
-- CREATE FUNCTION extractCoordPointValue AS LANGUAGE 'C++'
-- NAME 'extractCoordPointValueFactory' LIBRARY extractCoordPointValue NOT FENCED;

DROP LIBRARY IF EXISTS DenseGamma CASCADE;
-- \set libfile '\''`pwd`'/DenseGamma.so\'';
\set libfile '\'/home/vertica/gamma-vertica/DenseGamma.so\'';
CREATE LIBRARY DenseGamma AS :libfile;
CREATE TRANSFORM FUNCTION DenseGamma AS LANGUAGE 'C++'
NAME 'DenseGammaFactory' LIBRARY DenseGamma NOT FENCED;

DROP TABLE IF EXISTS kdd1m CASCADE;
CREATE TABLE kdd1m (i INT NOT NULL ENCODING RLE, j INT NOT NULL ENCODING COMMONDELTA_COMP, v float) ORDER BY i, j SEGMENTED BY MODULARHASH(i) ALL NODES;
COPY kdd1m FROM '/home/vertica/dataset/kdd1m_vert.csv' SKIP 0 DELIMITER ',';

DROP TABLE IF EXISTS kdd010kd010 CASCADE;
DROP TABLE IF EXISTS kdd010kd020 CASCADE;
DROP TABLE IF EXISTS kdd010kd040 CASCADE;
DROP TABLE IF EXISTS kdd010kd080 CASCADE;
DROP TABLE IF EXISTS kdd100kd010 CASCADE;
DROP TABLE IF EXISTS kdd100kd020 CASCADE;
DROP TABLE IF EXISTS kdd100kd040 CASCADE;
DROP TABLE IF EXISTS kdd100kd080 CASCADE;
DROP TABLE IF EXISTS kdd001md010 CASCADE;
DROP TABLE IF EXISTS kdd001md020 CASCADE;
DROP TABLE IF EXISTS kdd001md040 CASCADE;
DROP TABLE IF EXISTS kdd001md080 CASCADE;

CREATE TABLE kdd010kd010 (i INT NOT NULL ENCODING RLE, j INT NOT NULL ENCODING COMMONDELTA_COMP, v float) ORDER BY i, j SEGMENTED BY MODULARHASH(i) ALL NODES;
CREATE TABLE kdd010kd020 (i INT NOT NULL ENCODING RLE, j INT NOT NULL ENCODING COMMONDELTA_COMP, v float) ORDER BY i, j SEGMENTED BY MODULARHASH(i) ALL NODES;
CREATE TABLE kdd010kd040 (i INT NOT NULL ENCODING RLE, j INT NOT NULL ENCODING COMMONDELTA_COMP, v float) ORDER BY i, j SEGMENTED BY MODULARHASH(i) ALL NODES;
CREATE TABLE kdd010kd080 (i INT NOT NULL ENCODING RLE, j INT NOT NULL ENCODING COMMONDELTA_COMP, v float) ORDER BY i, j SEGMENTED BY MODULARHASH(i) ALL NODES;
CREATE TABLE kdd100kd010 (i INT NOT NULL ENCODING RLE, j INT NOT NULL ENCODING COMMONDELTA_COMP, v float) ORDER BY i, j SEGMENTED BY MODULARHASH(i) ALL NODES;
CREATE TABLE kdd100kd020 (i INT NOT NULL ENCODING RLE, j INT NOT NULL ENCODING COMMONDELTA_COMP, v float) ORDER BY i, j SEGMENTED BY MODULARHASH(i) ALL NODES;
CREATE TABLE kdd100kd040 (i INT NOT NULL ENCODING RLE, j INT NOT NULL ENCODING COMMONDELTA_COMP, v float) ORDER BY i, j SEGMENTED BY MODULARHASH(i) ALL NODES;
CREATE TABLE kdd100kd080 (i INT NOT NULL ENCODING RLE, j INT NOT NULL ENCODING COMMONDELTA_COMP, v float) ORDER BY i, j SEGMENTED BY MODULARHASH(i) ALL NODES;
CREATE TABLE kdd001md010 (i INT NOT NULL ENCODING RLE, j INT NOT NULL ENCODING COMMONDELTA_COMP, v float) ORDER BY i, j SEGMENTED BY MODULARHASH(i) ALL NODES;
CREATE TABLE kdd001md020 (i INT NOT NULL ENCODING RLE, j INT NOT NULL ENCODING COMMONDELTA_COMP, v float) ORDER BY i, j SEGMENTED BY MODULARHASH(i) ALL NODES;
CREATE TABLE kdd001md040 (i INT NOT NULL ENCODING RLE, j INT NOT NULL ENCODING COMMONDELTA_COMP, v float) ORDER BY i, j SEGMENTED BY MODULARHASH(i) ALL NODES;
CREATE TABLE kdd001md080 (i INT NOT NULL ENCODING RLE, j INT NOT NULL ENCODING COMMONDELTA_COMP, v float) ORDER BY i, j SEGMENTED BY MODULARHASH(i) ALL NODES;

CREATE PROJECTION kdd010kd010join AS SELECT * FROM kdd010kd010 ORDER BY j,i,v SEGMENTED BY MODULARHASH(j) ALL NODES;
CREATE PROJECTION kdd010kd020join AS SELECT * FROM kdd010kd020 ORDER BY j,i,v SEGMENTED BY MODULARHASH(j) ALL NODES;
CREATE PROJECTION kdd010kd040join AS SELECT * FROM kdd010kd040 ORDER BY j,i,v SEGMENTED BY MODULARHASH(j) ALL NODES;
CREATE PROJECTION kdd010kd080join AS SELECT * FROM kdd010kd080 ORDER BY j,i,v SEGMENTED BY MODULARHASH(j) ALL NODES;
CREATE PROJECTION kdd100kd010join AS SELECT * FROM kdd100kd010 ORDER BY j,i,v SEGMENTED BY MODULARHASH(j) ALL NODES;
CREATE PROJECTION kdd100kd020join AS SELECT * FROM kdd100kd020 ORDER BY j,i,v SEGMENTED BY MODULARHASH(j) ALL NODES;
CREATE PROJECTION kdd100kd040join AS SELECT * FROM kdd100kd040 ORDER BY j,i,v SEGMENTED BY MODULARHASH(j) ALL NODES;
CREATE PROJECTION kdd100kd080join AS SELECT * FROM kdd100kd080 ORDER BY j,i,v SEGMENTED BY MODULARHASH(j) ALL NODES;
CREATE PROJECTION kdd001md010join AS SELECT * FROM kdd001md010 ORDER BY j,i,v SEGMENTED BY MODULARHASH(j) ALL NODES;
CREATE PROJECTION kdd001md020join AS SELECT * FROM kdd001md020 ORDER BY j,i,v SEGMENTED BY MODULARHASH(j) ALL NODES;
CREATE PROJECTION kdd001md040join AS SELECT * FROM kdd001md040 ORDER BY j,i,v SEGMENTED BY MODULARHASH(j) ALL NODES;
CREATE PROJECTION kdd001md080join AS SELECT * FROM kdd001md080 ORDER BY j,i,v SEGMENTED BY MODULARHASH(j) ALL NODES;

INSERT INTO kdd001md040 SELECT * FROM kdd1m;
INSERT INTO kdd001md040 SELECT i, j+39, v FROM kdd1m WHERE j<=1;
INSERT INTO kdd001md080 SELECT * FROM kdd001md040;
INSERT INTO kdd001md080 SELECT i, j+40, v FROM kdd001md040;
INSERT INTO kdd001md020 SELECT * FROM kdd001md040 WHERE j<=20;
INSERT INTO kdd001md010 SELECT * FROM kdd001md020 WHERE j<=10;

INSERT INTO kdd100kd080 SELECT * FROM kdd001md080 WHERE i<=100000;
INSERT INTO kdd100kd040 SELECT * FROM kdd100kd080 WHERE j<=40;
INSERT INTO kdd100kd020 SELECT * FROM kdd100kd040 WHERE j<=20;
INSERT INTO kdd100kd010 SELECT * FROM kdd100kd020 WHERE j<=10;

INSERT INTO kdd010kd080 SELECT * FROM kdd100kd080 WHERE i<=10000;
INSERT INTO kdd010kd040 SELECT * FROM kdd010kd080 WHERE j<=40;
INSERT INTO kdd010kd020 SELECT * FROM kdd010kd040 WHERE j<=20;
INSERT INTO kdd010kd010 SELECT * FROM kdd010kd020 WHERE j<=10;

COMMIT;

\timing
\o /dev/null
SELECT DenseGamma(i, j, v USING PARAMETERS d=10) OVER (PARTITION BY MOD(i,4) ORDER BY i,j)
FROM kdd010kd010;
SELECT DenseGamma(i, j, v USING PARAMETERS d=20) OVER (PARTITION BY MOD(i,4) ORDER BY i,j)
FROM kdd010kd020;
SELECT DenseGamma(i, j, v USING PARAMETERS d=40) OVER (PARTITION BY MOD(i,4) ORDER BY i,j)
FROM kdd010kd040;
SELECT DenseGamma(i, j, v USING PARAMETERS d=80) OVER (PARTITION BY MOD(i,4) ORDER BY i,j)
FROM kdd010kd080;
SELECT a.j AS i, b.j AS j, sum(a.v * b.v) AS v FROM kdd010kd010 a JOIN kdd010kd010 b ON a.i = b.i GROUP BY a.j, b.j;
SELECT a.j AS i, b.j AS j, sum(a.v * b.v) AS v FROM kdd010kd020 a JOIN kdd010kd020 b ON a.i = b.i GROUP BY a.j, b.j;
SELECT a.j AS i, b.j AS j, sum(a.v * b.v) AS v FROM kdd010kd040 a JOIN kdd010kd040 b ON a.i = b.i GROUP BY a.j, b.j;
SELECT a.j AS i, b.j AS j, sum(a.v * b.v) AS v FROM kdd010kd080 a JOIN kdd010kd080 b ON a.i = b.i GROUP BY a.j, b.j;

SELECT DenseGamma(i, j, v USING PARAMETERS d=10) OVER (PARTITION BY MOD(i,4) ORDER BY i,j)
FROM kdd100kd010;
SELECT DenseGamma(i, j, v USING PARAMETERS d=20) OVER (PARTITION BY MOD(i,4) ORDER BY i,j)
FROM kdd100kd020;
SELECT DenseGamma(i, j, v USING PARAMETERS d=40) OVER (PARTITION BY MOD(i,4) ORDER BY i,j)
FROM kdd100kd040;
SELECT DenseGamma(i, j, v USING PARAMETERS d=80) OVER (PARTITION BY MOD(i,4) ORDER BY i,j)
FROM kdd100kd080;
SELECT a.j AS i, b.j AS j, sum(a.v * b.v) AS v FROM kdd100kd010 a JOIN kdd100kd010 b ON a.i = b.i GROUP BY a.j, b.j;
SELECT a.j AS i, b.j AS j, sum(a.v * b.v) AS v FROM kdd100kd020 a JOIN kdd100kd020 b ON a.i = b.i GROUP BY a.j, b.j;
SELECT a.j AS i, b.j AS j, sum(a.v * b.v) AS v FROM kdd100kd040 a JOIN kdd100kd040 b ON a.i = b.i GROUP BY a.j, b.j;
SELECT a.j AS i, b.j AS j, sum(a.v * b.v) AS v FROM kdd100kd080 a JOIN kdd100kd080 b ON a.i = b.i GROUP BY a.j, b.j;

SELECT DenseGamma(i, j, v USING PARAMETERS d=10) OVER (PARTITION BY MOD(i,4) ORDER BY i,j)
FROM kdd001md010;
SELECT DenseGamma(i, j, v USING PARAMETERS d=20) OVER (PARTITION BY MOD(i,4) ORDER BY i,j)
FROM kdd001md020;
SELECT DenseGamma(i, j, v USING PARAMETERS d=40) OVER (PARTITION BY MOD(i,4) ORDER BY i,j)
FROM kdd001md040;
SELECT DenseGamma(i, j, v USING PARAMETERS d=80) OVER (PARTITION BY MOD(i,4) ORDER BY i,j)
FROM kdd001md080;
SELECT a.j AS i, b.j AS j, sum(a.v * b.v) AS v FROM kdd001md010 a JOIN kdd001md010 b ON a.i = b.i GROUP BY a.j, b.j;
SELECT a.j AS i, b.j AS j, sum(a.v * b.v) AS v FROM kdd001md020 a JOIN kdd001md020 b ON a.i = b.i GROUP BY a.j, b.j;
SELECT a.j AS i, b.j AS j, sum(a.v * b.v) AS v FROM kdd001md040 a JOIN kdd001md040 b ON a.i = b.i GROUP BY a.j, b.j;
SELECT a.j AS i, b.j AS j, sum(a.v * b.v) AS v FROM kdd001md080 a JOIN kdd001md080 b ON a.i = b.i GROUP BY a.j, b.j;

-- srun "rm ~/cosc6340/v_cosc6340_node*_catalog/UDxLogs/UDxFencedProcesses.log"
-- srun "echo > ~/localN1/v_localn1_node*_catalog/vertica.log"