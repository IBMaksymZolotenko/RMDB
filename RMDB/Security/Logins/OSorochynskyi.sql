--CREATE LOGIN [OSorochynskyi] FROM WINDOWS
--IF	NOT EXISTS	(
--					select	1
--					from	master.sys.server_principals
--					where	name = N'BANKGROUP\OSorochynskyi'
--				)
	CREATE LOGIN [BANKGROUP\OSorochynskyi] FROM WINDOWS