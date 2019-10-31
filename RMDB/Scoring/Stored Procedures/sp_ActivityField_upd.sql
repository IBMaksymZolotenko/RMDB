--	----------------------------------------------------------------------------------------------------------------------------
--	
--		2019-10-23, Золотенко М.
--	
CREATE PROCEDURE [Scoring].[sp_ActivityField_upd]
	@aID						INT,
	@aPOSITION					NVARCHAR(200),
	@aFIELD_OF_ACTIVITY			NVARCHAR(200),
	@aDESCRIPTION				NVARCHAR(MAX),
	@aGROUP_FIELD_OF_ACTIVITY	NVARCHAR(200),
	@aGROUP_POSITION			NVARCHAR(200)
--WITH ENCRYPTION
AS
	SET NOCOUNT ON;

	UPDATE	[Scoring].[ActivityField]
	SET		POSITION					=	@aPOSITION,
			FIELD_OF_ACTIVITY			=	@aFIELD_OF_ACTIVITY,
			DESCRIPTION					=	@aDESCRIPTION,
			GROUP_FIELD_OF_ACTIVITY		=	@aGROUP_FIELD_OF_ACTIVITY,
			GROUP_POSITION				=	@aGROUP_POSITION
	WHERE	ID = @aID;

RETURN 0;