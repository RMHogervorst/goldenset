
An automated flow where you create a model only and github actions does the rest.



This is actually not the best [way to do this ](https://github.com/rstudio/vetiver-r/issues/155) but I want to keep the repository self contained.



So the actions should do the following things
- verify model against golden set
- build and push container to github registry