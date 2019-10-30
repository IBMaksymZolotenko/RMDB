--[ASukhliak]
--IF NOT EXISTS	(
--					SELECT	1
--					FROM	[sys].[database_principals]
--					WHERE	[type] in (N'S',N'U')
--							AND [name] = N'BANKGROUP\ASukhliak'
--				)
	CREATE USER [BANKGROUP\ASukhliak] FOR LOGIN [BANKGROUP\ASukhliak] WITH DEFAULT_SCHEMA = [dbo]