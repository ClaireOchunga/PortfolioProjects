                    -- Cleaning Data
-- Exploring the Data we are going to clean 
SELECT *
FROM PortfolioProject.. NationalHousing;


-- Standardize Date Format
ALTER TABLE NationalHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject..NationalHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);

ALTER TABLE NationalHousing
DROP COLUMN SaleDate;

EXEC sp_rename 'NationalHousing.SaleDateConverted','SaleDate','COLUMN'


--Property Address
SELECT *
FROM PortfolioProject.. NationalHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.. NationalHousing a
JOIN PortfolioProject..NationalHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.. NationalHousing a
JOIN PortfolioProject..NationalHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


-- Breaking address into Individual Columns ( Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject.. NationalHousing;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) as Address
FROM PortfolioProject.. NationalHousing;

ALTER TABLE PortfolioProject..NationalHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject..NationalHousing
SET PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE PortfolioProject..NationalHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject..NationalHousing
SET PropertySplitCity  = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress));


SELECT *
FROM PortfolioProject..NationalHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NationalHousing;

ALTER TABLE PortfolioProject..NationalHousing
ADD SplitOwnerAddress NVARCHAR(255);

UPDATE
PortfolioProject..NationalHousing
SET 
 SplitOwnerAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);


ALTER TABLE PortfolioProject..NationalHousing
ADD SplitOwnerAddressCity NVARCHAR(255);

UPDATE
PortfolioProject..NationalHousing
SET 
SplitOwnerAddressCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);


ALTER TABLE PortfolioProject..NationalHousing
ADD SplitOwnerAddressState NVARCHAR(255);

UPDATE
PortfolioProject..NationalHousing
SET 
SplitOwnerAddressState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

 
-- Change Y and N to Yes and No in SoldAsVacant
SELECT
DISTINCT SoldAsVacant, count(SoldAsVacant)
FROM PortfolioProject.. NationalHousing
GROUP BY  SoldAsVacant


UPDATE
PortfolioProject..NationalHousing
SET SoldAsVacant = REPLACE(SoldAsVacant, 'Y' , 'Yes')
WHERE SoldAsVacant LIKE 'Y'

UPDATE
PortfolioProject..NationalHousing
SET SoldAsVacant = REPLACE(SoldAsVacant, 'N' , 'NO')
WHERE SoldAsVacant LIKE 'N'


-- Removing Duplicates
WITH Row_Num_CTE AS(
SELECT *,
ROW_NUMBER()OVER(
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY UniqueID
			) As Row_Num

FROM PortfolioProject..NationalHousing
)
SELECT *
FROM Row_Num_CTE
WHERE Row_Num>1
--Order by PropertyAddress


--Deleting Unused Columns
SELECT *
FROM PortfolioProject..NationalHousing

ALTER TABLE PortfolioProject..NationalHousing
DROP COLUMN TaxDistrict
