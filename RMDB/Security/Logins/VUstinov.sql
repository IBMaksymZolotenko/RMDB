--IF	NOT EXISTS	(
--					select	1
--					from	master.sys.server_principals
--					where	name = N'BANKGROUP\VUstinov'
--				)
	CREATE LOGIN [BANKGROUP\VUstinov] FROM WINDOWS
