# ARM Kickstarter Project

This is a kickstarter project for bare-metal ARM development using Docker.

Use the `devcontainer` extension from vscode to get a fully reproducible and ready development setup.
Also `CLion` works also very well.

## Adopting this Project

Basically search for all 'TODO' tags and perform the actions described there. To test the development setup
you can use this project. It will build but just produce non-working target binaries and an empty test binary.

## Directory Structure

### Source Directories

 * `app` - Contains the main application sources to be compiled for both the tests and the target
 * `app/target` - Entry point for target application.
 * `app/test` - Entry point for test application.
 * `btl` - Target-only executable serving as a bootloader.
 * `hal/target` - The hardware abstraction layer that implements the interface between the app and the hardware
 * `hal/test` - The hardware abstraction layer to mock the actual HAL on the target
 * `target` - Target specific sources. Usually coming from the manufacturer. May contain interrupt vectors and startup code.

### Auxiliary Directories

 * `.devcontainer`, `.vscode` - VSCode settings and environment. Also take note of the `Dockerfile` in `.devcontainer`, which is also used for CI.
 * `cmake` - Source files for the build process
 * `jenkins` - Shell scripts for CI/CD pipeline
 * `tools` - Contains the merge_tool installed as a binary

## Docker on Windows

Make sure you use WSL 2 and clone the code into your WSL 2 file system.
Just follow the [vscode devcontainer tutorial](https://code.visualstudio.com/docs/remote/containers).

## Compile for Target and Tests

By default, cmake compiles for the target. If you add `-DTARGET=test` cmake will compile the tests.
Also, you should chose either `-DCMAKE_BUILD_TYPE=Debug` or `-DCMAKE_BUILD_TYPE=Release`.
Some cmake variants are prepared in `.vscode/cmake-variants.yaml`.

## Release Information & Bootloader

This project automatically builds a bootloader and produce release files using https://github.com/raffber/merge_tool.
Refer there for more information.

Also, the version is automatically inferred from the `CHANGELOG.md` file, so to change the version number, just add an
entry there and compile.
Additionally for packaging, an `info.json` file is generated containing some meta-information about the firmware.

## Other Tools

| Option      | Description                                |
|-------------|--------------------------------------------|
| cppcheck    | `cmake --build build --target cppcheck`    |
| clangformat | `cmake --build build --target clangformat` |
| clang-tidy  | `cmake --build build --target clang-tidy`  |


## CI-Setup

This project contains a `Jenkinsfile` to run a CI/CD pipeline with jenkins. Scripts can be found in the `jenkins/` directory.