# vibrant
A small library that generates semi-random pygments css from a palette of one or more colors.
Probably useless, but fun to play around with.

## usage

`(vibrant:vibrant output-path colors &key variance blending prefix)`

## examples

The sources for these files can be found in the premade-css folder.

color: #79BD9A

![green.png](https://raw.githubusercontent.com/arathnim/vibrant/master/img/green.png)

colors: #40C0CB #EB9F9F

![red.png](https://raw.githubusercontent.com/arathnim/vibrant/master/img/red.png)

colors: #73626E #B38184 #F0B49E

![purple.png](https://raw.githubusercontent.com/arathnim/vibrant/master/img/purple.png)

## dependencies and installation

This project requires quicklisp to run. It's been tested on sbcl, but should work on other CL implementations.
To install quicklisp, head over to [quicklisp's website](https://www.quicklisp.org/beta/) and follow 
the instructions there. Make sure you run `(ql:add-to-init-file)`, otherwise quicklisp won't be avaliable 
when you start your interpreter.

To load it, clone this repo and `sbcl --load vibrant.cl`