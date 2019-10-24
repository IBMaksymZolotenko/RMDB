--	------------------------------------------------------------------------------------
--	
--		2019/10/22, Золотенко М.
--	
--		Зв'язок скорингової карти з параметрами
--	
CREATE TABLE [Scoring].[ScoreCardParams]
	(
		[SCORECARDID]  INT NOT NULL,
		[SCOREPARAMID] INT NOT NULL,
		
		CONSTRAINT [PK_SCORING_SCORECARDPARAMS] PRIMARY KEY CLUSTERED ([SCORECARDID] ASC, [SCOREPARAMID] ASC)
	);