library(leaflet)
library(RCurl)
library("XML")
library(RColorBrewer)

# download html
html <- getURL("http://www.koeri.boun.edu.tr/scripts/lst1.asp",
                followlocation = TRUE)

# parse html
htmlText <- htmlParse(html, asText=TRUE)
plainTable <- xpathSApply(htmlText, "//pre", xmlValue)
tableLines <- strsplit(plainTable,split = "\n")

tableValues<-tableLines[[1]][c(8:2007)]
tableMatrix<-t(sapply(tableValues,USE.NAMES = F,function(x){
  tmp<-strsplit(x," ")[[1]]
  tmp<-tmp[nchar(tmp)!=0]
  tmp[1:8]
}))

table<-data.frame(as.numeric(as.character(tableMatrix[,3])),
                  as.numeric(as.character(tableMatrix[,4])),
                  as.numeric(as.character(tableMatrix[,7])),
                  paste("<b>Date:</b>",as.character(tableMatrix[,1]),as.character(tableMatrix[,2]),"<br>",
                        "<b>Magnitude (ML):</b>",as.character(tableMatrix[,7]),"<br>",
                        "<b>Depth (km):</b>",as.character(tableMatrix[,5]),"km <br>"))
colnames(table)<-c("Lat","Long","Mag","Tag")

pal = colorBin(c("green","red"), domain = 1:nrow(table))

quakes<-leaflet(table) %>% addTiles() %>% addCircles(~Long,~Lat,
  radius=~exp(2*Mag),
  popup=~Tag,
  color=~pal(nrow(table):1),
  stroke=F,
  fillOpacity = 0.5
)
