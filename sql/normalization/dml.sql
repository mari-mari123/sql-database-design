insert into LibraryMan.Librarian(LibrarianID,Name)
select distinct Librarian_Employee_ID, Librarian_Name from LibraryMan.testtable
GO
Insert into LibraryMan.Loan(LendingDate,ReturnDate,DueDate,ReturnOnTime,LibrarianID,LoanID)
select distinct loan_date,return_date,due_Date,iif(Overdue=1, 0, 1),Librarian_employee_id,Loan_ID
from libraryman.testtable
Go
insert into LibraryMan.Book(Title)
select distinct Book_Title from LibraryMan.testtable where Book_Title is not Null
GO
Update b
set b.PublicationYear=t.Book_Publication_Year
from LibraryMan.testtable t join LibraryMan.Book b on t.Book_Title = b.Title
GO
Update b
set b.Author=t.Book_Author
from LibraryMan.testtable t join LibraryMan.Book b on t.Book_Title = b.Title
GO
insert into LibraryMan.Category(Name)
select distinct Book_Category from LibraryMan.testtable where Book_Category is not null
GO
INSERT INTO LibraryMan.BookCategory (BookID, CategoryID, IsPrimary)
SELECT DISTINCT b.BookID, c.CategoryID,
    CASE WHEN t.Is_Default_Category = 1 THEN 1 ELSE 0 END AS IsPrimary
FROM LibraryMan.testtable t
JOIN LibraryMan.Book b ON t.Book_Title = b.Title and t.Book_Author=b.Author and t.Book_Publication_Year=b.PublicationYear
JOIN LibraryMan.Category c ON t.Book_Category = c.Name
WHERE t.Book_Title IS NOT NULL AND t.Book_Category IS NOT NULL
GO
alter table LibraryMan.[User] alter column Name NVARCHAR(100) Null
GO
insert into LibraryMan.[User] (Email)
select Distinct LTRIM(RTRIM(User_Email)) from LibraryMan.testtable
GO
Update u
set u.Name = t.[User_Name]
from LibraryMan.testtable t join LibraryMan.[User] u on u.Email=t.User_Email
GO
alter table LibraryMan.[User] alter column Name VARCHAR(100) Not Null
GO
Update u
set u.Phone = CorrectPhone
from
    LibraryMan.[User] u JOIN
    (
        select
            LTRIM(RTRIM(User_Email)) EmailKey,
            MIN(LTRIM(RTRIM(User_Phone))) CorrectPhone
        from LibraryMan.testtable
        where LTRIM(RTRIM(User_Phone)) is not null and LTRIM(RTRIM(User_Phone)) <> ''
        group by LTRIM(RTRIM(User_Email))
        having COUNT(distinct replace(REPLACE(LTRIM(RTRIM(User_Phone)),' ',''),'-',''))=1
    ) as t on u.Email = t.EmailKey
GO
Update u
set u.Phone = (
    select top 1 LTRIM(RTRIM(t.User_Phone))
    from LibraryMan.testtable t
    where LTRIM(RTRIM(t.User_Email)) = 'balazs.orban@example.com'
    ORDER BY Loan_Date DESC
)
from LibraryMan.[User] u
where u.Email = 'balazs.orban@example.com'
GO
Update u
set u.Phone = (
    select top 1 LTRIM(RTRIM(t.User_Phone))
    from LibraryMan.testtable t
    where LTRIM(RTRIM(t.User_Email)) = 'beata.takacs@example.com'
    ORDER BY Loan_Date DESC
)
from LibraryMan.[User] u
where u.Email = 'beata.takacs@example.com'
GO
Update u
set u.Phone = (
    select top 1 LTRIM(RTRIM(t.User_Phone))
    from LibraryMan.testtable t
    where LTRIM(RTRIM(t.User_Email)) = 'katalin.farkas@example.com'
    ORDER BY Loan_Date DESC
)
from LibraryMan.[User] u
where u.Email = 'katalin.farkas@example.com'
GO
update u
SET
    u.ZipCode = t.ZipCode,
    u.City = t.City,
    u.Street = t.Street
from LibraryMan.[User] u join
    (
        select
            Min(left(User_Address, CHARINDEX(',', User_Address)-1)) [Zip+City],
            Min(LTRIM(SUBSTRING(User_Address, CHARINDEX(',',User_Address)+1, 500))) [Street],
            Min(left(LTRIM(RTRIM(User_Address)), 4)) [ZipCode],
            Min(LTRIM(SUBSTRING(left(User_Address, CHARINDEX(',', User_Address)-1), CHARINDEX(' ',left(User_Address, CHARINDEX(',', User_Address)-1))+1, 500))) [City],
            User_Email [EmailKey]
        from LibraryMan.testtable
        GROUP by User_Email
        having count(distinct replace(replace(LTRIM(RTRIM(User_Address)), ',', ''), ' ', ''))=1
    ) as t on u.Email = t.EmailKey
GO
Update u
set u.ZipCode = t.ZipCode,
    u.City = t.City,
    u.Street = t.Street
from LibraryMan.[User] u join
    (
        select
            Top 1
            left(User_Address, CHARINDEX(',', User_Address)-1) [Zip+City],
            LTRIM(SUBSTRING(User_Address, CHARINDEX(',',User_Address)+1, 500)) [Street],
            left(LTRIM(RTRIM(User_Address)), 4) [ZipCode],
            LTRIM(SUBSTRING(left(User_Address, CHARINDEX(',', User_Address)-1), CHARINDEX(' ',left(User_Address, CHARINDEX(',', User_Address)-1))+1, 500)) [City],
            User_Email [EmailKey]
        from LibraryMan.testtable
        where User_Email = 'balazs.orban@example.com'
        Order by Loan_Date DESC
    ) as t on u.Email = t.EmailKey
where u.Email = 'balazs.orban@example.com'
GO
Update u
set u.ZipCode = t.ZipCode,
    u.City = t.City,
    u.Street = t.Street
from LibraryMan.[User] u join
    (
        select
            Top 1
            left(User_Address, CHARINDEX(',', User_Address)-1) [Zip+City],
            LTRIM(SUBSTRING(User_Address, CHARINDEX(',',User_Address)+1, 500)) [Street],
            left(LTRIM(RTRIM(User_Address)), 4) [ZipCode],
            LTRIM(SUBSTRING(left(User_Address, CHARINDEX(',', User_Address)-1), CHARINDEX(' ',left(User_Address, CHARINDEX(',', User_Address)-1))+1, 500)) [City],
            User_Email [EmailKey]
        from LibraryMan.testtable
        where User_Email = 'beata.takacs@example.com'
        Order by Loan_Date DESC
    ) as t on u.Email = t.EmailKey
where u.Email = 'beata.takacs@example.com'
GO
Update u
set u.ZipCode = t.ZipCode,
    u.City = t.City,
    u.Street = t.Street
from LibraryMan.[User] u join
    (
        select
            Top 1
            left(User_Address, CHARINDEX(',', User_Address)-1) [Zip+City],
            LTRIM(SUBSTRING(User_Address, CHARINDEX(',',User_Address)+1, 500)) [Street],
            left(LTRIM(RTRIM(User_Address)), 4) [ZipCode],
            LTRIM(SUBSTRING(left(User_Address, CHARINDEX(',', User_Address)-1), CHARINDEX(' ',left(User_Address, CHARINDEX(',', User_Address)-1))+1, 500)) [City],
            User_Email [EmailKey]
        from LibraryMan.testtable
        where User_Email = 'katalin.farkas@example.com'
        Order by Loan_Date DESC
    ) as t on u.Email = t.EmailKey
where u.Email = 'katalin.farkas@example.com'
GO
Insert into LibraryMan.BookCopy(BookID, CreatedBy, UpdatedBy)
select b.BookID, NULL, NULL from LibraryMan.Book b
GO
UPDATE l
SET l.UserID=u.UserID
from LibraryMan.Loan l
join LibraryMan.testtable t on l.LoanID=t.Loan_ID
join LibraryMan.[User] u on u.Email=LTRIM(RTRIM(t.User_Email))
where l.UserID is Null
GO
;with bad_loan as(
    select t.Loan_ID
    from LibraryMan.testtable t
    group by t.Loan_ID
    having sum(case when t.Book_Title is not null and t.Book_Author is not null and t.Book_Publication_Year is not null then 1 else 0 end) = 0
)
delete l
from LibraryMan.Loan l
join bad_loan b on l.LoanID=b.Loan_ID
GO
with uniquecopy as (
    select distinct t.Loan_ID, t.Book_Title, t.Book_Author, t.Book_Publication_Year
    from LibraryMan.testtable t
    where t.Book_Title is not null
)
update l
SET l.CopyID=bc.CopyID
from LibraryMan.Loan l
join uniquecopy uc on l.LoanID=uc.Loan_ID
join LibraryMan.Book b on b.Title=uc.Book_Title and b.PublicationYear = uc.Book_Publication_Year and b.Author=uc.Book_Author
join LibraryMan.BookCopy bc on bc.BookID=b.BookID
where l.CopyID is null
GO
insert into LibraryMan.UserPhone (UserID, Phone, IsPrimary)
select UserID, Phone, 1
from LibraryMan.[User]
where phone is not null and ltrim(RTRIM(Phone)) <> ''
GO
insert into LibraryMan.UserAddress (UserID, ZipCode, City, Street, IsPrimary)
select UserID, ZipCode, City, Street, 1
from LibraryMan.[User]
where (ZipCode is not null or City is not null or Street is not null) and (ltrim(rtrim(ZipCode)) <> '' and ltrim(rtrim(City)) <> '' and ltrim(RTRIM(Street)) <>'')
GO
;WITH candidate as (
    select u.UserID, LTRIM(RTRIM(t.User_Phone)) MissingPhone
    from LibraryMan.testtable t
    join LibraryMan.[User] u on u.Email =ltrim(rtrim(t.User_Email))
    where t.User_Phone Is NOT null and ltrim(RTRIM(t.User_Phone)) <> '' and not exists (select * from LibraryMan.UserPhone up where up.UserId=u.UserID and up.phone = ltrim(RTRIM(t.User_Phone)))
    group by u.UserID, LTRIM(RTRIM(t.User_Phone))
)
insert into LibraryMan.UserPhone (UserID, Phone, IsPrimary)
select c.UserID, c.MissingPhone, 0
from candidate c join libraryMan.UserPhone up on c.UserID = up.UserID
GO
;with candidateaddress as (
    select
        u.UserID,
        left(LTRIM(RTRIM(t.User_Address)), 4) [MissingZip],
        LTRIM(SUBSTRING(left(User_Address, CHARINDEX(',', User_Address)-1), CHARINDEX(' ',left(User_Address, CHARINDEX(',', User_Address)-1))+1, 500)) [missingCity],
        LTRIM(SUBSTRING(User_Address, CHARINDEX(',',User_Address)+1, 500)) [missingStreet]
    from LibraryMan.testtable t
    join LibraryMan.[User] u on u.Email=ltrim(rtrim(t.User_Email))
    where
        (ZipCode is not null or City is not null or Street is not null)
        and (ltrim(rtrim(ZipCode)) <> '' and ltrim(rtrim(City)) <> '' and ltrim(RTRIM(Street)) <>'')
        and not exists (
            select * from LibraryMan.UserAddress ua
            where
                ua.UserId=u.UserID and
                ua.ZipCode = left(LTRIM(RTRIM(t.User_Address)), 4) and
                ua.City = LTRIM(SUBSTRING(left(User_Address, CHARINDEX(',', User_Address)-1), CHARINDEX(' ',left(User_Address, CHARINDEX(',', User_Address)-1))+1, 500)) and
                ua.Street = LTRIM(SUBSTRING(User_Address, CHARINDEX(',',User_Address)+1, 500)))
    group by u.UserID, left(LTRIM(RTRIM(t.User_Address)), 4), LTRIM(SUBSTRING(left(User_Address, CHARINDEX(',', User_Address)-1), CHARINDEX(' ',left(User_Address, CHARINDEX(',', User_Address)-1))+1, 500)), LTRIM(SUBSTRING(User_Address, CHARINDEX(',',User_Address)+1, 500))
)
insert into LibraryMan.UserAddress (UserID, ZipCode, City, Street, IsPrimary)
select ca.UserID, ca.MissingZip, ca.missingCity, ca.missingStreet, 0
from candidateaddress ca join LibraryMan.UserAddress ua on ca.UserID=ua.UserID
GO
drop table if exists #addresstable
GO
select DISTINCT
    t.loan_id,
    ua.UserAddressID
into #addresstable
from LibraryMan.testtable t
join LibraryMan.UserAddress ua on left(LTRIM(rtrim(t.User_address)),4)=ua.ZipCode and substring(left(LTRIM(RTRIM(t.User_Address)), CHARINDEX(',', t.User_Address)-1), CHARINDEX(' ', t.User_Address)+1, 500)=ua.City and ltrim(rtrim(SUBSTRING(t.user_address, CHARINDEX(',', t.User_Address)+2, 500)))=ua.Street
GO
UPDATE l
SET l.UserAddressID=ad.UserAddressID
from #addresstable ad
join LibraryMan.Loan l on l.LoanID=ad.Loan_ID
GO
alter table libraryman.[User] drop column Phone
alter table libraryman.[User] drop column ZipCode
alter table libraryman.[User] drop column City
alter table libraryman.[User] drop column Street
GO
