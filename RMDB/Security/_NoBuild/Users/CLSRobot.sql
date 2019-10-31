--IF NOT EXISTS	(
--					SELECT	1
--					FROM	[sys].[database_principals]
--					WHERE	[type] in (N'S',N'U')
--							AND [name] = N'CLSRobot'
--				)
	CREATE USER [CLSRobot] FOR LOGIN [CLSRobot] WITH DEFAULT_SCHEMA = [dbo]