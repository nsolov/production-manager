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

**1. Get List of Productions**

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

**2. Start Production**

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

**3. Stop Production**

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



**4. Get Production Status**

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

**5. Get Production Summary** 

Returns status of the Production and all production Items, and array of Queues for running Productions 

GET Request
```
http://localhost:9098/production/summary/RestProduction.Demo.Production
```

Response 200
```
{
  "production_name": "RestProduction.Demo.Production",
  "status": "Running",
  "last_start_datetime": "2020-04-26 13:23:00",
  "last_stop_datetime": "",
  "BusinessOperation": [
    {
      "name": "BO1",
      "enabled": 1,
      "status": "ok"
    }
  ],
  "queues": [
    {
      "name": "BO1",
      "count": "0"
    },
    {
      "name": "Ens.Actor",
      "count": "0"
    },
    {
      "name": "Ens.Alarm",
      "count": "0"
    },
    {
      "name": "Ens.ScheduleHandler",
      "count": "0"
    }
  ],
  "suspended_messages_count": 0
}
```

**6. Get Production Settings and production Items**

GET Request
```
http://localhost:9098/production/productions/RestProduction.Demo.Production
```

Response 200

```
{
  "name": "RestProduction.Demo.Production",
  "description": "",
  "actor_pool_size": 1,
  "log_general_trace_events": 0,
  "testing_enabled": "",
  "settings": [
    {
      "name": "ShutdownTimeout",
      "target": "Adapter",
      "value": "120"
    },
    {
      "name": "UpdateTimeout",
      "target": "Adapter",
      "value": "10"
    },
    {
      "name": "AlertNotificationManager",
      "target": "Adapter",
      "value": ""
    },
    {
      "name": "AlertNotificationOperation",
      "target": "Adapter",
      "value": ""
    },
    {
      "name": "AlertNotificationRecipients",
      "target": "Adapter",
      "value": ""
    },
    {
      "name": "AlertActionWindow",
      "target": "Adapter",
      "value": "60"
    }
  ],
  "items": [
    {
      "name": "BO1"
    }
  ]
}
```
In Settings array all "ModifiedSettings" are shown.

**7. Create new production**

POST Request
```
http://localhost:9098/production/productions/RestProduction.Demo.NewProduction
```
body:
```
{
  "description": "new demo production",
  "actor_pool_size": 2,
  "log_general_trace_events": 1,
  "testing_enabled": 1,
  "settings": [
    {
      "name": "ShutdownTimeout",
      "target": "Adapter",
      "value": "180"
    }]}
```

Response 200

```
{
  "name": "RestProduction.Demo.NewProduction",
  "description": "new demo production",
  "actor_pool_size": 2,
  "log_general_trace_events": 1,
  "testing_enabled": 1,
  "settings": [
    {
      "name": "ShutdownTimeout",
      "target": "Adapter",
      "value": "180"
    }
  ],
  "items": []
}
```

**8. Update Production Settings

PUT Request
```
http://localhost:9098/production/productions/RestProduction.Demo.NewProduction
```
body:
```
{
  "description": "new demo production",
  "actor_pool_size": 1,
  "log_general_trace_events": 0,
  "testing_enabled": 0,
}
```

Response 200

```
{
  "name": "RestProduction.Demo.NewProduction",
  "description": "new demo production",
  "actor_pool_size": 1,
  "log_general_trace_events": 0,
  "testing_enabled": 0,
  "settings": [
    {
      "name": "ShutdownTimeout",
      "target": "Adapter",
      "value": "180"
    }
  ],
  "items": []
}
```

**9. Add Item to the Production**

POST Request
```
http://localhost:9098/production/productions/RestProduction.Demo.NewProduction
```
body:
```
{
  "enabled": 1,
  "pool_size": 1,
  "class_name": "RestProduction.Demo.Operation"
}
```

Response 200

```
{
  "name": "NewBusinessOperation",
  "type": "BusinessOperation",
  "enabled": 1,
  "pool_size": 1,
  "class_name": "RestProduction.Demo.Operation",
  "comment": "",
  "schedule": "",
  "category": "",
  "alert_groups": "",
  "disable_error_traps": "",
  "foreground": 0,
  "inactivity_timeout": "0",
  "log_trace_events": 0,
  "settings": [
    {
      "name": "InactivityTimeout",
      "target": "Host",
      "value": "0"
    }
  ]
}
```

**10. Get Item settings**

GET Request
```
http://localhost:9098/production/items/RestProduction.Demo.NewProduction/NewBusinessOperation
```

Response 200
```
{
  "name": "NewBusinessOperation",
  "type": "BusinessOperation",
  "enabled": 1,
  "pool_size": 1,
  "class_name": "RestProduction.Demo.Operation",
  "comment": "",
  "schedule": "",
  "category": "",
  "alert_groups": "",
  "disable_error_traps": "",
  "foreground": 0,
  "inactivity_timeout": "0",
  "log_trace_events": 0,
  "settings": [
    {
      "name": "InactivityTimeout",
      "target": "Host",
      "value": "0"
    },
    {
      "name": "RegistryID",
      "target": "Adapter",
      "value": ""
    },
    {
      "name": "FilePath",
      "target": "Adapter",
      "value": ""
    },
    {
      "name": "FileName",
      "target": "Host",
      "value": "out.txt"
    },
    <... part of the output is omitted ...>
    
  ]
}
```

**11. Update Item Settings**

PUT Request
```
http://localhost:9098/production/items/RestProduction.Demo.NewProduction/NewBusinessOperation
```
body:
```
{
  "pool_size": 2,
  "class_name": "RestProduction.Demo.Operation",
  "log_trace_events": 1,
  "settings": [
    {
      "name": "FilePath",
      "target": "Adapter",
      "value": "/irisdev/app"
    },
    {
      "name": "FileName",
      "target": "Host",
      "value": "newfile.txt"
    }]}
```


Response 200
```
{
  "name": "NewBusinessOperation",
  "type": "BusinessOperation",
  "enabled": 1,
  "pool_size": 2,
  "class_name": "RestProduction.Demo.Operation",
  "comment": "",
  "schedule": "",
  "category": "",
  "alert_groups": "",
  "disable_error_traps": "",
  "foreground": 0,
  "inactivity_timeout": "0",
  "log_trace_events": 1,
  "settings": [
    {
      "name": "FilePath",
      "target": "Adapter",
      "value": "/irisdev/app"
    },
    {
      "name": "FileName",
      "target": "Host",
      "value": "newfile.txt"
    },
    {
      "name": "InactivityTimeout",
      "target": "Host",
      "value": "0"
    }
  ]
}
```

**12. Delete Item**

DELETE Request
```
http://localhost:9098/production/items/RestProduction.Demo.NewProduction/NewBusinessOperation
```

Response 200:
```
{
  "name": "RestProduction.Demo.NewProduction",
  "description": "new demo production",
  "actor_pool_size": 1,
  "log_general_trace_events": 0,
  "testing_enabled": 0,
  "settings": [
    {
      "name": "ShutdownTimeout",
      "target": "Adapter",
      "value": "180"
    }
  ],
  "items": []
}
```

## Limitations

Doesn't support multiple items with the same name


## Next steps
* Search messages 
* Re-send message
* Search Event Log
* Testing Service API
