insert into LibraryMan.Dim_Geographic (City, ZipCode, Street)
select City, ZipCode, Street
from LibraryMan.UserAddress ua
where NOT EXISTS (
    select *
    from LibraryMan.Dim_Geographic dg
    where dg.ZipCode = ua.ZipCode and dg.City=ua.City and dg.Street=ua.Street
)
GO
insert into LibraryMan.Dim_Book (Title, Publication, NumberOfCopies, PublicationYear, Author, BookID)
select Title, Publication, NumberOfCopies, PublicationYear, Author, BookID
from LibraryMan.Book b
where not exists(
select *
from LibraryMan.Dim_Book db
where db.BookID = b.BookID
)
GO
update LibraryMan.Dim_Book
set PrimaryCategory = c.name
from LibraryMan.Book b
join LibraryMan.BookCategory bc on b.BookID=bc.BookID
join LibraryMan.Category c on c.CategoryID=bc.CategoryId and IsPrimary=1
join LibraryMan.Dim_Book db on db.BookID=b.BookID
GO
insert into LibraryMan.Dim_Librarian (Name,Email,LibrarianID)
select Name,Email,LibrarianID
from LibraryMan.librarian as l
where not exists(
select *
from LibraryMan.Dim_Librarian as db
where db.LibrarianID = l.LibrarianID
)
GO
DECLARE @lowerboundary date = (SELECT MIN(x) FROM (
    SELECT MIN(LendingDate) AS x FROM LibraryMan.Loan
    UNION ALL SELECT MIN(ReturnDate) FROM LibraryMan.Loan
    UNION ALL SELECT MIN(DueDate) FROM LibraryMan.Loan
) m);
DECLARE @upperboundary date = (SELECT MAX(x) FROM (
    SELECT MAX(LendingDate) AS x FROM LibraryMan.Loan
    UNION ALL SELECT MAX(ReturnDate) FROM LibraryMan.Loan
    UNION ALL SELECT MAX(DueDate) FROM LibraryMan.Loan
) m)
declare @actualdate date
set @actualdate=@lowerboundary
while @actualdate <= @upperboundary
begin
	insert LibraryMan.Dim_Date(datekey, year, quarter, month, MonthName, day, Week, WeekDayName, IsWeekend)
	values (
            @actualdate,
            year(@actualdate),
            datepart(quarter,@actualdate),
            month(@actualdate),
            DATENAME(month, @actualdate),
            day(@actualdate),
            DATENAME(week, @actualdate),
            DATENAME(WEEKDAY, @actualdate),
            IIF(DATENAME(WEEKDAY, @actualdate) in ('Sunday','Saturday'), 1, 0)
        )
	select @actualdate=dateadd(day,1,@actualdate)
end
GO
Insert into LibraryMan.Dim_User(Name, Email, PhoneNumber, UserID)
select u.Name, u.Email, up.Phone, u.UserID
from LibraryMan.[User] u join LibraryMan.UserPhone up on u.UserID=up.UserID where IsPrimary=1
GO
insert into libraryman.fact_loan (ReturnOnTime, LibrarianKey, UserKey, DueDateKey, ReturnDateKey, LendingDateKey, BookKey,AddressKey, LoanId)
select l.returnontime, dl.LibrarianKey, du.userkey, l.DueDate, l.ReturnDate, l.LendingDate, db.BookKey, g.AddressKey, l.LoanID
from LibraryMan.Loan l
join LibraryMan.Dim_Librarian dl on l.LibrarianID=dl.LibrarianID
join LibraryMan.BookCopy bc on bc.CopyID=l.CopyID
join LibraryMan.Book b on b.BookID=bc.BookID
join LibraryMan.Dim_Book db on b.BookID=db.BookID
join LibraryMan.[User] u on u.UserID=l.UserID
join LibraryMan.Dim_User du on u.UserID=du.userId
join LibraryMan.UserAddress a on a.UserAddressID=l.UserAddressID
join LibraryMan.Dim_Geographic g on g.City=a.City and g.ZipCode=a.ZipCode and g.Street=a.Street
