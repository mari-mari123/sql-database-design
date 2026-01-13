-- Trigger
Drop TRIGGER if EXISTS LibraryMan.trg_UpdateLoanModifiedOn
Alter table LibraryMan.Loan ADD CreatedOn DATETIME not null DEFAULT GETDATE()
Alter table LibraryMan.Loan ADD ModifiedOn DATETIME not null DEFAULT GETDATE()
GO
CREATE TRIGGER trg_UpdateLoanModifiedOn on LibraryMan.Loan
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE l SET ModifiedOn = GETDATE() FROM LibraryMan.Loan l join inserted i on l.LoanId=i.LoanId
END;
GO
Alter table LibraryMan.Fact_Loan Add LoadedAt DATETIME not null DEFAULT GETDATE()
Alter table LibraryMan.Fact_Loan Add SourceModifiedOn DATETIME not NULL DEFAULT GETDATE()
GO
DECLARE @LastETL datetime
select @LastETL = MAX(SourceModifiedOn) FROM LibraryMan.Fact_Loan
DROP TABLE IF EXISTS #tmp_loan
select * into #tmp_loan from LibraryMan.Loan where ModifiedOn > @LastETL

MERGE INTO LibraryMan.Dim_Librarian AS target
USING (select distinct l.Name, t.LibrarianID, l.Email from #tmp_loan t join LibraryMan.Librarian l on t.LibrarianID=l.LibrarianID) AS source
ON target.LibrarianID = source.LibrarianID
WHEN MATCHED AND ((target.Name <> source.Name) OR (target.Email <> source.Email))
    THEN UPDATE SET target.Name = Source.Name, target.Email = source.Email
WHEN NOT MATCHED BY target
    THEN INSERT (Name, Email, LibrarianID) VALUES (source.Name, source.Email, source.LibrarianID);

MERGE INTO LibraryMan.Dim_User AS t
USING (select distinct u.Name, t.UserID, u.Email, up.Phone from #tmp_loan t join LibraryMan.[User] u on t.UserID=u.UserID join LibraryMan.UserPhone up on u.UserID=up.UserID where up.IsPrimary=1) AS s
ON t.UserID = s.UserId
WHEN MATCHED AND ((t.Name <> s.Name) or (t.Email <> s.Email) or (t.PhoneNumber<>s.Phone))
    THEN UPDATE SET t.Name=s.Name,t.Email=s.Email,t.PhoneNumber=s.Phone
WHEN NOT MATCHED BY TARGET
    THEN INSERT (Name, Email, PhoneNumber, UserId) values (s.name, s.Email, s.Phone, s.UserID);

MERGE INTO LibraryMan.Dim_Geographic AS t
USING (select distinct ua.City, ua.ZipCode, ua.Street from #tmp_loan t join LibraryMan.UserAddress ua on ua.UserAddressID=t.UserAddressID) AS s
ON t.City=s.City and t.ZipCode=s.ZipCode and t.street=s.street
WHEN NOT MATCHED BY TARGET
    THEN INSERT (City, ZipCode, Street) VALUES (s.City, s.ZipCode, s.street);

MERGE INTO LibraryMan.Dim_Book AS t
USING (select distinct b.Title, c.Name as PrimaryCategory, b.NumberOfCopies, b.PublicationYear, b.Author, b.BookID from #tmp_loan l join LibraryMan.BookCopy bc on l.CopyID=bc.CopyID join LibraryMan.Book b on bc.BookID=b.BookID join LibraryMan.BookCategory bca on bca.bookid=b.bookid and bca.IsPrimary=1 join LibraryMan.Category c on c.CategoryID=bca.CategoryId) AS s
ON t.BookID=s.BookID
WHEN MATCHED AND ((t.title<>s.Title) or (t.PrimaryCategory<>s.PrimaryCategory) or (t.NumberOfCopies<>s.NumberOfCopies) or (t.PublicationYear<>s.PublicationYear) or (t.Author<>s.Author))
    THEN UPDATE SET t.title=s.Title, t.PrimaryCategory=s.PrimaryCategory, t.NumberOfCopies=s.NumberOfCopies, t.PublicationYear=s.PublicationYear, t.Author=s.Author
WHEN NOT MATCHED BY TARGET
    THEN INSERT (Title, PrimaryCategory, NumberOfCopies, PublicationYear, Author, BookId) VALUES (s.Title, s.PrimaryCategory, s.NumberOfCopies, s.PublicationYear, s.Author, s.BookID);

MERGE INTO LibraryMan.Fact_Loan AS target
USING (SELECT
        li.LibrarianKey,
        u.UserKey,
        t.DueDate,
        t.LendingDate,
        t.ReturnDate,
        db.BookKey,
        t.ReturnOnTime,
        t.LoanId,
        g.AddressKey,
        t.ModifiedOn
    FROM #tmp_loan t
    join libraryman.Dim_Librarian li on t.LibrarianID=li.LibrarianID
    join libraryMan.Dim_User u on u.UserId=t.UserId
    join libraryman.BookCopy bc on t.CopyID=bc.CopyID
    join libraryMan.book b on bc.bookid=b.BookID
    join libraryMan.Dim_Book db on db.bookid=b.bookid
    join libraryman.loan l on l.loanid=t.loanid
    join libraryman.useraddress ua on ua.useraddressid=t.useraddressid
    join LibraryMan.Dim_Geographic g on  g.City=ua.City and g.ZipCode=ua.ZipCode and g.Street=ua.Street) AS source
ON target.LoanID = source.LoanID
WHEN MATCHED and ((target.SourceModifiedOn<>source.ModifiedOn)
    or (target.ReturnDateKey<>source.ReturnDate)
    or (target.LendingDateKey<>source.LendingDate)
    or (target.ReturnOnTime<>source.ReturnOnTime)
    or (target.DueDateKey<>source.DueDate) )
    THEN
        UPDATE SET target.SourceModifiedOn = source.ModifiedOn,
        target.LendingDateKey = source.LendingDate,
        target.ReturnDateKey = source.ReturnDate,
        target.ReturnOnTime = source.ReturnOnTime,
        target.DueDateKey=source.DueDate,
        target.LibrarianKey=source.LibrarianKey,
        target.UserKey=source.userkey,
        target.AddressKey=source.AddressKey,
        target.BookKey=source.BookKey
WHEN NOT MATCHED BY TARGET
    THEN
        INSERT (LibrarianKey, UserKey, DueDateKey, LendingDateKey, ReturnDateKey, ReturnOnTime, LoanID, AddressKey, BookKey, LoadedAt, SourceModifiedOn)
        VALUES (source.LibrarianKey, source.UserKey, source.DueDate, source.LendingDate, source.ReturnDate, source.ReturnOnTime, source.LoanID, source.AddressKey, source.BookKey, GETDATE(), source.ModifiedOn);
