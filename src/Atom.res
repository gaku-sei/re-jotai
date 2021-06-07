@ocaml.doc("The set of permissions attached to an atom (read, write, read and write).
Allows for safe use of atoms.")
module Permissions = {
  type w = [#writable]

  type r = [#readable]

  type rw = [r | w]
}

@ocaml.doc("The atom type, takes the value, the setter value (can be a function), and the permission
(read/write/read and write). In general when using this type you can safely let the compiler
guess the 2 latter types for you:

```
let intAtom: Jotai.Atom.t<int, _, _> = Jotai.Atom.make(42)
```
")
type t<'value, 'setValue, 'permissions> constraint 'permissions = [< Permissions.rw]

@ocaml.doc("Creates a simple readable/writable atom:

```
let counterAtom = Jotai.Atom.make(10)
```
")
@module("jotai")
external make: 'value => t<'value, 'value => 'value, Permissions.rw> = "atom"

@ocaml.doc("Under the hood, getter is a function that takes an atom and returns a value for this atom.
Must be used with the `get` function.")
type getter

@ocaml.doc("Unlike the original API, and in order to keep the flexibility, derived atoms requires some light runtime code and small changes to the semantic: `get` is now `getter` (see `derivedAtom` and `derivedAsyncAtom` for more).

```
// Inside a derived atom
let value = getter->Jotai.Atom.get(atom)
```
")
let get = (type value, get: getter, atom: t<value, _, [> Permissions.r]>): value =>
  Obj.magic(get, atom)

@ocaml.doc("An inhabited type used for the derived, write only, atoms")
type void

@ocaml.doc("Creates a derived (readonly) atom.

```rescript
let doubleCounterDerivedAtom = Jotai.Atom.makeDerived(getter => getter->Jotai.Atom.get(counterAtom) * 2)
```
")
@module("jotai")
external makeDerived: (getter => 'derivedValue) => t<'derivedValue, void, Permissions.r> = "atom"

@ocaml.doc("Creates an async derived (readonly) atom.

```rescript
let asyncDerivedAtom = Jotai.Atom.makeAsyncDerived(getter =>
  Js.Promise.make((~resolve, ~reject as _) => {
    let tripleCounter = getter->Jotai.Atom.get(counterAtom) * 3

    Js.Global.setTimeout(() => resolve(. tripleCounter), 300)->ignore
  })
)
```
")
@module("jotai")
external makeAsynDerived: (getter => Js.Promise.t<'derivedValue>) => t<
  'derivedValue,
  void,
  Permissions.r,
> = "atom"

@ocaml.doc("Under the hood, setter is a function that takes an atom,
and a new value for this atom and return unit.
Must be used with the `set` function.")
type setter

@ocaml.doc("Unlike the original API, and in order to keep the flexibility, writable derived atoms requires some light runtime code and small changes to the semantic: `set` is now `setter` (see `makeWritableDerived` for more).

```rescript
// Inside a writable derived atom
setter->Jotai.Atom.set(atom, newValue)
```
")
let set = (
  type value,
  set: setter,
  atom: t<value, 'arg, [> Permissions.w]>,
  newValue: value,
): unit => Obj.magic(set, atom, newValue)

@ocaml.doc("In the following example we re-use an existing readable and writable atom
and derive both a new getter and a new setter.

```rescript
let writableDerivedCounter = Atom.makeWritableDerived(
  getter => getter->Atom.get(counterAtom) * 2,
  (getter, setter, arg) => {
    let newCounterValue = getter->Atom.get(counterAtom) * 2 + arg

    setter->Atom.set(counterAtom, newCounterValue)
  },
)
```
")
@module("jotai")
external makeWritableDerived: (
  getter => 'derivedValue,
  (getter, setter, 'arg) => unit,
) => t<'derivedValue, 'arg, Permissions.rw> = "atom"
