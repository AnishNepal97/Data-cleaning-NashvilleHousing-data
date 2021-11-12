/******In this part we are going to clean the Nashville housing data******/
--formatting column in standard form is important
--there are other ways to upade date format but i choose update statemet.
-- deal with nul vaules(basiclally remove or format in meaning full way so that oyu can calculate)

Select *
From NashvilleHousing
--- we saw there are total 56,477 rows of data


--lets format date in proper way(standard form).

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- we see there are some PropertyAddress are null value.
-- we are going to populate them.
--wee see parcelID has same propertyAddress so we populate par

Select *
From NashvilleHousing
where PropertyAddress is null
--29 rows
--we saw same parcelId has same propertyAddress but some are
--missing so we are going to use parcelID to populate null values in PropertyAddress
--lets joing two tables with parcelID and <>(not equal) uniqueID 
--Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Isnull statesment help to replace all the null values with new column value.
--do not forget to update the table after you feed new value
--so,
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
--(29 rows affected)


--lets update the Property address into following
--address, city, state
--we can not seperate 2 values from one column with out creating 2 seperate column
--so make 2 new column and then add those values

Select PropertyAddress
From NashvilleHousing
--just checking the column

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From NashvilleHousing
--Seperating address and city by INDEXING AND SLICING 

--Create new column for Address
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
--FEED new column
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

--Create new column for city
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);
--FEED new column
Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


--Just confirming
Select *
From NashvilleHousing

--lets update the Owner address into following
--address, city, state, 
--we are going to use PARSENAME which is super useful for 
--slicing and dicing with specific delimited value like comma in this file.

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing

--successfully seperated the owner address, city, and state 
--lets make new column and upade the table 
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- lets Change Y and N to Yes and No in "SoldAsVacant" field
--first we are going to see how many Y & N and Yes & No in our table 
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2
--SoldAsVacant	(No column name)
--Y	52
--N	399
--Yes	4623
--No	51403

--lets change this into Yes and No with CASE statement;
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing




--lets remove some duplicates 
--using CTE statement to figure out how many a rows are duplicate and and remove it from the table
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing)
--order by ParcelID
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


--lets DELETE ALL Duplicates from above statesment
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing)
--order by ParcelID
DELETE 
From RowNumCTE
Where row_num > 1

-- (104 rows affected)


--finally lets get rid of unused column from the teable

Select *
From NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
--Commands completed successfully.




