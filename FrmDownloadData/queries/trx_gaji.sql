



IF EXISTS(SELECT * FROM sys.objects WHERE type = 'P' AND name = 'del_gaji')
DROP PROCEDURE del_gaji
GO


/*
	Created By 	:	Chandra Arifin
	Date		:	
	Stored Proc	:	del_gaji
	Description	:	
*/
create procedure del_gaji
	--@nik int,
	@kdcabang varchar(5),
	@kdwarehouse varchar(3),
	@divisi smallint,
	@Tahun	smallint,
	@Bulan	tinyint
WITH ENCRYPTION
as
set nocount on

delete from 
	trx_gaji
where
	nik in 
	(select nik from ms_karyawan where KdCabang = @kdcabang and KdWarehouse = @kdwarehouse and Divisi = @divisi) and 
	tahun = @Tahun and bulan = @Bulan
GO





IF EXISTS(SELECT * FROM sys.objects WHERE type = 'P' AND name = 'ins_gaji')
DROP PROCEDURE ins_gaji
GO


/*
	Created By 	:	Chandra Arifin
	Date		:	
	Stored Proc	:	ins_gaji
	Description	:	
*/
create procedure ins_gaji	
	@nik			int,	 
	@Tahun			smallint,	 
	@Bulan			tinyint,	 
	@jml_hari		smallint,	 
	@jml_harikerja	smallint,	 
	@jml_bonusoff	smallint,	 
	@jml_sakit		smallint,	 
	@lain2			money,
	@keterangan		varchar(255)
WITH ENCRYPTION
as
set nocount on

declare @jml_hari_potongan smallint
declare @gajipokok	money,
		@potongan	money,	 
		@bonus		money,	 
		@total		money,
		@gajipokokperhari	money;

set @bonus = 0
set @total = 0

select 
	@gajipokok = gajipokok
from 
	ms_karyawan
where nik = @nik



set @gajipokokperhari = @gajipokok / @jml_hari

set @jml_hari_potongan = (@jml_harikerja + @jml_bonusoff + @jml_sakit) - @jml_hari

set @potongan = @gajipokokperhari * @jml_hari_potongan

if(@potongan > 0)
begin
	set @bonus = @potongan
	set @potongan = 0
end


delete from 
	trx_gaji
where
	nik = @nik and 
	tahun = @Tahun and bulan = @Bulan
	

insert into
	trx_gaji
	(
		nik,         
		Tahun,  
		Bulan, 
		jml_hari, 
		jml_harikerja, 
		jml_bonusoff, 
		jml_sakit, 
		gajipokok,             
		potongan,              
		bonus,                 
		lain2,                 
		--total,                 
		keterangan
	)
values
	(
		@nik,         
		@Tahun,  
		@Bulan, 
		@jml_hari, 
		@jml_harikerja, 
		@jml_bonusoff, 
		@jml_sakit, 
		@gajipokok,             
		@potongan,              
		@bonus,                 
		@lain2,                 
		--@total,                 
		@keterangan
	)
GO



