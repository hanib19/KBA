-- Écrire une procédure qui supprime en cascade
-- une question et ses réponses

/*
CREATE OR ALTER PROCEDURE SupprimerQuestion
   @idQuestion SMALLINT 
AS 
BEGIN
BEGIN TRANSACTION
BEGIN TRY

DELETE FROM ResponseTrivia WHERE idQuestion = @idQuestion;

DELETE FROM QuestionTrivia WHERE idQuestion = @idQuestion;
COMMIT
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
ROLLBACK
END CATCH
END
GO

-- Exécuter la procédure
EXECUTE SupprimerQuestion
@idQuestion = 100;

-- Écrire une procédure qui compte le nombre de questions 
CREATE PROCEDURE nomProcedure
@param CHAR(1)
AS
BEGIN
BEGIN TRANSACTION
BEGIN TRY 
-- code ici
COMMIT
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
ROLLBACK
END CATCH
-- IL FAUT METTRE DES TRANSACTIONS