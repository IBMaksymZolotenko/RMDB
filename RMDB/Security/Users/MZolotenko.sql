--[MZolotenko]
--IF NOT EXISTS	(
--					SELECT	1
--					FROM	[sys].[database_principals]
--					WHERE	[type] in (N'S',N'U')
--							AND [name] = N'BANKGROUP\MZolotenko'
--				)
	CREATE USER [BANKGROUP\MZolotenko] FOR LOGIN [BANKGROUP\MZolotenko] WITH DEFAULT_SCHEMA = [dbo]