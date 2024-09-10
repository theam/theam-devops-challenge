# theam-devops-challenge

## INTRO

This repo contains the application used for the DevOps challenge.

## Build and Run

To run the application first build the docker image:

```sh
docker build -t challenge-app .
```

and then run it configuring the port env variable:

```sh
docker run --init --env PORT=9000 -p 9000:9000 challenge-app
```
