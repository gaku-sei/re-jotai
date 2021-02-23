# ReJotai

Bindings for the [Jotai](https://github.com/pmndrs/jotai) library

The bindings aim to be as close as possible to the original API, and introduces only a little runtime code only when absolutely necessary (see the derived atom sections below).

## API

### Components

#### `Jotai.Provider`

The main Provider "wrapper" for the whole application

```rescript
module App = {
  @react.component
  let make = () =>
    <Jotai.Provider>
       ...
    </Jotai.Provider>
}
```

### Atoms

#### `Jotai.Atom.get`

Unlike the original API, and in order to keep the flexibility, derived atoms requires some light runtime code and small changes to the semantic: `get` is now `getter` (see `derivedAtom` and `derivedAsyncAtom` for more).

```rescript
// Inside a derived atom
let value = getter->Jotai.Atom.get(atom)
```

#### `Jotai.Atom.set`

Unlike the original API, and in order to keep the flexibility, writable derived atoms requires some light runtime code and small changes to the semantic: `set` is now `setter` (see `makeWritableDerived` for more).

```rescript
// Inside a writable derived atom
setter->Jotai.Atom.set(atom, newValue)
```

#### `Jotai.Atom.make`

Creates a simple readable/writable atom:

```rescript
let counterAtom = Jotai.Atom.make(10)
```

#### `Jotai.Atom.makeDerived`

Creates a derived (readonly) atom.

```rescript
let doubleCounterDerivedAtom = Jotai.Atom.makeDerived(getter => getter->Jotai.Atom.get(counterAtom) * 2)
```

#### `Jotai.Atom.makeAsyncDerived`

Creates an async derived (readonly) atom.

```rescript
let asyncDerivedAtom = Jotai.Atom.makeAsyncDerived(getter =>
  Js.Promise.make((~resolve, ~reject as _) => {
    let tripleCounter = getter->Jotai.Atom.get(counterAtom) * 3

    Js.Global.setTimeout(() => resolve(. tripleCounter), 300)->ignore
  })
)
```

### `Jotai.Atom.makeWritableDerived`

In the following example we re-use an existing readable and writable atom
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

### Hooks

#### `Jotai.Hooks.use`

_To prevent any mistake you can't use this hook with readonly derived atom_

```rescript
let (counter, setCounter) = Jotai.Hooks.use(counterAtom)
```

#### `Jotai.Hook.useReadable`

Can be used only with readable atoms. Returns only the value, no setter

```rescript
let doubleCounter = Jotai.Hook.useReadable(doubleCounterDerivedAtom)
```

#### `Jotai.Hook.useReadable` with Async atoms

Can be used only with readable atoms. Returns only the value, no setter.

In the example below `tripleCounter` is _not_ a Promise, but the component must be wrapped
in a React `Suspense` component.

```rescript
let tripleCounter = Jotai.Hook.useReadable(asyncDerivedAtom)
```

#### `Jotai.Hook.useWritable`

Can be used only with writable atoms. Returns only the setter, no value

```rescript
let setCounter = Jotai.Hook.useWritable(counterAtom)
```

### More

You can check the [tests](test/Main_Test.res) for more.

## Limitations

Some functions are still missing, namely:

- [`makeWritableOnly`](https://github.com/gaku-sei/re-jotai/issues/2)
- [`makeWritableAsyncDerived`](https://github.com/gaku-sei/re-jotai/issues/3)
