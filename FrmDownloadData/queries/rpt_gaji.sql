	
	

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'P' AND name = 'rpt_printgaji')
DROP PROCEDURE rpt_printgaji
GO


/*
	Created By 	:	Chandra Arifin
	Date		:	Friday, 11 July 2014, 14:05 PM
	Stored Proc	:	rpt_printgaji
	Description	:	
*/
create procedure rpt_printgaji
--	@nik int,
	@tahun smallint,
	@bulan tinyint,
	@kdcabang varchar(5),
	@kdwarehouse varchar(3),
	@divisi smallint
WITH ENCRYPTION
as
	set nocount on

	select 
		a.nik, a.nama, coalesce(a.nickname, '') as nickname, 
		coalesce(a.norek, '') as norek, a.KdWarehouse, w.NmWarehouse,
		b.Tahun, b.Bulan, b.jml_hari, b.jml_harikerja, b.jml_bonusoff, b.jml_sakit,
		b.gajipokok, b.potongan, b.bonus, b.lain2, round(b.total, 0) as total, b.keterangan,
		dbo.terbilang(round(b.total, 0)) as Terbilang
	from 
		ms_karyawan as a
	inner join
		MS_Warehouse as w
		on a.KdCabang = w.KdCabang and a.KdWarehouse = w.KdWarehouse
	inner join
		trx_gaji as b
		on a.nik = b.nik and b.Tahun = @tahun and b.Bulan = @bulan
	where 
		a.KdCabang = @kdcabang and a.kdwarehouse = @kdwarehouse and 
		a.stsrc <> 'D' and a.Divisi = @divisi 
	order by a.agamaid, a.nama

GO

