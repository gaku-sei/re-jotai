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

#### `Jotai.get`

Unlike the original API, and in order to keep the flexibility, derived atoms requires some light runtime code and small changes to the semantic: `get` is now `getter` (see `derivedAtom` and `derivedAsyncAtom` for more).

```rescript
// Inside a derived atom
let value = getter->Jotai.get(atom)
```

#### `Jotai.atom`

Creates a simple readable/writable atom:

```rescript
let counterAtom = Jotai.atom(10)
```

#### `Jotai.derivedAtom`

```rescript
let doubleCounterDerivedAtom = Jotai.derivedAtom(getter => getter->Jotai.get(counterAtom) * 2)
```

#### `Jotai.derivedAsyncAtom`

```rescript
let asyncDerivedAtom = Jotai.derivedAsyncAtom(getter =>
  Js.Promise.make((~resolve, ~reject as _) => {
    let tripleCounter = getter->Jotai.get(counterAtom) * 3

    Js.Global.setTimeout(() => resolve(. tripleCounter), 300)->ignore
  })
)
```

### Hooks

#### `Jotai.useAtom`

_To prevent any mistake you can't use this hook with readonly derived atom_

```rescript
let (counter, setCounter) = Jotai.useAtom(counterAtom)
```

#### `Jotai.useDerivedAtom`

Returns only the value, no setter

```rescript
let doubleCounter = Jotai.useDerivedAtom(doubleCounterDerivedAtom)
```

#### `Jotai.useDerivedAtom` with Async atoms

Returns only the value, no setter.

In the example below `tripleCounter` is _not_ a Promise, but the component must be wrapped
in a React `Suspense` component.

```rescript
let tripleCounter = Jotai.useDerivedAtom(asyncDerivedAtom)
```

### More

You can check the [tests](test/Main_Test.res) for more.

## Limitations

- Some functions are still missing, namely: [`derivedWritableAtom`](https://github.com/gaku-sei/re-jotai/issues/2) and [`derivedAsyncWritableAtom`](https://github.com/gaku-sei/re-jotai/issues/3)
