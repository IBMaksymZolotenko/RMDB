--[USemenyshyn]
--IF NOT EXISTS	(
--					SELECT	1
--					FROM	[sys].[database_principals]
--					WHERE	[type] in (N'S',N'U')
--							AND [name] = N'BANKGROUP\USemenyshyn'
--				)
	CREATE USER [BANKGROUP\USemenyshyn] FOR LOGIN [BANKGROUP\USemenyshyn] WITH DEFAULT_SCHEMA = [dbo]