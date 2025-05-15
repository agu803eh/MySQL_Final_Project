-- Use Case: Library Management System

-- 1. Create database
CREATE DATABASE IF NOT EXISTS LibraryDB;
USE LibraryDB;

-- 2. Create tables

-- Authors table
CREATE TABLE Authors (
    AuthorID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    BirthYear YEAR,
    Country VARCHAR(50)
);

-- Books table
CREATE TABLE Books (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    AuthorID INT,
    Genre VARCHAR(50),
    PublishedYear YEAR,
    ISBN VARCHAR(20) UNIQUE,
    CopiesAvailable INT DEFAULT 0,
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

-- Members table
CREATE TABLE Members (
    MemberID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20)
);

-- Staff table
CREATE TABLE Staff (
    StaffID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Position VARCHAR(50),
    HireDate DATE
);

-- Loans table
CREATE TABLE Loans (
    LoanID INT AUTO_INCREMENT PRIMARY KEY,
    BookID INT,
    MemberID INT,
    StaffID INT,
    LoanDate DATE DEFAULT (CURDATE()),
    DueDate DATE,
    ReturnDate DATE,
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

-- Fines table
CREATE TABLE Fines (
    FineID INT AUTO_INCREMENT PRIMARY KEY,
    LoanID INT,
    Amount DECIMAL(6,2),
    Paid BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID)
);

-- 3. Sample indexes for performance
CREATE INDEX idx_books_title ON Books(Title);
CREATE INDEX idx_loans_member ON Loans(MemberID);

-- 4. Sample data (optional)
INSERT INTO Authors (FirstName, LastName, BirthYear, Country) VALUES
('George', 'Orwell', 1903, 'UK'),
('Jane', 'Austen', 1975, 'UK');

INSERT INTO Books (Title, AuthorID, Genre, PublishedYear, ISBN, CopiesAvailable)
VALUES ('Animal Farm', (SELECT AuthorID FROM Authors WHERE FirstName='George' AND LastName='Orwell' LIMIT 1), 'Political Satire', 1945, '9780451526342', 5);
SET @BookID1 = LAST_INSERT_ID();

INSERT INTO Books (Title, AuthorID, Genre, PublishedYear, ISBN, CopiesAvailable)
VALUES ('Lady Susan', (SELECT AuthorID FROM Authors WHERE FirstName='Jane' AND LastName='Austen' LIMIT 1), 'Romance', 1975, '9780140439083', 3);
SET @BookID2 = LAST_INSERT_ID();

INSERT INTO Members (FirstName, LastName, Email, Phone) VALUES
('Alice', 'Smith', 'alice@example.com', '1234567890'),
('Bob', 'Johnson', 'bob@example.com', '0987654321');

INSERT INTO Staff (FirstName, LastName, Position, HireDate) VALUES
('Emily', 'Clark', 'Librarian', '2022-01-10');

-- Use the correct BookID values for Loans
INSERT INTO Loans (BookID, MemberID, StaffID, DueDate) VALUES
(@BookID1, 1, 1, '2023-12-01');
SET @LoanID1 = LAST_INSERT_ID();

INSERT INTO Loans (BookID, MemberID, StaffID, DueDate) VALUES
(@BookID2, 2, 1, '2023-12-15');
SET @LoanID2 = LAST_INSERT_ID();

INSERT INTO Fines (LoanID, Amount) VALUES
(@LoanID1, 5.00),
(@LoanID2, 0.00);
-- 5. Sample queries
-- Query to find all books by a specific author
SELECT b.Title, a.FirstName, a.LastName
FROM Books b
JOIN Authors a ON b.AuthorID = a.AuthorID
WHERE a.LastName = 'Orwell';
-- Query to find all loans for a specific member
SELECT l.LoanID, b.Title, l.LoanDate, l.DueDate
FROM Loans l
JOIN Books b ON l.BookID = b.BookID
WHERE l.MemberID = 1;
-- Query to find all overdue loans
SELECT l.LoanID, b.Title, l.DueDate
FROM Loans l
JOIN Books b ON l.BookID = b.BookID
WHERE l.ReturnDate IS NULL AND l.DueDate < CURRENT_DATE;
-- Query to calculate total fines for a specific member
SELECT SUM(f.Amount) AS TotalFines
FROM Fines f
JOIN Loans l ON f.LoanID = l.LoanID
WHERE l.MemberID = 1 AND f.Paid = FALSE;
-- Query to find all books with available copies
SELECT Title, CopiesAvailable
FROM Books
WHERE CopiesAvailable > 0;
-- Query to find all staff members
SELECT FirstName, LastName, Position
FROM Staff;
-- Query to find all authors from a specific country
SELECT FirstName, LastName
FROM Authors
WHERE Country = 'UK';
-- Query to find all books in a specific genre
SELECT Title, Genre
FROM Books
WHERE Genre = 'Dystopian';
-- Query to find all members who joined after a specific date
SELECT FirstName, LastName, JoinDate
FROM Members
WHERE JoinDate > '2023-01-01';
-- Query to find all loans handled by a specific staff member
SELECT l.LoanID, b.Title, m.FirstName, m.LastName
FROM Loans l
JOIN Books b ON l.BookID = b.BookID
JOIN Members m ON l.MemberID = m.MemberID
WHERE l.StaffID = 1;
-- Query to find all books with overdue loans
SELECT b.Title, l.DueDate
FROM Books b
JOIN Loans l ON b.BookID = l.BookID
WHERE l.ReturnDate IS NULL AND l.DueDate < CURRENT_DATE;
-- Query to find all members with unpaid fines
SELECT m.FirstName, m.LastName, SUM(f.Amount) AS TotalFines
FROM Members m
JOIN Loans l ON m.MemberID = l.MemberID
JOIN Fines f ON l.LoanID = f.LoanID
WHERE f.Paid = FALSE
GROUP BY m.MemberID
HAVING TotalFines > 0;
-- Query to find all books with a specific ISBN
SELECT Title, AuthorID, Genre, PublishedYear
FROM Books
WHERE ISBN = '9780451524935';
-- Query to find all authors with a specific last name
SELECT FirstName, LastName, BirthYear, Country
FROM Authors
WHERE LastName = 'Austen';


-- End of Library Management System schema