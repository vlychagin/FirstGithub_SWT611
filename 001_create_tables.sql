use master;
go


drop database if exists Polyclinic_SWT611;
go


create database Polyclinic_SWT611;
go

use Polyclinic_SWT611;
go


-- Создание таблиц базы данных
print('*** Старт скрипта создания таблиц ***'+char(13));


-- удаление существующих таблиц, работает в MS SQL Server 2016+
drop table if exists Appointments;
drop table if exists Doctors;
drop table if exists Patients;
drop table if exists People;
drop table if exists Specialities;
go


-- Таблица - справочник персональных данных, одинаковых  
-- для докторов и пациентов - People
print('*** Таблица - справочник персональных данных People ***')
create table dbo.People (
	Id          int          not null primary key identity (1, 1),
	Surname     nvarchar(60) not null,    -- Фамилия персоны
	[Name]      nvarchar(50) not null,    -- Имя персоны
	Patronymic  nvarchar(70) not null     -- Отчество персоны
);
print('*** OK ***' + char(13));
go


-- Таблица -  справочник врачебных специальностей докторов Specialities
print('*** Таблица - справочник врачебных специальностей докторов Specialities ***')
create table dbo.Specialities (
	Id      int          not null primary key identity (1, 1),
	[Name]  nvarchar(40) not null    -- название врачебной специальности
);
print('*** OK ***' + char(13));
go


-- Таблица сведений о докторах ВРАЧИ --> Doctors
print('*** Таблица сведений о докторах ВРАЧИ --> Doctors ***')
create table dbo.Doctors (
	Id           int          not null primary key identity (1, 1),
	PersonId     int          not null,    -- Внешний ключ, связь с персональными данными
	SpecialityId int          not null,    -- Внешний ключ, связь со справочником врачебных специальностей
	Price        int          not null,    -- Стоимость приема
	[Percent]    float        not null,    -- Процент отчисления от стоимости приема на зарплату врача
	
	-- ограничения полей таблицы
	constraint CK_Doctors_Price   check (Price > 0),
	constraint CK_Doctors_Percent check ([Percent] > 0 and [Percent] <= 40),

	-- внешний ключ - связь 1:1 к таблице People
	constraint FK_Doctors_People foreign key (PersonId) references dbo.People(Id),

	-- внешний ключ - связь M:1 к таблице Specialities (e.g.: много докторов одной специальности)  
	-- или 1:M
	constraint FK_Doctors_Specialities foreign key (SpecialityId) references dbo.Specialities(Id)
);
print('*** OK ***' + char(13));
go


-- Таблица сведений о пациентах ПАЦИЕНТЫ --> Patients
print('*** Таблица сведений о пациентах ПАЦИЕНТЫ --> Patients ***')
create table dbo.Patients (
	Id          int          not null primary key identity (1, 1),
	PersonId    int          not null,    -- Внешний ключ, связь с персональными данными
	BornDate    date         not null,    -- Дата рождения пациента
	[Address]   nvarchar(80) not null     -- Адрес проживания пациента
	
	-- внешний ключ - связь 1:1 к таблице People
	constraint  FK_Patients_People foreign key (PersonId) references dbo.People(Id)
);
print('*** OK ***' + char(13));
go


-- Таблица сведений о приемах пациентов докторами: ПРИЕМЫ --> Appointments  
print('*** Таблица сведений о приемах пациентов докторами: ПРИЕМЫ --> Appointments ***')
create table dbo.Appointments (
    Id              int  not null primary key identity (1, 1),
	AppointmentDate date not null,
	PatientId       int  not null,   -- Внешний ключ, связь с таблицей пациентов
	DoctorId        int  not null,   -- Внешний ключ, связь с таблицей докторов

	-- ограничение даты, не допустимы даты из будующих периодов
	constraint CK_Appointments_AppointmentDate check (AppointmentDate <= getDate()),

	-- внешний ключ - связь M:1 к таблице пациентов
	constraint FK_Appointments_Patients foreign key (PatientId) references dbo.Patients(Id),

	-- внешний ключ - связь M:1 к таблице докторов
	constraint FK_Appointments_Doctors foreign key (DoctorId) references dbo.Doctors(Id)
);
print('*** OK ***' + char(13));
print('*** Финиш скрипта создания таблиц ***');
go
