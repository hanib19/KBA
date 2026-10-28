/* GO
CREATE OR ALTER PROC CompterQuestionDisponible
@nombreQuestion INT OUTAS
SELECT @nombreQuestion = COUNT (idQuestion) FROM QuestionTrivia WHERE flag = ''
*/
GO
CREATE OR ALTER FUNCTION CompterQuestionDispo
()
RETURNS INT
AS
BEGIN
RETURN (SELECT COUNT (idQuestion)
FROM QuestionTrivia
WHERE flag = 'n' )
END;

GO
SELECT dbo CompterQuestionDispo;

SELECT COUNT (idQuestion)
FROM QuestionTrivia
WHERE flag = 'n'

GO
CREATE OR ALTER FUNCTION GenererSolutionnaire
()
RETURNS TABLE 
AS
RETURN (SELECT nomCategorie, enonce, laReponse
FROM QuestionTrivia q
INNER JOIN ReponseTrivia r ON q.idQuestion = r.idQuestion
INNER JOIN CategorieTrivia c ON c.idCategorie = q.idCategorie
WHERE estBonne = 'o')
;
GO

SELECT * FROM GenererSolutionnaire();