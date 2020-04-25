## IRIS Interoperability Production Manager
This is REST API to manage IRIS Interoperability Productions.


## What it does
Production manager allows:
* Create a new production
* Start and Stop Production
* Get Production status and production details
* Add new Business Host to the production
* Change Settings for Production and Business Hosts

## Built with
Using VSCode and ObjectScript plugin, IRIS Community Edition in Docker, ZPM, IRIS openapi API

## Installation with ZPM

zpm:USER>install production-manager

## Installation with Docker

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.


Clone/git pull the repo into any local directory e.g. like it is shown below:

```
$ git clone git@github.com:nsolov/production-manager.git
```

Open the terminal in this directory and run:

```
$ docker-compose up -d --build
```

## How to Work With it

This app creates /production REST web-application on IRIS which implements 4 types of communication: GET, POST, PUT and DELETE aka CRUD operations. 
The API is available on localhost:9098/production/
This REST API goes with  OpenAPI (swagger) documentation. you can check it localhost:9098/production/_spec
THis spec can be examined with different tools, such as [SwaggerUI](https://swagger.io/tools/swagger-ui/), [Postman](postman.com), etc.
Or you can install [swagger-ui](https://openexchange.intersystems.com/package/iris-web-swagger-ui) with:
```
zpm:IRISAPP>install swagger-ui
``` 
And check the documentation on localhost:52773/swagger-ui/index.html


# Testing 
