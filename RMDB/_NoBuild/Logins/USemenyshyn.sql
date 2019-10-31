--IF	NOT EXISTS	(
--					select	1
--					from	master.sys.server_principals
--					where	name = N'BANKGROUP\USemenyshyn'
--				)
	CREATE LOGIN [BANKGROUP\USemenyshyn] FROM WINDOWS