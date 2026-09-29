CREATE DATABASE RailOneDb;
GO
USE RailOneDb;
GO
CREATE TABLE Users(UserId INT IDENTITY PRIMARY KEY, Name NVARCHAR(80), Email NVARCHAR(100) UNIQUE, Password NVARCHAR(100));
CREATE TABLE Trains(TrainNo INT PRIMARY KEY, TrainName NVARCHAR(80), Source NVARCHAR(60), Destination NVARCHAR(60),
  DepTime NVARCHAR(10), ArrTime NVARCHAR(10), BaseFare DECIMAL(8,2), Seats INT DEFAULT 100);
CREATE TABLE Bookings(PNR BIGINT IDENTITY(4100000001,1) PRIMARY KEY, UserId INT, TrainNo INT, JourneyDate DATE,
  Class NVARCHAR(5), TotalFare DECIMAL(9,2), Status NVARCHAR(20), BookedOn DATETIME DEFAULT GETDATE());
CREATE TABLE Passengers(Id INT IDENTITY PRIMARY KEY, PNR BIGINT, Name NVARCHAR(80), Age INT, Gender NVARCHAR(10), SeatNo NVARCHAR(10));
INSERT Trains VALUES
(12635,'Vaigai Express','Chennai','Madurai','06:35','13:15',420,100),
(12673,'Cheran SF Express','Chennai','Coimbatore','22:10','06:15',480,100),
(12007,'Mysuru Shatabdi','Chennai','Mysuru','07:25','13:20',900,100),
(12695,'Trivandrum Express','Chennai','Trivandrum','15:40','06:30',620,100),
(12633,'Kanyakumari Express','Chennai','Kanyakumari','17:20','07:30',650,100),
(22625,'Bengaluru Double Decker','Bengaluru','Chennai','07:20','12:30',350,100),
(12680,'Coimbatore Intercity','Coimbatore','Bengaluru','06:00','12:05',300,100),
(16721,'Pandian Express','Madurai','Chennai','21:00','06:00',430,100);
