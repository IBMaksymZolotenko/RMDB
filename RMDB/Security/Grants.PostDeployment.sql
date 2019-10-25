/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

grant select on [Scoring].[ActivityField] to [RoleITUser]
grant execute on [Scoring].[sp_Calc_ScoreParams] to [RoleITUser]
go

grant select on [Scoring].[ActivityField] to [RoleRMUser]
grant select on [Scoring].[ActivityFieldHistory] to [RoleRMUser]
go

exec sp_addrolemember 'RoleRMUser', 'RoleRMUserExt'
go

grant execute on [Scoring].[sp_Calc_ScoreParams] to [RoleRMUserExt]
grant execute on [Scoring].[sp_ActivityField_ins] to [RoleRMUserExt]
grant execute on [Scoring].[sp_ActivityField_del] to [RoleRMUserExt]
grant execute on [Scoring].[sp_ActivityField_upd] to [RoleRMUserExt]
go

IF NOT EXISTS	(
					SELECT	1
					FROM	[sys].[database_principals]
					WHERE	[type] = N'S'
							AND [name] = N'SGromov'
				)
	CREATE USER [SGromov] FOR LOGIN [SGromov] WITH DEFAULT_SCHEMA=[dbo]
go

IF NOT EXISTS	(
					SELECT	1
					FROM	[sys].[database_principals]
					WHERE	[type] = N'S'
							AND [name] = N'CLSRobot'
				)
	CREATE USER [CLSRobot] FOR LOGIN [CLSRobot] WITH DEFAULT_SCHEMA=[dbo]
go

exec	sp_addrolemember 'RoleITUser', 'SGromov'
go

exec	sp_addrolemember 'RoleITUser', 'CLSRobot'
go
