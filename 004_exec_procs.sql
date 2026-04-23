use Polyclinic_SWT611;
go

select
    *
from
    dbo.ViewAppointments;
go        

-- запросы к базе данных Polyclinic по заданию

-- Запрос 1. Хранимая процедура с параметрами
-- Выбирает информацию о пациентах, фамилия которых начинается с заданной буквы (например, «И»)
exec GetPatientsSurnameLike 'И';
exec GetPatientsSurnameLike 'А';
exec GetPatientsSurnameLike 'Я';
go

-- Запрос 2. Хранимая процедура с параметром
-- Выбирает информацию о врачах, имеющих заданную специальность. Например, «хирург»
exec GetDoctorsSpecialityEq 'хирург'
exec GetDoctorsSpecialityEq 'офтальмолог'
exec GetDoctorsSpecialityEq 'терапевт'
go


-- Запрос 3. Хранимая процедура без параметров	
-- Выбирает информацию о приемах: фамилия, имя и отчество пациента, дата приема, 
-- дата рождения пациента, специальность врача, стоимость прима
exec GetAppointments;
go


-- Запрос 4. Хранимая процедура с параметром	
-- Выбирает информацию о врачах с заданным значением в поле Стоимость приема. 
exec GetDoctorsWherePriceEq 600;    
exec GetDoctorsWherePriceEq 3300;    
exec GetDoctorsWherePriceEq 1300;    
go


-- Запрос 5. Хранимая процедура с параметрами	
-- Выбирает информацию о врачах, Процент отчисления на зарплату которых находится 
-- в некотором заданном диапазоне. 
exec GetDoctorsWherePercentBetween 1.5, 3.5;
exec GetDoctorsWherePercentBetween 4.5, 2.5;
exec GetDoctorsWherePercentBetween 4.5, 7.5;    
go


-- Запрос 6. Хранимая процедура без параметров	
-- Вычисляет размер заработной платы врача за каждый прием. Включает поля 
-- Фамилия врача, Имя врача, Отчество врача, Специальность врача, Стоимость 
-- приема, Зарплата. Сортировка по полю Фамилия врача
exec GetDoctorsSalary;
go
 