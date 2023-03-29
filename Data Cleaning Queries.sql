--Cleaning Data

select * from PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------------
--Standardizing the Date Format


alter table NashvilleHousing
add SaleDateConverted date;

Update NashvilleHousing
set SaleDateConverted=CONVERT(date,Saledate)

select *
from PortfolioProject..NashvilleHousing



---------------------------------------------------------------------------------------------------------------------


--Populate Property Address data

 select * 
from PortfolioProject..NashvilleHousing
order by ParcelID

select a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress,ISNULL(a.propertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.propertyaddress is null


update a
set PropertyAddress=ISNULL(a.propertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID=b.ParcelID
And a.[UniqueID ]<>b.[UniqueID ]
where a.propertyaddress is null


----------------------------------------------------------------------------------------------------------

--Breaking down address into (address,city,state)

 select *
from PortfolioProject..NashvilleHousing

-- Splitting "PropertyAddress" column into "PropertySplitAddress" and "PropertySplitCity" columns using PARSENAME and REPLACE functions

SELECT 
    PARSENAME(REPLACE(PropertyAddress, ', ', '.'), 2) AS PropertySplitAddress,
    PARSENAME(REPLACE(PropertyAddress, ', ', '.'), 1) AS PropertySplitCity
FROM PortfolioProject..NashvilleHousing;


-- Adding "PropertySplitCity" and "PropertySplitAddress" columns to the "NashvilleHousing" table

alter table NashvilleHousing
add PropertySplitCity nvarchar(255),
	PropertySplitAddress nvarchar(255);

-- Updating the "Address" and "City" columns in the "NashvilleHousing" table with the extracted values from "PropertyAddress"

UPDATE NashvilleHousing
SET PropertySplitCity = PARSENAME(REPLACE(PropertyAddress, ', ', '.'), 1),
    PropertySplitAddress = PARSENAME(REPLACE(PropertyAddress, ', ', '.'), 2);


-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Breaking down owneraddress into (address,city,state)

select OwnerAddress 
from PortfolioProject..NashvilleHousing;


-- Splitting "OwnerAddress" column into "OwnerSplitAddress" , "OwnerSplitCity" and "OwnerSplitState"columns using PARSENAME and REPLACE functions
select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing

-- Adding "OwnerSplitAddress", "OwnerSplitCity", and "OwnerSplitState" columns to the "NashvilleHousing" table

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255),
    OwnerSplitCity nvarchar(255),
    OwnerSplitState nvarchar(255);

-- Updating the "OwnerAddress", "OwnerCity", and "OwnerState" columns in the "NashvilleHousing" table with the extracted values from "OwnerAddress"

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

select OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
from PortfolioProject..NashvilleHousing

select * from PortfolioProject..NashvilleHousing


----------------------------------------------------------------------------------------------

--Changing Y and N to YES and NO in "Sold as Vacant" field

select distinct (SoldAsVacant),COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
from PortfolioProject..NashvilleHousing;


-- Updating the "SoldAsVacant" column in the "NashvilleHousing" table

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
                        WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
                    END

select distinct(SoldAsVacant) from PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------

--Removing Duplicates

with DupRow as(
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress,SaleDate,SalePrice,LegalReference ORDER BY UniqueId) AS Row_Count
  FROM PortfolioProject..NashvilleHousing
)
delete
from DupRow 
where Row_Count>1   -- Delete all rows from the CTE where rn is greater than 1




select * from PortfolioProject..NashvilleHousing


------------------------------------------------------------------------------------------------------------------

--Deleteing Unused Columns

select * from PortfolioProject..NashvilleHousing


ALter table PortfolioProject..NashvilleHousing
drop column PropertyAddress,OwnerAddress,TaxDistrict,SaleDate
