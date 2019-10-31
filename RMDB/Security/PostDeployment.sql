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

--exec sp_addrolemember 'RoleRMDev', 'Bankgroup\ASukhliak';
--exec sp_addrolemember 'RoleITUser', 'CLSRobot';
--exec sp_addrolemember 'RoleRMUserExt', 'IBorushchak';
--exec sp_addrolemember 'RoleRMDev', 'Bankgroup\MZolotenko';
--exec sp_addrolemember 'RoleRMUser', 'Bankgroup\OSorochynskyi';
--exec sp_addrolemember 'RoleITUser', 'SGromov';
--exec sp_addrolemember 'RoleRMUser', 'Bankgroup\USemenyshyn';
--exec sp_addrolemember 'RoleRMUser', 'Bankgroup\VUstinov';
--exec sp_addrolemember 'RoleRMUser', 'Bankgroup\YaHembarovska';
--go

--	доступ до інтерфейсу
grant select on [Scoring].[ActivityField] to [RoleITUser]
grant execute on [Scoring].[sp_Calc_ScoreParams] to [RoleITUser]
go

--	користувачі ДпУР
grant select on [Scoring].[ActivityField] to [RoleRMUser]
grant select on [Scoring].[ActivityFieldHistory] to [RoleRMUser]
go

--	коритувачі ДпУР з розширеними можливостями
exec sp_addrolemember 'RoleRMUser', 'RoleRMUserExt'
grant execute on [Scoring].[sp_Calc_ScoreParams] to [RoleRMUserExt]
grant execute on [Scoring].[sp_ActivityField_ins] to [RoleRMUserExt]
grant execute on [Scoring].[sp_ActivityField_del] to [RoleRMUserExt]
grant execute on [Scoring].[sp_ActivityField_upd] to [RoleRMUserExt]
go

--	користувачі ДпУР - розробиники з максимально можливим доступом
grant select, insert, update, delete on [Scoring].[ActivityField] to [RoleRMDev]
grant select, insert, update, delete on [Scoring].[ActivityFieldHistory] to [RoleRMDev]

grant execute on [Scoring].[sp_Calc_ScoreParams] to [RoleRMDev]
grant execute on [Scoring].[sp_ActivityField_ins] to [RoleRMDev]
grant execute on [Scoring].[sp_ActivityField_del] to [RoleRMDev]
grant execute on [Scoring].[sp_ActivityField_upd] to [RoleRMDev]
go
/*


*/