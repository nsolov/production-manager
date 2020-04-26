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
Open localhost:9098/swagger-ui/index.html and enter http://localhost:9098/production/_spec (instead of http://localhost:52773/crud/_spec).



# Examples

This Packege includes a simple demo production (RestProduction.Demo.Production)

1. Get List of Productions

GET Request
```
http://localhost:9098/production/productions
```

Response 200
```
{
  "productions": [
    {
      "production_name": "RestProduction.Demo.Production",
      "status": "Stopped",
      "last_start_datetime": "",
      "last_stop_datetime": ""
    }
  ]
}
```

2. Start Production

GET Request
```
http://localhost:9098/production/start/RestProduction.Demo.Production
```

Response 202
```
{
  "type": "ok",
  "message": "Production RestProduction.Demo.Production is starting in job 807"
}
```

Use /status/{production} request to get the result of Start Production method

3. Stop Production

GET Request
```
http://localhost:9098/production/stop/RestProduction.Demo.Production
```

Response 202

```
{
  "type": "ok",
  "message": "Production RestProduction.Demo.Production is stopping in job:1060"
}
```

Use /status/{production} request to get the result of Stop Production method



4. Get Production Status

Returns current production status and results of StartProduction, StopProduction and UpdateProduction methods.

GET Request
```
http://localhost:9098/production/status/RestProduction.Demo.Production
```

Response 200
```
{
  "name": "RestProduction.Demo.Production",
  "status": "Running",
  "StartProduction": {
    "job": "807",
    "ts-start": "2020-04-26 12:58:11",
    "ts-stop": "2020-04-26 12:58:11",
    "status": 1
  }
}
```





# Next steps
* Search messages 
* Re-send message
* Search Event Log
* Testing Service API
