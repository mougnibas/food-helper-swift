# FoodHelper

A swift project to play with swift and food.

# Usage

TODO

# TODOs

Add CI script (xcode test on all testable targets), with code coverage reports on individual targets.
Also aggregate reports for global code coverage report.

Add a recipe component, with protected resources.

Remove exposition of kernel endpoints in docker compose.

# Dev notes

## Notes

### Xcode

#### Workspace

Open workspace `FoodHelper.xcworkspace`.

#### Scheme

1 SPM target = 1 Xcode scheme.

Select a scheme according to your current task.

#### Code style

SwiftLint is integrated with SwiftPackage plugin.

Just run "Build" or "Test", then open "Show the issue navigator" on the left panel.

Or run :

```zsh
cd FoodHelperKernel/
swiftlint
```

#### Coverage

After running tests, code coverage result is available on "Show the Report navigator" on the left panel.

### Profiles

Application can be run with a given profile.

#### Development (without Fluent)

This profile include local pure swift in-memory data access implementation.

#### Testing (with Fluent / SQLite in-memory)

This profile include Fluent middleware, but with a local in-memory SQLite data access implementation.

#### Production (with Fluent / MariaDB)

This profile include Fluent middleware, but need an external MariaDB server data access implementation.

### Architecture

#### Overview

All module follow this general guidelines.

`<Project><Module><Submodule>`

`<Project>` = `FoodHelper`

`<Module>` = `Kernel` (other module will come)

`<Submodule>` = 

- `` (root) : Contain module's service contract and models
- `DataAccess` : Container internal data access service, restricted to this module.
- `DataAccessFluent` : Fluent-based implementation of data access service (cannot be run outside of Vapor).
- `DataAccessInMemory` : In memory based implementation of data access service (no Vapor, no Fluent).
- `Impl` : Implementation of module service. Work with a `DataAccess` protocol (will need a real one at runtime).
- `Webservice` : Connect services together. Provide http routes, database connectivty, configuration and so on.

For simplicity purpose, `Webservice` will inject the correct configuration at runtime, which mean it will know and
embbed multiple database drivers, even if they are not all used at runtime.
This is acceptable as long as the drivers are small and secured.
Actually, there is only two drivers : mysql (for production purpose) and sqlite (for testing purpose).

It looks like an hexagonal architecture. Same idea, but with different words :

- ``(root) expose the business services.
- `Impl` focus on business function. It doesn't know about http functions or persistence. 
   It only use data access service to make CRUD operations. 
   It doesn't know the details of the data service implementation, and doesn't care about it (not my concern).
- `DataAccess` provide the an interface to data access to `Impl`
- `DataAccessFluent` provide a concrete implementation of data access service (based on Vapor/Fluent).
- `DataAccessInMemory` provide a concrete in-memory implementation of data access service (NOT based on Vapor/Fluent).
- `Webservice` embbed all this together and expose http routes for accessing the business services.

`Impl` can be fully unit tested, given that you provide a functional implementation (simple in-memory actor will do).
It behavior will not change if you use another implementation of data access.
It focus on business critic functions. Data access is not in his scope. Http route is not in this scope.

##### Kernel

Main 'Core' domain.

Handle business critic functions.

Must NOT expose any interface outside. Public interface must be wraped inside another dedicated component.

## Requirements

### Xcode 26.2

Download [https://apps.apple.com/fr/app/xcode/id497799835?mt=12](Xcode).

### Docker Dekstop

Download [https://docs.docker.com/desktop/setup/install/mac-install/](Docker Desktop for Mac) and install it.

Run Docker Desktop app.

## Manual pipeline

### Build

#### Build with Swift CLI

##### Build for debug

```zsh
cd FoodHelperKernel/
swift build
```

Executable file : `FoodHelperKernel/.build/arm64-apple-macosx/debug/FoodHelperKernelWebservice`

##### Build for release

```zsh
cd FoodHelperKernel/
swift build --configuration release
```

Executable file : `FoodHelperKernel/.build/arm64-apple-macosx/release/FoodHelperKernelWebservice`

#### Build with Xcode

`Product / Build`

Or

`Command + B`

### Test

#### Before running tests or production profile

Run a temporary mariadb daemon container :

```zsh
docker run                                  \
  --rm                                      \
  --interactive --tty                       \
  --name     mariadb                        \
  --hostname mariadb                        \
  --publish 3306:3306                       \
  --env MARIADB_ROOT_PASSWORD=my-secret-pw  \
  --env MARIADB_USER=kernel-db-user         \
  --env MARIADB_PASSWORD=kernel-db-password \
  --env MARIADB_DATABASE=kernel-db          \
  mariadb:12.1-noble
```

For end-to-end tests, also build and run docker-compose app :

```zsh
docker compose build       && \
docker compose up --detach
```

#### Test with Swift CLI

To be noted : All tests can not be run at once, because when end-to-end tests is setup (docker compose), default port
is used by docker, but in integration, we will try to also run on default port, but it is already open.

##### Test with Swift CLI (unit tests)

```zsh
cd FoodHelperKernel && swift test --filter Unit
cd FoodHelperRecipe && swift test --filter Unit
```

##### Test with Swift CLI (integration tests)

```zsh
cd FoodHelperKernel && swift test --filter Integration --no-parallel
cd FoodHelperRecipe && swift test --filter Integration --no-parallel
```

##### Test with Swift CLI (end-to-end tests)

```zsh
cd FoodHelperRecipe && swift test --filter EndToEnd --no-parallel
```

#### Test with Xcode

`Product / Test`

Or

`Command + U`

#### After running tests

Stop the temporary mariadb daemon container :

```zsh
docker container stop mariadb
```

For end-to-end tests, also stop docker-compose app :

```zsh
docker compose down --volumes
```

#### Test with `script-ci-xcode.sh`

##### Test with `script-ci-xcode.sh` (run all targets)

```zsh
./script-ci-xcode.sh
```

##### Test with `script-ci-xcode.sh` (run only unit tests)

```zsh
./script-ci-xcode.sh --mode=unit
```

##### Test with `script-ci-xcode.sh` (run only integration tests)

```zsh
./script-ci-xcode.sh --mode=integration
```

##### Test with `script-ci-xcode.sh` (run only end-to-end tests)

```zsh
./script-ci-xcode.sh --mode=end-to-end
```

### Package (docker image)

```zsh
docker compose build
```

### Run

#### Run (from swift command)

##### Run (from swift command / development profile)

```zsh
cd FoodHelperKernel/
swift run FoodHelperKernelWebservice --env development
```

##### Run (from swift command / testing profile)

```zsh
cd FoodHelperKernel/
swift run FoodHelperKernelWebservice --env testing
```

##### Run (from swift command / production profile)

[MariaDB service must be up before running the webservice.](#before-running-tests-or-production-profile)

```zsh
cd FoodHelperKernel/
swift run FoodHelperKernelWebservice --env production
```

#### Run (from builded executable app)

##### Run (from executable release file/ development profile)

```zsh
cd FoodHelperKernel/
.build/arm64-apple-macosx/release/FoodHelperKernelWebservice
```
or

```zsh
cd FoodHelperKernel/
.build/arm64-apple-macosx/release/FoodHelperKernelWebservice --env development
```

##### Run (from executable release file / testing profile)

```zsh
cd FoodHelperKernel/
.build/arm64-apple-macosx/release/FoodHelperKernelWebservice --env testing
```

##### Run (from executable release file / production profile)

[MariaDB service must be up before running the webservice.](#before-running-tests-or-production-profile)

```zsh
cd FoodHelperKernel/
.build/arm64-apple-macosx/release/FoodHelperKernelWebservice --env production
```

#### Run (from docker compose)

```zsh
docker compose up --detach
```

##### Stop (from docker compose)

```zsh
docker compose stop
```

##### Remove (from docker compose)

```zsh
docker compose down
```

##### Remove and delete database (from docker compose)

```zsh
docker compose down --volumes
```

### Send requests

#### Root message

```zsh
curl http://127.0.0.1:8081
```

#### Get all recipes

```zsh
curl http://127.0.0.1:8081/recipe
```

#### Get a recipe

```zsh
curl http://127.0.0.1:8081/recipe/B68A66C6-670B-4D48-8B25-8F9A61FD8E9D
```

```zsh
curl http://127.0.0.1:8081/recipe/00000000-0000-0000-0000-000000000000
```

#### Post a new recipe

```zsh
curl http://127.0.0.1:8081/recipe                   \
    --header "Content-Type: application/json"              \
    --data '{
             "id": "00000000-0000-0000-0000-000000000000",
             "name": "Pizza",
             "steps": []
            }'
```
#### Health checks

##### Live (response 200 OK if server is up)

```zsh
curl --verbose http://127.0.0.1:8081/health/live
```

##### Ready (response 200 OK if serveur is up AND ready)

```zsh
curl --verbose http://127.0.0.1:8081/health/ready
```
