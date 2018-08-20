#!/usr/bin/env bats

container_name="mamba"
image_name="mamba"

function build_container() {
  docker build -t ${image_name} .
}

function run_container() {
  docker run -d -p 8080:8080 --name "${container_name}" ${image_name}
}

function clean_up() {
  docker stop ${container_name}
  docker rm -v ${container_name}
  docker rmi ${image_name}
}

function setup() {
  if [[ "${BATS_TEST_NUMBER}" -eq 1 ]]; then
    clean_up || echo cleanup
  fi
}

function teardown() {
  if [[ "${#BATS_TEST_NAMES[@]}" -eq "$BATS_TEST_NUMBER" ]]; then
    echo "OIMG"
    if docker exec ${container_name} whoami; then
      docker stop ${container_name}
      docker rm -v ${container_name} 
      docker rmi ${image_name}
    fi
  fi
}

@test "Container Build" {
  run build_container
  [ "$status" -eq 0 ]
}

@test "Run Container" {
  run_container
  sleep 3 # wait three seconds for container to be running
  run docker exec ${container_name} whoami
  [ "$status" -eq 0 ]
}

@test "Test accessing localhost:8080/mamba" {
  run curl --fail localhost:8080/mamba
  [ "$status" -eq 0 ]
}

@test "Test 404 on localhost:8080/error" {
  run curl --fail localhost:8080/error
  [ "$status" -eq 22 ]
}

@test "Test accessing mysql-via-container" {
  skip
}

@test "Test entrypoint --help command" {
  run docker run --rm $image_name --help
  [ "$status" -eq 1 ]
}

@test "Test entrypoint for command passthrough" {
  run docker run --rm ${image_name} whoami
  [ "$status" -eq 0 ]
}
