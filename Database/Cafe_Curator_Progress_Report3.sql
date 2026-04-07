-- Final Project: Cafe Curator Database with sample data and sample queries
-- Drop database if it exists already (for reruns)
DROP DATABASE IF EXISTS cafe_curator;
-- Create the database
CREATE DATABASE cafe_curator;
-- For use the database
USE cafe_curator;
CREATE TABLE User (
UserID INT PRIMARY KEY AUTO_INCREMENT,
Username VARCHAR(50) NOT NULL UNIQUE,
Email VARCHAR(100) NOT NULL UNIQUE,
Password VARCHAR(255) NOT NULL,
RegDate DATE NOT NULL,
CONSTRAINT chk_email_format CHECK (Email LIKE '%_@_%._%')
);
-- Regular User Table : Type of User
CREATE TABLE Regular_User (
UserID INT PRIMARY KEY,
Level INT NOT NULL DEFAULT 1,
FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
CONSTRAINT chk_level_positive CHECK (Level > 0)
);
-- Admin Table : Type of User
CREATE TABLE Admin (
UserID INT PRIMARY KEY,
AdminLevel VARCHAR(20) NOT NULL DEFAULT 'Standard',
FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
CONSTRAINT chk_admin_level CHECK (AdminLevel IN ('Standard', 'Senior', 'Super'))
);
-- Curator Table : Type of User
CREATE TABLE Curator (
UserID INT PRIMARY KEY,
AdminID INT NOT NULL,
VerifDate DATE,
Bio TEXT,
FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
FOREIGN KEY (AdminID) REFERENCES Admin(UserID)
);
-- Venue Table
CREATE TABLE Venue (
VenueID INT PRIMARY KEY AUTO_INCREMENT,
Name VARCHAR(100) NOT NULL,
Street VARCHAR(200) NOT NULL,
City VARCHAR(50) NOT NULL,
PostalCode VARCHAR(20) NOT NULL,
PriceRange VARCHAR(10),
Description TEXT,
Phone VARCHAR(20),
Website VARCHAR(200),
CONSTRAINT chk_price_range CHECK (PriceRange IN ('$', '$$', '$$$', '$$$$') OR PriceRange IS NULL)
);
-- Review Table (Many-to-Many between User and Venue)
-- This make so that Users can write multiple reviews for the same venue
-- over time (tracked by DatePosted). This allows for updated experiences
CREATE TABLE Review (
ReviewID INT PRIMARY KEY AUTO_INCREMENT,
UserID INT NOT NULL,
VenueID INT NOT NULL,
DatePosted DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
Comment TEXT,
FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
FOREIGN KEY (VenueID) REFERENCES Venue(VenueID) ON DELETE CASCADE,
CONSTRAINT unique_user_venue_review UNIQUE (UserID, VenueID, DatePosted)
);
-- Attribute Table (Weak entity - dependent on Review)
CREATE TABLE Attribute (
ReviewID INT NOT NULL,
AttributeName VARCHAR(50) NOT NULL,
RatingValue INT NOT NULL,
PRIMARY KEY (ReviewID, AttributeName),
FOREIGN KEY (ReviewID) REFERENCES Review(ReviewID) ON DELETE CASCADE,
CONSTRAINT chk_rating_range CHECK (RatingValue BETWEEN 1 AND 5),
CONSTRAINT chk_attribute_name CHECK (AttributeName IN ('Food', 'Service', 'Atmosphere', 'WiFi', 'Study', 'Accessibility', 'Value',
'Cleanliness'))
);
-- Check_In Table (This is between Regular_User and Venue, can have many)
CREATE TABLE Check_In (
UserID INT NOT NULL,
VenueID INT NOT NULL,
CheckInTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
Notes TEXT,
PRIMARY KEY (UserID, VenueID, CheckInTime),
FOREIGN KEY (UserID) REFERENCES Regular_User(UserID) ON DELETE CASCADE,
FOREIGN KEY (VenueID) REFERENCES Venue(VenueID) ON DELETE CASCADE
);
-- Expertise_Category Table ( Admin can uses this)
CREATE TABLE Expertise_Category (
CategoryID INT PRIMARY KEY AUTO_INCREMENT,
AdminID INT NOT NULL,
CategoryName VARCHAR(100) NOT NULL UNIQUE,
Description TEXT,
FOREIGN KEY (AdminID) REFERENCES Admin(UserID)
);
-- Specializes_In Table (Between Curator and Expertise_Category, can have many to many relationships)
CREATE TABLE Specializes_In (
CuratorID INT NOT NULL,
CategoryID INT NOT NULL,
PRIMARY KEY (CuratorID, CategoryID),
FOREIGN KEY (CuratorID) REFERENCES Curator(UserID) ON DELETE CASCADE,
FOREIGN KEY (CategoryID) REFERENCES Expertise_Category(CategoryID) ON DELETE CASCADE
);
-- Recommends Table (Between Curator and Venue - M:M)
CREATE TABLE Recommends (
CuratorID INT NOT NULL,
VenueID INT NOT NULL,
RecNote TEXT,
RecScore INT,
PRIMARY KEY (CuratorID, VenueID),
FOREIGN KEY (CuratorID) REFERENCES Curator(UserID) ON DELETE CASCADE,
FOREIGN KEY (VenueID) REFERENCES Venue(VenueID) ON DELETE CASCADE,
CONSTRAINT chk_rec_score CHECK (RecScore BETWEEN 1 AND 10 OR RecScore IS NULL)
);
-- Badge Table (Achievement system for gamification)
CREATE TABLE Badge (
BadgeID INT PRIMARY KEY AUTO_INCREMENT,
BadgeType VARCHAR(50) NOT NULL,
Name VARCHAR(100) NOT NULL UNIQUE,
Description TEXT,
PtsRequired INT NOT NULL,
CONSTRAINT chk_pts_required CHECK (PtsRequired >= 0),
CONSTRAINT chk_badge_type CHECK (BadgeType IN ('Review', 'Check-In', 'Social', 'Curator'))
);
-- Earns Table (Between User and Badge - M:M)
-- Any user type can earn badges
CREATE TABLE Earns (
UserID INT NOT NULL,
BadgeID INT NOT NULL,
DateEarned DATE NOT NULL,
PRIMARY KEY (UserID, BadgeID),
FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
FOREIGN KEY (BadgeID) REFERENCES Badge(BadgeID) ON DELETE CASCADE
);
-- Follows Table (Between Regular_User and Curator - M:M)
CREATE TABLE Follows (
FollowerID INT NOT NULL,
CuratorID INT NOT NULL,
PRIMARY KEY (FollowerID, CuratorID),
FOREIGN KEY (FollowerID) REFERENCES Regular_User(UserID) ON DELETE CASCADE,
FOREIGN KEY (CuratorID) REFERENCES Curator(UserID) ON DELETE CASCADE,
CONSTRAINT chk_no_self_follow CHECK (FollowerID != CuratorID)
);
-- Tag Table (For venue categorization)
CREATE TABLE Tag (
TagID INT PRIMARY KEY AUTO_INCREMENT,
TagName VARCHAR(50) NOT NULL UNIQUE,
TagType VARCHAR(30) NOT NULL,
CONSTRAINT chk_tag_type CHECK (TagType IN ('Amenity', 'Atmosphere', 'Service', 'Dietary', 'Accessibility'))
);
-- Tagged_With Table (M:M between Venue and Tag)
CREATE TABLE Tagged_With (
VenueID INT NOT NULL,
TagID INT NOT NULL,
Score INT,
PRIMARY KEY (VenueID, TagID),
FOREIGN KEY (VenueID) REFERENCES Venue(VenueID) ON DELETE CASCADE,
FOREIGN KEY (TagID) REFERENCES Tag(TagID) ON DELETE CASCADE,
CONSTRAINT chk_tag_score CHECK (Score BETWEEN 1 AND 5 OR Score IS NULL)
);
-- Indexs for performance
-- Indexes on frequently searched fields (non-FK columns)
CREATE INDEX idx_venue_city ON Venue(City);
CREATE INDEX idx_venue_name ON Venue(Name);
-- Sample Data for the tables below
-- Sample Users
INSERT INTO User (UserID, Username, Email, Password, RegDate) VALUES
(1, 'Praveen', 'praveen@ucalgary.ca', 'pass_1', '2025-03-15'),
(2, 'saira', 'saira@ucalgary.ca', 'pass_2', '2025-03-16'),
(3, 'leo', 'leo@ucalgary.ca', 'pass_3', '2025-01-17'),
(4, 'personA', 'personA@gmail.com', 'pass_word_4', '2026-03-15'),
(5, 'personB', 'personB@gmail.com', 'pass_w_5', '2026-02-02');
-- Sample Admins
INSERT INTO Admin (UserID, AdminLevel) VALUES
(1, 'Super');
-- Sample Curators
INSERT INTO Curator (UserID, AdminID, VerifDate, Bio) VALUES
(2, 1, '2026-02-05', 'Coffee expert and food critic'),
(3, 1, '2026-02-10', 'Interior design specialist');
-- Sample Regular Users
INSERT INTO Regular_User (UserID, Level) VALUES
(4, 3),
(5, 2);
-- Sample Venues
INSERT INTO Venue (VenueID, Name, Street, City, PostalCode, PriceRange, Description, Phone, Website) VALUES
(1, 'NEW Coffee', '740 17 Ave SW', 'Calgary', 'T3R 0B7', '$$', 'Minimalist cafe with great coffe', '403-555-0001', 'www.sample1.ca'),
(2, 'Coffee Place', '803 1 St SW', 'Calgary', 'T2P 1M7', '$$$', 'Downtown cafe with fast WiFi', '403-555-0002', 'www.rc.com'),
(3, 'Some Cafe', '940 2 Ave NW', 'Calgary', 'T2N 0J9', '$', 'Budget cafe for students', '403-555-0003', 'www.vsomedomecafe.ca');
-- Sample Expertise Categories
INSERT INTO Expertise_Category (CategoryID, AdminID, CategoryName, Description) VALUES
(1, 1, 'Coffee Quality', 'Coffee bean and brewing expertise'),
(2, 1, 'Interior Design', 'Cafe ambiance and design');
-- Sample Curator Specializations
INSERT INTO Specializes_In (CuratorID, CategoryID) VALUES
(2, 1),
(3, 2);
-- Sample Reviews
INSERT INTO Review (ReviewID, UserID, VenueID, DatePosted, Comment) VALUES
(1, 2, 1, '2026-03-10 14:30:00', 'Excellent coffee quality'),
(2, 4, 2, '2026-03-12 09:00:00', 'Great WiFi for studying'),
(3, 5, 3, '2026-03-14 11:00:00', 'Good budget option');
-- Sample Review Attributes
INSERT INTO Attribute (ReviewID, AttributeName, RatingValue) VALUES
(1, 'Food', 4),
(1, 'Service', 5),
(1, 'Atmosphere', 4),
(2, 'WiFi', 5),
(2, 'Study', 5),
(3, 'Value', 5);
-- Sample Check-Ins
INSERT INTO Check_In (UserID, VenueID, CheckInTime, Notes) VALUES
(4, 1, '2026-03-10 09:00:00', 'Starting study session'),
(5, 2, '2026-03-12 08:30:00', 'Working on assignment');
-- Sample Curator Recommendations
INSERT INTO Recommends (CuratorID, VenueID, RecNote, RecScore) VALUES
(2, 1, 'Best coffee ever', 9),
(3, 1, 'Beautiful minimalist design', 8);
-- Sample Tags
INSERT INTO Tag (TagID, TagName, TagType) VALUES
(1, 'WiFi Available', 'Amenity'),
(2, 'Study Friendly', 'Atmosphere'),
(3, 'Pet Friendly', 'Service');
-- Sample Venue Tags
INSERT INTO Tagged_With (VenueID, TagID, Score) VALUES
(1, 1, 4),
(1, 2, 5),
(2, 1, 5),
(2, 2, 5),
(3, 1, 5),
(3, 2, 4);
-- Sample Badges
INSERT INTO Badge (BadgeID, BadgeType, Name, Description, PtsRequired) VALUES
(1, 'Review', 'First Review', 'Write your first review', 0),
(2, 'Check-In', 'First Check-In', 'Check in to a venue', 0),
(3, 'Social', 'First Follow', 'Follow a curator', 0);
-- Sample Badge Achievements
INSERT INTO Earns (UserID, BadgeID, DateEarned) VALUES
(4, 1, '2024-03-12'),
(4, 2, '2024-03-10'),
(2, 3, '2024-02-05');
-- Sample Follows
INSERT INTO Follows (FollowerID, CuratorID) VALUES
(4, 2),
(5, 2),
(5, 3);
-- Sample Queries Below
-- Query 1: Get venues with their ratings
SELECT
v.Name,
v.City,
COUNT(DISTINCT r.ReviewID) AS TotalReviews,
ROUND(AVG(a.RatingValue), 2) AS AvgRating
FROM Venue v
LEFT JOIN Review r ON v.VenueID = r.VenueID
LEFT JOIN Attribute a ON r.ReviewID = a.ReviewID
GROUP BY v.VenueID, v.Name, v.City
ORDER BY AvgRating DESC;
-- Query 2: Get curator recommendations
SELECT
u.Username AS Curator,
v.Name AS Venue,
rec.RecScore,
rec.RecNote
FROM Recommends rec
JOIN User u ON rec.CuratorID = u.UserID
JOIN Venue v ON rec.VenueID = v.VenueID
ORDER BY rec.RecScore DESC;
-- Query 3: Find most active reviewers
SELECT
u.Username,
COUNT(DISTINCT r.ReviewID) AS ReviewCount,
ROUND(AVG(a.RatingValue), 2) AS AvgRating
FROM User u
JOIN Review r ON u.UserID = r.UserID
JOIN Attribute a ON r.ReviewID = a.ReviewID
GROUP BY u.UserID, u.Username
ORDER BY ReviewCount DESC;
-- Query 4: Get study friendly cafes with WiFi
SELECT
v.Name,
v.Street,
v.City
FROM Venue v
JOIN Tagged_With tw ON v.VenueID = tw.VenueID
JOIN Tag t ON tw.TagID = t.TagID
WHERE t.TagName IN ('WiFi Available', 'Study Friendly')
GROUP BY v.VenueID, v.Name, v.Street, v.City
HAVING COUNT(DISTINCT t.TagID) = 2;
-- Query 5: Get curators with follower count
SELECT
u.Username AS Curator,
COUNT(f.FollowerID) AS Followers
FROM Curator c
JOIN User u ON c.UserID = u.UserID
LEFT JOIN Follows f ON c.UserID = f.CuratorID
GROUP BY c.UserID, u.Username
ORDER BY Followers DESC;
-- Sample UPDATE query
UPDATE Venue
SET Phone = '403-555-9999'
WHERE VenueID = 1;
-- Sample DELETE query
DELETE FROM Review
WHERE ReviewID = 3;
