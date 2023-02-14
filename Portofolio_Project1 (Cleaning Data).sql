--Cleaning Data in SQL Queries

--Fetch the data sets that we want to clean

SELECT *
FROM Portofolio_Project1.dbo.Nashville_Housing

------------------------------------------------------------------------------------------

-- Standardize the Date Format so we can make use of it


SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM Portofolio_Project1.dbo.Nashville_Housing


UPDATE Nashville_Housing
SET SaleDate = CONVERT(Date,SaleDate)

------------------------------------------------------------------------------------------

-- Populate property Address data

--Firstly we checked the Property Address data using ParcelID, since it seems the ParcelID and the Property Address is equal
SELECT *
FROM Portofolio_Project1.dbo.Nashville_Housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--We want to copy the data from fulfilled Property Addres according to their ParcelID by using JOIN command
SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portofolio_Project1.dbo.Nashville_Housing a
JOIN Portofolio_Project1.dbo.Nashville_Housing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress IS NULL 

--We need to update the information from what we got before using UPDATE statement
UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portofolio_Project1.dbo.Nashville_Housing a
JOIN Portofolio_Project1.dbo.Nashville_Housing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress IS NULL 


------------------------------------------------------------------------------------------

-- Breaking out Property Address into individual columns (Address, City, State)

--Working on Property Address first
SELECT PropertyAddress
FROM Portofolio_Project1.dbo.Nashville_Housing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1 ) as Address
--CHARINDEX(',',PropertyAddress) #We don't want to comma included in our Address data so we check the len of the Address that appeared and -1 for get rid of the commas
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM Portofolio_Project1.dbo.Nashville_Housing

ALTER TABLE Nashville_Housing
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE Nashville_Housing
ADD PropertyCity NVARCHAR(255);

UPDATE Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1 )

UPDATE Nashville_Housing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


--Working on Owner Address
SELECT OwnerAddress
FROM Portofolio_Project1.dbo.Nashville_Housing

--Using PARSENAME Statement to separate the Owner Address
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portofolio_Project1.dbo.Nashville_Housing


ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE Nashville_Housing
ADD OwnerSplitState NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


------------------------------------------------------------------------------------------

-- Change 0 and 1 to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT (SoldAsVacant)
FROM Portofolio_Project1.dbo.Nashville_Housing

SELECT soldAsVacant
, CASE WHEN SoldAsVacant = '0' THEN 'No'
		WHEN SoldAsVacant = '1' THEN 'Yes'
		END
FROM Portofolio_Project1.dbo.Nashville_Housing

--The queries below is not working because i forced to change the boolean type into str
UPDATE Nashville_Housing
SET soldAsVacant= CASE WHEN soldAsVacant = '0' THEN 'No'
		WHEN soldAsVacant = '1' THEN 'Yes'
		END

--Not working then we used this queries instead

ALTER TABLE Nashville_Housing
ADD SoldAsVacantConverted VARCHAR(10);

UPDATE Nashville_Housing
SET SoldAsVacantConverted = CASE WHEN soldAsVacant = '0' THEN 'No'
		WHEN soldAsVacant = '1' THEN 'Yes'
		END

------------------------------------------------------------------------------------------

-- Remove duplicates data 

SELECT *
FROM Portofolio_Project1.dbo.Nashville_Housing

WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY	ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY
							UniqueID) Row_No
FROM Portofolio_Project1.dbo.Nashville_Housing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE Row_No > 1


------------------------------------------------------------------------------------------

-- Remove Unused Columns

SELECT *
FROM Portofolio_Project1.dbo.Nashville_Housing

ALTER TABLE Portofolio_Project1.dbo.Nashville_Housing
DROP COLUMN PropertyAddress, SoldAsVacant, OwnerAddress, TaxDistrict
