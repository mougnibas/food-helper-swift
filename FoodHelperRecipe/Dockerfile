## GNU AFFERO GENERAL PUBLIC LICENSE
## Version 3, 19 November 2007
##
## Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
## Everyone is permitted to copy and distribute verbatim copies
## of this license document, but changing it is not allowed.

##
## Multi-stage Dockerfile.
## First stage actually build the binary.
## Second stage get the binary from first stage and add it to a slim base image.
##

##
## First stage (build binary).
##

##
## Full swift image to build swift binary.
##
FROM swift:6.2.0-noble AS builder

##
## Copy module sources.
##
COPY Package.swift        /app/FoodHelperRecipe/Package.swift
COPY Package.resolved     /app/FoodHelperRecipe/Package.resolved
COPY Sources/             /app/FoodHelperRecipe/Sources
COPY Tests/               /app/FoodHelperRecipe/Tests

##
## Copy dependencies sources.
## FoodHelperKernel is provided by compose as a named build context.
##
COPY --from=kernel-module / /app/FoodHelperKernel

##
## Conventional path.
##
WORKDIR /app/FoodHelperRecipe

##
## Resolve dependencies.
##
RUN swift package resolve               --disable-sandbox

##
## Build.
##
RUN swift build --configuration release --disable-sandbox

##
## Second stage (add binary to base image).
##

##
## Slim swift image to run the binary.
##
FROM swift:6.2.0-noble-slim

##
## Port exposed.
##
EXPOSE 8081

##
## Conventional path.
##
WORKDIR /app/FoodHelperRecipe

##
## Copy the binary.
##
COPY --from=builder /app/FoodHelperRecipe/.build/release/FoodHelperRecipeWebservice .

##
## Add curl to image, for liveness probing purpose.
##
RUN apt-get update              && \
    apt-get install -y curl     && \
    rm -rf /var/lib/apt/lists/*

##
## Run the binary.
##
ENTRYPOINT ["./FoodHelperRecipeWebservice"]
