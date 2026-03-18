# picoruby-nRF52

`picoruby-nRF52` is the platform repository for the nRF52 PicoRuby port.

It owns:
- the nRF52 startup and linker files
- the nRF52 HAL and board glue
- the published nRF5 SDK path used by downstream product repositories

It does not own:
- USB CDC or MSC product behavior
- product packaging and flashing workflow

Those product-layer concerns belong in `R2P2-nRF52`.

## SDK Setup

This repository expects the Nordic SDK at the fixed local path:

```text
nrf52/sdk/nRF5_SDK_17.1.0_ddde560
```

The SDK directory is intentionally ignored by git. Download or unpack the SDK
yourself and place it there.

The published build interface is:

```make
build_config/nrf52-sdk.mk
```

Downstream repositories such as `R2P2-nRF52` should include that file instead
of hardcoding SDK paths.

## Build

Build the current nRF52 firmware from the repository root:

```sh
make GNU_INSTALL_ROOT=
```

Outputs are written under:

```text
_build/
```

## Current Runtime Goal

The current platform goal is:
- boot PicoRuby on nRF52
- run `mrblib/main_task.rb`
- print `Hello World!` on the platform console path

USB CDC is intentionally handled in `R2P2-nRF52`.
