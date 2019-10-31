:setvar DatabaseName "RMDB"

USE master
GO

--	---------------------------------------------------------------------------------------------------------------------
--	LOGINS
--	
IF	NOT EXISTS	(
					select	1
					from	master.sys.server_principals
					where	name = N'BANKGROUP\ASukhliak'
				)
	CREATE LOGIN [BANKGROUP\ASukhliak] FROM WINDOWS
GO

IF	NOT EXISTS	(
					select	1
					from	master.sys.server_principals
					where	name = N'CLSRobot'
				)
	CREATE LOGIN [CLSRobot] WITH PASSWORD=N'', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

IF	NOT EXISTS	(
					select	1
					from	master.sys.server_principals
					where	name = N'IBorushchak'
				)
	CREATE LOGIN [IBorushchak] WITH PASSWORD=N'', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;

IF	NOT EXISTS	(
					select	1
					from	master.sys.server_principals
					where	name = N'BANKGROUP\MZolotenko'
				)
	CREATE LOGIN [BANKGROUP\MZolotenko] FROM WINDOWS;

IF	NOT EXISTS	(
					select	1
					from	master.sys.server_principals
					where	name = N'BANKGROUP\RTrykur'
				)
	CREATE LOGIN [BANKGROUP\RTrykur] FROM WINDOWS;

IF	NOT EXISTS	(
					select	1
					from	master.sys.server_principals
					where	name = N'BANKGROUP\OSorochynskyi'
				)
	CREATE LOGIN [BANKGROUP\OSorochynskyi] FROM WINDOWS;

IF	NOT EXISTS	(
					select	1
					from	master.sys.server_principals
					where	name = N'SGromov'
				)
	CREATE LOGIN [SGromov] WITH PASSWORD=N'', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;

IF	NOT EXISTS	(
					select	1
					from	master.sys.server_principals
					where	name = N'BANKGROUP\USemenyshyn'
				)
	CREATE LOGIN [BANKGROUP\USemenyshyn] FROM WINDOWS;

IF	NOT EXISTS	(
					select	1
					from	master.sys.server_principals
					where	name = N'BANKGROUP\VUstinov'
				)
	CREATE LOGIN [BANKGROUP\VUstinov] FROM WINDOWS;

IF	NOT EXISTS	(
					select	1
					from	master.sys.server_principals
					where	name = N'BANKGROUP\YaHembarovska'
				)
	CREATE LOGIN [BANKGROUP\YaHembarovska] FROM WINDOWS
GO
--	---------------------------------------------------------------------------------------------------------------------
--	USERS
--	
USE $(DatabaseName)

IF NOT EXISTS	(
					SELECT	1
					FROM	[sys].[database_principals]
					WHERE	[type] in (N'S',N'U')
							AND [name] = N'BANKGROUP\ASukhliak'
				)
	CREATE USER [BANKGROUP\ASukhliak] FOR LOGIN [BANKGROUP\ASukhliak] WITH DEFAULT_SCHEMA = [dbo];

IF NOT EXISTS	(
					SELECT	1
					FROM	[sys].[database_principals]
					WHERE	[type] in (N'S',N'U')
							AND [name] = N'CLSRobot'
				)
	CREATE USER [CLSRobot] FOR LOGIN [CLSRobot] WITH DEFAULT_SCHEMA = [dbo];

IF NOT EXISTS	(
					SELECT	1
					FROM	[sys].[database_principals]
					WHERE	[type] in (N'S',N'U')
							AND [name] = N'IBorushchak'
				)
	CREATE USER [IBorushchak] FOR LOGIN [IBorushchak] WITH DEFAULT_SCHEMA = [dbo];

IF NOT EXISTS	(
					SELECT	1
					FROM	[sys].[database_principals]
					WHERE	[type] in (N'S',N'U')
							AND [name] = N'BANKGROUP\MZolotenko'
				)
	CREATE USER [BANKGROUP\MZolotenko] FOR LOGIN [BANKGROUP\MZolotenko] WITH DEFAULT_SCHEMA = [dbo];

IF NOT EXISTS	(
					SELECT	1
					FROM	[sys].[database_principals]
					WHERE	[type] in (N'S',N'U')
							AND [name] = N'BANKGROUP\RTrykur'
				)
	CREATE USER [BANKGROUP\RTrykur] FOR LOGIN [BANKGROUP\RTrykur] WITH DEFAULT_SCHEMA = [dbo];

IF NOT EXISTS	(
					SELECT	1
					FROM	[sys].[database_principals]
					WHERE	[type] in (N'S',N'U')
							AND [name] = N'BANKGROUP\OSorochynskyi'
				)
	CREATE USER [BANKGROUP\OSorochynskyi] FOR LOGIN [BANKGROUP\OSorochynskyi] WITH DEFAULT_SCHEMA = [dbo];

IF NOT EXISTS	(
					SELECT	1
					FROM	[sys].[database_principals]
					WHERE	[type] in (N'S',N'U')
							AND [name] = N'SGromov'
				)
	CREATE USER [SGromov] FOR LOGIN [SGromov] WITH DEFAULT_SCHEMA = [dbo];

IF NOT EXISTS	(
					SELECT	1
					FROM	[sys].[database_principals]
					WHERE	[type] in (N'S',N'U')
							AND [name] = N'BANKGROUP\USemenyshyn'
				)
	CREATE USER [BANKGROUP\USemenyshyn] FOR LOGIN [BANKGROUP\USemenyshyn] WITH DEFAULT_SCHEMA = [dbo];

IF NOT EXISTS	(
					SELECT	1
					FROM	[sys].[database_principals]
					WHERE	[type] in (N'S',N'U')
							AND [name] = N'BANKGROUP\VUstinov'
				)
	CREATE USER [BANKGROUP\VUstinov] FOR LOGIN [BANKGROUP\VUstinov] WITH DEFAULT_SCHEMA = [dbo];

IF NOT EXISTS	(
					SELECT	1
					FROM	[sys].[database_principals]
					WHERE	[type] in (N'S',N'U')
							AND [name] = N'BANKGROUP\YaHembarovska'
				)
	CREATE USER [BANKGROUP\YaHembarovska] FOR LOGIN [BANKGROUP\YaHembarovska] WITH DEFAULT_SCHEMA = [dbo];
--	--------------------------------------------------------------------------------------------------------------------------
--	ADD TO ROLES
--	
exec sp_addrolemember 'RoleRMDev', 'Bankgroup\ASukhliak';
exec sp_addrolemember 'RoleITUser', 'CLSRobot';
exec sp_addrolemember 'RoleRMUserExt', 'IBorushchak';
exec sp_addrolemember 'RoleRMDev', 'Bankgroup\MZolotenko';
exec sp_addrolemember 'RoleRMUser', 'Bankgroup\RTrykur';
exec sp_addrolemember 'RoleRMUser', 'Bankgroup\OSorochynskyi';
exec sp_addrolemember 'RoleITUser', 'SGromov';
exec sp_addrolemember 'RoleRMUser', 'Bankgroup\USemenyshyn';
exec sp_addrolemember 'RoleRMUser', 'Bankgroup\VUstinov';
exec sp_addrolemember 'RoleRMUser', 'Bankgroup\YaHembarovska';