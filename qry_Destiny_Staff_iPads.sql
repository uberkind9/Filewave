SET NOCOUNT ON;
SELECT 	--,CircCatAdmin.Copy.CopyBarcode AS "Barcode"
	UPPER(CircCatAdmin.CopyAsset.SerialNumber) AS "serial_number"
	,CircCatAdmin.Patron.DistrictID AS "checked_out_psnum"
    ,CircCatAdmin.Patron.LastName + ': ' + CircCatAdmin.Patron.FirstName + ' ' + CircCatAdmin.Patron.MiddleName AS "checked_out_name"
	,CircCatAdmin.Patron.GradeLevel AS "checked_out_gradelevel"
	,(
		CASE 
		WHEN CircCatAdmin.SitePatron.SiteID IS NOT NULL
		THEN (
			CASE CircCatAdmin.SitePatron.SiteID
			WHEN 100
				THEN 'JEF'
			WHEN 102
				THEN 'MEN'
			WHEN 201
				THEN 'WAS'
			WHEN 106
				THEN 'WEB'
			WHEN 103
				THEN 'PHS'
			WHEN 101
				THEN 'LJH'
			WHEN 104
				THEN 'RIS'
			WHEN 303
				THEN 'PCSC'
			ELSE ''
			END
			)
		ELSE ''
		END				
		) AS "checked_out_school"

	,CASE CircCatAdmin.Copy.STATUS
		WHEN 0
			THEN 'Available'
		WHEN 100
			THEN 'Checked Out'
		WHEN 102
			THEN 'Loaned Out'
		WHEN 104
			THEN 'Out for Repairs'
		WHEN 105
			THEN 'In Transit'
		WHEN 106
			THEN 'In Use'
		WHEN 107
			THEN 'Returned to Vendor'
		WHEN 200
			THEN 'Lost'
		WHEN 201
			THEN 'Stolen'
		WHEN 202
			THEN 'No Longer in Use'
		WHEN 203
			THEN 'Available for Parts'
		WHEN 206
			THEN 'Ready for Disposal'
		ELSE ''
		END AS "checked_out_status" 
		
		,CircCatAdmin.Patron.EmailAddress1 AS "checked_out_email"
FROM CircCatAdmin.Copy
JOIN CircCatAdmin.CopyAsset ON CircCatAdmin.CopyAsset.CopyID = CircCatAdmin.Copy.CopyID
JOIN CircCatAdmin.BibAsset ON CircCatAdmin.BibAsset.BibID = CircCatAdmin.Copy.BibID
LEFT JOIN CircCatAdmin.Patron ON CircCatAdmin.Patron.PatronID = CircCatAdmin.Copy.PatronID
LEFT JOIN CircCatAdmin.SitePatron ON CircCatAdmin.SitePatron.PatronID = CircCatAdmin.Patron.PatronID
WHERE CircCatAdmin.BibAsset.TemplateID IN (
		SELECT CircCatAdmin.AssetTemplate.AssetTemplateID
		FROM [destiny].[CircCatAdmin].[AssetTemplate]
		WHERE lower(CircCatAdmin.AssetTemplate.NAME) LIKE '%staff ipads%'
			--OR lower(CircCatAdmin.AssetTemplate.NAME) LIKE '%ipads%'
		)
--AND LOWER(CircCatAdmin.Patron.EmailAddress1) LIKE '%plymouth.k12.in.us%'
ORDER BY CircCatAdmin.Copy.STATUS;