--DATA CLEANING PROJECT

SELECT*
FROM PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------------

-- STANDARIZE DATE FORMAT

SELECT SaleDateConverted, CONVERT (DATE,SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate=CONVERT (Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

------------------------------------------------------------------------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADRESS DATA

SELECT*
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT X.ParcelID, X.PropertyAddress, Y.ParcelID, Y.PropertyAddress, ISNULL(X.PropertyAddress, Y.PropertyAddress)
FROM PortfolioProject..NashvilleHousing X
JOIN PortfolioProject..NashvilleHousing Y
ON X.ParcelID = Y.ParcelID
WHERE X.PropertyAddress IS NULL 
AND X.UniqueID <> Y.UniqueID

UPDATE X
SET PropertyAddress = ISNULL(X.PropertyAddress, Y.PropertyAddress)
FROM PortfolioProject..NashvilleHousing X
JOIN PortfolioProject..NashvilleHousing Y
ON X.ParcelID = Y.ParcelID
AND X.UniqueID <> Y.UniqueID
WHERE X.PropertyAddress IS NULL

-----------------------------------------------------------------------------------------------------------------------------------------------------------

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress,1 , CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing
 

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR (255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1 , CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR (255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT*
FROM PortfolioProject..NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE (OwnerAddress, ',','.'),3),
PARSENAME(REPLACE (OwnerAddress, ',','.'),2),
PARSENAME(REPLACE (OwnerAddress, ',','.'),1)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR (255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR (255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR (255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE (OwnerAddress, ',','.'),1)

SELECT*
FROM PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------------------------

----CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD------

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
----------------------------------------------------------------------------------------------------------------------------------------------------------

---REMOVE DUPLICATES

WITH RowNumCTE AS
(
SELECT*,
ROW_NUMBER () OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
	ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing)
SELECT*
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress

WITH RowNumCTE AS
(
SELECT*,
ROW_NUMBER () OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
	ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing)
DELETE
FROM RowNumCTE
WHERE row_num >1
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS

SELECT*
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate
