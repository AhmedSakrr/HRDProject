

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'P' AND name = 'IsKaryawanExists')
DROP PROCEDURE IsKaryawanExists
GO

/*
	Created By 	:	Chandra Arifin
	Date		:	
	Stored Proc	:	IsKaryawanExists
	Description	:	
*/
create procedure dbo.IsKaryawanExists
	@nik int
WITH ENCRYPTION
as
if(exists(
	select 1 from ms_karyawan where nik = @nik
	))
	select 1 as IsExists
else
	select 0 as IsExists
GO






IF EXISTS(SELECT * FROM sys.objects WHERE type = 'P' AND name = 'get_listkaryawan')
DROP PROCEDURE get_listkaryawan
GO



/*
	Created By 	:	Chandra Arifin
	Date		:	Friday, 04 July 2014, 10:03 AM
	Stored Proc	:	get_listkaryawan
	Description	:	
*/
create procedure get_listkaryawan
	@KdCabang		varchar(5),	 
	@KdWarehouse	varchar(3),	 
	@Divisi			smallint
WITH ENCRYPTION
as
set nocount on

select
	a.nik,
	a.KdCabang,
	a.KdWarehouse,
	a.stsrc,
	a.nama,
	coalesce(a.nickname, '') as nickname,
	a.Divisi,
	b.[Description]
from
	ms_karyawan as a
inner join
	lt_divisi as b
	on a.Divisi = b.Divisi
inner join
	MS_Warehouse as c
	on a.KdCabang = c.KdCabang and a.KdWarehouse = c.KdWarehouse
where
	a.KdCabang = @KdCabang and a.KdWarehouse = @KdWarehouse and a.Divisi = @Divisi and
	a.stsrc = 'A'
order by
	a.nama
GO





IF EXISTS(SELECT * FROM sys.objects WHERE type = 'P' AND name = 'ins_offkerja')
DROP PROCEDURE ins_offkerja
GO


/*
	Created By 	:	Chandra Arifin
	Date		:	
	Stored Proc	:	
	Description	:	
*/
create procedure ins_offkerja
	@nik			int,
	@periodeawal date,
	@periodeakhir date,
	@offhari varchar(10)
WITH ENCRYPTION
as
set nocount on

	declare @query as varchar(max)

	SET @PeriodeAwal = convert(date, convert(varchar(10), @periodeawal, 105), 105)
	SET @PeriodeAkhir = convert(date, convert(varchar(10), @PeriodeAkhir, 105), 105)

	delete from ms_offkerja where nik = @nik and tgloff between @periodeawal and @periodeakhir


	--method 1
		--;WITH ctedaterange
		--	 AS (SELECT [rn]=Row_number()
		--					   OVER(
		--						 ORDER BY (SELECT NULL))
		--		 FROM   sys.objects a
		--				CROSS JOIN sys.objects b
		--				CROSS JOIN sys.objects c
		--				CROSS JOIN sys.objects d)
		--SELECT Dateadd(dd, rn, @periodeawal)
		--FROM   ctedaterange
		--WHERE  [rn] <= Datediff(dd, @periodeawal, @periodeakhir)

	-- 0 = Senin
	-- 1 = selasa
	-- 2 = rabu
	-- 3 = kamis
	-- 6 = minggu


	select @query = '
	;WITH cte
	     AS (SELECT [Dates]= cast(''' + cast(@periodeawal as varchar(10)) + ''' as datetime) 
	         UNION ALL
	         SELECT [dates] + 1
	         FROM   cte
	         WHERE  [dates] + 1<= cast(''' + cast(@periodeakhir as varchar(10)) + ''' as datetime)) '
	         
	select @query = @query +
	
	'insert into
	ms_offkerja
	(
		nik, tgloff, offhari
	)
	select 
		' + cast(@nik as varchar) + ', cast(dates as DATE), ''' + @offhari + '''
	from 
		cte
	where 
		DATEDIFF(dd, 0, dates) % 7 in (' + @offhari + ') OPTION (MAXRECURSION 0)';
		
	exec (@query)

GO





IF EXISTS(SELECT * FROM sys.objects WHERE type = 'P' AND name = 'Get_SearchKaryawan')
DROP PROCEDURE Get_SearchKaryawan
GO


/*
	Created By 	:	Chandra Arifin
	Date		:	Wednesday; 02 July 2014; 12:46 PM
	Stored Proc	:	
	Description	:	
*/
create procedure [dbo].[Get_SearchKaryawan]
	@Nama nvarchar(255) = null
WITH ENCRYPTION
as
set nocount on

select
	a.stsrc,
	a.nik,
	a.KdWarehouse,
	b.NmWarehouse,
	a.nama,
	coalesce(a.nickname, '') as nickname
from
	ms_karyawan as a
inner join
	MS_Warehouse as b
	on a.KdCabang = b.KdCabang and a.KdWarehouse = b.KdWarehouse
where
	a.Stsrc = 'A' AND
	Nama LIKE '%' + coalesce(@Nama, '') + '%'
order by
	a.Nama

GO





IF EXISTS(SELECT * FROM sys.objects WHERE type = 'P' AND name = 'get_karyawan')
DROP PROCEDURE get_karyawan
GO



/*
	Created By 	:	Chandra Arifin
	Date		:	Tuesday; 31 Dec 2013; 20:09 PM
	Stored Proc	:	get_karyawan
	Description	:	Mendapatkan Info Ttg karywan
*/
create procedure get_karyawan
	@stsrc char(1) = null,
	@nik int = null
WITH ENCRYPTION
as
set nocount on

select
	a.nik,
	a.KdCabang,
	a.KdWarehouse,
	a.stsrc,
	a.nama,
	coalesce(a.nickname, '') as nickname,
	a.idjam,
	a.Divisi,
	b.[Description],
	coalesce(a.norek, '') as norek,
	a.gajipokok,
	a.uangmakan,
	a.ishitungum,
	a.agamaid	
from
	ms_karyawan as a
left join
	lt_divisi as b
	on a.Divisi = b.Divisi
where
	a.stsrc = coalesce(@stsrc, a.stsrc) and a.nik = coalesce(@nik, a.nik)
order by
	a.nama
GO




IF EXISTS(SELECT * FROM sys.objects WHERE type = 'P' AND name = 'del_karyawan')
DROP PROCEDURE del_karyawan
GO


/*
	Created By 	:	Chandra Arifin
	Date		:	Tuesday; 31 Dec 2013; 20:09 PM
	Stored Proc	:	del_karyawan
	Description	:	Delete karyawan
*/
create procedure del_karyawan
	@nik int,
	@userid nvarchar(10)
WITH ENCRYPTION
as
set nocount on

update
	ms_karyawan
set
	stsrc = 'D',
	UserUpdated = @UserID,
	DateUpdated = getdate()
where
	nik = @nik
GO





IF EXISTS(SELECT * FROM sys.objects WHERE type = 'P' AND name = 'del_karyawanpermanent')
DROP PROCEDURE del_karyawanpermanent
GO

/*
	Created By 	:	Chandra Arifin
	Date		:	Tuesday; 31 Dec 2013; 20:09 PM
	Stored Proc	:	del_karyawanpermanent
	Description	:	Delete karyawan permanent
*/
create procedure del_karyawanpermanent
	@nik int,
	@userid nvarchar(10)
WITH ENCRYPTION
as
set nocount on

DELETE from
	ms_karyawan
where
	nik = @nik
GO





IF EXISTS(SELECT * FROM sys.objects WHERE type = 'P' AND name = 'ins_karyawan')
DROP PROCEDURE ins_karyawan
GO


/*
	Created By 	:	Chandra Arifin
	Date		:	Tuesday; 31 Dec 2013; 20:09 PM
	Stored Proc	:	ins_karyawan
	Description	:	Insert karyawan
*/
create procedure ins_karyawan
	@nik			int,	 
	@KdCabang		varchar(5),	 
	@KdWarehouse	varchar(3),	 
	@stsrc			char(1) = 'A',	 
	@nama			nvarchar(255),	 
	@nickname		nvarchar(255) = null,	 
	@idjam			smallint,	 
	@Divisi			smallint,	 
	@norek			varchar(20) = null,	 
	@gajipokok		money = 650000,	 
	@uangmakan		money = 20000,	 
	@ishitungum		bit = 1,
	@agamaid		tinyint = 1,	 	
	@userid nvarchar(10)
WITH ENCRYPTION
as
set nocount on

insert into
	ms_karyawan
	(
		nik, KdCabang, KdWarehouse, stsrc, nama, nickname,
		idjam, Divisi, norek, gajipokok, uangmakan, ishitungum,	
		agamaid,
		DateCreated,
		UserCreated,
		DateUpdated,
		UserUpdated
	)
values
	(
		@nik, @KdCabang, @KdWarehouse, 'A', @nama, @nickname,
		@idjam, @Divisi, @norek, @gajipokok, @uangmakan, @ishitungum,
		@agamaid,			
		getdate(), @UserID, getdate(), @UserID
	)
GO



IF EXISTS(SELECT * FROM sys.objects WHERE type = 'P' AND name = 'upd_karyawan')
DROP PROCEDURE upd_karyawan
GO


/*
	Created By 	:	Chandra Arifin
	Date		:	Tuesday; 31 Dec 2013; 20:09 PM
	Stored Proc	:	upd_karyawan
	Description	:	Update karyawan
*/
create procedure upd_karyawan
	@nik			int,	 
	@KdCabang		varchar(5),	 
	@KdWarehouse	varchar(3),	 
	@stsrc			char(1) = null,	 
	@nama			nvarchar(255),	 
	@nickname		nvarchar(255),	 
	@idjam			smallint,	 
	@Divisi			smallint,	 
	@norek			varchar(20),	 
	@gajipokok		money,	 
	@uangmakan		money,	 
	@ishitungum		bit,	
	@agamaid		tinyint,	 	
	@userid nvarchar(10)
WITH ENCRYPTION
as
set nocount on

update
	ms_karyawan
set
	stsrc = coalesce(@StsRc, stsrc),
	KdCabang = @KdCabang,
	KdWarehouse = @KdWarehouse,
	nama = @nama,
	nickname = @nickname,
	idjam = @idjam,
	Divisi = @Divisi,
	norek = @norek,
	gajipokok = @gajipokok,
	uangmakan = @uangmakan,
	ishitungum = @ishitungum,
	agamaid = @agamaid,
	UserUpdated = @UserID,
	DateUpdated = getdate()
where
	nik = @nik
GO



