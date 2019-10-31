--IF NOT EXISTS	(
--					SELECT	1
--					FROM	[sys].[database_principals]
--					WHERE	[type] in (N'S',N'U')
--							AND [name] = N'SGromov'
--				)
	CREATE USER [SGromov] FOR LOGIN [SGromov] WITH DEFAULT_SCHEMA = [dbo]