--[YaHembarovska]
--IF NOT EXISTS	(
--					SELECT	1
--					FROM	[sys].[database_principals]
--					WHERE	[type] in (N'S',N'U')
--							AND [name] = N'BANKGROUP\YaHembarovska'
--				)
	CREATE USER [BANKGROUP\YaHembarovska] FOR LOGIN [BANKGROUP\YaHembarovska] WITH DEFAULT_SCHEMA = [dbo]