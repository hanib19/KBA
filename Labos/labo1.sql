-- Partie 1
CREATE DATABASE BDTourismo;
USE BDTourismo; 

---------------------------

CREATE TABLE Villes (
    codeVille CHAR(3) NOT NULL, nomVille VARCHAR(50) NOT NULL, population INT, 
    CONSTRAINT PK_Villes PRIMARY KEY (codeVille)
);

CREATE TABLE Monuments
(
    idMonument INT IDENTITY(2,1) NOT NULL, nomMonument VARCHAR(30) NOT NULL, histoireMonument VARCHAR(60) NOT NULL,
    nbEtoile SMALLINT NOT NULL, coutVisite MONEY NOT NULL,
    CONSTRAINT PK_Monuments PRIMARY KEY (idMonument)
);

CREATE TABLE Circuits
(
    idcircuit INT IDENTITY(51,1) NOT NULL, nomcircuit VARCHAR(30) NOT NULL, dureecircuit INT NOT NULL,
    coutcircuit MONEY NOT NULL, nbmaxclients SMALLINT, codevilledebut CHAR(3) NOT NULL, codevillefin CHAR(3) NOT NULL,
    CONSTRAINT PK_Circuits PRIMARY KEY (idcircuit),
    CONSTRAINT FK_Circuits_VilleDebut FOREIGN KEY (codevilledebut) REFERENCES Villes(codeVille),
    CONSTRAINT FK_Circuits_VilleFin FOREIGN KEY (codevillefin) REFERENCES Villes(codeVille)
);


CREATE TABLE Circuitsmonuments
(
    idmonument INT NOT NULL,
    idcircuit INT NOT NULL,
    ordredevisite SMALLINT
);
---------------------------------------

-- Partie 2

-- 1a
ALTER TABLE CircuitsMonuments
ADD CONSTRAINT PK_CircuitsMonuments PRIMARY KEY (idmonument, idcircuit);

-- 1b
ALTER TABLE CircuitsMonuments
ADD CONSTRAINT FK_Idmonument FOREIGN KEY (idmonument) REFERENCES Monuments(idMonument);

ALTER TABLE CircuitsMonuments
ADD CONSTRAINT FK_Idcircuit FOREIGN KEY (idcircuit) REFERENCES Circuits(idcircuit);

-- 2
ALTER TABLE Monuments
ADD CONSTRAINT CK_Monuments_nbEtoile CHECK (nbEtoile BETWEEN 1 AND 5);

-- 3 (insertion du script tourismo.sql)

-- 4a
SELECT C.nomcircuit, VD.nomVille AS VilleDebut, VF.nomVille AS VilleArrivee, C.coutcircuit
FROM Circuits C
INNER JOIN Villes VD ON C.codevilledebut = VD.codeVille
INNER JOIN Villes VF ON C.codevillefin = VF.codeVille
WHERE VD.nomVille = 'Montréal';

-- 4b
SELECT C.nomcircuit, VD.nomVille AS VilleDebut, VF.nomVille AS VilleArrivee, C.coutcircuit, SUM(M.nbEtoile) AS TotalEtoiles
FROM Circuits C
INNER JOIN Villes VD ON C.codevilledebut = VD.codeVille
INNER JOIN Villes VF ON C.codevillefin = VF.codeVille
INNER JOIN CircuitsMonuments CM ON C.idcircuit = CM.idcircuit
INNER JOIN Monuments M ON CM.idmonument = M.idMonument
GROUP BY C.nomcircuit, VD.nomVille, VF.nomVille, C.coutcircuit
ORDER BY TotalEtoiles DESC;

-- 4c
SELECT M.nomMonument, M.nbEtoile
FROM Monuments M
LEFT JOIN CircuitsMonuments CM ON M.idMonument = CM.idmonument
WHERE CM.idmonument IS NULL;

-- 4d
SELECT C.nomcircuit, SUM(M.nbEtoile) AS TotalEtoiles
FROM Circuits C
INNER JOIN CircuitsMonuments CM ON C.idcircuit = CM.idcircuit
INNER JOIN Monuments M ON CM.idmonument = M.idMonument
GROUP BY C.nomcircuit
HAVING SUM(M.nbEtoile) >= 15;

-- 4e
SELECT TOP 2 C.nomcircuit, SUM(M.nbEtoile) AS TotalEtoiles, VD.nomVille AS VilleDebut, VF.nomVille AS VilleFin
FROM Circuits C
INNER JOIN Villes VD ON C.codevilledebut = VD.codeVille
INNER JOIN Villes VF ON C.codevillefin = VF.codeVille
INNER JOIN CircuitsMonuments CM ON C.idcircuit = CM.idcircuit
INNER JOIN Monuments M ON CM.idmonument = M.idMonument
GROUP BY C.nomcircuit, VD.nomVille, VF.nomVille
ORDER BY TotalEtoiles DESC;

-- 4f
SELECT M.nomMonument, SUM(M.nbEtoile) AS TotalEtoiles, M.histoireMonument, COUNT(CM.idcircuit) AS NombreCircuits
FROM Monuments M
INNER JOIN CircuitsMonuments CM ON M.idMonument = CM.idmonument
GROUP BY M.nomMonument, M.nbEtoile, M.histoireMonument
HAVING COUNT(CM.idcircuit) > 2;

-- 4g
/* CREATE VIEW VMonuments
AS
SELECT C.nomcircuit AS nomCircuit, M.nomMonument, CM.ordredevisite AS ordreDevisite, M.nbEtoile, C.coutcircuit
FROM Circuits C
INNER JOIN CircuitsMonuments CM ON C.idcircuit = CM.idcircuit
INNER JOIN Monuments M ON CM.idmonument = M.idMonument;
*/


-- 4h
SELECT *
FROM VMonuments
WHERE nbEtoile >= 4
ORDER BY nomCircuit DESC; 

-- 5
UPDATE Circuits SET coutcircuit =
    CASE
        WHEN coutcircuit <= 250 THEN coutcircuit * 1.10
        WHEN coutcircuit > 250 AND coutcircuit <= 450 THEN coutcircuit * 1.05
        ELSE coutcircuit * 1.01
    END;

-- 6
WHILE (SELECT AVG(coutVisite) FROM Monuments) <= 80 AND (SELECT MAX(coutVisite) FROM Monuments) < 250
BEGIN
    UPDATE Monuments SET coutVisite = coutVisite * 1.05;
    UPDATE Monuments SET coutVisite = 250
    WHERE coutVisite > 250;
END;

-- Partie 3

-- 1
SET IDENTITY_INSERT Monuments ON; -- cette genre d'insertion a besoin d'une liste de colonnes on dirait!
INSERT INTO Monuments (idMonument, nomMonument, histoireMonument, nbEtoile, coutVisite) VALUES (100, 'La statue', 'La statue de bronze', 2, 20);

-- 2
SET IDENTITY_INSERT Monuments OFF;
INSERT INTO Monuments VALUES ('La Sphère', 'La Sphère de Las Vegas', 2, 20);
-- le ID de celui-ci est 101, SQL server fait juste générer la valeur qui suivra la dernière (plutôt cool)

-- 3
/*
entre Idcircuit et Idmonument, je dirais que... aucune finira par être déclarée pour CircuitsMonuments? 
c'est une table qui lie les monuments et les circuits.. et ces deux clés sont des clés étrangères
*/

-- 4
/* 
les nouveaux éléments qui viennent avec SQL Server sont heureusement plutôt simples à comprendre.
étant le premier labo de BD depuis la session dernière, je suis content d'être encore si familier! 
c'est probablement la meilleure chose qui est venu de travail, la pratique avec le code en SQL
*/