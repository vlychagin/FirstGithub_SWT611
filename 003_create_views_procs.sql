use Polyclinic_SWT611;
go

-- создание представлений

-- Из таблиц ПЕРСОНЫ + ПАЦИЕНТЫ
create or alter view ViewPatients as
select
    Patients.Id
    , PersonId

    , People.Surname    as PatientSurname
    , People.[Name]     as PatientName
    , People.Patronymic as PatientPatronymic 
    , Patients.BornDate
    , Patients.[Address]
from
    Patients join People on Patients.PersonId = People.Id;
go


-- Из таблиц ПЕРСОНЫ + ВРАЧИ + СПЕЦИАЛЬНОСТИ
create or alter view ViewDoctors as 
select
    Doctors.Id
    , PersonId
    , SpecialityId

    , People.Surname          as DoctorSurname
    , People.[Name]           as DoctorName
    , People.Patronymic       as DoctorPatronymic
    , Specialities.[Name]     as Speciality
    , Doctors.Price
    , Doctors.[Percent]
from
    Doctors join Specialities on Doctors.SpecialityId = Specialities.Id
            join People on Doctors.PersonId = People.Id;
go


-- Из таблицы ПРИЕМЫ и двух представлений из предыдущих пунктов или соединения всех таблиц
create or alter view ViewAppointments as
select
    Appointments.Id
    , Appointments.PatientId
    , Appointments.DoctorId
    , ViewDoctors.SpecialityId

    , Appointments.AppointmentDate

    -- пациенты
    , ViewPatients.PatientSurname
    , ViewPatients.PatientName
    , ViewPatients.PatientPatronymic

    , dateDiff(year, ViewPatients.BornDate, getDate()) as Age -- вычисляемое поле

    , ViewPatients.BornDate
    , ViewPatients.[Address]

    -- второй путь связи с персонами, через синоним P для таблицы People
    , ViewDoctors.DoctorSurname
    , ViewDoctors.DoctorName
    , ViewDoctors.DoctorPatronymic

    , ViewDoctors.Speciality
    , ViewDoctors.Price
    , ViewDoctors.[Percent]
from
    Appointments 
        join ViewPatients on Appointments.PatientId = ViewPatients.Id
        join ViewDoctors on Appointments.DoctorId = ViewDoctors.Id;
go

-- ------------------------------------------------------------------------

-- создание хранимых процелдур для запросы к базе данных Polyclinic по заданию

-- Запрос 1. Хранимая процедура с параметрами
-- Выбирает информацию о пациентах, фамилия которых начинается с заданной буквы (например, «И»)
create or alter proc GetPatientsSurnameLike
    @firstLetter nvarchar
as
begin
    select
        Id
        , PatientSurname
        , PatientName
        , PatientPatronymic
        , BornDate
        , [Address]
    from
        ViewPatients
    where
        PatientSurname like @firstLetter + '%';
    end;
go


-- Запрос 2. Хранимая процедура с параметром
-- Выбирает информацию о врачах, имеющих заданную специальность. Например, «хирург»
create or alter proc GetDoctorsSpecialityEq
    @speciality nvarchar(40)
as 
    select
        Id
        , DoctorSurname
        , DoctorName
        , DoctorPatronymic
        , Speciality
        , Price
        , [Percent]
    from
        ViewDoctors 
    where
        Speciality = @speciality;

go


-- Запрос 3. Хранимая процедура без параметров	
-- Выбирает информацию о приемах: фамилия, имя и отчество пациента, дата приема, 
-- дата рождения пациента, специальность врача, стоимость прима
create or alter proc GetAppointments
as 
begin
    select
        PatientSurname + ' ' + Substring(PatientName, 1, 1) + '.' + Substring(PatientPatronymic, 1, 1) + '.' as PatientNP
        , PatientSurname
        , PatientName
        , PatientPatronymic
        , AppointmentDate
        , BornDate
        , Age
        , Speciality
        , Price
    from
        ViewAppointments; 
end;    
go


-- Запрос 4. Хранимая процедура с параметром	
-- Выбирает информацию о врачах с заданным значением в поле Стоимость приема. 
create or alter proc GetDoctorsWherePriceEq
    @price int
as 
begin
    select
        Id
        , DoctorSurname
        , DoctorName
        , DoctorPatronymic
        , Speciality
        , Price
        , [Percent]
    from
        ViewDoctors 
    where
        ViewDoctors.Price = @price;
end;    
go


-- Запрос 5. Хранимая процедура с параметрами	
-- Выбирает информацию о врачах, Процент отчисления на зарплату которых находится 
-- в некотором заданном диапазоне. 
create or alter proc GetDoctorsWherePercentBetween
    @loPerscent float, 
    @hiPercent float
as 
begin
    select
        Id
        , DoctorSurname
        , DoctorName
        , DoctorPatronymic
        , Speciality
        , Price
        , [Percent]
    from
        ViewDoctors 
    where
        [Percent] between @loPerscent and @hiPercent
    order by
        [Percent];
end;    
go


-- Запрос 6. Хранимая процедура без параметров	
-- Вычисляет размер заработной платы врача за каждый прием. Включает поля 
-- Фамилия врача, Имя врача, Отчество врача, Специальность врача, Стоимость 
-- приема, Зарплата. Сортировка по полю Фамилия врача
create or alter proc GetDoctorsSalary
as
begin
    select
        Id
        , DoctorSurname
        , DoctorName
        , DoctorPatronymic
        , Speciality
        , Price
        , [Percent]

        -- вычисляемое поле, зарплата за прием - 87% от начисления, 13% - подоходный налог
        -- , Replace(Trim(Str(0.87 * (Price * [Percent] / 100), 15, 2)), '.', ',') as Salary
        , 0.87 * (Price * [Percent] / 100)    as Salary
    from
        ViewDoctors 
    order by
        DoctorSurname;
end;
go
 	 	

-- Запрос 7. Хранимая процедура без параметров
-- Выполняет группировку по полю Дата приема. 
-- Для каждой даты вычисляет минимальную стоимость приема
create or alter proc AppointmentsDateReport
as 
begin
    select
        AppointmentDate
        , min(Price)    as MinPrice
        , count(*)      as AppointmentsAmount
    from
        ViewAppointments
    group by
        AppointmentDate;
    end;
go


-- Запрос 8. Хранимая процедура без параметров
-- Для ВСЕХ докторов вычисляет количество приемов, сумму оплат за приемы
create or alter proc AllDoctorsAppointmentsSalaryReport
as
    select
        ViewDoctors.Id
        , ViewDoctors.DoctorSurname
        , ViewDoctors.DoctorName
        , ViewDoctors.DoctorPatronymic
        , ViewDoctors.Price
        , ViewDoctors.Speciality

        , count(ViewAppointments.DoctorId) as AppointmentAmount
        , count(ViewAppointments.DoctorId) * ViewDoctors.Price as TotalPrice
    from 
        ViewDoctors
        left join 
        ViewAppointments on ViewDoctors.Id = ViewAppointments.DoctorId
    group by
        ViewDoctors.Id
        , ViewDoctors.DoctorSurname
        , ViewDoctors.DoctorName
        , ViewDoctors.DoctorPatronymic
        , ViewDoctors.Price
        , ViewDoctors.Speciality;
go


-- Запрос 9. Хранимая процедура без параметров
-- Для ВСЕХ пациентов определить количество приемов
create or alter proc AllPatientsAppointmentsAmountReport
as
    select 
        ViewPatients.Id
        , ViewPatients.PatientSurname
        , ViewPatients.PatientName
        , ViewPatients.PatientPatronymic
        , ViewPatients.BornDate
        
        , year(GetDate()) - year(ViewPatients.BornDate ) as Age
        , count(ViewAppointments.PatientId) as Amount
    from 
        ViewPatients left join ViewAppointments on ViewPatients.Id = ViewAppointments.PatientId
    group BY
        ViewPatients.Id
        , ViewPatients.PatientSurname
        , ViewPatients.PatientName
        , ViewPatients.PatientPatronymic
        , ViewPatients.BornDate
        , year(getDate()) - year(ViewPatients.BornDate);    
go
