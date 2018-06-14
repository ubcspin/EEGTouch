Installation
============
You should be able to just run

`npm install --python=python2.6`

And everything should be peachy. Then run:

`npm run dev`

to get the development server running. That should pop up a webpage to:

`http://localhost:8080/`

which will have the interface running.


To *rebuild* the the package for production-ready
-------------------------------------------------

`npm run build`

To run at `http://localhost:3000/` (note the different localhost port) for the gaming session, AFTER building, run:

`npm run server`


Logs
----

The server will always log to a new file every time it's run, named with the UNIX timestamp of when it started. They are under `../node/logs`.


Notes
=====

Great tutorial for React+webpack:
https://medium.freecodecamp.org/part-1-react-app-from-scratch-using-webpack-4-562b1d231e75