# Coal Index Visualizer

A web-based Shiny application to visualize and analyze coal index prices from trade deal data. The app processes uploaded CSV files, filters valid deals, computes Volume Weighted Average Prices (VWAP), and provides interactive charts and downloadable outputs. Built for commodity analysts, energy traders, and data professionals working with coal market data.

## Features

- Upload raw deal data in CSV format.
- Automatically calculates VWAP per day for selected indices.
- Includes logic to filter deals where delivery starts within 180 days of the deal date.
- Identifies COAL2 and COAL4 indices based on delivery location and source.
- Provides filters for selecting date ranges and indices.
- Displays trends using both static (ggplot2) and interactive (Plotly) visualizations.
- Generates a clean, downloadable index summary table.
- Offers download options for input format and computed results.

## Index Classification Logic

- **COAL2**: Delivery location is one of ARA, AMS, ROT, or ANT.
- **COAL4**: Commodity source location is South Africa.

Deals not matching these criteria are excluded from the analysis.

## Input CSV Requirements

Your input file should include the following columns:

- `Deal_Date` (e.g., "15-Apr-2024")
- `Delivery_Month` (e.g., "Jun")
- `Delivery_Year` (e.g., "2024")
- `Delivery_Location` (e.g., "AMS")
- `Commodity_Source_Location` (e.g., "South Africa")
- `Price` (numeric)
- `Volume` (numeric)

You can download a sample format from within the app.

## Getting Started

To run the app locally:

```r
# In R or RStudio
shiny::runApp()
