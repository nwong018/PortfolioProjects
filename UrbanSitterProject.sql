-- Left joined table showing all enrolled and bookings if made
Select *
FROM Enrollments
	LEFT JOIN Bookings
	ON Bookings.[Parent User Uid] = Enrollments.[Parent User Uid]



-- use temp table to filter out ppl that enrolled and booked
-- use temp table to filter out ppl that enrolled
-- Percent of Enrolled that Booked
WITH NumBookings ([Parent User Uid])
AS
(
SELECT
	 COUNT(DISTINCT Enrollments.[Parent User Uid])
FROM Enrollments
	LEFT JOIN Bookings
	ON Bookings.[Parent User Uid] = Enrollments.[Parent User Uid]
WHERE Bookings.[Booking ID] IS NOT NULL
),
TotalEnrolled AS 
(
Select 
	COUNT (DISTINCT Enrollments.[Parent User Uid]) AS 'Total Enrolled'
FROM Enrollments
	LEFT JOIN Bookings
	ON Bookings.[Parent User Uid] = Enrollments.[Parent User Uid]
)
SELECT 
	*,
	CAST([Parent User Uid] AS float)/CAST([Total Enrolled] AS float) AS 'Percent Enrolled That Booked'
FROM NumBookings, TotalEnrolled



-- Most registered weekdays
SELECT 
	DATENAME(WEEKDAY, Enrollments.[Employee Created Date]) AS 'Day of the Week',
	COUNT(DATENAME(WEEKDAY, Enrollments.[Employee Created Date])) AS Count
FROM Enrollments
GROUP BY
	DATENAME(WEEKDAY, Enrollments.[Employee Created Date])
ORDER BY COUNT DESC


-- Most booked weekdays
SELECT 
	DATENAME(WEEKDAY, Bookings.[Created Date]) AS 'Day of the Week',
	COUNT(DATENAME(WEEKDAY, Bookings.[Created Date])) AS Count
FROM Bookings
GROUP BY
	DATENAME(WEEKDAY, Bookings.[Created Date])
ORDER BY COUNT DESC
-- reminder of thanksgiving holiday on slides


-- Joined inner table
Select *
FROM Bookings
	JOIN Enrollments
	ON Bookings.[Parent User Uid] = Enrollments.[Parent User Uid]



-- Joined table showing most used voucher codes (contains possible error in Voucher Code Comment)
Select 
	([US Voucher Code Name]),
	COUNT([Us Voucher Code Name]) AS 'Total Voucher Code Used',
	([Voucher Code Comment]),
	COUNT([Voucher Code Comment]) AS 'Voucher Code Comment', 
	FORMAT(AVG([Booking Total]), 'C') AS 'Average Booking Total',
	FORMAT(AVG([Discount Applied]), 'C') AS 'Average Discount Applied'
FROM Bookings
	JOIN Enrollments 
	ON Bookings.[Parent User Uid] = Enrollments.[Parent User Uid]
GROUP BY
	[US Voucher Code Name], [Voucher Code Comment]
ORDER BY
	COUNT([Us Voucher Code Name]) DESC



-- Joined table showing most common booking type
Select 
	([Booking Type]),
	COUNT(([Booking Type])) AS 'Total Booking Type Used', 
	FORMAT(AVG([Booking Total]), 'C') AS 'Average Booking Total',
	FORMAT(AVG([Discount Applied]), 'C') AS 'Average Discount Applied'
FROM Bookings
	JOIN Enrollments 
	ON Bookings.[Parent User Uid] = Enrollments.[Parent User Uid]
GROUP BY
	[Booking Type]
ORDER BY
	COUNT(([Booking Type])) DESC



--EXTRA


-- Num of Distinct User IDs that enrolled AND booked
Select 
	COUNT (DISTINCT Enrollments.[Parent User Uid])
FROM Enrollments
	LEFT JOIN Bookings
	ON Bookings.[Parent User Uid] = Enrollments.[Parent User Uid]
WHERE
	Bookings.[Booking ID] IS NOT NULL


-- Num of Distinct User IDs that enrolled
Select 
	COUNT (DISTINCT Enrollments.[Parent User Uid]) AS TotalEnrolled
FROM Enrollments
	LEFT JOIN Bookings
	ON Bookings.[Parent User Uid] = Enrollments.[Parent User Uid]