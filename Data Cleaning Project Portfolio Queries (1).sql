
/*
CLEANING DATA USING SQL QUERIES
*/

--USING THE NASHVILLE HOUSING DATASET FROM KAGGLE

Select *
From PortfolioProject.dbo.Nashville


-- STANDARDIZE DATE FORMAT

SELECT saleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.Nashville


UPDATE Nashville
SET SaleDate = CONVERT(Date,SaleDate)

--OR USE THIS 

ALTER TABLE Nashville
Add SaleDateConverted Date


UPDATE Nashville
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- POPULATE PROPERTY-ADDRESS COLUMN
-----this is used to join a table to itself using two conditions (ParcelID is the same but UniqueID is not)
--Also the third column of the first table is empty
------Another column is created where the blank spaces of the column of the first table are replaced with the attributes of the same column of the second table

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.Nashville as a
JOIN PortfolioProject.dbo.Nashville as b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Nashville a
JOIN PortfolioProject.dbo.Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


---Update the table with the newly created column
--Note that this is repeated for simplicity purposes
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.Nashville as a
JOIN PortfolioProject.dbo.Nashville as b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


---USING SUBSTRING, BREAK OUT PROPERTY-ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY)

---This represents the actions of splitting
SELECT 
SUBSTRING (PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)  AS City
FROM PortfolioProject.dbo.Nashville

---Table is updated to include a new column for address only
ALTER TABLE PortfolioProject.dbo.Nashville
ADD OnlyAddress nvarchar(255)

UPDATE PortfolioProject.dbo.Nashville
SET OnlyAddress = SUBSTRING (PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) AS Address

---Table is updated to include a new column for city only
ALTER TABLE PortfolioProject.dbo.Nashville
ADD OnlyCity nvarchar(255)

UPDATE PortfolioProject.dbo.Nashville
SET OnlyCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)  AS City


--OR 


---USING PARSENAME, BREAK OUT OWNER-ADDRESS INTO SEPARATE COLUMNS

SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.' 3) AS Address
PARSENAME(REPLACE(OwnerAddress,',', '.' 2) AS City
PARSENAME(REPLACE(OwnerAddress,',', '.' 1) AS State
FROM PortfolioProject.dbo.Nashville


-----Table is updated to include a new column for address, city and state only
ALTER TABLE PortfolioProject.dbo.Nashville
ADD OnlyAddress nvarchar(255)

UPDATE PortfolioProject.dbo.Nashville
SET OnlyAddress = PARSENAME(REPLACE(OwnerAddress,',', '.' 3)) -1)


ALTER TABLE PortfolioProject.dbo.Nashville
ADD OnlyCity Nvarchar(255)

UPDATE PortfolioProject.dbo.Nashville
SET OnlyCity = PARSENAME(REPLACE(OwnerAddress,',', '.' 2)

ALTER TABLE PortfolioProject.dbo.Nashville
ADD OnlyState Nvarchar(255)

UPDATE PortfolioProject.dbo.Nashville
SET OnlyAddress = PARSENAME(REPLACE(OwnerAddress,',', '.' 1)


---Change Y to YES and N to NO
SELECT SoldAsVacant
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END AS Response
FROM PortfolioProject.dbo.Nashville

---Update the table
UPDATE Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END


----REMOVE DUPLICATES

---change the SELECT * to DELETE after viewing to remove the duplicates

WITH RowNumCTE AS 
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID,
				PropertyAddress, 
				SalePrice,
				SaleDate,
				LegalReference
ORDER BY UniqueID) AS Row_Num
FROM PortfolioProject.dbo.Nashville
)
SELECT *
FROM RowNumCTE
WHERE Row_Num > 1
ORDER BY PropertyAddress



---DELETE UNUSED COLUMNS
SELECT *
FROM PortfolioProject.dbo.Nashville

ALTER TABLE PortfolioProject.dbo.Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

