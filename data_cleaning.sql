SELECT * FROM nashville_housing


--Convert datetime format to date

SELECT SaleDate, CONVERT(DATE, SaleDate) AS Date
FROM nashville_housing

UPDATE nashville_housing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE nashville_housing
ADD SaleDateConverted Date;

UPDATE nashville_housing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

SELECT * FROM nashville_housing


--Populating missing property address data

SELECT *
FROM nashville_housing
WHERE PropertyAddress IS NULL

SELECT *
FROM nashville_housing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Breaking address into address, city, state

SELECT PropertyAddress
FROM nashville_housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
FROM nashville_housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM nashville_housing

ALTER TABLE nashville_housing
ADD Address AS SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE nashville_housing
ADD City AS SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT PropertyAddress, OwnerAddress, Address, City FROM nashville_housing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM nashville_housing

ALTER TABLE nashville_housing
ADD OwnerAd AS PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE nashville_housing
ADD OwnerCity AS PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE nashville_housing
ADD OwnerState AS PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * FROM nashville_housing

ALTER TABLE nashville_housing
DROP COLUMN OwnerAd

ALTER TABLE nashville_housing
ADD OwnerAddr AS PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


--Change Y and N to Yes and No in "Sold as Vacant" column

SELECT DISTINCT SoldAsVacant
FROM nashville_housing

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes '
	WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant
END
FROM nashville_housing

UPDATE nashville_housing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes '
	WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant
END

UPDATE nashville_housing
set SoldAsVacant = replace(SoldAsVacant, 'Y', 'Yes')

UPDATE nashville_housing
set SoldAsVacant = replace(SoldAsVacant, 'N', 'No')

UPDATE nashville_housing
set SoldAsVacant = replace(SoldAsVacant, 'Yeses', 'Yes')

UPDATE nashville_housing
set SoldAsVacant = replace(SoldAsVacant, 'Noo', 'No')

SELECT * FROM nashville_housing


--Remove duplicates

WITH RowNumCTE AS(
SELECT *, 
ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		ORDER BY UniqueId) row_num
FROM nashville_housing)

DELETE FROM RowNumCTE
WHERE row_num > 1


--Delete unused columns

ALTER TABLE nashville_housing
DROP COLUMN TaxDistrict, SaleDate

SELECT * FROM nashville_housing









