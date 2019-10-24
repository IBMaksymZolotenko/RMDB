--	------------------------------------------------------------------------------------
--	
--		2019/10/22, Золотенко М.
--	
--		Скорингові парамтери
--	
CREATE TABLE [Scoring].[ScoreParam]
	(
		[ID]          INT            IDENTITY (1, 1) NOT NULL,
		[NAME]        NVARCHAR (100) NOT NULL,
		[DESCRIPTION] NVARCHAR (MAX) NULL,
		[FL_DISABLED] BIT            DEFAULT 0 NOT NULL,

		CONSTRAINT [PK_SCORING_SCOREPARAM] PRIMARY KEY CLUSTERED ([ID] ASC),
		CONSTRAINT [UQ_SCORING_SCOREPARAM__NAME] UNIQUE NONCLUSTERED ([NAME] ASC)
	);

