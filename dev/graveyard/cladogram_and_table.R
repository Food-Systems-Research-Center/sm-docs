## Cladogram

Show Wiltshire framework - what have we covered, what have we added.

```{r cladogram}
#| label: cladogram
#| fig-cap: Cladogram of Sustainability Metrics framework
#| fig-height: 20
#| fig-width: 8
pacman::p_load(
  ggtree,
  dplyr,
  ape,
  data.tree,
  viridisLite,
  stringr
)

## Load data and add an origin level
dat <- readRDS('data/tree_dat.rds') %>% 
  mutate(Framework = 'Sustainability') %>% 
  select(Framework, Dimension:Indicator) %>% 
  mutate(across(
    everything(), 
    ~ str_trim(str_replace_all(., ';|%|/|\\.|\"|,|\\(|\\)', '_'))
  ))

dat$pathString <- paste(
  dat$Framework,
  dat$Dimension,
  dat$Index,
  dat$Indicator,
  sep = '/'
)
tree <- as.Node(dat)

# Convert the data.tree structure to Newick format
tree_newick <- ToNewick(tree)

# Read the Newick tree into ape
phylo_tree <- read.tree(text = tree_newick)

# Make all edge lengths 1
phylo_tree$edge.length <- rep(1, length(phylo_tree$edge.length))

# Add a space to end of node labels so it isn't cut off
phylo_tree$node.label <- paste0(phylo_tree$node.label, ' ')

# Plot it
plot(
  phylo_tree, 
  type = 'c',
  cex = 0.75,
  edge.width = 2,
  show.tip.label = TRUE,
  label.offset = 0,
  no.margin = TRUE,
  tip.color = 'black',
  edge.color = viridis(181),
  x.lim = c(-0.1, 5)
)

nodelabels(
  phylo_tree$node.label,
  cex = 0.8,
  bg = 'white'
)

```
## Metrics Explorer

Using the table: 
  
  * Click column headers to sort
* Global search at top right, column search in each header
* Change page length and page through results at the bottom
* Use the download button to download a .csv file of the filtered table

```{r}
#| label: metadata_table

pacman::p_load(
  dplyr,
  reactable,
  stringr,
  htmltools
)

# Load full metadata table
metadata_all <- readRDS('data/sm_data.rds')[['metadata']]

# Pick out variables to display
metadata <- metadata_all %>% 
  select(
    metric,
    definition,
    dimension,
    index,
    indicator,
    units,
    'Year' = latest_year, # Note renaming latest year as year, not including year
    source,
    scope,
    resolution,
    url
  )

# Fix capitalization of column names
names(metadata) <- str_to_title(names(metadata))

###
htmltools::browsable(
  tagList(
    
    tags$div(
      style = "display: flex; gap: 16px; margin-bottom: 20px; justify-content: center;",
      
      tags$button(
        class = "btn btn-primary",
        style = "display: flex; align-items: center; gap: 8px; padding: 8px 12px;",
        tagList(fontawesome::fa("download"), "Show/hide more columns"),
        onclick = "Reactable.setHiddenColumns('metrics_table', prevColumns => {
          return prevColumns.length === 0 ? ['Definition', 'Scope', 'Resolution', 'Url'] : []
        })"
      ),
      
      tags$button(
        class = "btn btn-primary",
        style = "display: flex; align-items: center; gap: 8px; padding: 8px 12px;",
        tagList(fontawesome::fa("download"), "Download as CSV"),
        onclick = "Reactable.downloadDataCSV('metrics_table', 'sustainability_metrics.csv')"
      )
    ),
    
    reactable(
      metadata,
      sortable = TRUE,
      resizable = TRUE,
      filterable = TRUE,
      searchable = TRUE,
      pagination = TRUE,
      bordered = TRUE,
      wrap = TRUE,
      rownames = FALSE,
      onClick = 'select',
      striped = TRUE,
      pageSizeOptions = c(5, 10, 25, 50, 100),
      defaultPageSize = 5,
      showPageSizeOptions = TRUE,
      highlight = TRUE,
      style = list(fontSize = "14px"),
      compact = TRUE,
      columns = list(
        # Dimension = colDef(
        # minWidth = 75,
        # sticky = 'left'
        # ),
        # Index = colDef(
        # minWidth = 75,
        # sticky = 'left'
        # ),
        # Indicator = colDef(
        # minWidth = 100,
        # sticky = 'left'
        # ),
        Metric = colDef(
          minWidth = 200,
          sticky = 'left'
        ),
        Definition = colDef(
          minWidth = 250,
        ),
        # Units = colDef(minWidth = 50),
        # Year = colDef(minWidth = 75),
        'Latest Year' = colDef(minWidth = 75),
        Source = colDef(minWidth = 250),
        Scope = colDef(show = FALSE),
        Resolution = colDef(show = FALSE),
        Url = colDef(
          minWidth = 300,
          show = FALSE
        )
      ),
      defaultColDef = colDef(minWidth = 100),
      elementId = "metrics_table",
      details = function(index) {
        div(
          style = "padding: 15px; border: 1px solid #ddd; margin: 10px 0;
             background-color: #E0EEEE; border-radius: 10px; border-color: black;
             box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.1);",
          
          tags$h4(
            strong("Details"), 
          ),
          tags$p(
            strong('Metric Name: '), 
            as.character(metadata_all[index, 'metric']),
          ),
          tags$p(
            strong('Definition: '), 
            as.character(metadata_all[index, 'definition']),
          ),
          tags$p(
            strong('Source: '), 
            as.character(metadata_all[index, 'source'])
          ),
          tags$p(
            strong('Latest Year: '), 
            as.character(metadata_all[index, 'latest_year'])
          ),
          tags$p(
            strong('All Years (cleaned, wrangled, and included here): '), 
            as.character(metadata_all[index, 'year'])
          ),
          tags$p(
            strong('Updates: '), 
            str_to_title(as.character(metadata_all[index, 'updates']))
          ),
          tags$p(
            strong('URL: '), 
            tags$a(
              href = as.character(metadata_all[index, 'url']),
              target = '_blank',
              as.character(metadata_all[index, 'url'])
            )
          )
        )
      }
    )
  )
)

```
