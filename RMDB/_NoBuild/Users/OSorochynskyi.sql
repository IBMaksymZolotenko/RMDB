--IF NOT EXISTS	(
--					SELECT	1
--					FROM	[sys].[database_principals]
--					WHERE	[type] in (N'S',N'U')
--							AND [name] = N'BANKGROUP\OSorochynskyi'
--				)
	CREATE USER [BANKGROUP\OSorochynskyi] FOR LOGIN [BANKGROUP\OSorochynskyi] WITH DEFAULT_SCHEMA = [dbo]