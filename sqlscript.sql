-- Cleaning the data

-- Number of rows
select count(*) from nashvillehousing;

-- Standardize the date format
Alter table nashvillehousing
add SaleDateConverted Date;

update nashvillehousing
set SaleDateConverted=CONVERT(Date, SaleDate);

select SaleDateConverted from nashvillehousing;

alter table nashvillehousing
drop column SaleDate;

select SaleDate from nashvillehousing;

-- Populate Property Address Data
select PropertyAddress
from nashvillehousing
where PropertyAddress is null;

select ParcelID,count(ParcelID)
from nashvillehousing
group by ParcelID
order by 2 desc;

select nv1.ParcelID, nv1.PropertyAddress, nv2.ParcelID, nv2.PropertyAddress,
ISNULL(nv1.PropertyAddress, nv2.PropertyAddress)
from nashvillehousing nv1
join nashvillehousing nv2
on nv1.ParcelID=nv2.ParcelID and nv1.[UniqueID ]<> nv2.[UniqueID ]
where nv1.PropertyAddress is null;

update nv1
set PropertyAddress= ISNULL(nv1.PropertyAddress, nv2.PropertyAddress)
from nashvillehousing nv1
join nashvillehousing nv2
	on nv1.ParcelID=nv2.ParcelID 
	and nv1.[UniqueID ]<> nv2.[UniqueID ]
where nv1.PropertyAddress is null;


-- Breaking Address into Address,City, State
select PropertyAddress
from nashvillehousing;

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City	
from nashvillehousing;

alter table nashvillehousing
add PropertySplitAddress nvarchar(250)

update nashvillehousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table nashvillehousing
add PropertySplitCity nvarchar(250)

update nashvillehousing
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select PropertySplitAddress, PropertySplitCity
from nashvillehousing;

select OwnerAddress
from nashvillehousing

select PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from nashvillehousing
where OwnerAddress is not null;

alter table nashvillehousing
add OwnerSplitAddress nvarchar(250)

update nashvillehousing
set OwnerSplitAddress=PARSENAME(Replace(OwnerAddress,',','.'),3)

alter table nashvillehousing
add OwnerSplitCity nvarchar(250)

update nashvillehousing
set OwnerSplitCity=PARSENAME(Replace(OwnerAddress,',','.'),2)

alter table nashvillehousing
add OwnerSplitState nvarchar(250)

update nashvillehousing
set OwnerSplitState=PARSENAME(Replace(OwnerAddress,',','.'),1)

select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from nashvillehousing;


-- Change Y and N to Yes and No in Sold as Vacant field
select SoldAsVacant
from nashvillehousing;

select distinct(soldasvacant), count(soldasvacant)
from nashvillehousing
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case 
	when soldasvacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
end
from nashvillehousing;

update nashvillehousing
set SoldAsVacant= 
	case 
		when soldasvacant='Y' then 'Yes'
		when SoldAsVacant='N' then 'No'
		else SoldAsVacant
	end

select distinct(SoldAsVacant)
from nashvillehousing;


-- Remove Duplicates

--finding the duplicate rows
with rownumcte as(
select *, 
ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID
				)row_no
from nashvillehousing
)
select * from rownumcte
where row_no>1
order by PropertyAddress;

--deleting the duplicates
with rownumcte as(
select *, 
ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID
				)row_no
from nashvillehousing
)
delete from rownumcte
where row_no>1;

--verifying the duplicates have been deleted
with rownumcte as(
select *, 
ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID
				)row_no
from nashvillehousing
)
select * from rownumcte
where row_no>1
order by PropertyAddress;


-- Delete Unused Columns
select * 
from nashvillehousing;

alter table nashvillehousing
drop column PropertyAddress, OwnerAddress, TaxDistrict
