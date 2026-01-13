
---books with multiple categories---

SELECT B.Title, B.Author, 
COUNT(BC.CategoryID) AS CategoryCount,
STRING_AGG(C.Name, ', ') AS Categories
FROM LibraryMan.Book B
JOIN LibraryMan.BookCategory BC ON B.BookID = BC.BookID
JOIN LibraryMan.Category C ON BC.CategoryID = C.CategoryID
GROUP BY B.BookID, B.Title, B.Author
HAVING COUNT(BC.CategoryID) > 1
ORDER BY CategoryCount DESC

---the book which was most barrowed---

SELECT TOP 1 B.Title, B.Author,
COUNT(L.LoanID) AS TotalBorrows,
DENSE_RANK() OVER (ORDER BY COUNT(L.LoanID) DESC) AS BorrowRank
FROM LibraryMan.Book B
JOIN LibraryMan.BookCopy BC ON B.BookID = BC.BookID
JOIN LibraryMan.Loan L ON BC.CopyID = L.CopyID
GROUP BY B.BookID, B.Title, B.Author
ORDER BY TotalBorrows DESC

--Top 3 users who has most barrowed books--

SELECT TOP 3 U.Name,
COUNT(L.LoanID) AS LoanCount,
SUM(COUNT(L.LoanID)) OVER (PARTITION BY U.UserID ORDER BY COUNT(L.LoanID) DESC) AS RunningLoanTotal
FROM LibraryMan.Loan L
JOIN LibraryMan.[User] U ON L.UserID = U.UserID
GROUP BY U.UserID, U.Name
ORDER BY LoanCount DESC

---best ranking librarian---

SELECT TOP 1 L.Name AS LibrarianName,
COUNT(LO.LoanID) AS TotalLoansProcessed,
RANK() OVER (ORDER BY COUNT(LO.LoanID) DESC) AS PerformanceRank
FROM LibraryMan.Librarian L
JOIN LibraryMan.Loan LO ON L.LibrarianID = LO.LibrarianID
GROUP BY L.LibrarianID, L.Name
ORDER BY TotalLoansProcessed DESC

---books were overdue, how many days? (as date of today)---

SELECT U.Name, B.Title, L.LendingDate, L.DueDate, 
DATEDIFF(DAY, L.DueDate, GETDATE()) AS DaysOverdue
FROM LibraryMan.Loan L
JOIN LibraryMan.[User] U ON L.UserID = U.UserID
JOIN LibraryMan.BookCopy BC ON L.CopyID = BC.CopyID
JOIN LibraryMan.Book B ON BC.BookID = B.BookID
WHERE L.ReturnDate IS NULL AND L.DueDate < GETDATE() 
ORDER BY DaysOverdue DESC

---users with a pattern of late returns---

SELECT Name,
COUNT(*) AS LateLoanCount
FROM (SELECT U.Name, L.LoanID, L.LendingDate, L.DueDate, L.ReturnDate,
DATEDIFF(DAY, L.DueDate, GETDATE()) AS DaysOverdue,
ROW_NUMBER() OVER (PARTITION BY U.UserID ORDER BY L.LendingDate) AS LoanSeq,
(ROW_NUMBER() OVER (PARTITION BY U.UserID ORDER BY L.LendingDate) -
ROW_NUMBER() OVER (PARTITION BY U.UserID, CASE WHEN L.ReturnDate IS NULL 
AND L.DueDate < GETDATE() THEN 1 ELSE 0 END ORDER BY L.LendingDate)) AS GroupSeq
FROM LibraryMan.Loan L
JOIN LibraryMan.[User] U ON L.UserID = U.UserID) 
AS LoanSequence
WHERE DaysOverdue > 0
GROUP BY Name, GroupSeq
HAVING COUNT(*) > 1
ORDER BY LateLoanCount DESC