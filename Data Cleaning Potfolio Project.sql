--CLEANING DATA IN SQL

SELECT *
FROM PortfolioMain..Nashville

--1. STANDARDIZE DATE FROMAT

ALTER TABLE Nashville
ADD SaleDateConverted Date

UPDATE Nashville
SET SaleDateConverted = CONVERT(Date, SaleDate)

select SaleDate, SaleDateConverted
from PortfolioMain..Nashville

----------------------------------------------------
--2. POPULATE PROPERTY ADDRESS DATA

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioMain..Nashville a
join PortfolioMain..Nashville b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioMain..Nashville a
join PortfolioMain..Nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

--3. BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (Address, City. State)

Select Propertyaddress 
from PortfolioMain..Nashville

Select PropertyAddress, 
		SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
from PortfolioMain..Nashville

ALTER TABLE PortfolioMain..Nashville
ADD PropertyAddressSplit nvarchar(225),
	PropertyAddressCity nvarchar(255)

UPDATE PortfolioMain..Nashville
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
	PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
from PortfolioMain..Nashville

SELECT *
FROM PortfolioMain..Nashville

--ALTERNATIVE

ALTER TABLE PortfolioMain..Nashville
ADD OwnerAddressSplit nvarchar(225),
	OwnerAddressCity nvarchar(255),
	OwnerAddressState nvarchar(255);

--SELECT
--	PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1),
--	PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2),
--	PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)
--FROM PortfolioMain..Nashville
--WHERE OwnerAddress is not null

UPDATE PortfolioMain..Nashville
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1),
	OwnerAddressCity = 	PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2),
	OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)
FROM PortfolioMain..Nashville

SELECT OwnerAddressSplit, OwnerAddressCity,  OwnerAddressState
FROM PortfolioMain..Nashville
WHERE OwnerAddressSplit is not null

SELECT *
FROM PortfolioMain..Nashville

--4. CHANGE Y AND N TO YES AND NO IN SoldAsVacant

select SoldAsVacant, count(soldasvacant)
from PortfolioMain..Nashville
group by soldasvacant
order by 2 

select SoldAsVacant,
	CASE
		 WHEN soldasvacant = 'Y' then 'Yes'
		 WHEN soldasvacant = 'N' THEN 'NO'
		 Else Soldasvacant
	END
from PortfolioMain..Nashville

UPDATE PortfolioMain..Nashville
SET SoldAsVacant =
	CASE
		 WHEN soldasvacant = 'Y' then 'Yes'
		 WHEN soldasvacant = 'N' THEN 'NO'
		 Else Soldasvacant
	END
from PortfolioMain..Nashville

--------------------------------------------------------------------------------

----5. REMOVE DUPLICATE

WITH RowNumCTE as (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 Saleprice,
				 LegalReference
				 ORDER BY
					UniqueID
	) DupliRows
FROM PortfolioMain..Nashville
--order by Newdata desc
)

SELECT *
from RowNumCTE 
where Duplirows > 1

SELECT *
FROM PortfolioMain..Nashville

----------------------------------------------------------

--6. DELETE UNUSED COLUMNS

ALTER TABLE PortfolioMain..Nashville
DROP COLUMN PropertyAddress, SaleDate, TaxDistrict, OwnerAddress