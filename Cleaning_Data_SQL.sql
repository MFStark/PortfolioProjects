/* Data Cleaning */

SELECT *
FROM [Portfolio Project]..NashvilleHousing


-- Standarize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date




-- Populate Property Address Data

SELECT COUNT(*)
FROM [Portfolio Project]..NashvilleHousing
WHERE PropertyAddress IS NULL

-- 29 Rows with NULL values for Property Address



/* Self Join on ParcelID and unique ID. Looks at a new table where Property Address is Null for inital 'A' table and populated for 'B' table */
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM [Portfolio Project]..NashvilleHousing AS A
JOIN [Portfolio Project]..NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ]<> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


/*IS NULL Populates NULL Values in A.PropertyAddress with corresponding row values of B.PropertyAddress */
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing AS A
JOIN [Portfolio Project]..NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ]<> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


/*Populate orginal NashvilleHousing table, alias 'A', with PropertyAddress values from above */
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing AS A
JOIN [Portfolio Project]..NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ]<> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

/* Check that all NULL values were populated correctly */
SELECT COUNT(*)
FROM [Portfolio Project]..NashvilleHousing
WHERE PropertyAddress IS NULL



-- Break Address into individual columns, Address, City, State

/* Create new columns for property address and city. Populate using substring and CHARINDEX */
--SELECT PropertyAddress
--FROM [Portfolio Project]..NashvilleHousing


--ALTER TABLE NashvilleHousing
--DROP COLUMN Property_Address, Property_City

ALTER TABLE NashvilleHousing
ADD Property_Address varchar(255), 
Property_City varchar(255)

UPDATE NashvilleHousing
SET Property_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, CHARINDEX(',',PropertyAddress))


--SELECT Property_Address, Property_City
--FROM [Portfolio Project]..NashvilleHousing


/* Split Owner Address into Address, City, State */

--SELECT OwnerAddress
--FROM [Portfolio Project]..NashvilleHousing

--ALTER TABLE NashvilleHousing
--DROP COLUMN Owner_Address, Owner_City, Owner_State


SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD Owner_Address varchar(255), 
Owner_City varchar(255),
Owner_State varchar(255)

Update NashvilleHousing
SET
Owner_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
Owner_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
Owner_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--SELECT *
--FROM [Portfolio Project]..NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" Field with case statements

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


-- Remove duplicates


/* Create Row Number column with partition including unique values in each row */
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
				 ) AS Row_Num
FROM [Portfolio Project]..NashvilleHousing
)

DELETE 
FROM RowNumCTE
WHERE Row_Num > 1

SELECT COUNT(*)
FROM [Portfolio Project]..NashvilleHousing


--Drop unused columns

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict



SELECT *
FROM [Portfolio Project]..NashvilleHousing
