-- Create the database
CREATE DATABASE CinemaDB;
drop database CinemaDB;
USE CinemaDB;

-- Users Table
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100),
    Email NVARCHAR(100) UNIQUE,
    Password NVARCHAR(255),
    Phone NVARCHAR(20),
    Role NVARCHAR(50) CHECK (Role IN ('User', 'Admin'))
);

-- Rooms Table
CREATE TABLE Rooms (
    Id INT PRIMARY KEY IDENTITY(1,1),
    RoomName NVARCHAR(100),
    Capacity INT,
    RoomDescription NVARCHAR(255),
    Image NVARCHAR(255)
);

-- Movie Categories Table
CREATE TABLE MovieCategories (
    Id INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100)
);

-- Movies Table
CREATE TABLE Movies (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(100),
    Description NVARCHAR(500),
    Duration INT, -- in minutes
    CategoryId INT FOREIGN KEY REFERENCES MovieCategories(Id),
    ReleaseDate DATE,
    Image NVARCHAR(255),
    TicketPrice DECIMAL(10, 2), -- New field for movie ticket price
    Rating INT CHECK (Rating BETWEEN 1 AND 5) -- Rating for the movie
);

CREATE TABLE PrivateRooms (
    Id INT PRIMARY KEY IDENTITY(1,1),
    RoomId INT FOREIGN KEY REFERENCES Rooms(Id),
    VIPName NVARCHAR(100),
    VIPDescription NVARCHAR(255),
    VIPPrice DECIMAL(10, 2),
    Capacity INT
);

CREATE TABLE PrivateBookings (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT FOREIGN KEY REFERENCES Users(Id),
    PrivateRoomId INT FOREIGN KEY REFERENCES PrivateRooms(Id),
    MovieId INT FOREIGN KEY REFERENCES Movies(Id),
    BookingDate DATE ,
    StartTime TIME ,
    EndTime TIME ,
    TotalPrice DECIMAL(10,2) ,
    PaymentStatus NVARCHAR(50) CHECK (PaymentStatus IN ('Pending', 'Paid', 'Failed')),
    PaymentMethod NVARCHAR(50) CHECK (PaymentMethod IN ('Credit Card', 'PayPal', 'Cash')),
    Status NVARCHAR(50) DEFAULT 'Pending' -- Example: Pending, Confirmed, Cancelled
);


-- Room Availability Table (with days and times)
CREATE TABLE RoomAvailability (
    Id INT PRIMARY KEY IDENTITY(1,1),
    -- Nullable references: one of these should be filled
    RoomId INT NULL FOREIGN KEY REFERENCES Rooms(Id),
    PrivateRoomId INT NULL FOREIGN KEY REFERENCES PrivateRooms(Id),
    AvailableDay NVARCHAR(20) CHECK (AvailableDay IN ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun')),
    StartTime TIME,
    EndTime TIME,
);
ALTER TABLE Bookings
ALTER COLUMN StartTime DATETIME ;

ALTER TABLE Bookings
ALTER COLUMN EndTime DATETIME ;

ALTER TABLE PrivateBookings
ALTER COLUMN StartTime DATETIME ;

ALTER TABLE PrivateBookings
ALTER COLUMN EndTime DATETIME ;

ALTER TABLE PrivateBookings
ALTER COLUMN BookingDate DATETIME ; 

ALTER TABLE Movies
ADD IsViable BIT NOT NULL DEFAULT 1;

-- Bookings Table
CREATE TABLE Bookings (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT FOREIGN KEY REFERENCES Users(Id),
    RoomId INT FOREIGN KEY REFERENCES Rooms(Id),
    MovieId INT FOREIGN KEY REFERENCES Movies(Id),
    BookingDate DATETIME DEFAULT GETDATE(),
    StartTime TIME,
    EndTime TIME,
    TotalPrice DECIMAL(10, 2),
    Cancelled BIT DEFAULT 0, -- 0 means not canceled, 1 means canceled
    CancellationDate DATETIME, -- Date when booking was canceled
    PaymentStatus NVARCHAR(50) CHECK (PaymentStatus IN ('Pending', 'Paid', 'Failed')), -- New field for payment status
    PaymentMethod NVARCHAR(50) CHECK (PaymentMethod IN ('Credit Card', 'PayPal', 'Cash')) -- New field for payment method
);


-- Blacklist Table
CREATE TABLE Blacklist (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT FOREIGN KEY REFERENCES Users(Id),
    Reason NVARCHAR(255)
);

-- Reviews Table (for movie reviews)
CREATE TABLE Reviews (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT FOREIGN KEY REFERENCES Users(Id),
    MovieId INT FOREIGN KEY REFERENCES Movies(Id),
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Title NVARCHAR(100), -- New field for review title
    ReviewText NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE()
);


-- Chat Messages Table (User and Admin or between users)
CREATE TABLE ChatMessages (
    Id INT PRIMARY KEY IDENTITY(1,1),
    SenderId INT FOREIGN KEY REFERENCES Users(Id),
    ReceiverId INT FOREIGN KEY REFERENCES Users(Id),
    Message NVARCHAR(500),
    SentAt DATETIME DEFAULT GETDATE()
);

-- CONTACT US MESSAGES TABLE (Admin can view these messages)
CREATE TABLE contact_us (
    id  INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) ,
    email VARCHAR(100) ,
    phone VARCHAR(20),
    subject VARCHAR(200),
    message TEXT ,
	submission_date DATETIME2 DEFAULT GETDATE()
); 

-- ROOM BOOKINGS TABLE (Room booking with Snacks)
CREATE TABLE RoomBookings (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT FOREIGN KEY REFERENCES Users(Id),
    RoomId INT FOREIGN KEY REFERENCES Rooms(Id),
    MovieId INT FOREIGN KEY REFERENCES Movies(Id),
    BookingDate DATE,
    StartTime TIME,
    EndTime TIME,
    SeatNumber NVARCHAR(20),
    Status NVARCHAR(50) DEFAULT 'Pending'
);

CREATE TABLE Payments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    BookingId INT FOREIGN KEY REFERENCES Bookings(Id),
    Amount DECIMAL(10, 2),
    PaymentDate DATETIME DEFAULT GETDATE(),
    PaymentMethod NVARCHAR(50) CHECK (PaymentMethod IN ('Credit Card', 'PayPal', 'Cash')),
    PaymentStatus NVARCHAR(50) CHECK (PaymentStatus IN ('Pending', 'Paid', 'Failed')),
);



-- Inserting data into Users Table
INSERT INTO Users (FullName, Email, Password, Phone, Role)
VALUES
('John Doe', 'john.doe@example.com', 'password123', '123-456-7890', 'User'),
('Jane Smith', 'jane.smith@example.com', 'password456', '987-654-3210', 'User'),
('Admin User', 'admin@cinema.com', 'adminpassword', '555-555-5555', 'Admin');

-- Inserting data into Movie Categories Table
INSERT INTO MovieCategories (CategoryName)
VALUES
('Action'),
('Comedy'),
('Drama'),
('Horror'),
('Sci-Fi');

-- Inserting data into Movies Table
INSERT INTO Movies (Title, Description, Duration, CategoryId, ReleaseDate, Image, TicketPrice, Rating)
VALUES
('Avengers: Endgame', 'The Avengers assemble to stop Thanos and save the universe.', 181, 1, '2019-04-26', 'avengers_endgame.jpg', 15.00, 5),
('The Hangover', 'A group of friends tries to piece together what happened during a wild bachelor party.', 100, 2, '2009-06-05', 'the_hangover.jpg', 12.50, 4),
('The Shawshank Redemption', 'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.', 142, 3, '1994-09-22', 'shawshank_redemption.jpg', 10.00, 5),
('It', 'A group of bullied kids band together to destroy a monster that has taken the shape of a clown.', 135, 4, '2017-09-08', 'it.jpg', 13.00, 4),
('Inception', 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a CEO.', 148, 5, '2010-07-16', 'inception.jpg', 14.00, 5);

-- Inserting data into Rooms Table
INSERT INTO Rooms (RoomName, Capacity, RoomDescription, Image)
VALUES
('Room 1', 100, 'Standard movie theater with comfortable seating.', 'room1.jpg'),
('Room 2', 50, 'Small theater perfect for intimate screenings.', 'room2.jpg'),
('Room 3', 200, 'Large theater for blockbuster movies with Dolby sound.', 'room3.jpg');

-- Inserting data into Room Availability Table
INSERT INTO RoomAvailability (RoomId, AvailableDay, StartTime, EndTime)
VALUES
(1, 'Mon', '10:00', '12:00'),
(1, 'Mon', '14:00', '16:00'),
(2, 'Tue', '10:00', '12:00'),
(3, 'Wed', '12:00', '14:00'),
(1, 'Thu', '16:00', '18:00');

-- Inserting data into Bookings Table
INSERT INTO Bookings (UserId, RoomId, MovieId, BookingDate, StartTime, EndTime, TotalPrice, PaymentStatus, PaymentMethod)
VALUES
(1, 1, 1, '2025-04-18', '10:00', '12:00', 15.00, 'Paid', 'Credit Card'),
(2, 2, 2, '2025-04-19', '14:00', '16:00', 12.50, 'Pending', 'PayPal');

-- Inserting data into Blacklist Table
INSERT INTO Blacklist (UserId, Reason)
VALUES
(3, 'Suspicious activity detected');

-- Inserting data into Reviews Table
INSERT INTO Reviews (UserId, MovieId, Rating, Title, ReviewText)
VALUES
(1, 1, 5, 'Amazing movie!', 'The Avengers: Endgame is a masterpiece, with incredible action and heart. Must watch!'),
(2, 4, 4, 'Scary but entertaining', 'It had some scary moments, but it was also a lot of fun. Highly recommend for horror fans.');

-- Inserting data into ChatMessages Table
INSERT INTO ChatMessages (SenderId, ReceiverId, Message)
VALUES
(1, 3, 'Hello, I have a question about booking a ticket for the Avengers movie.'),
(2, 1, 'Do you want to join me for The Hangover on Friday?');

-- Inserting data into Contact Us Table
INSERT INTO contact_us (name, email, phone, subject, message)
VALUES
('Michael Green', 'michael.green@example.com', '123-789-4560', 'Booking Issues', 'I was charged incorrectly for my recent booking. Please help!'),
('Sarah Blue', 'sarah.blue@example.com', '555-987-6543', 'General Inquiry', 'Could you please tell me about upcoming movie releases?');

-- Inserting data into RoomBookings Table
INSERT INTO RoomBookings (UserId, RoomId, MovieId, BookingDate, StartTime, EndTime, SeatNumber, Status)
VALUES
(1, 1, 1, '2025-04-20', '10:00', '12:00', 'A1', 'Confirmed'),
(2, 2, 2, '2025-04-22', '14:00', '16:00', 'B2', 'Pending');


-- Sample Payments
INSERT INTO Payments (BookingId, Amount, PaymentMethod, PaymentStatus)
VALUES
(1, 15.00, 'Credit Card', 'Paid'),
(2, 12.50, 'PayPal', 'Pending');
----------------------------



-- Create the database
CREATE DATABASE CinemaDB;
USE CinemaDB;

-- Users Table
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100),
    Email NVARCHAR(100) UNIQUE,
    Password NVARCHAR(255),
    Phone NVARCHAR(20),
    Role NVARCHAR(50) CHECK (Role IN ('User', 'Admin'))
);

-- Rooms Table
CREATE TABLE Rooms (
    Id INT PRIMARY KEY IDENTITY(1,1),
    RoomName NVARCHAR(100),
    Capacity INT,
    RoomDescription NVARCHAR(255),
    Image NVARCHAR(255)
);

-- Movie Categories Table
CREATE TABLE MovieCategories (
    Id INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100)
);

-- Movies Table
CREATE TABLE Movies (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(100),
    Description NVARCHAR(500),
    Duration INT, -- in minutes
    CategoryId INT FOREIGN KEY REFERENCES MovieCategories(Id),
    ReleaseDate DATE,
    Image NVARCHAR(255),
    TicketPrice DECIMAL(10, 2),
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    IsViable BIT NOT NULL DEFAULT 1 -- NEW
);
TRUNCATE TABLE Movies;
DELETE FROM Movies;


---- Private Rooms Table
--CREATE TABLE PrivateRooms (
--    Id INT PRIMARY KEY IDENTITY(1,1),
--    RoomId INT FOREIGN KEY REFERENCES Rooms(Id),
--    VIPName NVARCHAR(100),
--    VIPDescription NVARCHAR(255),
--    VIPPrice DECIMAL(10, 2),
--    Capacity INT
--);
-- Private Rooms Table
CREATE TABLE PrivateRooms (
    Id INT PRIMARY KEY IDENTITY(1,1),
    VIPName NVARCHAR(100),
    VIPDescription NVARCHAR(255),
    VIPPrice DECIMAL(10, 2),
    Capacity INT
);

-- Private Bookings Table
CREATE TABLE PrivateBookings (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT FOREIGN KEY REFERENCES Users(Id),
    PrivateRoomId INT FOREIGN KEY REFERENCES PrivateRooms(Id),
    MovieId INT FOREIGN KEY REFERENCES Movies(Id),
    BookingDate DATETIME,
    StartTime DATETIME,
    EndTime DATETIME,
    TotalPrice DECIMAL(10,2),
    PaymentStatus NVARCHAR(50) CHECK (PaymentStatus IN ('Pending', 'Paid', 'Failed')),
    PaymentMethod NVARCHAR(50) CHECK (PaymentMethod IN ('Credit Card', 'PayPal', 'Cash')),
    Status NVARCHAR(50) DEFAULT 'Pending'
);

-- Room Availability Table (linked to standard or private rooms)
CREATE TABLE RoomAvailability (
    Id INT PRIMARY KEY IDENTITY(1,1),
    RoomId INT NULL FOREIGN KEY REFERENCES Rooms(Id),
    PrivateRoomId INT NULL FOREIGN KEY REFERENCES PrivateRooms(Id),
    AvailableDay NVARCHAR(20) CHECK (AvailableDay IN ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun')),
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    IsAvailable BIT DEFAULT 1
);

-- Bookings Table
CREATE TABLE Bookings (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT FOREIGN KEY REFERENCES Users(Id),
    RoomId INT FOREIGN KEY REFERENCES Rooms(Id),
    MovieId INT FOREIGN KEY REFERENCES Movies(Id),
    BookingDate DATETIME DEFAULT GETDATE(),
    StartTime DATETIME,
    EndTime DATETIME,
    TotalPrice DECIMAL(10, 2),
    Cancelled BIT DEFAULT 0,
    CancellationDate DATETIME,
    PaymentStatus NVARCHAR(50) CHECK (PaymentStatus IN ('Pending', 'Paid', 'Failed')),
    PaymentMethod NVARCHAR(50) CHECK (PaymentMethod IN ('Credit Card', 'PayPal', 'Cash'))
);

-- Blacklist Table
CREATE TABLE Blacklist (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT FOREIGN KEY REFERENCES Users(Id),
    Reason NVARCHAR(255)
);

-- Reviews Table
CREATE TABLE Reviews (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT FOREIGN KEY REFERENCES Users(Id),
    MovieId INT FOREIGN KEY REFERENCES Movies(Id),
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Title NVARCHAR(100),
    ReviewText NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Chat Messages Table
CREATE TABLE ChatMessages (
    Id INT PRIMARY KEY IDENTITY(1,1),
    SenderId INT FOREIGN KEY REFERENCES Users(Id),
    ReceiverId INT FOREIGN KEY REFERENCES Users(Id),
    Message NVARCHAR(500),
    SentAt DATETIME DEFAULT GETDATE()
);

-- Contact Us Table
CREATE TABLE contact_us (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    subject VARCHAR(200),
    message TEXT,
    submission_date DATETIME2 DEFAULT GETDATE()
);

-- Room Bookings Table (with Snacks)
CREATE TABLE RoomBookings (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT FOREIGN KEY REFERENCES Users(Id),
    RoomId INT FOREIGN KEY REFERENCES Rooms(Id),
    MovieId INT FOREIGN KEY REFERENCES Movies(Id),
    BookingDate DATE,
    StartTime TIME,
    EndTime TIME,
    SeatNumber NVARCHAR(20),
    Status NVARCHAR(50) DEFAULT 'Pending'
);

-- Payments Table
CREATE TABLE Payments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    BookingId INT FOREIGN KEY REFERENCES Bookings(Id),
    Amount DECIMAL(10, 2),
    PaymentDate DATETIME DEFAULT GETDATE(),
    PaymentMethod NVARCHAR(50) CHECK (PaymentMethod IN ('Credit Card', 'PayPal', 'Cash')),
    PaymentStatus NVARCHAR(50) CHECK (PaymentStatus IN ('Pending', 'Paid', 'Failed'))
);


ALTER TABLE MovieCategories
ADD IsVisible BIT NOT NULL DEFAULT 1;

ALTER TABLE Bookings
ADD Seat1 VARCHAR(10),
    Seat2 VARCHAR(10),
    Seat3 VARCHAR(10);

	INSERT INTO Users (FullName, Email, Password, Phone, Role)
VALUES ('Test User', 'test@example.com', '123456', '1234567890', 'User');

SELECT * FROM PrivateRooms WHERE Id = 3;

-- Make sure a Room with Id = 1 exists first
INSERT INTO PrivateRooms ( VIPName, VIPDescription, VIPPrice, Capacity)
VALUES ( 'VIP Room A', 'Luxury private room with surround sound', 50.00, 8);

SELECT * FROM Rooms WHERE Id = 1;


SELECT name
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('PrivateRooms');

ALTER TABLE PrivateRooms
DROP CONSTRAINT FK__PrivateRo__RoomI__4316F928;


ALTER TABLE PrivateRooms
DROP COLUMN RoomId;

INSERT INTO PrivateRooms (VIPName, VIPDescription, VIPPrice, Capacity)
VALUES ('VIP Room A', 'Luxury VIP room with surround sound', 50.00, 8);
SELECT * FROM Movies WHERE Id = 2;
INSERT INTO MovieCategories (CategoryName) VALUES ('Action');


INSERT INTO Movies (Title, Description, Duration, CategoryId, ReleaseDate, Image, TicketPrice, Rating, IsViable)
VALUES (
  'Inception',
  'A mind-bending thriller by Christopher Nolan.',
  148,
  1, -- Make sure this ID exists in MovieCategories
  '2010-07-16',
  'inception.jpg',
  10.00,
  5,
  1
);

ALTER TABLE Payments
ADD PrivateBookingId INT NULL FOREIGN KEY REFERENCES PrivateBookings(Id);


-- 1. Action Movie
('John Wick: Chapter 4',
 'John Wick uncovers a path to defeating The High Table. But before he can earn his freedom, Wick must face a new enemy.',
 169, 1, '2023-03-24',
 'https://m.media-amazon.com/images/M/MV5BMTJhOGFkMmUtMzU5MC00MzI5LThmNzktYjVjMzI0NDVkZTVlXkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_FMjpg_UX1000_.jpg',
 15.00, 5, 1),

-- 2. Adventure
('Dune: Part Two',
 'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family.',
 166, 2, '2024-03-01',
 'https://m.media-amazon.com/images/M/MV5BMTJlOTQ2NGYtYjMzOS00MmRhLTk2ZmYtZTcxNDhiNTRiYjI0XkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_FMjpg_UX1000_.jpg',
 18.00, 5, 1),
 INSERT INTO Movies (Title, Description, Duration, CategoryId, ReleaseDate, Image, TicketPrice, Rating, IsViable)
VALUES 
-- 3. Drama
('Oppenheimer',
 'The story of American scientist J. Robert Oppenheimer and his role in the development of the atomic bomb.',
 180, 3, '2023-07-21',
 'https://m.media-amazon.com/images/M/MV5BYzY1NGVkNDAtZTYxMi00N2VhLWEzNzYtM2I5Y2NlODdkNzMyXkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_.jpg',
 20.00, 5, 1),

-- 4. Sci-Fi
('Interstellar',
 'A team of explorers travel through a wormhole in space in an attempt to ensure humanity\'s survival.',
 169, 4, '2014-11-07',
 'https://m.media-amazon.com/images/I/91kFYg4fX3L._AC_UF1000,1000_QL80_.jpg',
 12.00, 5, 1),

-- 5. Animation
('Spider-Man: Into the Spider-Verse',
 'Teen Miles Morales becomes Spider-Man of his reality, crossing paths with five counterparts from other dimensions.',
 117, 5, '2018-12-14',
 'https://m.media-amazon.com/images/I/81d8UeK+J-L._AC_UF894,1000_QL80_.jpg',
 10.00, 5, 1);


INSERT INTO Movies (Title, Description, Duration, CategoryId, ReleaseDate, Image, TicketPrice, Rating, IsViable)
VALUES 
('The Conjuring',
 'Paranormal investigators Ed and Lorraine Warren work to help a family terrorized by a dark presence in their farmhouse.',
 112, 2, '2013-07-19',
 'https://m.media-amazon.com/images/I/81p+xe8cbnL._AC_UF894,1000_QL80_.jpg',
 11.00, 4, 1),

-- 7. Comedy
('The Hangover',
 'Three buddies wake up from a bachelor party in Las Vegas with no memory and the bachelor missing.',
 100, 4, '2009-06-05',
 'https://m.media-amazon.com/images/I/71xBLRBYOiL._AC_UF894,1000_QL80_.jpg',
 9.00, 4, 1),

-- 8. Crime
('The Godfather',
 'An organized crime dynasty\'s aging patriarch transfers control of his clandestine empire to his reluctant son.',
 175, 6, '1972-03-24',
 'https://m.media-amazon.com/images/I/51rggtPgmRL._AC_.jpg',
 14.00, 5, 1),

-- 9. Documentary
('Free Solo',
 'Follow Alex Honnold as he attempts to become the first person to free solo climb El Capitan in Yosemite National Park.',
 100, 7, '2018-12-13',
 'https://m.media-amazon.com/images/I/71lTtSuLZyL._AC_UF894,1000_QL80_.jpg',
 8.00, 5, 1),

-- 10. Family
('Paddington 2',
 'Paddington, now happily settled with the Brown family, picks up a series of odd jobs to buy a gift for his aunt.',
 103, 8, '2017-11-10',
 'https://m.media-amazon.com/images/I/91o9H9n9U7L._AC_UF1000,1000_QL80_.jpg',
 7.50, 5, 1),

-- 11. Animation
('Inside Out',
 'After young Riley is uprooted from her Midwest life, her emotions conflict on how best to navigate a new city and school.',
 95, 3, '2015-06-19',
 'https://m.media-amazon.com/images/I/71w6xk5KqXL._AC_UF894,1000_QL80_.jpg',
 9.00, 5, 1),

-- 12. Action
('Mad Max: Fury Road',
 'In a post-apocalyptic wasteland, Max teams up with a mysterious woman to flee from a cult leader.',
 120, 1, '2015-05-15',
 'https://m.media-amazon.com/images/I/81Tt3OgQE4L._AC_UF894,1000_QL80_.jpg',
 13.00, 4, 1);



 INSERT INTO PrivateRooms (VIPName, VIPDescription, VIPPrice, Capacity)
VALUES
('Silver Lounge', 'Cozy room with recliners and private screen', 75.00, 4),
('Gold Lounge', 'Spacious room with luxury seats and snacks included', 120.00, 6),
('Platinum Suite', 'Premium room with on-demand service and full privacy', 200.00, 8),
('Family Room', 'Comfortable room for families with kids amenities', 90.00, 5),
('Couples Corner', 'Romantic setup with soft lighting and drinks', 80.00, 2);
