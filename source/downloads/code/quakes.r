# load packages
# install.packages("devtools")
# devtools::install_github("rstudio/leaflet")
library(leaflet)
library(RCurl)
library("XML")
library(RColorBrewer)

# download html
html <- getURL("http://www.koeri.boun.edu.tr/scripts/lst1.asp", followlocation = TRUE)

# parse html
doc = htmlParse(html, asText=TRUE)
plain.text <- xpathSApply(doc, "//pre", xmlValue)
tmp<-strsplit(plain.text,split = "\n")

tmp1<-tmp[[1]][c(8:2007)]
tmp2<-t(sapply(tmp1,USE.NAMES = F,function(x){
  tmp<-strsplit(x," ")[[1]]
  tmp<-tmp[nchar(tmp)!=0]
  tmp[1:8]
}))
head(tmp2)

k<-"Büyüklük"

tmp3<-data.frame(as.numeric(as.character(tmp2[,3])),as.numeric(as.character(tmp2[,4])),as.numeric(as.character(tmp2[,7])),
                 paste("<b>Tarih:</b>",as.character(tmp2[,1]),as.character(tmp2[,2]),"<br>",
                       "<b>BÃ¼yÃ¼klÃ¼k:</b>",as.character(tmp2[,7]),"<br>",
                       "<b>Derinlik:</b>",as.character(tmp2[,5]),"km <br>"))
colnames(tmp3)<-c("Lat","Long","Mag","Tag")
head(tmp3)

FUN <- colorRamp(c("red","darkred"))
mg<-10^as.numeric(tmp3[,3])
MPG <- (mg - min(mg)) / diff(range(mg))
cols <- rgb(FUN(MPG),maxColorValue = 256)

quakes<-leaflet(tmp3) %>% addTiles() %>% addCircles(~Long,~Lat,
  radius=~(10^Mag)/2,
  popup=~Tag,
  color=cols,
  stroke=F
)

# library(htmlwidgets)
# saveWidget(quakes, file="~/GitHub/myBlog/source/quakes.html",selfcontained = F)