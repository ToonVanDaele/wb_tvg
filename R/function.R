# Function to calculate a new value and add to the input data frame

calculate_netP <- function(df_in, loc_P, loc_PETpm) {

  df_in %>%
    filter(loc == loc_P & var == "P") -> df_p
  df_in %>%
    filter(loc == loc_PETpm & var == "PETpm") -> df_PETpm

  df_p %>%
    inner_join(df_PETpm,
               by = "date") %>%
    mutate(value = value.x - value.y,
           var = "NetP") %>%
    dplyr::select(loc = loc.x,
                  date,
                  var,
                  value) -> df_out

  return(df_out)
}
