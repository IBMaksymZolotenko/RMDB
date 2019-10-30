--[IBorushchak]
--IF NOT EXISTS	(
--					SELECT	1
--					FROM	[sys].[database_principals]
--					WHERE	[type] in (N'S',N'U')
--							AND [name] = N'IBorushchak'
--				)
CREATE USER [IBorushchak] FOR LOGIN [IBorushchak] WITH DEFAULT_SCHEMA = [dbo]