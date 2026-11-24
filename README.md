# Calgary Secondary Suites Analysis

SQL and Power BI analysis of secondary suite permits and completions in Calgary, built for a Building Permits and Inspections scheduling use case.

## Stakeholder

The City of Calgary's Building Permits and Inspections team (Planning and Development), specifically the group responsible for scheduling secondary suite inspections and forecasting permit volume.

## Business Problem

Secondary suites have become a fast growing part of Calgary's housing supply. Completions have jumped from roughly 100 per year a decade ago to over 6,000 per year recently, driven by the city's push to add "missing middle" housing. That growth is straining inspection capacity and permit processing resources, and the team currently has no consolidated view of where suites are concentrated, when demand peaks, or which areas experience inspection delays.

## Why It Matters

Without this visibility, the team can't proactively allocate inspectors, anticipate seasonal workload spikes, or flag communities where the permit to completion process is breaking down. A data driven view lets them shift from reactive scheduling to planned resourcing.

## Data

City of Calgary Secondary Suites open dataset (26,543 rows). Fields include Address, Community, CompletionDate, InspectionDate, PermitNumber, StickerNumber, and Ward.

## Data Quality Checks

- Missing StickerNumber values
- Permits covering more than one suite/address
- Anomaly check for CompletionDate recorded before InspectionDate

## Business Questions and Visualizations

1. **Which Calgary communities have generated the most secondary suite permits?** Bar/column chart of top 15 communities by suite count.
2. **How has the number of secondary suite completions changed year over year?** Line chart of completions by year.
3. **Which Wards have the highest number of secondary suites?** Ranked bar chart of suite count and community count by ward.
4. **What share of secondary suite completions falls in each quarter of the year?** Stacked bar/treemap showing seasonality.
5. **Which communities have the longest average inspection to completion lag?** Exception analysis flagging communities with above average lag.

## Tools

- SQL Server (Docker) for data cleaning and aggregation
- Power BI for visualization

## Files

- `Secondary_Suites_queries.sql` - all data quality checks and business question queries
- `Secondary_Suites_Visual.pbix` - Power BI dashboard file (open in Power BI Desktop to view)
- `Visualization Screenshot.png` - screenshot of the finished dashboard

![Dashboard screenshot](Visualization%20Screenshot.png)

## Key Findings

- Suite completions grew 6.3x over the period covered by the data
- Completions are heavily concentrated in a small number of communities, with Ward 5 leading all wards
- Completions show a clear seasonal pattern across quarters
- A handful of communities show meaningfully longer inspection to completion lag than the rest, worth flagging for process review
