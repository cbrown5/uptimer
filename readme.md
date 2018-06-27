# Uptimer

Uptimer is an R app for time management.

## The time log
To run the app you need to collect data on how you use your time.
You need to keep track of tasks in a file `time-log.csv`. Uptimer will look for this in the folder `data-raw` under the package directory (NB I haven't shared the data-raw folder, so you will have to create your own).
The time log is a simple spreadsheet where you log tasks as rows. Each row is a record of some time you spent on a task. It has headings:

`Date`: Record dates as dd/mm/yyyy  

`Start` and `End`: are times in format hh:mm (24 hour clock)  

`Project`: When you start a project decide on a name for it. Use this consistently to record time against that project. I recommend using only lower case and avoiding spaces, special characters. Leave this blank and the `Task` name will be transferred to this column, which is useful for generic tasks like email.  

`Task`: you can put project time against a series of discrete tasks. I recommend using 2-12 categories here (e.g. I have tasks `email`, `admin`, `writing`, `editing`, `reading`, `coding`, `meeting`, `teaching`, `submitting`, `presenting`)  

`Person`: I put names of time spent with my direct reports here, so I can check that I spend enough time with them (or that they aren't taking too much time).  

`Notes`: Any notes you have. Will appear as popups in some graphs.

## Project baselines
You might also like to add baselines for project time to the graph on the 'Single project' tab. To do this create a file `baseline-projects.csv` in the data-raw folder. It should have one column with heading `Project`. Under this column list the names of projects you wish to use as baselines (each on a separate row). I only add completed projects here.

## How to use
Once you've set up your `time-log.csv` then it is easy to run the app.  

Open up the file inst/app.R in Rstudio. Hit the green arrow (Run App) and it will launch. Hopefully its use is pretty intuitive from there. The GUI won't change any original data sources when it is running, so you can't break anything playing around with it.
Note that there is still a fair bit of data wrangling and a few parameters that are set in the file `inst/data-prep.R`. You might want to modify some of this for your own purposes.  

If you want to have a desktop icon that launches uptimer automatically on Windows edit the file paths to R and the shiny app in the file `inst/run-uptimer.bat`. Then just create a shortcut to the .bat file and put it on your desktop. If you are using OSX try [these instructions](http://blog.rdata.lu/post/2017-12-26-launching-your-shiny-app-in-2-clicks/). 

## Known issues
Date formats are always a problem, especially if you open you time log in excel (which can change the format of dates).
If you have issues, then first try checking the dates are formatted correctly by calls to strptime in app.R. You might also want to change the date formats at lines 19-23 of `inst/data-prep.R`.  
