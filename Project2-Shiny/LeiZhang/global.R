r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()
df<-read.csv("df.csv")
pkmStatus<-read.csv("PokemonStatus.csv")
city_choice<-levels(df$city)
pokemon_choice<-levels(df$pokemonName)
maptype = c("terrain", "terrain-background", "satellite",
            "roadmap", "hybrid", "toner", "watercolor", "terrain-labels", "terrain-lines",
            "toner-2010", "toner-2011", "toner-background", "toner-hybrid",
            "toner-labels", "toner-lines", "toner-lite")
source = c("google", "osm",
             "stamen", "cloudmade")
map=c("HERE.hybridDay","Stamen.TonerLines","Stamen.Terrain","CartoDB.Positron","Esri.WorldImagery")
## named vector for text to be displayed with xlab

## very good!