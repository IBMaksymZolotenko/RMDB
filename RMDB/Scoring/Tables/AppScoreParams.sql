CREATE TABLE [Scoring].[AppScoreParams]
(
	[APPID] INT NOT NULL , 
    [SCOREPARAMID] INT NOT NULL, 
    [SCOREPARAMVALUE] NVARCHAR(100) NULL, 
    [created] DATETIME2 NOT NULL DEFAULT sysdatetime(), 
    [creator] NVARCHAR(50) NOT NULL DEFAULT user, 
    CONSTRAINT [pk_scoring_appscoreparams] PRIMARY KEY ([APPID], [SCOREPARAMID])
)
