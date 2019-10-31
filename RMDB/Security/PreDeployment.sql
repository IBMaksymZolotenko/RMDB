/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

--	ALTER AUTHORIZATION ON DATABASE::[$(DatabaseName)] TO [sa]


/*

	2019-10-30, Золотенко М.:

		Нажаль, потрібно окремо виділити з проекту частину, що пов'язана з роздачею доступів та створенням користувачів та логінів.
		Тому відповідні скрипти викинув з Build'у.


*/