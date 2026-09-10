/*
   SQL Data Visualization Presentation
   Dataset: City of Calgary - Secondary Suites
   Table assumed: SecondarySuites
   Columns: id, Address, BuildingAddress, Community, CompletionDate,
            InspectionDate, PermitNumber, StickerNumber, TpAddress,
            Ward, Point

Stakeholder: The City of Calgary's Building Permits & Inspections team (Planning & Development), 
specifically the group responsible for scheduling secondary suite inspections and forecasting permit volume.

Business Problem: Secondary suites have become a fast-growing part of Calgary's housing supply. 
Completions have jumped from roughly 100/year a decade ago to over 6,000/year recently, driven by the city's push to 
add "missing middle" housing. That growth is straining inspection capacity and permit-processing resources, 
and the team currently has no consolidated view of where suites are concentrated, when demand peaks, or which areas experience inspection delays.

Why it matters: Without this visibility, the team can't proactively allocate inspectors, anticipate seasonal workload spikes, 
or flag communities where the permit-to-completion process is breaking down. A data-driven view lets them shift from reactive scheduling to planned resourcing.
*/


-- DATA QUALITY CHECKS

-- 1. Missing StickerNumber values
SELECT COUNT(*) AS MissingStickerNumberCount
FROM SecondarySuites
WHERE StickerNumber IS NULL;

-- 2. Permits that cover more than one suite/address
--    (same PermitNumber appearing on multiple rows -
--    not an error, but a pattern worth documenting)
SELECT PermitNumber, COUNT(*) AS SuitesOnPermit
FROM SecondarySuites
GROUP BY PermitNumber
HAVING COUNT(*) > 1
ORDER BY SuitesOnPermit DESC;

-- 3. Anomaly check: CompletionDate recorded before InspectionDate
SELECT id, Address, Community, InspectionDate, CompletionDate,
       DATEDIFF(day,
                 TRY_CONVERT(date, InspectionDate, 111),
                 TRY_CONVERT(date, CompletionDate, 111)) AS LagDays
FROM SecondarySuites
WHERE TRY_CONVERT(date, CompletionDate, 111) < TRY_CONVERT(date, InspectionDate, 111)
ORDER BY LagDays ASC;


/* 
   Question 1: Category Comparison (bar/column chart)
   Business question: Which Calgary communities have generated
   the most secondary suite permits?
 */

SELECT TOP 15
    Community,
    COUNT(*) AS SuiteCount
FROM SecondarySuites
GROUP BY Community
ORDER BY SuiteCount DESC;


/*
   Question 2: Trend Over Time (line chart)
   Business question: How has the number of secondary suite
   completions changed year over year?
*/

SELECT
    YEAR(TRY_CONVERT(date, CompletionDate, 111)) AS CompletionYear,
    COUNT(*) AS SuiteCount
FROM SecondarySuites
WHERE TRY_CONVERT(date, CompletionDate, 111) IS NOT NULL
GROUP BY YEAR(TRY_CONVERT(date, CompletionDate, 111))
ORDER BY CompletionYear;


/*
   Question 3: Geographic Comparison (ranked bar / map)
   Business question: Which Wards have the highest number of
   secondary suites?
*/

SELECT
    Ward,
    COUNT(*) AS SuiteCount,
    COUNT(DISTINCT Community) AS CommunitiesInWard
FROM SecondarySuites
GROUP BY Ward
ORDER BY SuiteCount DESC;


/*
   Question 4: Composition / Share (100% stacked bar
   or treemap)
   Business question: What share of secondary suite
   completions falls in each quarter of the year (seasonality)?
*/

WITH QuarterCounts AS (
    SELECT
        DATEPART(quarter, TRY_CONVERT(date, CompletionDate, 111)) AS CompletionQuarter,
        COUNT(*) AS SuiteCount
    FROM SecondarySuites
    WHERE TRY_CONVERT(date, CompletionDate, 111) IS NOT NULL
    GROUP BY DATEPART(quarter, TRY_CONVERT(date, CompletionDate, 111))
)
SELECT
    CompletionQuarter,
    SuiteCount,
    CAST(100.0 * SuiteCount / SUM(SuiteCount) OVER () AS DECIMAL(5,1)) AS PercentOfTotal
FROM QuarterCounts
ORDER BY CompletionQuarter;


/*
   Question 5: Relationship / Performance / Exception
   Business question: Which communities have the longest average
   inspection-to-completion lag, and where do exceptions occur?
*/

SELECT
    Community,
    COUNT(*) AS SuiteCount,
    AVG(DATEDIFF(day,
                  TRY_CONVERT(date, InspectionDate, 111),
                  TRY_CONVERT(date, CompletionDate, 111))) AS AvgLagDays,
    MAX(DATEDIFF(day,
                  TRY_CONVERT(date, InspectionDate, 111),
                  TRY_CONVERT(date, CompletionDate, 111))) AS MaxLagDays,
    CASE
        WHEN AVG(DATEDIFF(day,
                  TRY_CONVERT(date, InspectionDate, 111),
                  TRY_CONVERT(date, CompletionDate, 111))) > 30
        THEN 'Above average lag'
        ELSE 'Typical lag'
    END AS LagFlag
FROM SecondarySuites
GROUP BY Community
HAVING COUNT(*) >= 20   -- exclude communities with too few permits to be meaningful
ORDER BY AvgLagDays DESC;