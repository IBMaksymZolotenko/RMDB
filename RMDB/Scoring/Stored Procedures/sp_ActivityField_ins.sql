--	----------------------------------------------------------------------------------------------------------------------------
--	
--		2019-10-23, Золотенко М.
--	
CREATE PROCEDURE [Scoring].[sp_ActivityField_ins]
	@aPOSITION					NVARCHAR(200),
	@aFIELD_OF_ACTIVITY			NVARCHAR(200),
	@aDESCRIPTION				NVARCHAR(MAX),
	@aGROUP_FIELD_OF_ACTIVITY	NVARCHAR(200),
	@aGROUP_POSITION			NVARCHAR(200)
WITH ENCRYPTION
AS
	SET NOCOUNT ON;

	INSERT	[Scoring].[ActivityField]
		(
			POSITION,FIELD_OF_ACTIVITY,DESCRIPTION,GROUP_FIELD_OF_ACTIVITY,GROUP_POSITION
		)
	VALUES	(
				@aPOSITION,
				@aFIELD_OF_ACTIVITY,
				@aDESCRIPTION,
				@aGROUP_FIELD_OF_ACTIVITY,
				@aGROUP_POSITION
			);

RETURN 0;