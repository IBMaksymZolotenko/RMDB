--	------------------------------------------------------------------------------------
--	
--		2019/10/22, Золотенко М.
--	
--		Скорингові карти
--	
CREATE TABLE [Scoring].[ScoreCard]
	(
		[ID]          INT            IDENTITY (1, 1) NOT NULL,
		[NAME]        NVARCHAR (100) NOT NULL,
		[DESCRIPTION] NVARCHAR (MAX) NOT NULL,

		CONSTRAINT [pk_scoring_scorecard] PRIMARY KEY CLUSTERED ([ID] ASC),
		CONSTRAINT [uq_scoring_scorecard__name] UNIQUE NONCLUSTERED ([NAME] ASC)
	);