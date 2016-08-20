# API Reference

The following is a list of all user-facing parts of Vex.

If there are backwards-incompatible changes to anything listed here, they will
be noted in the changelog and the author will feel bad.

Anything not listed here is subject to change at any time with no warning, so
don't touch it.

[TOC]

## Package `VEX`

### `VEC2`

`#<STANDARD-CLASS DOCPARSER:STRUCT-NODE>`

### `VEC2-ADD` (function)

    (VEC2-ADD V1 V2)

Add `v1` and `v2` componentwise, returning a new vector.

### `VEC2-ADD*` (function)

    (VEC2-ADD* V X Y)

Add `x` and `y` to the components of `v`, returning a new vector.

### `VEC2-ADD*!` (function)

    (VEC2-ADD*! V X Y)

Destructively update `v` by adding `x` and `y`, returning `v`.

### `VEC2-ANGLE` (function)

    (VEC2-ANGLE V)

Return the angle of `v`.

### `VEC2-DIRECTION` (function)

    (VEC2-DIRECTION V)

Return the angle of `v`.

### `VEC2-DIV` (function)

    (VEC2-DIV V SCALAR)

Divide the components of `v` by `scalar`, returning a new vector.

### `VEC2-EQL` (function)

    (VEC2-EQL V1 V2 &OPTIONAL EPSILON)

Return whether `v1` and `v2` are componentwise `=`.

          If `epsilon` is given, this instead checks that each pair of
          components are within `epsilon` of each other.

          

### `VEC2-LENGTH` (function)

    (VEC2-LENGTH V)

Return the magnitude of `v`.

### `VEC2-MAGDIR` (function)

    (VEC2-MAGDIR MAGNITUDE DIRECTION)

Create a fresh vector with the given `magnitude` and `direction`.

### `VEC2-MAGNITUDE` (function)

    (VEC2-MAGNITUDE V)

Return the magnitude of `v`.

### `VEC2-MUL` (function)

    (VEC2-MUL V SCALAR)

Multiply the components of `v` by `scalar`, returning a new vector.

### `VEC2-SUB` (function)

    (VEC2-SUB V1 V2)

Subtract `v1` and `v2` componentwise, returning a new vector.

### `VEC2-SUB*` (function)

    (VEC2-SUB* V X Y)

Subtract `x` and `y` from the components of `v`, returning a new vector.

### `VEC2-SUB*!` (function)

    (VEC2-SUB*! V X Y)

Destructively update `v` by subtracting `x` and `y`, returning `v`.

### `VEC2-X` (function)

    (VEC2-X VALUE INSTANCE)

### `VEC2-Y` (function)

    (VEC2-Y VALUE INSTANCE)

### `VEC2D`

`#<STANDARD-CLASS DOCPARSER:STRUCT-NODE>`

### `VEC2D-ADD` (function)

    (VEC2D-ADD V1 V2)

Add `v1` and `v2` componentwise, returning a new vector.

### `VEC2D-ADD*` (function)

    (VEC2D-ADD* V X Y)

Add `x` and `y` to the components of `v`, returning a new vector.

### `VEC2D-ADD*!` (function)

    (VEC2D-ADD*! V X Y)

Destructively update `v` by adding `x` and `y`, returning `v`.

### `VEC2D-ANGLE` (function)

    (VEC2D-ANGLE V)

Return the angle of `v`.

### `VEC2D-DIRECTION` (function)

    (VEC2D-DIRECTION V)

Return the angle of `v`.

### `VEC2D-DIV` (function)

    (VEC2D-DIV V SCALAR)

Divide the components of `v` by `scalar`, returning a new vector.

### `VEC2D-EQL` (function)

    (VEC2D-EQL V1 V2 &OPTIONAL EPSILON)

Return whether `v1` and `v2` are componentwise `=`.

          If `epsilon` is given, this instead checks that each pair of
          components are within `epsilon` of each other.

          

### `VEC2D-LENGTH` (function)

    (VEC2D-LENGTH V)

Return the magnitude of `v`.

### `VEC2D-MAGDIR` (function)

    (VEC2D-MAGDIR MAGNITUDE DIRECTION)

Create a fresh vector with the given `magnitude` and `direction`.

### `VEC2D-MAGNITUDE` (function)

    (VEC2D-MAGNITUDE V)

Return the magnitude of `v`.

### `VEC2D-MUL` (function)

    (VEC2D-MUL V SCALAR)

Multiply the components of `v` by `scalar`, returning a new vector.

### `VEC2D-SUB` (function)

    (VEC2D-SUB V1 V2)

Subtract `v1` and `v2` componentwise, returning a new vector.

### `VEC2D-SUB*` (function)

    (VEC2D-SUB* V X Y)

Subtract `x` and `y` from the components of `v`, returning a new vector.

### `VEC2D-SUB*!` (function)

    (VEC2D-SUB*! V X Y)

Destructively update `v` by subtracting `x` and `y`, returning `v`.

### `VEC2D-X` (function)

    (VEC2D-X VALUE INSTANCE)

### `VEC2D-Y` (function)

    (VEC2D-Y VALUE INSTANCE)

### `VEC2F`

`#<STANDARD-CLASS DOCPARSER:STRUCT-NODE>`

### `VEC2F-ADD` (function)

    (VEC2F-ADD V1 V2)

Add `v1` and `v2` componentwise, returning a new vector.

### `VEC2F-ADD*` (function)

    (VEC2F-ADD* V X Y)

Add `x` and `y` to the components of `v`, returning a new vector.

### `VEC2F-ADD*!` (function)

    (VEC2F-ADD*! V X Y)

Destructively update `v` by adding `x` and `y`, returning `v`.

### `VEC2F-ANGLE` (function)

    (VEC2F-ANGLE V)

Return the angle of `v`.

### `VEC2F-DIRECTION` (function)

    (VEC2F-DIRECTION V)

Return the angle of `v`.

### `VEC2F-DIV` (function)

    (VEC2F-DIV V SCALAR)

Divide the components of `v` by `scalar`, returning a new vector.

### `VEC2F-EQL` (function)

    (VEC2F-EQL V1 V2 &OPTIONAL EPSILON)

Return whether `v1` and `v2` are componentwise `=`.

          If `epsilon` is given, this instead checks that each pair of
          components are within `epsilon` of each other.

          

### `VEC2F-LENGTH` (function)

    (VEC2F-LENGTH V)

Return the magnitude of `v`.

### `VEC2F-MAGDIR` (function)

    (VEC2F-MAGDIR MAGNITUDE DIRECTION)

Create a fresh vector with the given `magnitude` and `direction`.

### `VEC2F-MAGNITUDE` (function)

    (VEC2F-MAGNITUDE V)

Return the magnitude of `v`.

### `VEC2F-MUL` (function)

    (VEC2F-MUL V SCALAR)

Multiply the components of `v` by `scalar`, returning a new vector.

### `VEC2F-SUB` (function)

    (VEC2F-SUB V1 V2)

Subtract `v1` and `v2` componentwise, returning a new vector.

### `VEC2F-SUB*` (function)

    (VEC2F-SUB* V X Y)

Subtract `x` and `y` from the components of `v`, returning a new vector.

### `VEC2F-SUB*!` (function)

    (VEC2F-SUB*! V X Y)

Destructively update `v` by subtracting `x` and `y`, returning `v`.

### `VEC2F-X` (function)

    (VEC2F-X VALUE INSTANCE)

### `VEC2F-Y` (function)

    (VEC2F-Y VALUE INSTANCE)

### `VEC2I`

`#<STANDARD-CLASS DOCPARSER:STRUCT-NODE>`

### `VEC2I-ADD` (function)

    (VEC2I-ADD V1 V2)

Add `v1` and `v2` componentwise, returning a new vector.

### `VEC2I-ADD*` (function)

    (VEC2I-ADD* V X Y)

Add `x` and `y` to the components of `v`, returning a new vector.

### `VEC2I-ADD*!` (function)

    (VEC2I-ADD*! V X Y)

Destructively update `v` by adding `x` and `y`, returning `v`.

### `VEC2I-ANGLE` (function)

    (VEC2I-ANGLE V)

Return the angle of `v`.

### `VEC2I-DIRECTION` (function)

    (VEC2I-DIRECTION V)

Return the angle of `v`.

### `VEC2I-DIV` (function)

    (VEC2I-DIV V SCALAR)

Divide the components of `v` by `scalar`, returning a new vector.

### `VEC2I-EQL` (function)

    (VEC2I-EQL V1 V2 &OPTIONAL EPSILON)

Return whether `v1` and `v2` are componentwise `=`.

          If `epsilon` is given, this instead checks that each pair of
          components are within `epsilon` of each other.

          

### `VEC2I-LENGTH` (function)

    (VEC2I-LENGTH V)

Return the magnitude of `v`.

### `VEC2I-MAGDIR` (function)

    (VEC2I-MAGDIR MAGNITUDE DIRECTION)

Create a fresh vector with the given `magnitude` and `direction`.

### `VEC2I-MAGNITUDE` (function)

    (VEC2I-MAGNITUDE V)

Return the magnitude of `v`.

### `VEC2I-MUL` (function)

    (VEC2I-MUL V SCALAR)

Multiply the components of `v` by `scalar`, returning a new vector.

### `VEC2I-SUB` (function)

    (VEC2I-SUB V1 V2)

Subtract `v1` and `v2` componentwise, returning a new vector.

### `VEC2I-SUB*` (function)

    (VEC2I-SUB* V X Y)

Subtract `x` and `y` from the components of `v`, returning a new vector.

### `VEC2I-SUB*!` (function)

    (VEC2I-SUB*! V X Y)

Destructively update `v` by subtracting `x` and `y`, returning `v`.

### `VEC2I-X` (function)

    (VEC2I-X VALUE INSTANCE)

### `VEC2I-Y` (function)

    (VEC2I-Y VALUE INSTANCE)

