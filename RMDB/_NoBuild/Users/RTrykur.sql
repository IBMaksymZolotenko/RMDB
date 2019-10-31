--IF NOT EXISTS	(
--					SELECT	1
--					FROM	[sys].[database_principals]
--					WHERE	[type] in (N'S',N'U')
--							AND [name] = N'BANKGROUP\RTrykur'
--				)
	CREATE USER [BANKGROUP\RTrykur] FOR LOGIN [BANKGROUP\RTrykur] WITH DEFAULT_SCHEMA = [dbo]