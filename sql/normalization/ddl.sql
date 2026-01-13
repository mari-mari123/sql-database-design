drop table if exists LibraryMan.Loan
drop table if EXISTS LibraryMan.UserAddress
drop table if EXISTS LibraryMan.BookCopy
drop table if exists LibraryMan.BookCategory
drop table if exists LibraryMan.Book
drop table if exists LibraryMan.Category
drop table if EXISTS LibraryMan.UserPhone
drop table if exists LibraryMan.[User]
drop table if exists LibraryMan.Librarian
GO
create table LibraryMan.Category (
    CategoryID int identity(1,1),
    Name NVARCHAR(100) NOT NULL,
    PrimaryCategoryID int Null,
    CONSTRAINT PK_Category PRIMARY KEY(CategoryId)
)
GO
create table LibraryMan.[User] (
    UserID int IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Email VARCHAR(200) NULL,
    Phone VARCHAR(100) NULL,
    ZipCode int NULL,
    City NVARCHAR(100) NULL,
    Street NVARCHAR(200) Null,
    CONSTRAINT PK_User PRIMARY KEY(UserID)
)
GO
create table LibraryMan.Librarian (
    LibrarianID varchar(10),
    Name NVARCHAR(100) Not Null,
    Email VARCHAR(200) NULL,
    CONSTRAINT PK_Librarian PRIMARY KEY(LibrarianID)
)
GO
create table LibraryMan.Book (
    BookID int identity(1,1),
    Title NVARCHAR(400) NOT NULL,
    Publication NVARCHAR(400) NULL,
    PublicationYear int NULL,
    Author NVARCHAR(200) NULL,
    NumberOfCopies int Not NULL DEFAULT 1,
    CreatedByLibrarianID VARCHAR(10) Null,
    CONSTRAINT PK_Book PRIMARY KEY(BookID)
)
GO
create table LibraryMan.Loan (
    LoanID int,
    LendingDate DATE NOT NULL,
    ReturnDate DATE Null,
    DueDate Date Null,
    ReturnOnTime bit Null,
    LibrarianID varchar(10),
    UserID int,
    CopyID int,
    CONSTRAINT PK_Loan PRIMARY KEY(LoanID)
)
GO
create table LibraryMan.BookCopy (
    CopyID int IDENTITY(1,1),
    CreatedBy VARCHAR(10) Null,
    UpdatedBy VARCHAR(10) NULL,
    BookID int Not NULL,
    CONSTRAINT PK_BookCopy PRIMARY KEY(CopyID)
)
GO
create table LibraryMan.BookCategory (
    BookID int Not null,
    CategoryId int NOT null,
    IsPrimary bit NOT null default 0,
    CONSTRAINT PK_BookCategory PRIMARY KEY(BookID,CategoryID)
)
GO
create table LibraryMan.UserPhone (
    UserPhoneID int IDENTITY(1,1),
    UserID INT not null,
    Phone VARCHAR(200) not NULL,
    IsPrimary BIT not null default 0,
    CONSTRAINT FK_UserPhone_User FOREIGN KEY (UserID) REFERENCES LibraryMan.[User](UserID),
    constraint PK_UserPhone PRIMARY Key (UserPhoneID)
)
GO
create table LibraryMan.UserAddress (
    UserAddressID int IDENTITY(1,1),
    UserID int not null,
    ZipCode NVARCHAR(10) NULL,
    City NVARCHAR(100) NULL,
    Street NVARCHAR(200) Null,
    IsPrimary bit Not null default 0,
    CONSTRAINT FK_UserAddress_User FOREIGN KEY (UserID) REFERENCES LibraryMan.[User](UserID),
    constraint PK_UserAddress PRIMARY KEY (UserAddressID)
)
GO
Alter table LibraryMan.BookCategory add CONSTRAINT FK_BookCategory_Book FOREIGN KEY (BookID) REFERENCES LibraryMan.Book (BookID)
GO
Alter table LibraryMan.BookCategory add constraint FK_BooKCategory_Category FOREIGN KEY (CategoryID) REFERENCES LibraryMan.Category (CategoryID)
GO
ALTER TABLE LibraryMan.Loan ADD CONSTRAINT FK_Loan_BookCopy FOREIGN KEY (CopyID) REFERENCES LibraryMan.BookCopy(CopyID)
GO
ALTER TABLE LibraryMan.Loan ADD CONSTRAINT FK_Loan_User FOREIGN KEY (UserID) REFERENCES LibraryMan.[User](UserID)
GO
ALTER TABLE LibraryMan.Loan ADD CONSTRAINT FK_Loan_Librarian FOREIGN KEY (LibrarianID) REFERENCES LibraryMan.Librarian(LibrarianID)
GO
ALTER TABLE LibraryMan.BookCopy ADD CONSTRAINT FK_BookCopy_Book FOREIGN KEY (BookID) REFERENCES LibraryMan.Book(BookID)
GO
alter table libraryMan.BookCopy add constraint FK_BookCopy_Librarian_Creat FOREIGN KEY (CreatedBy) REFERENCES LibraryMan.Librarian (LibrarianID)
GO
alter table libraryMan.BookCopy add constraint FK_BookCopy_LibrarianID_Update FOREIGN KEY (UpdatedBy) REFERENCES LibraryMan.Librarian (LibrarianID)
GO
ALTER TABLE LibraryMan.Book ADD CONSTRAINT FK_Book_CreatedByLibrarian FOREIGN KEY (CreatedByLibrarianID) REFERENCES LibraryMan.Librarian(LibrarianID)
GO
alter table Libraryman.Loan add UserAddressID int FOREIGN KEY REFERENCES LibraryMan.UserAddress (UserAddressID)
GO
