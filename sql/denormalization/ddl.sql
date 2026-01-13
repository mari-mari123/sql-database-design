drop table if EXISTS LibraryMan.Fact_Loan
drop table if exists LibraryMan.Dim_Book
drop table if exists LibraryMan.Dim_Geographic
drop table if exists libraryman.Dim_User
drop table if EXISTS LibraryMan.Dim_Date
drop table if EXISTS LibraryMan.Dim_Librarian
GO
Create table Libraryman.Dim_Book (
    BookKey int identity(1,1) primary key,
    Title nvarchar (200) not null,
    Publication nvarchar (200),
    PrimaryCategory nvarchar(100),
    NumberOfCopies int,
    PublicationYear int,
    Author nvarchar(200),
    BookId int
)
 GO
Create table LibraryMan.Dim_Geographic (
    AddressKey int identity(1,1) primary key,
    City nvarchar (200) not null,
    ZipCode int not null,
    Street nvarchar (200) not null,
)
GO
create table Libraryman.Dim_User (
    UserKey int identity(1,1) primary key,
    Name nvarchar(150) not null,
    Email nvarchar(150),
    PhoneNumber nvarchar(50),
    UserID int
)
GO
create table LibraryMan.Dim_Date (
    DateKey DATE PRIMARY KEY,
    Year int,
    Quarter int,
    Month int,
    MonthName VARCHAR(20),
    Day int,
    Week int,
    WeekDayName VARCHAR(20),
    IsWeekend bit
)
GO
create table LibraryMan.Dim_Librarian (
    LibrarianKey int IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) not NULL,
    Email VARCHAR(100) NULL,
    LibrarianID VARCHAR(10)
)
GO
create table LibraryMan.Fact_Loan (
    LoanKey int IDENTITY (1,1) PRIMARY KEY,
    LoanID int not null,
    ReturnOnTime bit,
    LibrarianKey int not null FOREIGN KEY REFERENCES LibraryMan.Dim_Librarian(LibrarianKey),
    UserKey int not null FOREIGN KEY REFERENCES LibraryMan.Dim_User(UserKey),
    DueDateKey date not null FOREIGN KEY REFERENCES LibraryMan.Dim_Date(DateKey),
    LendingDateKey date not null FOREIGN KEY REFERENCES LibraryMan.Dim_Date(DateKey),
    ReturnDateKey date FOREIGN KEY REFERENCES LibraryMan.Dim_Date(DateKey),
    AddressKey int not null FOREIGN KEY REFERENCES LibraryMan.Dim_Geographic(AddressKey),
    BookKey int not null FOREIGN KEY REFERENCES libraryMan.Dim_Book(BookKey)
)
GO
