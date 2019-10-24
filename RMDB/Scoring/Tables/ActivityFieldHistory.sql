--	-------------------------------------------------------------------------------------------------------------------
--	
--		2019/10/23, Золотенко М.
--		
--		Історія зміни даних у [Scoring].[SCORING_ACTIVITY_FIELD]
--		
CREATE TABLE [Scoring].[ActivityFieldHistory]
	(
		[ID]							INT				NOT NULL	IDENTITY(1,1),

		[SCORING_ACTIVITY_FIELD_ID]		INT				NOT NULL,
		[POSITION]						NVARCHAR(200)	NOT NULL,
		[FIELD_OF_ACTIVITY]				NVARCHAR(200)	NOT NULL,
		[DESCRIPTION]					NVARCHAR(MAX),
		[GROUP_FIELD_OF_ACTIVITY]		NVARCHAR(200),
		[GROUP_POSITION]				NVARCHAR(200),

		[CREATED]						DATETIME2(7)	NOT NULL,
		[CREATOR]						NVARCHAR(100)	NOT NULL,
		[CHANGED]						DATETIME2(7)		NULL,
		[CHANGER]						NVARCHAR(100)		NULL,

		[HCREATED]						DATETIME2(7)	NOT NULL	DEFAULT SYSDATETIME(),

		CONSTRAINT PK_SCORING_ACTIVITYFIELDHISTORY PRIMARY KEY (ID),
	);