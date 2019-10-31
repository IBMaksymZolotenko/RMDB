--IF NOT EXISTS	(
--					SELECT	1
--					FROM	[sys].[database_principals]
--					WHERE	[type] in (N'S',N'U')
--							AND [name] = N'BANKGROUP\VUstinov'
--				)
	CREATE USER [BANKGROUP\VUstinov] FOR LOGIN [BANKGROUP\VUstinov] WITH DEFAULT_SCHEMA = [dbo]