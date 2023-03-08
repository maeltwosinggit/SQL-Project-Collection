/*

Cleaning Data in SQL Queries

*/

select *
from PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

select SaleDateConverted, CONVERT(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

--update NashvilleHousing
--Set SaleDate = CONVERT(date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
Set SaleDateConverted = CONVERT(date,SaleDate)

---------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

-- #####################PROPERTY ADDRESS####################
-- using substring method

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +2, LEN(PropertyAddress)) as Address2

from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update NashvilleHousing
Set  PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1)


alter table NashvilleHousing
Add PropertySplitCity nvarchar(255);

update NashvilleHousing
Set  PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +2, LEN(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing

-- #####################OWNER ADDRESS####################
-- using Parsename method

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
Set  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

update NashvilleHousing
Set  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


alter table NashvilleHousing
Add OwnerSplitState nvarchar(255);

update NashvilleHousing
Set  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


select *
from PortfolioProject.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end
from PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)

select *
from RowNumCTE
where row_num > 1
order by PropertyAddress



---------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate


