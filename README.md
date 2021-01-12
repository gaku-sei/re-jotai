# ReJotai

Binding for the [Jotai](https://github.com/pmndrs/jotai) library

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

#### `Jotai.atom`

Creates a simple readable/writable atom:

```rescript
let counterAtom = Jotai.atom(10)
```

#### `Jotai.derivedAtom`

```rescript
let doubleCounterDerivedAtom = Jotai.derivedAtom(get => get(counterAtom) * 2)
```

#### `Jotai.derivedAsyncAtom`

```rescript
let asyncDerivedAtom = Jotai.derivedAsyncAtom(get =>
  Js.Promise.make((~resolve, ~reject as _) => {
    let tripleCounter = get(counterAtom) * 3

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

- The `get` function in derived atoms currently supports only one type at a time (see this [issue](https://github.com/gaku-sei/re-jotai/issues/1) for more)
- Some functions are still missing, namely: [`derivedWritableAtom`](https://github.com/gaku-sei/re-jotai/issues/2) and [`derivedAsyncWritableAtom`](https://github.com/gaku-sei/re-jotai/issues/3)
