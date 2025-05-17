USE ORDER_DDS;


UPDATE TARGET
SET 
    TerritoryDescription_Prior = TerritoryDescription_Current,
    RegionID_Prior = RegionID_Current,
    TerritoryDescription_Current = SOURCE.TerritoryDescription,
    RegionID_Current = SOURCE.RegionID,
    LastUpdated = GETDATE()
FROM dbo.DimTerritories_SCD3 TARGET
JOIN (
    SELECT 
        st.staging_raw_id,
        st.TerritoryID,
        st.TerritoryDescription,
        st.RegionID,
        sor.SORKey
    FROM dbo.Staging_Territories st
    JOIN dbo.Dim_SOR sor
        ON sor.StagingTableName = 'Staging_Territories'
       AND sor.TablePrimaryKeyColumn = 'TerritoryID'
) AS SOURCE
ON TARGET.TerritoryID_NK = SOURCE.TerritoryID
WHERE 
    ISNULL(TARGET.TerritoryDescription_Current, '') <> ISNULL(SOURCE.TerritoryDescription, '') OR
    ISNULL(TARGET.RegionID_Current, -1)             <> ISNULL(SOURCE.RegionID, -1);



INSERT INTO dbo.DimTerritories_SCD3 (
    TerritoryID_NK,
    TerritoryDescription_Current,
    RegionID_Current,
    TerritoryDescription_Prior,
    RegionID_Prior,
    LastUpdated
)
SELECT 
    st.TerritoryID,
    st.TerritoryDescription,
    st.RegionID,
    NULL,
    NULL,
    GETDATE()
FROM dbo.Staging_Territories st
JOIN dbo.Dim_SOR sor
    ON sor.StagingTableName = 'Staging_Territories'
   AND sor.TablePrimaryKeyColumn = 'TerritoryID'
LEFT JOIN dbo.DimTerritories_SCD3 dt
    ON dt.TerritoryID_NK = st.TerritoryID
WHERE dt.TerritoryID_NK IS NULL;

