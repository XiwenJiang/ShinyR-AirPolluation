# US Air Polluation Visualization

The current R Shiny app allows users to look at trends in pollution levels in the U.S. for each year (2011 - 2020) that there is available data. It includes a graph of daily averages and a table showing various monthly summary statistics at county level, and the U.S. map to visualize the monthly average air pollution at states level.

## Usage
To run it locally, you'll need to download all code and data from this repository and run the following code to install needed packages.

``` {r}
install.packages(c("shiny", "tidyverse", "stringr", "maps", "DT", "zoo", "lubridate", "shinyWidgets", "ggthemes"))
```

After all these packages are installed, you can run this app by entering the directory, and then running the following in R:

```{r}
shiny::runApp()
```
