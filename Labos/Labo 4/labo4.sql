CREATE DATABASE BDRestos;
USE BDRestos;


GO
CREATE TABLE Categories (
    idCategorie SMALLINT PRIMARY KEY, nomCategorie VARCHAR(30) NOT NULL
);

GO
CREATE TABLE Restaurants (
    idRestaurant INT IDENTITY(1,1) PRIMARY KEY, nomRestaurant VARCHAR(30) NOT NULL,
    adresse VARCHAR(50) NOT NULL, nbEtoiles SMALLINT NOT NULL CHECK (nbEtoiles BETWEEN 1 AND 5),
    prixMoyen MONEY NOT NULL, commentaire VARCHAR(100) NOT NULL,
    idCategorie SMALLINT FOREIGN KEY REFERENCES Categories(idCategorie)
);



GO
CREATE OR ALTER PROCEDURE sp_AjouterRestaurant
    @nomRestaurant VARCHAR(30), @adresse VARCHAR(50), @nbEtoiles SMALLINT,
    @prixMoyen MONEY, @commentaire VARCHAR(100), @idCategorie SMALLINT
AS
BEGIN
    BEGIN TRY
        INSERT INTO Restaurants (nomRestaurant, adresse, nbEtoiles, prixMoyen, commentaire, idCategorie) VALUES (@nomRestaurant, @adresse, @nbEtoiles, @prixMoyen, @commentaire, @idCategorie);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK;
    END CATCH
END;

GO
CREATE OR ALTER PROCEDURE sp_ModifierEtoiles
    @idRestaurant INT, @nbEtoiles SMALLINT
AS
BEGIN
    BEGIN TRY
        UPDATE Restaurants 
        SET nbEtoiles = @nbEtoiles WHERE idRestaurant = @idRestaurant;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK;
    END CATCH
END;



GO
CREATE OR ALTER FUNCTION fn_RechercherTous()
RETURNS TABLE
AS
RETURN (
    SELECT r.idRestaurant, r.nomRestaurant, r.adresse, r.nbEtoiles, r.prixMoyen, r.commentaire, c.nomCategorie FROM Restaurants r
    INNER JOIN Categories c ON r.idCategorie = c.idCategorie
);


GO
CREATE OR ALTER FUNCTION fn_RechercherParCommentaire()
RETURNS TABLE
AS
RETURN (
    SELECT r.nomRestaurant, r.adresse, r.nbEtoiles, r.prixMoyen, r.commentaire, c.nomCategorie FROM Restaurants r
    INNER JOIN Categories c ON r.idCategorie = c.idCategorie
    WHERE r.commentaire LIKE '%excellent%' OR r.commentaire LIKE '%bon%'
);


GO
CREATE OR ALTER FUNCTION fn_RechercherParEtoiles (@nbEtoiles SMALLINT)
RETURNS TABLE
AS
RETURN (
    SELECT nomRestaurant, prixMoyen, nbEtoiles FROM Restaurants
    WHERE nbEtoiles = @nbEtoiles
);


GO
CREATE OR ALTER FUNCTION fn_RechercherParCategorie (@idCategorie SMALLINT)
RETURNS TABLE
AS
RETURN (
    SELECT nomRestaurant, nbEtoiles, prixMoyen, adresse FROM Restaurants
    WHERE idCategorie = @idCategorie
);

-- différences entre executenonquery(), executereader(), executescaler() : sera une question à l'exam final (élément important)
-- insert: executenonquery(), select qui retourne une valeur: executescaler()