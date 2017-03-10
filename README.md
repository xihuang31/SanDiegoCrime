San Diego Crime
This is an IOS app, which can show crime data by district in San Diego.

1. Please update your xocde to updated one and iOS simulator to 10.2, only 10.2 can support this JBChart version

2. When tap the annotation view in the map view,
it call out the small layout shows the top3 crime. 
I change the way to go to detail view controller.
You need to tap the annotation view(Like Pin) again to reach detail view.

Technique: (1) SQL Database : Third Party Library https://github.com/stephencelis/SQLite.swift
           (2) JBChart
           (3) Map, Location Service.

![screen shot 2017-03-10 at 12 10 01 pm](https://cloud.githubusercontent.com/assets/15055996/23811572/77cebc10-058b-11e7-9040-fac31dc5f551.png)
![screen shot 2017-03-10 at 12 10 17 pm](https://cloud.githubusercontent.com/assets/15055996/23811574/77d1545c-058b-11e7-8765-556b24aaccea.png)
![screen shot 2017-03-10 at 12 10 32 pm](https://cloud.githubusercontent.com/assets/15055996/23811573/77d07e42-058b-11e7-9b81-98fa5d6605d9.png)
![screen shot 2017-03-10 at 12 23 06 pm](https://cloud.githubusercontent.com/assets/15055996/23811799/5c9ab466-058c-11e7-9688-72fe27398e87.png)

DataSource:http://data.sandiegodata.org/dataset/clarinova_com-crime-incidents-casnd-7ba4-extract
