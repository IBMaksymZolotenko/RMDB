
	--IF	NOT EXISTS	(
	--					select	1
	--					from	master.sys.server_principals
	--					where	name = N'BANKGROUP\ASukhliak'
	--				)
		CREATE LOGIN [BANKGROUP\ASukhliak] FROM WINDOWS