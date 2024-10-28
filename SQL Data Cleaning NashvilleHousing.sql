--Standardising Date_format

SELECT SalesDataConverted ,Convert(date,SaleDate) as New_date
FROM portfolio..Nashvillehousing

UPDATE Nashvillehousing
SET SaleDate = Convert(date,SaleDate)


ALTER TABLE Nashvillehousing
ADD SalesDataConverted Date

UPDATE Nashvillehousing
SET SalesDataConverted = Convert(date,SaleDate)

--Populate Property Address

SELECT*
FROM portfolio..Nashvillehousing
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress ,b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolio..Nashvillehousing a
JOIN portfolio..Nashvillehousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolio..Nashvillehousing a
JOIN portfolio..Nashvillehousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null


--Breaking Address into Individual Coloumns [Address, City, States]

--PropertySplitAddress, PropertySplitCity

SELECT *
FROM portfolio..Nashvillehousing

SELECT
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress)) as Address
FROM portfolio..Nashvillehousing

ALTER TABLE portfolio..Nashvillehousing
ADD PropertySplitAddress nvarchar(255);

UPDATE portfolio..Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE portfolio..Nashvillehousing
ADD PropertySplitCity nvarchar(255);

UPDATE portfolio..Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress))



SELECT OwnerAddress
FROM portfolio..Nashvillehousing
where OwnerAddress is not null


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 3) 
 ,PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 2) 
 ,PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 1)
FROM portfolio..Nashvillehousing


ALTER TABLE portfolio..Nashvillehousing
ADD ownersSplitAddress nvarchar(255);

UPDATE portfolio..Nashvillehousing
SET ownersSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 3)

ALTER TABLE portfolio..Nashvillehousing
ADD ownersSplitCity nvarchar(255);

UPDATE portfolio..Nashvillehousing
SET ownersSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 2)

ALTER TABLE portfolio..Nashvillehousing
ADD ownersSplitstate nvarchar(255);

UPDATE portfolio..Nashvillehousing
SET ownersSplitstate = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 1)

SELECT * FROM
portfolio..Nashvillehousing


--CHANGINNG YES  AND NO FROM Y N




SELECT  DISTINCT SoldAsVacant, count(SoldAsVacant)
FROM portfolio..Nashvillehousing
GROUP BY SoldAsVacant
order by 2

SELECT SoldAsVacant
 ,CASE	WHEN SoldAsVacant ='Y' THEN 'YES'
		WHEN SoldAsVacant ='N' THEN  'NO'
		ELSE SoldAsVacant
		END
FROM portfolio..Nashvillehousing


UPDATE portfolio..Nashvillehousing
SET SoldAsVacant = CASE	WHEN SoldAsVacant ='Y' THEN 'YES'
		WHEN SoldAsVacant ='N' THEN  'NO'
		ELSE SoldAsVacant
		END

SELECT *
FROM portfolio..Nashvillehousing
order by [UniqueID ]

WITH Road_Numcte AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
			       UniqueID
		           ) row_num
FROM portfolio..Nashvillehousing
--order by ParcelID
)
--SELECT *
DELETE 
FROM Road_Numcte
where row_num >1
--order by PropertyAddress

--DELETE UNUSED COLUMNS

SELECT * 
FROM portfolio..Nashvillehousing

ALTER TABLE portfolio..Nashvillehousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress