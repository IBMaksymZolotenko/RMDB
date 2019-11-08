--	-------------------------------------------------------------------------------------------------------------------------------
--
--		2019-09-10, Золотенко М.
--
--		Розрахунок параметрів для нового скорингу
--
--
CREATE PROCEDURE [Scoring].[sp_Calc_ScoreParams]
	@aROWID				INT,
	@aDATE				DATETIME,
	@aDEBUG				BIT = 0
--WITH ENCRYPTION
AS

BEGIN TRY

	SET NOCOUNT ON;
	
	SET ANSI_NULLS ON;

	SET ANSI_WARNINGS ON;

	--	-------------------------------------------------------------------------------------------------------------------------------
	--	!!!!!!!!!!!!!!!!!!!!! ОБОВ'ЯЗКОВО ПОТРІБНО ПРОПИСАТИ АКТУАЛЬНУ НАЗВУ ЛІНКУ НА Б2 ТА СХЕМУ І ПАКЕТ З Ф-ЦІЯМИ!!!!!!!!!!!!!!!!!!!!
	--	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	НА МОМЕНТ РОЗРОБКИ - ЦЕ ЛІНК НА ТЕСТОВОМУ СЕВРВЕРІ DB_TEST НА ТЕСТОВИЙ СЕРВЕР Б2 !!!!!!!!!!!!!!
	--	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	ПРИ ПЕРЕНОСІ НА ПРОД ЦЕЙ ЛІНК ПОТРІБНО ПЕРЕПИСАТИ НА АКТУАЛЬНИЙ ЛІНК НА ПРОД Б2 !!!!!!!!!!!!!!!
	--	
	DECLARE @B2_LINK	VARCHAR(100)	=	'B2ORACLE_SC';
	DECLARE @PKG		VARCHAR(100)	=	'CREATOR.PKG_IDEA_RM';
	DECLARE @isMBKIID	INT				=	777;

	DECLARE @PARAMS
		TABLE	(
			ROWID														INT,
			INN															VARCHAR(20),
			APPDATE														DATETIME,

			STARTCALC													DATETIME,
			ENDCALC														DATETIME	DEFAULT GETDATE(),					

			BKI_MAX_DPD_EVR												INT,
			BKI_CNT_ACTV_BANK_CRED_LAST_2_YEAR							INT,
			APP_SEX														CHAR(1),
			BKI_CNT_PREMATURELY_CLSD_CRED								INT,
			APP_MARITAL_STATUS_SEX										VARCHAR(50),
			APP_MARITAL_STATUS											VARCHAR(50),
			BKI_MAX_CRED_AMT_EVR										MONEY,
			BKI_CNT_OVD_CRED_NOW										INT,
			BKI_MIN_CNT_DAY_TO_200_PD									INT,
			BKI_CNT_MON_FROM_FIRST_CRED									INT,
			BKI_CNT_REQ_LAST_90_DAY										INT,
			HIST_MAX_DPD_LAST_24_MON									INT,
			BKI_CNT_MFO_REQ_LAST_MON									INT,
			BKI_MAX_PD_LAST_12_MON										MONEY,
			HIST_RATIO_AVG_SALDO_LAST_3_MON_TO_AVG_SALDO_PREV_3_MON		MONEY,
			BKI_CNT_PREMATURELY_CLSD_BANK_CRED							INT,
			HIST_RATIO_CUR_SALDO_TO_CUR_LIM								MONEY,
			BKI_CNT_IN_TIME_CLSD_CRED									INT,
			BKI_CNT_MON_TO_LAST_BANK_CRED								INT,
			BKI_MAX_PD_LAST_6_MON										MONEY,
			BKI_CNT_1PLUS_EXIT_LAST_12_MON								INT,
			BKI_CNT_REQ_LAST_180_DAY									INT,
			HIST_CNT_MON_FIRST_CRED										INT,
			BKI_CNT_OPEN_CRED_LAST_3_MON								INT,
			APP_WORK_EXP												VARCHAR(20),
			HIST_RATIO_CURR_SALDO_TO_CRED_AMT							MONEY,
			APP_FIELD_OF_ACTIVITY										INT,

			FL_BNK_HIST													BIT,
			FL_MFO_LAST_3_MON											BIT
		);
	DECLARE @PARAMS_PROD
		TABLE (
			
			ROWID							INT,
			IDENTCODE						VARCHAR(20),
			isMBKI							INT,
			PARAMCODE						VARCHAR(100),
			PARAMVALUE						FLOAT,
			PARAMVALUESTRING				VARCHAR(255)
		);

	DECLARE @STARTCALC			DATETIME	=	GETDATE();
	DECLARE @ROWID	INT			=	@aROWID;
	DECLARE @DATE	DATETIME	=	@aDATE;

	DECLARE	@BKI_CNT_ACTV_BANK_CRED_LAST_2_YEAR								INT;
	DECLARE	@BKI_CNT_PREMATURELY_CLSD_CRED									INT;
	DECLARE	@BKI_CNT_MON_FROM_FIRST_CRED									INT;
	DECLARE @BKI_CNT_REQ_LAST_90_DAY										INT;
	DECLARE @BKI_CNT_MFO_REQ_LAST_MON										INT;
	DECLARE @BKI_CNT_MON_TO_LAST_BANK_CRED									INT;
	DECLARE @BKI_CNT_REQ_LAST_180_DAY										INT;
	DECLARE @BKI_CNT_OPEN_CRED_LAST_3_MON									INT;

	DECLARE @BKI_MAX_CRED_AMT_EVR											MONEY;
	DECLARE	@BKI_CNT_OVD_CRED_NOW											INT;
	DECLARE @BKI_MAX_PD_LAST_12_MON											MONEY;
	DECLARE @BKI_MAX_PD_LAST_6_MON											MONEY;
	DECLARE @BKI_CNT_1PLUS_EXIT_LAST_12_MON									INT;

	DECLARE @INN															VARCHAR(20);
	DECLARE @APP_MARITAL_STATUS_SEX											VARCHAR(50);
	DECLARE @APP_MARITAL_STATUS												VARCHAR(50);
	DECLARE @APP_WORK_EXP													VARCHAR(20);
	DECLARE @APP_FIELD_OF_ACTIVITY											INT;

	DECLARE @BKI_MAX_DPD_EVR												INT;
	DECLARE @BKI_MIN_CNT_DAY_TO_200_PD										INT;
	DECLARE @BKI_CNT_PREMATURELY_CLSD_BANK_CRED								INT;
	DECLARE @BKI_CNT_IN_TIME_CLSD_CRED										INT;

	DECLARE @HIST_MAX_DPD_LAST_24_MON										INT;
	DECLARE @HIST_RATIO_AVG_SALDO_LAST_3_MON_TO_AVG_SALDO_PREV_3_MON		MONEY;
	DECLARE @HIST_RATIO_CUR_SALDO_TO_CUR_LIM								MONEY;
	DECLARE @HIST_CNT_MON_FIRST_CRED										INT;
	DECLARE @HIST_RATIO_CURR_SALDO_TO_CRED_AMT								MONEY;

	DECLARE @FL_MFO_LAST_3_MON												BIT;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	допоміжні змінні
	--	
	DECLARE @HIST_PARAMS	TABLE
								(
									MAX_DPD_LAST_24_MON										INT,
									RATIO_AVG_SALDO_LAST_3_MON_TO_AVG_SALDO_PREV_3_MON		MONEY,
									RATIO_CUR_SALDO_TO_CUR_LIM								MONEY,
									CNT_MON_FIRST_CRED										INT,
									RATIO_CURR_SALDO_TO_CRED_AMT							MONEY
								);
	DECLARE @FROMDATE		VARCHAR(8);
	DECLARE @TILLDATE		VARCHAR(8);
	DECLARE @SQL			VARCHAR(MAX);
	DECLARE @SQL_OPENQUERY	VARCHAR(MAX);
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	ВИДАЛЯЄМО ІСНУЮЧІ ДАНІ
	--	
	IF @aDEBUG = 0
	BEGIN

		DELETE	
		FROM	[Decision].[dbo].[ScoringBKIDetail]
		WHERE	ROWID = @ROWID
				AND IsMbki = 777;

	END;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	INN
	--
	SELECT	@INN = T1.Info
	FROM	[Decision].dbo.ConnotationValues T1
	INNER JOIN [Decision].dbo.ConnotationList T2 ON T2.ID = T1.Kind
	WHERE	T1.OWNERID = @ROWID
			AND T1.KIND = 804;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	BKI_CNT_ACTV_BANK_CRED_LAST_2_YEAR
	--
	SELECT	@BKI_CNT_ACTV_BANK_CRED_LAST_2_YEAR =
				COUNT	(
							distinct
							convert(varchar(max),convert(date,begindate))+convert(varchar(max),credamount)
						)
	FROM	(
				SELECT	a1.rowid								AS	ROWID,
						[startDate]								AS	BEGINDATE,
						[expectedEndDate]						AS	EXCLOSEDATE,
						[factualEndDate]						AS	CLOSEDATE,
						ISNULL([totalAmount], [creditLimit])	AS	CREDAMOUNT
				FROM	[Decision].[dbo].[CreditBur7_Subject] a1
				left join [Decision].[dbo].[CreditBur7_Contract] a on a1.Id = a.SubjectId
				WHERE	a1.rowid = @ROWID
						AND ISNULL([totalAmount], [creditLimit]) > 50
						and CASE WHEN isnull(ISNULL([totalAmount], [creditLimit]), 0) BETWEEN 50 AND 10000 AND DATEDIFF(dd, [startDate] , [expectedEndDate]) <= 60 THEN 1
								ELSE 0
							END = 0
						and (
								[factualEndDate] is null or
								[factualEndDate] between DATEADD(mm,-24,@date) and @date
							)

				UNION ALL

				SELECT	U.ROWID,
						m.[dlds] AS begindate,
						ISNULL(m.dldpf,'19000101') AS exclosedate,
						CASE WHEN m.dldff = '1900-01-01 00:00:00.000' THEN NULL
							ELSE m.dldff
						END AS closedate,
						u1.dlamt
				FROM	[Decision].[dbo].[CreditBur3_comp] u
				LEFT JOIN [Decision].[dbo].[CreditBur3_crdeal] u1 ON u.Id = u1.compId
				INNER JOIN	(

								SELECT	T3.*,
										ROW_NUMBER() OVER (PARTITION BY T1.ROWID, T2.ID ORDER BY CAST(T3.DLYEAR AS VARCHAR(4))+RIGHT('00'+CAST(T3.DLMONTH AS VARCHAR(2)),2) DESC, T3.ID DESC)		AS	RN
								FROM	[Decision].[dbo].[CreditBur3_comp] T1
								INNER JOIN [Decision].dbo.CreditBur3_crdeal T2 ON T2.compId = T1.ID
								INNER JOIN [Decision].dbo.CreditBur3_deallife T3 ON T3.crdealId = T2.Id
								WHERE	T1.RowId = @ROWID

							) m ON M.crdealId = U1.Id
								--AND fl_last = 1
								AND M.RN = 1
								AND u.rowid = @ROWID
								and	CASE WHEN isnull(dlamt, 0) BETWEEN 50 AND 10000 AND DATEDIFF(dd, m.[dlds], isnull(m.dldpf,'19000101')) <= 60 THEN 1
										ELSE 0
									END = 0
								AND u1.dlamt > 50
								and (
										CASE	WHEN m.dldff = '1900-01-01 00:00:00.000'
												THEN NULL
												ELSE m.dldff
										END is null or
										CASE WHEN m.dldff = '1900-01-01 00:00:00.000' THEN NULL
											ELSE m.dldff
										END between DATEADD(mm,-24,@date) and @date
									)
			) V1
	GROUP BY V1.ROWID;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	BKI_CNT_PREMATURELY_CLSD_CRED
	--
	select	@BKI_CNT_PREMATURELY_CLSD_CRED =
				COUNT	(
							distinct
							convert(varchar(max),convert(date,begindate))	+ convert(varchar(max),convert(date,exclosedate))+ convert(varchar(max),credamount)
						)
	from	(
				SELECT	a1.rowid								AS	ROWID,
						[startDate]								AS	begindate,
						[expectedEndDate]						AS	exclosedate,
						[factualEndDate]						AS	closedate,
						ISNULL([totalAmount], [creditLimit])	AS	credamount
				FROM	[Decision].[dbo].[CreditBur7_Subject] a1
				left join [Decision].[dbo].[CreditBur7_Contract] a on a1.Id = a.SubjectId
				WHERE	a1.rowid = @ROWID AND
						ISNULL([totalAmount], [creditLimit]) > 0
						and	CASE WHEN isnull(ISNULL([totalAmount], [creditLimit]), 0) BETWEEN 50 AND 10000 AND DATEDIFF(dd, [startDate] , [expectedEndDate]) <= 60 THEN 1
								ELSE 0
							END	= 0
						and factualEndDate < DATEADD(d, -30, expectedEndDate)

				UNION ALL

				SELECT	U.ROWID,
						m.[dlds] AS begindate,
						ISNULL(m.dldpf,'19000101') AS exclosedate,
						CASE
							WHEN m.dldff = convert(datetime,'1900-01-01 00:00:00.000')
							THEN NULL
							ELSE m.dldff
						END AS closedate,
						u1.dlamt
				FROM	[Decision].[dbo].[CreditBur3_comp] u
				LEFT JOIN [Decision].[dbo].[CreditBur3_crdeal] u1 ON u.Id = u1.compId
				INNER JOIN	(

								SELECT	T3.*,
										ROW_NUMBER() OVER (PARTITION BY T1.ROWID, T2.ID ORDER BY CAST(T3.DLYEAR AS VARCHAR(4))+RIGHT('00'+CAST(T3.DLMONTH AS VARCHAR(2)),2) DESC, T3.ID DESC)		AS	RN
								FROM	[Decision].[dbo].[CreditBur3_comp] T1
								INNER JOIN [Decision].dbo.CreditBur3_crdeal T2 ON T2.compId = T1.ID
								INNER JOIN [Decision].dbo.CreditBur3_deallife T3 ON T3.crdealId = T2.Id
								WHERE	T1.RowId = @ROWID

							) m ON M.crdealId = U1.Id
								AND M.RN = 1
								AND u.rowid = @ROWID
								and	CASE WHEN isnull(dlamt, 0) BETWEEN 50 AND 10000 AND DATEDIFF(dd, convert(datetime,m.[dlds]), convert(datetime, ISNULL(m.dldpf,'19000101'))) <= 60 THEN 1
										ELSE 0
									END = 0
								AND u1.dlamt > 0
								and	CASE WHEN m.dldff = convert(datetime,'1900-01-01 00:00:00.000') THEN NULL
										ELSE m.dldff
									END < DATEADD(d, -30, convert(datetime, ISNULL(m.dldpf, '19000101')))

		  ) m
	group by m.rowid;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	BKI_CNT_MON_FROM_FIRST_CRED
	--
	SELECT	TOP 1
			@BKI_CNT_MON_FROM_FIRST_CRED = DATEDIFF(mm, begindate, @date)
	FROM	(
				SELECT	a1.rowid,
						[startDate] AS begindate,
						[expectedEndDate] AS exclosedate,
						[factualEndDate] AS closedate,
						ISNULL([totalAmount], [creditLimit]) AS credamount
				FROM	[Decision].[dbo].[CreditBur7_Subject] a1
				LEFT JOIN [Decision].[dbo].[CreditBur7_Contract] a on a1.Id = a.SubjectId
				WHERE	a1.rowid = @ROWID

				UNION ALL

				SELECT	U.ROWID,
						m.[dlds] AS begindate,
						ISNULL(m.dldpf,'19000101') AS exclosedate,
						CASE
							WHEN m.dldff = '1900-01-01 00:00:00.000'
							THEN NULL
							ELSE m.dldff
						END AS closedate,
						u1.dlamt
				FROM	[Decision].[dbo].[CreditBur3_comp] U
				LEFT JOIN [Decision].[dbo].[CreditBur3_crdeal] u1 ON u.Id = u1.compId
				INNER JOIN (

								SELECT	T3.*,
										ROW_NUMBER() OVER (PARTITION BY T1.ROWID, T2.ID ORDER BY CAST(T3.DLYEAR AS VARCHAR(4))+RIGHT('00'+CAST(T3.DLMONTH AS VARCHAR(2)),2) DESC, T3.ID DESC)		AS	RN
								FROM	[Decision].[dbo].[CreditBur3_comp] T1
								INNER JOIN [Decision].dbo.CreditBur3_crdeal T2 ON T2.compId = T1.ID
								INNER JOIN [Decision].dbo.CreditBur3_deallife T3 ON T3.crdealId = T2.Id
								WHERE	T1.RowId = @ROWID

							) m ON M.crdealId = U1.Id
								AND M.RN = 1
								AND u.rowid = @ROWID
			) m
	WHERE	M.begindate IS NOT NULL
	ORDER BY begindate ASC;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	BKI_CNT_REQ_LAST_90_DAY
	--
	SELECT	@BKI_CNT_REQ_LAST_90_DAY =
				case when g.rowid is null then null
					else count(h2.redate)
				end
	FROM	(
				select @ROWID as rowid
			) t
	OUTER APPLY	(
					select	top 1
							h.rowid
					from	(
								SELECT	a.rowid,
										a1.[when_EVENT] AS redate
								FROM	[Decision].[dbo].[CreditBur7_Subject] a
								INNER JOIN [Decision].[dbo].[CreditBur7_Event] a1	ON A1.SubjectId = A.ID
																			AND event = 'request'
																			AND a.rowid IN (@ROWID)

								UNION all

								SELECT	u.rowid,
										u1.redate as redate
								FROM	[Decision].[dbo].[CreditBur3_comp] u
								INNER JOIN [Decision].[dbo].[CreditBur3_credres] u1 ON U1.compId = U.Id
								WHERE	u.rowid IN(@ROWID)
							) h
				) g
	LEFT JOIN	(
					SELECT	a.rowid,
							a1.[when_EVENT] AS redate
					FROM	[Decision].[dbo].[CreditBur7_Subject] a
					INNER JOIN [Decision].[dbo].[CreditBur7_Event] a1 ON A1.SubjectId = A.Id
																AND event = 'request'
																AND a.rowid IN (@ROWID)
					UNION all

					SELECT	u.rowid,
							u1.redate as redate
					FROM	[Decision].[dbo].[CreditBur3_comp] u
					INNER JOIN [Decision].[dbo].[CreditBur3_credres] u1 ON U1.compId = U.ID
					WHERE u.rowid IN (@ROWID)
				) h2 on h2.rowid = t.rowid
						and DATEDIFF(dd, h2.redate, CONVERT(DATETIME, CONVERT(DATE, @DATE))) <= 90
	GROUP BY t.rowid,
			g.rowid;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	BKI_CNT_MFO_REQ_LAST_MON
	--
	SELECT	@BKI_CNT_MFO_REQ_LAST_MON = case when u.rowid is null then null else count(h.compId) end
	FROM	[Decision].[dbo].[CreditBur3_comp] u
	OUTER APPLY	(
					SELECT	TOP 100
							*
					FROM	[Decision].[dbo].[CreditBur3_credres] u1
					WHERE	u.Id = u1.compId
							and DATEDIFF(d,redate, @date) <= 30
							and org in ('MFO')
					ORDER BY redate DESC
				) h
	WHERE	u.rowid = @rowid
	GROUP BY u.rowid;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	BKI_CNT_MON_TO_LAST_BANK_CRED
	--
	SELECT	top 1
			@BKI_CNT_MON_TO_LAST_BANK_CRED = COALESCE(DATEDIFF(month, h.dlds,@date), -1)
	FROM	[Decision].[dbo].[CreditBur3_comp] u
	OUTER APPLY	(
					SELECT	TOP 10
							u1.dlref,
							m.[dlds],
							u1.dldonor
					FROM	[Decision].[dbo].[CreditBur3_crdeal] u1
					OUTER APPLY	(
									SELECT	TOP 1
											[dlref],
											[dlds]
									FROM	[Decision].[dbo].[CreditBur3_deallife] tt
									WHERE	tt.crdealId = u1.id
								) m
					WHERE u1.compId = u.Id
					ORDER BY m.dlds DESC
				) h
	WHERE	h.dldonor NOT IN ('MFO', 'FIN')
			AND u.rowid = @ROWID
	ORDER BY h.dlds desc;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	BKI_CNT_REQ_LAST_180_DAY
	--
	SELECT	@BKI_CNT_REQ_LAST_180_DAY =
				case when g.rowid is null then null
					else count(h2.redate)
				end
	FROM	(
				select @ROWID as rowid
			) t
	outer apply	(
					select	top 1
							h.rowid
					from	(
								SELECT	a.rowid,
										a1.[when_Event] AS redate
								FROM	[Decision].[dbo].[CreditBur7_Subject] a
								INNER JOIN [Decision].[dbo].[CreditBur7_Event] a1 ON A1.SubjectId = A.Id
																			AND event = 'request'
																			AND a.rowid IN (@ROWID)

								UNION all

								SELECT	u.rowid,
										u1.redate as redate
								FROM	[Decision].[dbo].[CreditBur3_comp] u
								INNER JOIN [Decision].[dbo].[CreditBur3_credres] u1 ON u1.compId = U.Id
								WHERE	u.rowid IN (@ROWID)
							) h
				) g
	left join	(
					SELECT	a.rowid,
							a1.[when_Event] AS redate
					FROM	[Decision].[dbo].[CreditBur7_Subject] a
					INNER JOIN [Decision].[dbo].[CreditBur7_Event] a1 ON A1.SubjectId = A.Id
																AND event = 'request'
																AND a.rowid IN (@ROWID)

					UNION all

					SELECT	u.rowid,
							u1.redate	as redate
					FROM	[Decision].[dbo].[CreditBur3_comp] u
					INNER JOIN [Decision].[dbo].[CreditBur3_credres] u1 ON u1.compId = U.Id
					WHERE	u.rowid IN (@ROWID)
				 ) h2 on h2.rowid = t.rowid
						and DATEDIFF(dd, h2.redate, CONVERT(DATETIME, CONVERT(DATE, @DATE))) <= 180
	group by t.rowid,
			g.rowid;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	BKI_CNT_OPEN_CRED_LAST_3_MON
	--
	select	@BKI_CNT_OPEN_CRED_LAST_3_MON = count(distinct convert(varchar(max),convert(date,begindate))+ convert(varchar(max),convert(date,exclosedate))+ convert(varchar(max),credamount))
	from	(
				SELECT	a1.rowid,
						[startDate] AS begindate,
						[expectedEndDate] AS exclosedate,
						[factualEndDate] AS closedate,
						ISNULL([totalAmount], [creditLimit]) AS credamount
				FROM	[Decision].[dbo].[CreditBur7_Subject] a1
				LEFT JOIN [Decision].[dbo].[CreditBur7_Contract] a on A.SubjectId = A1.Id
				WHERE	a1.rowid = @ROWID
						AND ISNULL([totalAmount], [creditLimit]) > 0
						and datediff(dd,[startDate],convert(datetime,convert(date,@date))) <= 90

				UNION ALL

				SELECT	U.ROWID,
						m.[dlds] AS begindate,
						ISNULL(m.dldpf,'19000101') AS exclosedate,
						CASE WHEN m.dldff = '1900-01-01 00:00:00.000' THEN NULL
							ELSE m.dldff
						END AS closedate,
						u1.dlamt
				FROM	[Decision].[dbo].[CreditBur3_comp] u
				LEFT JOIN [Decision].[dbo].[CreditBur3_crdeal] u1 ON u1.compId = u.Id
				INNER JOIN	(
								SELECT	T3.*,
										ROW_NUMBER() OVER (PARTITION BY T1.ROWID, T2.ID ORDER BY CAST(T3.DLYEAR AS VARCHAR(4))+RIGHT('00'+CAST(T3.DLMONTH AS VARCHAR(2)),2) DESC, T3.ID DESC)		AS	RN
								FROM	[Decision].[dbo].[CreditBur3_comp] T1
								INNER JOIN [Decision].dbo.CreditBur3_crdeal T2 ON T2.compId = T1.ID
								INNER JOIN [Decision].dbo.CreditBur3_deallife T3 ON T3.crdealId = T2.Id
								WHERE	T1.RowId = @ROWID
							) m ON m.crdealId = u1.Id
								and m.RN = 1
								AND u.rowid = @ROWID
								AND u1.dlamt > 0
								AND DATEDIFF(dd,m.[dlds],convert(datetime,convert(date,@date))) <= 90
			) m
	group by m.rowid;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	BKI_MAX_CRED_AMT_EVR
	--
	SELECT	@BKI_MAX_CRED_AMT_EVR = MAX(V1.CREDAMT)
	FROM	(
				SELECT	T3.dlamtlim	AS	CREDAMT
				FROM	[Decision].[dbo].[CreditBur3_comp] T1
				INNER JOIN [Decision].[dbo].[CreditBur3_crdeal] T2 ON T2.compId = T1.Id
				INNER JOIN [Decision].[dbo].[CreditBur3_deallife] T3 ON T3.crdealId = T2.Id
				WHERE	T1.RowId = @ROWID

				UNION ALL

				SELECT	ISNULL(T2.totalAmount,T2.creditLimit)	AS	CREDAMT
				FROM	[Decision].[dbo].[CreditBur7_Subject] T1
				INNER JOIN [Decision].[dbo].[CreditBur7_Contract] T2 ON T2.SubjectId = T1.ID
				WHERE	T1.RowId = @ROWID
			) V1;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	BKI_CNT_OVD_CRED_NOW
	--
	SELECT	@BKI_CNT_OVD_CRED_NOW = COUNT(*)
	FROM	(
				SELECT	V3.dlamtexp			AS	OVERDUE_AMT
				FROM	[Decision].[dbo].[CreditBur3_comp] T1
				INNER JOIN [Decision].[dbo].[CreditBur3_crdeal] T2 ON T2.compId = T1.Id
				INNER JOIN	(
								SELECT	T3.*,
										ROW_NUMBER() OVER (PARTITION BY T1.ROWID, T2.ID ORDER BY CAST(T3.DLYEAR AS VARCHAR(4))+RIGHT('00'+CAST(T3.DLMONTH AS VARCHAR(2)),2) DESC, T3.ID DESC)		AS	RN
								FROM	[Decision].[dbo].[CreditBur3_comp] T1
								INNER JOIN [Decision].dbo.CreditBur3_crdeal T2 ON T2.compId = T1.ID
								INNER JOIN [Decision].dbo.CreditBur3_deallife T3 ON T3.crdealId = T2.Id
								WHERE	T1.RowId = @ROWID
							) V3 ON V3.crdealId = T2.Id
									AND V3.RN = 1
				WHERE	T1.ROWID = @ROWID
						AND V3.dlamtexp > 0

				UNION ALL

				SELECT	T2.overdueAmount	AS	OVERDUE_AMT
				FROM	[Decision].[dbo].[CreditBur7_Subject] T1
				INNER JOIN [Decision].[dbo].[CreditBur7_Contract] T2 ON T2.SubjectId = T1.Id
				WHERE	T1.ROWID = @ROWID
						AND T2.overdueAmount > 0
			) V1;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	BKI_MAX_PD_LAST_12_MON, BKI_MAX_PD_LAST_6_MON, BKI_CNT_1PLUS_EXIT_LAST_12_MON
	--
	;WITH CTE AS
		(
			select	@ROWID								AS	ROWID,
					v1.CodeOfContract					as	CodeOfContract,
					cast(cast(v1.YYYY as char(4))+right('00'+cast(v1.mm as varchar(2)), 2)+'01' as date)	as	ArcDate,
					v1.YYYY								as	YYYY,
					v1.MM								as	MM,
					cast(min(v1.MinBeginDate) as date)	as	BeginDate,
					max(v1.PD_SALDO)					as	pd_saldo,
					max(v1.dpd)							as	dpd,
					max(v1.pd_payment)					as	pd_payment
			from	(
						select	v1.*,
								cast(v1.fl_limit as char(1)) + '^' +
									cast(v1.Currency as char(3)) + '^' +
									convert(varchar(10), v1.MinBeginDate, 112) + '^' +
									case when v1.fl_limit = 1 then ''
										else convert(varchar(100), v1.MaxCredAmt)
									end + '^'			as	CodeOfContract
						from	(
									select	t1.RowId															as	RowId,
											t1.Id																as	CompId,
											t2.Id																as	CredId,
											t3.Id																as	CredHistId,
											t2.dlcurr															as	Currency,
											case when t2.dlcelcredref in ('Кредитная карта') then 1
												else 0
											end																	as	fl_limit,
											--t2.dlcelcredref,
											--t2.dlcelcred,
											cast(t3.dlds as date)												as	BeginDate,
											cast(min(t3.dlds) over(partition by t1.rowid,t2.id) as date)		as	MinBeginDate,
											t3.dlamtlim															as	CredAmt,
											max(t3.dlamtlim) over(partition by t1.rowid,t2.id)					as	MaxCredAmt,
											t3.dlyear															as	YYYY,
											t3.dlmonth															as	MM,
											t3.dlamtexp															as	PD_SALDO,
											t3.dldayexp															as	DPD,
											null																as	PD_PAYMENT
									from	[Decision].[dbo].[CreditBur3_comp] t1
									inner join [Decision].[dbo].[CreditBur3_crdeal] t2 on t2.compid = t1.id
									inner join [Decision].[dbo].[CreditBur3_deallife] t3 on t3.crdealid = t2.id
									where	t1.rowid = @rowid
								) v1
						union all
						select	v1.*,
								cast(v1.fl_limit as char(1)) + '^' +
									cast(v1.Currency as char(3)) + '^' +
									convert(varchar(10), v1.MinBeginDate, 112) + '^' +
									case when v1.fl_limit = 1 then ''
										else convert(varchar(100), v1.MaxCredAmt)
									end + '^'			as	CodeOfContract
						from	(
									select	t1.RowId											as	RowId,
											t1.Id												as	SubjectId,
											t2.Id												as	CredId,
											t3.Id												as	CredHistId,
											isnull(case when t2.currency = 'USD' then 840
														when t2.currency = 'EUR' then 978
														else 980
													end,980)							as	Currency,
											case when t2.type in ('credit','nonInstalment') then 1
												else 0
											end													as	fl_limit,
											t2.startDate										as	BeginDate,
											t2.startDate										as	MinBeginDate,
											ROUND((isnull(t2.totalAmount,t2.creditLimit)),2)	as	CredAmt,
											ROUND((isnull(t2.totalAmount,t2.creditLimit)),2)	as	MaxCredAmt,
											YEAR(t3.accountingDate)								as	YYYY,
											MONTH(t3.accountingDate)							as	MM,
											t3.overdueAmount									AS	PD_SALDO,
											null												as	DPD,
											t3.overdueCount										AS	PD_PAYMENT
									from	[Decision].[dbo].[CreditBur7_Subject] t1
									inner join [Decision].[dbo].[CreditBur7_Contract] t2 on t2.SubjectId = t1.id
									left join [Decision].[dbo].[CreditBur7_Record] t3 on t3.SubjectId = t1.id
																			and t3.contractid = t2.contractid
									where	t1.RowId = @rowid
								) v1
					where	datediff(month, cast(cast(v1.YYYY as char(4))+right('00'+cast(v1.mm as varchar(2)), 2)+'01' as date), @date) <= 18
					) v1
			group by v1.CodeOfContract,
					v1.YYYY,
					v1.MM
		)
	SELECT	@BKI_MAX_PD_LAST_12_MON = MAX(CASE WHEN DATEDIFF(MONTH, T1.ArcDate, @DATE) <= 12 THEN T1.PD_SALDO ELSE NULL END),
			@BKI_MAX_PD_LAST_6_MON = MAX(CASE WHEN DATEDIFF(MONTH, T1.ArcDate, @DATE) <= 6 THEN T1.PD_SALDO ELSE NULL END),
			@BKI_CNT_1PLUS_EXIT_LAST_12_MON = SUM(	CASE WHEN DATEDIFF(MONTH, T1.ArcDate, @DATE) <= 12
															THEN CASE WHEN T1.RN > 1 AND (ISNULL(convert(int, T1.pd_saldo),0) > 0 /*OR ISNULL(T1.dpd,0) > 0 OR ISNULL(T1.pd_payment,0) > 0*/) AND ISNULL(T2.pd_saldo,0) = 0 /*AND ISNULL(T2.DPD,0) = 0 AND ISNULL(T2.pd_payment,0) = 0*/ THEN 1 ELSE 0 END +
																CASE WHEN T1.RN = 1 and (ISNULL(T1.pd_saldo,0) > 0 /*OR ISNULL(T1.dpd,0) > 0 OR ISNULL(T1.pd_payment,0) > 0*/) /*and (ISNULL(T2.pd_saldo,0) > 0 OR ISNULL(T2.DPD,0) > 0 OR ISNULL(T2.pd_payment,0) > 0)*/ then 1 else 0 end
														ELSE NULL
													END)
	FROM	(
				SELECT	T1.*,
						ROW_NUMBER() OVER(PARTITION BY T1.CODEOFCONTRACT ORDER BY T1.ARCDATE)	AS	RN
				FROM	CTE T1
				WHERE	DATEDIFF(MONTH, T1.ArcDate, @DATE) <= 12
			) T1
	LEFT JOIN	(
					SELECT	T1.*,
							ROW_NUMBER() OVER(PARTITION BY T1.CODEOFCONTRACT ORDER BY T1.ARCDATE)	AS	RN
					FROM	CTE T1
					WHERE	DATEDIFF(MONTH, T1.ArcDate, @DATE) <= 12
				) T2 ON T2.CodeOfContract = T1.CodeOfContract
						--AND T2.ArcDate = DATEADD(MONTH, -1, T1.ARCDATE);
						AND T2.RN = T1.RN-1;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	BKI_MAX_DPD_EVR, BKI_MIN_CNT_DAY_TO_200_PD, BKI_CNT_PREMATURELY_CLSD_BANK_CRED, BKI_CNT_IN_TIME_CLSD_CRED
	--
	;WITH CTE AS
		(
			select	@ROWID								AS	ROWID,
					v1.CodeOfContract					as	CodeOfContract,
					cast(cast(v1.YYYY as char(4))+right('00'+cast(v1.mm as varchar(2)), 2)+'01' as date)	as	ArcDate,
					v1.YYYY								as	YYYY,
					v1.MM								as	MM,
					cast(min(v1.MinBeginDate) as date)	as	BeginDate,
					max(v1.PD_SALDO)					as	pd_saldo,
					max(v1.dpd)							as	dpd,
					max(v1.pd_payment)					as	pd_payment,
					MIN(V1.fl_limit)					AS	FL_LIMIT,
					MAX(V1.CredAmt)						AS	CREDAMT,
					min(v1.CloseDate)					as	CloseDate,
					MAX(case when v1.ExpectedCloseDate = '19000101' then null
							else v1.ExpectedCloseDate
						end)							as	ExpectedCloseDate
			from	(
						select	v1.*,
								cast(v1.fl_limit as char(1)) + '^' +
									cast(v1.Currency as char(3)) + '^' +
									convert(varchar(10), v1.MinBeginDate, 112) + '^' +
									case when v1.fl_limit = 1 then ''
										else convert(varchar(100), v1.MaxCredAmt)
									end + '^'			as	CodeOfContract
						from	(
									select	t1.RowId															as	RowId,
											t1.Id																as	CompId,
											t2.Id																as	CredId,
											t3.Id																as	CredHistId,
											t2.dlcurr															as	Currency,
											case when t2.dlcelcredref in ('Кредитная карта') then 1
												else 0
											end																	as	fl_limit,
											cast(t3.dlds as date)												as	BeginDate,
											cast(min(t3.dlds) over(partition by t1.rowid,t2.id) as date)		as	MinBeginDate,
											t3.dlamtlim															as	CredAmt,
											max(t3.dlamtlim) over(partition by t1.rowid,t2.id)					as	MaxCredAmt,
											t3.dlyear															as	YYYY,
											t3.dlmonth															as	MM,
											t3.dlamtexp															as	PD_SALDO,
											t3.dldayexp															as	DPD,
											null																as	PD_PAYMENT,
											case when T3.dldff = '19000101' then null
												else t3.dldff
											end																	as	CloseDate,
											max(t3.dldpf) over(partition by t2.id)								as	ExpectedCloseDate
									from	[Decision].[dbo].[CreditBur3_comp] t1
									inner join [Decision].[dbo].[CreditBur3_crdeal] t2 on t2.compid = t1.id
									inner join [Decision].[dbo].[CreditBur3_deallife] t3 on t3.crdealid = t2.id
									where	t1.rowid = @rowid
								) v1
						union all
						select	v1.*,
								cast(v1.fl_limit as char(1)) + '^' +
									cast(v1.Currency as char(3)) + '^' +
									convert(varchar(10), v1.MinBeginDate, 112) + '^' +
									case when v1.fl_limit = 1 then ''
										else convert(varchar(100), v1.MaxCredAmt)
									end + '^'			as	CodeOfContract
						from	(
									select	t1.RowId											as	RowId,
											t1.Id												as	SubjectId,
											t2.Id												as	CredId,
											t3.Id												as	CredHistId,
											isnull(case when t2.currency = 'USD' then 840
														when t2.currency = 'EUR' then 978
														else 980
													end,980)							as	Currency,
											case when t2.type in ('credit','nonInstalment') then 1
												else 0
											end													as	fl_limit,
											t2.startDate										as	BeginDate,
											t2.startDate										as	MinBeginDate,
											ROUND((isnull(t2.totalAmount,t2.creditLimit)),2)	as	CredAmt,
											ROUND((isnull(t2.totalAmount,t2.creditLimit)),2)	as	MaxCredAmt,
											YEAR(t3.accountingDate)								as	YYYY,
											MONTH(t3.accountingDate)							as	MM,
											t3.overdueAmount									AS	PD_SALDO,
											null												as	DPD,
											t3.overdueCount										AS	PD_PAYMENT,
											t2.factualEndDate									as	CloseDate,
											t2.expectedEndDate									as	ExpectedCloseDate
									from	[Decision].[dbo].[CreditBur7_Subject] t1
									inner join [Decision].[dbo].[CreditBur7_Contract] t2 on t2.SubjectId = t1.id
									left join [Decision].[dbo].[CreditBur7_Record] t3 on t3.SubjectId = t1.id
																			and t3.contractid = t2.contractid
									where	t1.RowId = @rowid
								) v1
					) v1
			group by v1.CodeOfContract,
					v1.YYYY,
					v1.MM
		)
	SELECT	@BKI_MAX_DPD_EVR =
				ISNULL	(
							CASE WHEN MAX(V1.MAXCREDAMT) > 0 AND MAX(V1.pd_payment) IS NULL AND MAX(V1.DPD) IS NULL THEN NULL
								ELSE
										MAX	(
														(
															CASE WHEN V1.MAXCREDAMT > 0 THEN
																	CASE WHEN ISNULL(V1.pd_payment,0)*30 > ISNULL(V1.DPD,0) THEN ISNULL(V1.pd_payment,0)*30
																		ELSE ISNULL(V1.DPD,0)
																	END
															END
														)
											)
							END,
							-1
						),
			@BKI_MIN_CNT_DAY_TO_200_PD =
				ISNULL	(
							MIN	(
									CASE WHEN V1.pd_saldo > 200 THEN DATEDIFF(DAY, V1.BeginDate, V1.ArcDate)
										ELSE NULL
									END
								)
							,999999
						),
			@BKI_CNT_PREMATURELY_CLSD_BANK_CRED =
				COUNT(DISTINCT CASE WHEN V1.FL_LIMIT = 0 AND V1.MaxCredAmt > 0 AND V1.MinCloseDate < DATEADD(DAY, -31, V1.MaxExpectedCloseDate) THEN V1.CodeOfContract ELSE NULL END),
			@BKI_CNT_IN_TIME_CLSD_CRED =
				ISNULL	(
							COUNT(DISTINCT CASE WHEN V1.FL_LIMIT = 0 AND V1.MaxCredAmt > 0 AND V1.MinCloseDate BETWEEN DATEADD(DAY, -31, V1.MaxExpectedCloseDate) AND DATEADD(DAY, 31, V1.MaxExpectedCloseDate) THEN V1.CodeOfContract ELSE NULL END),
							-1
						)
	FROM	(
				SELECT	T1.*,
						min(t1.CloseDate)	over(partition by t1.codeofcontract)		as	MinCloseDate,
						max(t1.CREDAMT) over(partition by t1.codeofcontract)			as	MaxCredAmt,
						max(t1.ExpectedCloseDate) over(partition by t1.codeofcontract)	as	MaxExpectedCloseDate
				FROM	CTE T1
				--WHERE	DATEDIFF(MONTH, T1.ArcDate, @DATE) <= 12
			) V1
	GROUP BY V1.ROWID;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	APP_MARITAL_STATUS_SEX
	--
	SELECT	@APP_MARITAL_STATUS_SEX =
				CASE WHEN SEX = 'F' AND marital_status_g = 'married' THEN 'married_F'
					WHEN SEX = 'M' AND marital_status_g = 'married' THEN 'married_M'
					WHEN SEX = 'F' AND marital_status_g = 'else' THEN 'NOTmarried_F'
					ELSE 'NOTmarried_M'
				END
    FROM	(
				SELECT CASE WHEN info IN('одружений (замiжня)', 'Одружений') THEN 'married'
							ELSE 'else'
						END			AS marital_status_g,
						CASE WHEN SUBSTRING(@INN, 9, 1) IN('0', '2', '4', '6', '8') THEN 'F'
							ELSE 'M'
						END			AS	SEX
				FROM	[Decision].dbo.[ConnotationValues](nolock)
				WHERE	ownerid = @ROWID
						AND Kind = 876
			) V1;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	APP_MARITAL_STATUS
	--
	SELECT	@APP_MARITAL_STATUS =
				CASE WHEN info IN('одружений (замiжня)', 'Одружений') THEN 'married'
					ELSE 'else'
				END
	FROM	[Decision].dbo.[ConnotationValues]
	WHERE	ownerid = @ROWID
			AND Kind = 876;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	APP_WORK_EXP
	--
	SELECT  @APP_WORK_EXP = info
	FROM	[Decision].dbo.[ConnotationValues]
	WHERE	ownerid = @ROWID
			AND Kind = 2566;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	APP_FIELD_OF_ACTIVITY
	--
	SELECT	@APP_FIELD_OF_ACTIVITY =
				CASE WHEN l.SO='СО' or (Group_field_of_activity in ('Будівництво/Ремонт')and GROUP_POSITION<>'Підприємець') THEN 1
					WHEN Group_field_of_activity IN('Пенсіонери') and GROUP_POSITION<>'Підприємець' THEN 2
					WHEN Group_field_of_activity IN('Послуги/Обслуговування/Виробництво', 'Збройні сили/Прикордонники/МВС/СБУ/ДПІ/Органи влади/Охорона') and GROUP_POSITION<>'Підприємець' THEN 3
					WHEN Group_field_of_activity is null THEN null
					ELSE 4
				END
	FROM	(
				SELECT	h.ownerid,
						a.info AS info_1,
						b.info AS info_2,
						b1.info as SO
				FROM	(
							SELECT	TOP 1
									ownerid
							FROM	[Decision].dbo.[ConnotationValues] a(nolock)
							WHERE	ownerid = @ROWID
						) h
				LEFT JOIN	(
								SELECT  ownerid ,
										[Info]
								FROM	[Decision].dbo.[ConnotationValues] a(nolock)
								WHERE	kind = 821
										AND ownerid IN (@ROWID)
							) a ON a.ownerid = h.ownerid
				LEFT JOIN	(
								SELECT	ownerid ,
										[Info]
								FROM	[Decision].dbo.[ConnotationValues] a(nolock)
								WHERE	kind = 2634
										AND ownerid IN (@ROWID)
							) b ON a.ownerid = h.ownerid
				LEFT JOIN	(
								SELECT	ownerid ,
										[Info] = 'СО'
								FROM	[Decision].dbo.[ConnotationValues] a(nolock)
								WHERE	kind = 4505
										AND (
												info = 'CО'
												OR info = 'СО'
												OR info = 'CO'
												OR info = 'Самозайнята особа'
											)
										AND ownerid IN (@ROWID)
							) b1 ON a.ownerid = h.ownerid
		) l
	LEFT JOIN [Scoring].[ActivityField] b ON l.info_1 = b.POSITION
										AND l.info_2 = b.FIELD_OF_ACTIVITY;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	FL_MFO_LAST_3_MON
	--
	;WITH CTE0 AS
		(
			SELECT	@aROWID	AS	ROWID,
					@aDATE	AS	APPDATE
		),
		CTE1 AS
		(
			SELECT	U.ROWID,
					case when u.rowid is null then null else MAX(H.REDATE) end	AS	MAX_REDATE
			FROM	[Decision].[dbo].[CreditBur3_comp] u
			OUTER APPLY	(
							SELECT	TOP 100
									*
							FROM	[Decision].[dbo].[CreditBur3_credres] u1
							WHERE	u.Id = u1.compId
									and org in ('MFO')
							ORDER BY redate DESC
						) h
			WHERE	u.rowid = @rowid
			GROUP BY u.rowid
		),
		CTE2 AS
		(
			SELECT	T1.ROWID,
					MAX(NULLIF(T3.DLDS,'19000101'))	AS	MAX_MFO_LOANDATE
			FROM	[Decision].[dbo].[CreditBur3_comp] T1
			LEFT JOIN [Decision].[dbo].[CreditBur3_crdeal] T2 ON T2.COMPID = T1.ID
													AND T2.DLDONOR = 'MFO'
			LEFT JOIN [Decision].[dbo].[CreditBur3_deallife] T3 ON T3.CRDEALID = T2.ID
			WHERE	T1.ROWID = @ROWID
			GROUP BY T1.ROWID
		)
	SELECT	@FL_MFO_LAST_3_MON = 
				CASE WHEN COALESCE(DATEDIFF(MONTH, T2.MAX_MFO_LOANDATE, T0.APPDATE),-1) IN (0,1,2,3) OR
						COALESCE(DATEDIFF(MONTH, T1.MAX_REDATE, T0.APPDATE), -1) IN (0,1,2) THEN 1
					ELSE 0
				END
	FROM	CTE0	T0
	LEFT JOIN CTE1 T1 ON T1.ROWID = T0.ROWID
	LEFT JOIN CTE2 T2 ON T2.ROWID = T0.ROWID;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	
	--	BANK HISTORY
	--
	--	

	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	HIST_MAX_DPD_LAST_24_MON, HIST_RATIO_AVG_SALDO_LAST_3_MON_TO_AVG_SALDO_PREV_3_MON, HIST_RATIO_CUR_SALDO_TO_CUR_LIM,
	--		HIST_CNT_MON_FIRST_CRED, HIST_RATIO_CURR_SALDO_TO_CRED_AMT
	--	
	SET	@FROMDATE	=	CONVERT(VARCHAR(8),DATEADD(YEAR,-1,DATEADD(DAY,-1,@DATE)), 112);
	SET	@TILLDATE	=	CONVERT(VARCHAR(8),DATEADD(DAY,-2,@DATE), 112);
	SET	@SQL		=	
		'
			WITH CTE AS
				(
					SELECT  '''+@INN+'''                    AS  INN,
							TO_DATE('''+CONVERT(VARCHAR(8), CAST(@DATE AS DATE), 112)+''',''YYYYMMDD'')  AS  APPDATE
					FROM    DUAL
				)
			SELECT  NVL(V1.MAX_DPD_LAST_24MON,0)															AS  MAX_DPD_LAST_24_MON,
					TRUNC(CASE WHEN V1.AVG_6_MON = 0 THEN 0 ELSE V1.AVG_3_MON/V1.AVG_6_MON END,2)			AS  RATIO_AVG_SALDO_LAST_3_MON_TO,
					TRUNC(CASE WHEN V1.CREDAMOUNT = 0 THEN 0 ELSE V1.PRINCIPAL/V1.CREDAMOUNT END,2)			AS  RATIO_CUR_SALDO_TO_CUR_LIM,
					CASE WHEN V1.FIRST_LOANDATE >= V1.APPDATE THEN NULL
						ELSE TRUNC(MONTHS_BETWEEN(LAST_DAY(V1.APPDATE),LAST_DAY(V1.FIRST_LOANDATE)))
					END                                         AS  CNT_MON_FIRST_CRED,
					ROUND(CASE WHEN V1.INIT_CREDAMOUNT = 0 THEN 0 ELSE V1.PRINCIPAL/V1.INIT_CREDAMOUNT END,4)    AS  RATIO_CURR_SALDO_TO_CRED_AMT
			FROM    (
						SELECT  '+@PKG+'.GET_SUM_DAVG_PRINC_BY_PERIOD(T1.INN,ADD_MONTHS(T1.APPDATE-1,-3),T1.APPDATE-1)						AS  AVG_3_MON,
								'+@PKG+'.GET_SUM_DAVG_PRINC_BY_PERIOD(T1.INN,ADD_MONTHS(T1.APPDATE-1,-6),ADD_MONTHS(T1.APPDATE-1,-3))		AS  AVG_6_MON,
								'+@PKG+'.GET_MAX_DPD_BY_PERIOD(T1.INN,ADD_MONTHS(T1.APPDATE-1,-24),T1.APPDATE-1)							AS  MAX_DPD_LAST_24MON,
								'+@PKG+'.GET_FIRST_LOANDATE(T1.INN)																			AS  FIRST_LOANDATE,
								'+@PKG+'.GET_INIT_CREDAMOUNT(T1.INN, T1.APPDATE-1)															AS  INIT_CREDAMOUNT,
								'+@PKG+'.GET_PRINCIPAL_BY_DATE(T1.INN,T1.APPDATE-1)															AS  PRINCIPAL,
								'+@PKG+'.GET_CREDAMOUNT_BY_DATE(T1.INN,T1.APPDATE-1)														AS  CREDAMOUNT,
								T1.APPDATE																									AS	APPDATE
						FROM    CTE T1
					) V1';

	SET	@SQL_OPENQUERY	=	'SELECT * FROM OPENQUERY('+@B2_LINK+', '''+REPLACE(@SQL,'''','''''')+''')';

	INSERT	@HIST_PARAMS
		(
			MAX_DPD_LAST_24_MON,
			RATIO_AVG_SALDO_LAST_3_MON_TO_AVG_SALDO_PREV_3_MON,
			RATIO_CUR_SALDO_TO_CUR_LIM,
			CNT_MON_FIRST_CRED,
			RATIO_CURR_SALDO_TO_CRED_AMT
		)
	EXECUTE	(@SQL_OPENQUERY);

	SELECT	@HIST_MAX_DPD_LAST_24_MON									=	MAX_DPD_LAST_24_MON,
			@HIST_RATIO_AVG_SALDO_LAST_3_MON_TO_AVG_SALDO_PREV_3_MON	=	RATIO_AVG_SALDO_LAST_3_MON_TO_AVG_SALDO_PREV_3_MON,
			@HIST_RATIO_CUR_SALDO_TO_CUR_LIM							=	RATIO_CUR_SALDO_TO_CUR_LIM,
			@HIST_CNT_MON_FIRST_CRED									=	CNT_MON_FIRST_CRED,
			@HIST_RATIO_CURR_SALDO_TO_CRED_AMT							=	RATIO_CURR_SALDO_TO_CRED_AMT
	FROM	@HIST_PARAMS;
	--	-----------------------------------------------------------------------------------------------------------------------------------.
	--	RESULT on PRODUCTION
	--	
	--	1.
	INSERT	@PARAMS_PROD(ROWID,IDENTCODE,isMBKI,PARAMCODE,PARAMVALUE,PARAMVALUESTRING)
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'BKI_MAX_DPD_EVR'											AS	PARAMCODE,
			CAST(@BKI_MAX_DPD_EVR AS VARCHAR(100))						AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	2.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'BKI_CNT_ACTV_BANK_CRED_LAST_2_YEAR'						AS	PARAMCODE,
			CAST(ISNULL(@BKI_CNT_ACTV_BANK_CRED_LAST_2_YEAR,0) AS VARCHAR(100))	AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	3.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'APP_SEX'													AS	PARAMCODE,
			NULL														AS	PARAMVALUE,
			CASE WHEN SUBSTRING(@INN, 9, 1) IN ('0', '2', '4', '6', '8') THEN 'F'
				ELSE 'M'
			END															AS	PARAMVALUESTRING
	UNION ALL
	--	4. 
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'BKI_CNT_PREMATURELY_CLSD_CRED'								AS	PARAMCODE,
			CAST(ISNULL(@BKI_CNT_PREMATURELY_CLSD_CRED,0) AS VARCHAR(100))		AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	5. 
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'APP_MARITAL_STATUS_SEX'									AS	PARAMCODE,
			NULL														AS	PARAMVALUE,
			@APP_MARITAL_STATUS_SEX										AS	PARAMVALUESTRING
	UNION ALL
	--	6. 
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'APP_MARITAL_STATUS'										AS	PARAMCODE,
			NULL														AS	PARAMVALUE,
			CAST(@APP_MARITAL_STATUS AS VARCHAR(100))					AS	PARAMVALUESTRING
	UNION ALL
	--	7. 
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'BKI_MAX_CRED_AMT_EVR'										AS	PARAMCODE,
			CAST(ISNULL(@BKI_MAX_CRED_AMT_EVR,0) AS VARCHAR(100))		AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	8. 
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'BKI_CNT_OVD_CRED_NOW'										AS	PARAMCODE,
			CAST(ISNULL(@BKI_CNT_OVD_CRED_NOW,0) AS VARCHAR(100))		AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	9. 
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'BKI_MIN_CNT_DAY_TO_200_PD'									AS	PARAMCODE,
			CAST(@BKI_MIN_CNT_DAY_TO_200_PD AS VARCHAR(100))			AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	10.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'BKI_CNT_MON_FROM_FIRST_CRED'								AS	PARAMCODE,
			CAST(ISNULL(@BKI_CNT_MON_FROM_FIRST_CRED,0) AS VARCHAR(100))			AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	11.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'BKI_CNT_REQ_LAST_90_DAY'									AS	PARAMCODE,
			CAST(@BKI_CNT_REQ_LAST_90_DAY AS VARCHAR(100))				AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	12.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'HIST_MAX_DPD_LAST_24_MON'									AS	PARAMCODE,
			CAST(ISNULL(@HIST_MAX_DPD_LAST_24_MON,0) AS VARCHAR(100))	AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	13. 
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'BKI_CNT_MFO_REQ_LAST_MON'									AS	PARAMCODE,
			CAST(ISNULL(@BKI_CNT_MFO_REQ_LAST_MON,0) AS VARCHAR(100))	AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	14.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'BKI_MAX_PD_LAST_12_MON'									AS	PARAMCODE,
			CAST(ISNULL(@BKI_MAX_PD_LAST_12_MON,0) AS VARCHAR(100))		AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	15.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'HIST_RATIO_AVG_SALDO_LAST_3_MON_TO_AVG_SALDO'				AS	PARAMCODE,
			CAST(ISNULL(@HIST_RATIO_AVG_SALDO_LAST_3_MON_TO_AVG_SALDO_PREV_3_MON,0) AS VARCHAR(100))		AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	16.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'BKI_CNT_PREMATURELY_CLSD_BANK_CRED'						AS	PARAMCODE,
			CAST(@BKI_CNT_PREMATURELY_CLSD_BANK_CRED AS VARCHAR(100))	AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	17.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'HIST_RATIO_CUR_SALDO_TO_CUR_LIM'							AS	PARAMCODE,
			CAST(ISNULL(@HIST_RATIO_CUR_SALDO_TO_CUR_LIM,0) AS VARCHAR(100))		AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	18.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'BKI_CNT_IN_TIME_CLSD_CRED'									AS	PARAMCODE,
			CAST(@BKI_CNT_IN_TIME_CLSD_CRED AS VARCHAR(100))			AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	19.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'BKI_CNT_MON_TO_LAST_BANK_CRED'								AS	PARAMCODE,
			CAST(ISNULL(@BKI_CNT_MON_TO_LAST_BANK_CRED,-1) AS VARCHAR(100))		AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	20.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'BKI_MAX_PD_LAST_6_MON'										AS	PARAMCODE,
			CAST(ISNULL(@BKI_MAX_PD_LAST_6_MON,0) AS VARCHAR(100))		AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	21.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'BKI_CNT_1PLUS_EXIT_LAST_12_MON'							AS	PARAMCODE,
			CAST(ISNULL(@BKI_CNT_1PLUS_EXIT_LAST_12_MON,-1) AS VARCHAR(100))		AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	22.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'BKI_CNT_REQ_LAST_180_DAY'									AS	PARAMCODE,
			CAST(@BKI_CNT_REQ_LAST_180_DAY AS VARCHAR(100))				AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	23.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'HIST_CNT_MON_FIRST_CRED'									AS	PARAMCODE,
			CAST(ISNULL(@HIST_CNT_MON_FIRST_CRED,0) AS VARCHAR(100))	AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	24.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'BKI_CNT_OPEN_CRED_LAST_3_MON'								AS	PARAMCODE,
			CAST(ISNULL(@BKI_CNT_OPEN_CRED_LAST_3_MON,0) AS VARCHAR(100))			AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	25.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'APP_WORK_EXP'												AS	PARAMCODE,
			NULL														AS	PARAMVALUE,
			@APP_WORK_EXP												AS	PARAMVALUESTRING
	UNION ALL
	--	26.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'HIST_RATIO_CURR_SALDO_TO_CRED_AMT'							AS	PARAMCODE,
			CAST(ISNULL(@HIST_RATIO_CURR_SALDO_TO_CRED_AMT,0) AS VARCHAR(100))	AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	27.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'APP_FIELD_OF_ACTIVITY'										AS	PARAMCODE,
			CAST(@APP_FIELD_OF_ACTIVITY AS VARCHAR(100))				AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	28.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'FL_BNK_HIST'												AS	PARAMCODE,
			CAST(
					CASE WHEN @HIST_CNT_MON_FIRST_CRED IS NOT NULL THEN 1
						ELSE 0
					END AS VARCHAR(100)
				)														AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	29.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'FL_MFO_LAST_3_MON'											AS	PARAMCODE,
			CAST(@FL_MFO_LAST_3_MON AS VARCHAR(100))					AS	PARAMVALUE,
			NULL														AS	PARAMVALUESTRING
	UNION ALL
	--	30.
	SELECT	@ROWID														AS	ROWID,
			@INN														AS	IDENTCODE,
			@isMBKIID													AS	isMBKI,
			'TYPE_SET'													AS	PARAMCODE,
			NULL														AS	PARAMVALUE,
			case when CASE WHEN @HIST_CNT_MON_FIRST_CRED IS NOT NULL THEN 1
						ELSE 0
					END = 1 and @FL_MFO_LAST_3_MON = 1 then 'ZNANI_MFO_SET'
				when CASE WHEN @HIST_CNT_MON_FIRST_CRED IS NOT NULL THEN 1
						ELSE 0
					END = 1 then 'ZNANI_NOT_MFO_SET'		
				when @FL_MFO_LAST_3_MON = 1 then 'NEZNANI_MFO_SET'
				when COALESCE(@BKI_CNT_ACTV_BANK_CRED_LAST_2_YEAR, 0) < 1 or COALESCE(@BKI_MAX_CRED_AMT_EVR, 0) < 3000 then 'WITHOUT_CRED_HIST'
				else 'WITH_CRED_HIST'
			end															AS	PARAMVALUESTRING;

	IF @aDEBUG = 1
	BEGIN

		SELECT	ROWID,IDENTCODE,isMBKI,PARAMCODE,PARAMVALUE,PARAMVALUESTRING
		FROM	@PARAMS_PROD

	END ELSE
	BEGIN

		INSERT Decision.dbo.ScoringBKIDetail
			(
				Rowid, IdentCode, IsMbki, ParamCode, Value, ValueString
			)
		select	ROWID,IDENTCODE,isMBKI,PARAMCODE,PARAMVALUE,PARAMVALUESTRING
		from	@PARAMS_PROD

	END;
	--	-----------------------------------------------------------------------------------------------------------------------------------
	--	RESULT
	--
	--INSERT	@PARAMS
	--	(
	--		ROWID,INN,APPDATE,STARTCALC,
	--		BKI_MAX_DPD_EVR,BKI_CNT_ACTV_BANK_CRED_LAST_2_YEAR,APP_SEX,BKI_CNT_PREMATURELY_CLSD_CRED,APP_MARITAL_STATUS_SEX,APP_MARITAL_STATUS,BKI_MAX_CRED_AMT_EVR,
	--		BKI_CNT_OVD_CRED_NOW,BKI_MIN_CNT_DAY_TO_200_PD,BKI_CNT_MON_FROM_FIRST_CRED,BKI_CNT_REQ_LAST_90_DAY,HIST_MAX_DPD_LAST_24_MON,BKI_CNT_MFO_REQ_LAST_MON,BKI_MAX_PD_LAST_12_MON,
	--		HIST_RATIO_AVG_SALDO_LAST_3_MON_TO_AVG_SALDO_PREV_3_MON,BKI_CNT_PREMATURELY_CLSD_BANK_CRED,HIST_RATIO_CUR_SALDO_TO_CUR_LIM,BKI_CNT_IN_TIME_CLSD_CRED,BKI_CNT_MON_TO_LAST_BANK_CRED,
	--		BKI_MAX_PD_LAST_6_MON,BKI_CNT_1PLUS_EXIT_LAST_12_MON,BKI_CNT_REQ_LAST_180_DAY,HIST_CNT_MON_FIRST_CRED,BKI_CNT_OPEN_CRED_LAST_3_MON,APP_WORK_EXP,HIST_RATIO_CURR_SALDO_TO_CRED_AMT,
	--		APP_FIELD_OF_ACTIVITY, FL_BNK_HIST, FL_MFO_LAST_3_MON
	--	)
	--SELECT	@ROWID																	AS	ROWID,
	--		@INN																	AS	INN,
	--		@aDATE																	AS	APPDATE,
	--		@STARTCALC																AS	STARTCALC,

	--		@BKI_MAX_DPD_EVR														AS	BKI_MAX_DPD_EVR,											--	1. INT
	--		ISNULL(@BKI_CNT_ACTV_BANK_CRED_LAST_2_YEAR,0)							AS	COUNT_ACTIV_CRED_BKI_NON_MFO_LAST_2_YEAR,					--	2. INT
	--		CASE WHEN SUBSTRING(@INN, 9, 1) IN ('0', '2', '4', '6', '8') THEN 'F'
	--			ELSE 'M'
	--		END																		AS	APP_SEX,													--	3. CHAR
	--		ISNULL(@BKI_CNT_PREMATURELY_CLSD_CRED,0)								AS	BKI_CNT_PREMATURELY_CLSD_CRED,								--	4. INT
	--		@APP_MARITAL_STATUS_SEX													AS	APP_MARITAL_STATUS_SEX,										--	5. VARCHAR
	--		@APP_MARITAL_STATUS														AS	APP_MARITAL_STATUS,											--	6. VARCHAR
	--		ISNULL(@BKI_MAX_CRED_AMT_EVR,0)											AS	BKI_MAX_CRED_AMT_EVR,										--	7. MONEY
	--		ISNULL(@BKI_CNT_OVD_CRED_NOW,0)											AS	BKI_CNT_OVD_CRED_NOW,										--	8. INT
	--		@BKI_MIN_CNT_DAY_TO_200_PD												AS	BKI_MIN_CNT_DAY_TO_200_PD,									--	9. INT
	--		ISNULL(@BKI_CNT_MON_FROM_FIRST_CRED,0)									AS	BKI_CNT_MON_FROM_FIRST_CRED,								--	10. INT
	--		@BKI_CNT_REQ_LAST_90_DAY												AS	BKI_CNT_REQ_LAST_90_DAY,									--	11. INT
	--		ISNULL(@HIST_MAX_DPD_LAST_24_MON,0)										AS	HIST_MAX_DPD_LAST_24_MON,									--	12. INT
	--		ISNULL(@BKI_CNT_MFO_REQ_LAST_MON,0)										AS	BKI_CNT_MFO_REQ_LAST_MON,									--	13. INT
	--		ISNULL(@BKI_MAX_PD_LAST_12_MON,0)										AS	BKI_MAX_PD_LAST_12_MON,										--	14. MONEY
	--		ISNULL(@HIST_RATIO_AVG_SALDO_LAST_3_MON_TO_AVG_SALDO_PREV_3_MON,0)		AS	HIST_RATIO_AVG_SALDO_LAST_3_MON_TO_AVG_SALDO_PREV_3_MON,	--	15. MONEY
	--		@BKI_CNT_PREMATURELY_CLSD_BANK_CRED										AS	BKI_CNT_PREMATURELY_CLSD_BANK_CRED,							--	16. INT
	--		ISNULL(@HIST_RATIO_CUR_SALDO_TO_CUR_LIM,0)								AS	HIST_RATIO_CUR_SALDO_TO_CUR_LIM,							--	17. MONEY
	--		@BKI_CNT_IN_TIME_CLSD_CRED												AS	BKI_CNT_IN_TIME_CLSD_CRED,									--	18. INT
	--		ISNULL(@BKI_CNT_MON_TO_LAST_BANK_CRED,-1)								AS	BKI_CNT_MON_TO_LAST_BANK_CRED,								--	19. INT
	--		ISNULL(@BKI_MAX_PD_LAST_6_MON,0)										AS	BKI_MAX_PD_LAST_6_MON,										--	20. MONEY
	--		ISNULL(@BKI_CNT_1PLUS_EXIT_LAST_12_MON,-1)								AS	BKI_CNT_1PLUS_EXIT_LAST_12_MON,								--	21. INT
	--		@BKI_CNT_REQ_LAST_180_DAY												AS	BKI_CNT_REQ_LAST_180_DAY,									--	22. INT
	--		ISNULL(@HIST_CNT_MON_FIRST_CRED,0)										AS	HIST_CNT_MON_FIRST_CRED,									--	23. INT
	--		ISNULL(@BKI_CNT_OPEN_CRED_LAST_3_MON,0)									AS	BKI_CNT_OPEN_CRED_LAST_3_MON,								--	24. INT
	--		@APP_WORK_EXP															AS	APP_WORK_EXP,												--	25. VARCHAR
	--		ISNULL(@HIST_RATIO_CURR_SALDO_TO_CRED_AMT,0)							AS	HIST_RATIO_CURR_SALDO_TO_CRED_AMT,							--	26. MONEY
	--		@APP_FIELD_OF_ACTIVITY													AS	APP_FIELD_OF_ACTIVITY,										--	27. INT
	--		CASE WHEN @HIST_CNT_MON_FIRST_CRED IS NOT NULL THEN 1
	--			ELSE 0
	--		END																		AS	FL_BNK_HIST,
	--		@FL_MFO_LAST_3_MON														AS	FL_MFO_LAST_3_MON
				

	--INSERT	[dbo].[Z_NEW_SCORING_BACKTEST]
	--	(
	--		[ROWID],[INN],[APPDATE],[STARTCALC],[ENDCALC],[MAX_PD_PAY_EVER],[COUNT_ACTIV_CRED_BKI_NON_MFO_LAST_2_YEAR],[SEX],[CNT_DOSTROK_CRED_CLOSE],[MARITAL_SEX],[MARITAL_STATUS_G],[MAX_CREDAMOUNT_ALL],
	--		[COUNT_OVERDUE_AMT_BKI_NOW],[MIN_CNT_DAY_TO_200_PD],[MOB_BKI],[COUNT_QWER_BKI_LAST_90_DAY],[MAX_DPD_BEFORE_LAST_24_MONTH_29],[MFO_QUERY_LAST_MONTH_CNT],[MAX_SUMM_PAY_LAST_12_MONTH],
	--		[AVG_SALDO_LAST3M_FROM_AVG_SALDO_LAST456M_11],[CNT_PREMATURELY_CLOSE_CREDIT],[ALL_SALDO_FROM_LIMIT_18],[CNT_IN_TIME_CLOSE_CREDIT],[LAST_NOT_MFO_FIN_START_DATE_UBKI],[MAX_SUMM_PAY_LAST_6_MONTH],
	--		[COUNT_EXITS_1PLUS_DPD_BKI_LAST_12_MONTH],[COUNT_QWER_BKI_LAST_180_DAY],[COUNT_MONTH_FROM_OPEN_FIRST_CRED_1],[COUNT_OPEN_CRED_BKI_LAST_3_MONTH],[WORK_EXPERIENCE],[DIFF_SALDO_FROM_AMOUN_NOW_27],
	--		[GROUP_FIELD_OF_ACTIVITY_G],[FL_BNK_HIST],[FL_MFO_LAST_3_MON],[TYPE_SET],[ERROR]
	--	)
	--SELECT	ROWID,INN,APPDATE,STARTCALC,ENDCALC,
	--		BKI_MAX_DPD_EVR,BKI_CNT_ACTV_BANK_CRED_LAST_2_YEAR,APP_SEX,BKI_CNT_PREMATURELY_CLSD_CRED,APP_MARITAL_STATUS_SEX,APP_MARITAL_STATUS,BKI_MAX_CRED_AMT_EVR,
	--		BKI_CNT_OVD_CRED_NOW,BKI_MIN_CNT_DAY_TO_200_PD,BKI_CNT_MON_FROM_FIRST_CRED,BKI_CNT_REQ_LAST_90_DAY,HIST_MAX_DPD_LAST_24_MON,BKI_CNT_MFO_REQ_LAST_MON,BKI_MAX_PD_LAST_12_MON,
	--		HIST_RATIO_AVG_SALDO_LAST_3_MON_TO_AVG_SALDO_PREV_3_MON,BKI_CNT_PREMATURELY_CLSD_BANK_CRED,HIST_RATIO_CUR_SALDO_TO_CUR_LIM,BKI_CNT_IN_TIME_CLSD_CRED,BKI_CNT_MON_TO_LAST_BANK_CRED,
	--		BKI_MAX_PD_LAST_6_MON,BKI_CNT_1PLUS_EXIT_LAST_12_MON,BKI_CNT_REQ_LAST_180_DAY,HIST_CNT_MON_FIRST_CRED,BKI_CNT_OPEN_CRED_LAST_3_MON,APP_WORK_EXP,HIST_RATIO_CURR_SALDO_TO_CRED_AMT,
	--		APP_FIELD_OF_ACTIVITY,FL_BNK_HIST,FL_MFO_LAST_3_MON,
	--		case when FL_BNK_HIST = 1 and FL_MFO_LAST_3_MON = 1 then 'ZNANI_MFO_SET'
	--			when FL_BNK_HIST = 1 then 'ZNANI_NOT_MFO_SET'		
	--			when FL_MFO_LAST_3_MON = 1 then 'NEZNANI_MFO_SET'
	--			when COALESCE(BKI_CNT_ACTV_BANK_CRED_LAST_2_YEAR, 0) < 1 or COALESCE(BKI_MAX_CRED_AMT_EVR, 0) < 3000 then 'WITHOUT_CRED_HIST'
	--			else 'WITH_CRED_HIST'
	--		end,
	--		NULL
	--FROM	@PARAMS;

	--UPDATE	T1
	--SET		/*T1.MAX_DPD_BEFORE_LAST_24_MONTH_29 = T2.HIST_MAX_DPD_LAST_24_MON,
	--		T1.AVG_SALDO_LAST3M_FROM_AVG_SALDO_LAST456M_11 = T2.HIST_RATIO_AVG_SALDO_LAST_3_MON_TO_AVG_SALDO_PREV_3_MON,
	--		T1.ALL_SALDO_FROM_LIMIT_18 = T2.HIST_RATIO_CUR_SALDO_TO_CUR_LIM,*/
	--		T1.COUNT_MONTH_FROM_OPEN_FIRST_CRED_1 = T2.HIST_CNT_MON_FIRST_CRED,
	--		--T1.DIFF_SALDO_FROM_AMOUN_NOW_27 = T2.HIST_RATIO_CURR_SALDO_TO_CRED_AMT
	--		T1.FL_BNK_HIST = T2.FL_BNK_HIST,
	--		T1.FL_MFO_LAST_3_MON = T2.FL_MFO_LAST_3_MON
	--FROM	[dbo].[Z_NEW_SCORING_BACKTEST] T1
	--INNER JOIN @PARAMS T2 ON T2.ROWID = T1.ROWID
	

RETURN 0;

END TRY
BEGIN CATCH

	DECLARE	@ERROR_MSG VARCHAR(MAX) =	ERROR_MESSAGE();
	DECLARE @ERROR_NUM	INT			=	ERROR_NUMBER();

	DECLARE @ERROR VARCHAR(MAX) = 'Error num: '+CAST(@ERROR_NUM AS VARCHAR(100))+', Error msg: '+@ERROR_MSG;

	SET	@ERROR = ERROR_MESSAGE();

	RAISERROR(@ERROR,16,0);

	--SELECT	@ERROR;

	--INSERT	[dbo].[Z_NEW_SCORING_BACKTEST]
	--	(
	--		ROWID,INN,APPDATE,ERROR
	--	)
	--VALUES	(@aROWID, @INN, @aDATE, @ERROR);

	--UPDATE	[dbo].[Z_NEW_SCORING_BACKTEST]
	--SET		ERROR = @ERROR
	--WHERE	ROWID = @aROWID;

END CATCH