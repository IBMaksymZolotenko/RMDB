--	----------------------------------------------------------------------------------------------------------------------------
--	
--		2019-10-23, Золотенко М.
--	
CREATE PROCEDURE [Scoring].[sp_ActivityField_del]
	@aID						INT
WITH ENCRYPTION
AS
	SET NOCOUNT ON;

	DELETE	
	FROM	[Scoring].[ActivityField]
	WHERE	ID = @aID;

RETURN 0;