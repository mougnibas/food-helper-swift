## GNU AFFERO GENERAL PUBLIC LICENSE
## Version 3, 19 November 2007
##
## Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
## Everyone is permitted to copy and distribute verbatim copies
## of this license document, but changing it is not allowed.

# Logs
LOG_FILE="reports/script-xcode.log"

# Function: init logs.
init_logs() {
    mkdir -p reports
    truncate -s 0 "$LOG_FILE"
}

# Function: mariadb stop.
stop_mariadb_on_failure() {
    echo "Stopping environment for integration tests: ..."
    if docker container stop mariadb >> "$LOG_FILE" 2>&1; then
        echo "Stopping environment for integration tests: SUCCESS"
    else
        echo "Stopping environment for integration tests: FAILURE (see $LOG_FILE)" >&2
    fi
}

# Function: compose down.
stop_compose_on_failure() {
    echo "Stopping environment for end-to-end tests: ..."
    if docker compose down --volumes >> "$LOG_FILE" 2>&1; then
        echo "Stopping environment for end-to-end tests: SUCCESS"
    else
        echo "Stopping environment for end-to-end tests: FAILURE (see $LOG_FILE)" >&2
    fi
}

# Function : List Xcode Schemes.
list_schemes() {
    echo "Listing Schemes: ..."
    if xcodebuild -list -json >> "$LOG_FILE" 2>&1; then
        echo "Listing Schemes: SUCCESS"
        echo
    else
        echo "Listing Schemes: FAILURE (see $LOG_FILE)" >&2
        exit 1
    fi
}

# Function: open latest xcresult report.
open_latest_xcresult() {
    local derived_data_dir="$HOME/Library/Developer/Xcode/DerivedData"
    local latest_result

    latest_result="$(ls -td "$derived_data_dir"/*/Logs/Test/*.xcresult 2>/dev/null | head -n 1)"
    if [ -n "$latest_result" ]; then
        xed "$latest_result"
    else
        echo "No xcresult report found in $derived_data_dir" >&2
    fi
}

# Function: Unit Tests.
tests_unit() {
    echo "Running Unit tests: ..."

    echo "Running Unit tests: FoodHelperKernelTestUnit: ..."
    if xcodebuild -scheme FoodHelperKernelTestUnit test -enableCodeCoverage YES >> "$LOG_FILE" 2>&1; then
        echo "Running Unit tests: FoodHelperKernelTestUnit: SUCCESS"
        open_latest_xcresult
    else
        echo "Running Unit tests: FoodHelperKernelTestUnit: FAILURE (see $LOG_FILE)" >&2
        exit 1
    fi

    echo "Running Unit tests: FoodHelperKernelTestsDataAccessInMemoryUnit: ..."
    if xcodebuild -scheme FoodHelperKernelTestsDataAccessInMemoryUnit test -enableCodeCoverage YES >> "$LOG_FILE" 2>&1; then
        echo "Running Unit tests: FoodHelperKernelTestsDataAccessInMemoryUnit: SUCCESS"
        open_latest_xcresult
    else
        echo "Running Unit tests: FoodHelperKernelTestsDataAccessInMemoryUnit: FAILURE (see $LOG_FILE)" >&2
        exit 1
    fi

    echo "Running Unit tests: FoodHelperKernelTestImplUnit: ..."
    if xcodebuild -scheme FoodHelperKernelTestImplUnit test -enableCodeCoverage YES >> "$LOG_FILE" 2>&1; then
        echo "Running Unit tests: FoodHelperKernelTestImplUnit: SUCCESS"
        open_latest_xcresult
    else
        echo "Running Unit tests: FoodHelperKernelTestImplUnit: FAILURE (see $LOG_FILE)" >&2
        exit 1
    fi

    echo "Running Unit tests: FoodHelperKernelTestsClientUnit: ..."
    if xcodebuild -scheme FoodHelperKernelTestsClientUnit test -enableCodeCoverage YES >> "$LOG_FILE" 2>&1; then
        echo "Running Unit tests: FoodHelperKernelTestsClientUnit: SUCCESS"
        open_latest_xcresult
    else
        echo "Running Unit tests: FoodHelperKernelTestsClientUnit: FAILURE (see $LOG_FILE)" >&2
        exit 1
    fi

    echo "Running Unit tests: FoodHelperRecipeTestImplUnit: ..."
    if xcodebuild -scheme FoodHelperRecipeTestImplUnit test -enableCodeCoverage YES >> "$LOG_FILE" 2>&1; then
        echo "Running Unit tests: FoodHelperRecipeTestImplUnit: SUCCESS"
        open_latest_xcresult
    else
        echo "Running Unit tests: FoodHelperRecipeTestImplUnit: FAILURE (see $LOG_FILE)" >&2
        exit 1
    fi

    echo "Running Unit tests: SUCCESS"
    echo
}

# Function: Integration Tests.
tests_integration() {
    echo "Starting environment for integration tests: ..."
    if docker run                                  \
      --rm                                         \
      --detach                                     \
      --name     mariadb                           \
      --hostname mariadb                           \
      --publish 3306:3306                          \
      --env MARIADB_ROOT_PASSWORD=my-secret-pw     \
      --env MARIADB_USER=kernel-db-user            \
      --env MARIADB_PASSWORD=kernel-db-password    \
      --env MARIADB_DATABASE=kernel-db             \
      mariadb:12.1-noble >> "$LOG_FILE" 2>&1; then
        echo "Starting environment for integration tests: SUCCESS"
    else
        echo "Starting environment for integration tests: FAILURE (see $LOG_FILE)" >&2
        stop_mariadb_on_failure
        exit 1
    fi

    echo "Running Integration tests: ..."
    echo "Running Integration tests: FoodHelperKernelTestsDataAccessFluentIntegration: ..."
    if xcodebuild -scheme FoodHelperKernelTestsDataAccessFluentIntegration test -enableCodeCoverage YES >> "$LOG_FILE" 2>&1; then
        echo "Running Integration tests: FoodHelperKernelTestsDataAccessFluentIntegration: SUCCESS"
        open_latest_xcresult
    else
        echo "Running Integration tests: FoodHelperKernelTestsDataAccessFluentIntegration: FAILURE (see $LOG_FILE)" >&2
        stop_mariadb_on_failure
        exit 1
    fi

    echo "Running Integration tests: FoodHelperKernelTestsWebserviceIntegration: ..."
    if xcodebuild -scheme FoodHelperKernelTestsWebserviceIntegration test -enableCodeCoverage YES >> "$LOG_FILE" 2>&1; then
        echo "Running Integration tests: FoodHelperKernelTestsWebserviceIntegration: SUCCESS"
        open_latest_xcresult
    else
        echo "Running Integration tests: FoodHelperKernelTestsWebserviceIntegration: FAILURE (see $LOG_FILE)" >&2
        stop_mariadb_on_failure
        exit 1
    fi

    echo "Running Integration tests: FoodHelperKernelTestsClientIntegration: ..."
    if xcodebuild -scheme FoodHelperKernelTestsClientIntegration test -enableCodeCoverage YES >> "$LOG_FILE" 2>&1; then
        echo "Running Integration tests: FoodHelperKernelTestsClientIntegration: SUCCESS"
        open_latest_xcresult
    else
        echo "Running Integration tests: FoodHelperKernelTestsClientIntegration: FAILURE (see $LOG_FILE)" >&2
        stop_mariadb_on_failure
        exit 1
    fi
    echo "Running Integration tests: SUCCESS"

    echo "Stopping environment for integration tests: ..."
    if docker stop mariadb >> "$LOG_FILE" 2>&1; then
        echo "Stopping environment for integration tests: SUCCESS"
        echo
    else
        echo "Stopping environment for integration tests: FAILURE (see $LOG_FILE)" >&2
        exit 1
    fi
}

# Function: End-to-end Tests.
tests_end_to_end() {
    echo "Building and running environment for end-to-end tests: ..."
    if docker compose build       >> "$LOG_FILE" 2>&1 && \
       docker compose up --detach >> "$LOG_FILE" 2>&1; then
        echo "Building and running environment for end-to-end tests: SUCCESS"
        echo
    else
        echo "Building and running environment for end-to-end tests: FAILURE (see $LOG_FILE)" >&2
        stop_compose_on_failure
        exit 1
    fi

    echo "Running End-to-end tests: ..."
    echo "Running End-to-end tests: FoodHelperKernelTestsWebserviceEndToEnd: ..."
    if xcodebuild -scheme FoodHelperKernelTestsWebserviceEndToEnd test -enableCodeCoverage YES >> "$LOG_FILE" 2>&1; then
        echo "Running End-to-end tests: FoodHelperKernelTestsWebserviceEndToEnd: SUCCESS"
        open_latest_xcresult
    else
        echo "Running End-to-end tests: FoodHelperKernelTestsWebserviceEndToEnd: FAILURE (see $LOG_FILE)" >&2
        stop_compose_on_failure
        exit 1
    fi

    echo "Running End-to-end tests: FoodHelperKernelTestsClientEndToEnd: ..."
    if xcodebuild -scheme FoodHelperKernelTestsClientEndToEnd test -enableCodeCoverage YES >> "$LOG_FILE" 2>&1; then
        echo "Running End-to-end tests: FoodHelperKernelTestsClientEndToEnd: SUCCESS"
        open_latest_xcresult
    else
        echo "Running End-to-end tests: FoodHelperKernelTestsClientEndToEnd: FAILURE (see $LOG_FILE)" >&2
        stop_compose_on_failure
        exit 1
    fi

    echo "Running End-to-end tests: SUCCESS"

    echo "Stopping environment for end-to-end tests: ..."
    if docker compose down --volumes >> "$LOG_FILE" 2>&1; then
        echo "Stopping environment for end-to-end tests: SUCCESS"
        echo
    else
        echo "Stopping environment for end-to-end tests: FAILURE (see $LOG_FILE)" >&2
        exit 1
    fi
}

# Initialize log file.
init_logs

# Resolve optional target parameter (unit, integration, end-to-end).
# Default : no parameter (all).
TARGET="all"
if [ "$#" -gt 0 ]; then
    case "$1" in
        --mode=unit|--mode=integration|--mode=end-to-end)
            TARGET="${1#--mode=}"
            ;;
        *)
            echo "Usage: $0 [--mode=unit|--mode=integration|--mode=end-to-end]" >&2
            exit 1
            ;;
    esac
fi

# List Xcode schemes.
list_schemes

# Xcode tests by target.
if [ "$TARGET" = "all" ] || [ "$TARGET" = "unit" ]; then
    tests_unit
fi

if [ "$TARGET" = "all" ] || [ "$TARGET" = "integration" ]; then
    tests_integration
fi

if [ "$TARGET" = "all" ] || [ "$TARGET" = "end-to-end" ]; then
    tests_end_to_end
fi
