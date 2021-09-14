open Jest
open Expect
open ReactTestingLibrary

let initialCounter = 42

let counterAtom = Atom.make(initialCounter)

let messageAtom = Atom.make("Welcome Jotai!")

let mixedDerivedAtom = Atom.makeDerived(getter => {
  let counter = getter->Atom.get(counterAtom)
  let message = getter->Atom.get(messageAtom)

  {"counter": counter, "message": message}
})

let doubleCounterDerivedAtom = Atom.makeDerived(getter => getter->Atom.get(counterAtom) * 2)
let incDoubleCounterDervivedAtom = Atom.makeDerived(getter => {
  getter->Atom.get(doubleCounterDerivedAtom) + 1
})

let writableDerivedCounter = Atom.makeWritableDerived(
  getter => getter->Atom.get(counterAtom) * 3,
  (getter, setter, arg) => {
    let counter = getter->Atom.get(counterAtom) * 3

    setter->Atom.set(counterAtom, counter + arg)
  },
)

let asyncDerivedAtom = Atom.makeAsynDerived(getter =>
  Js.Promise.make((~resolve, ~reject as _) => {
    let tripleCounter = getter->Atom.get(counterAtom) * 3

    Js.Global.setTimeout(() => resolve(. tripleCounter), 300)->ignore
  })
)

/**
 * Jotai by default will set the provider less mode where a TestProvider is
 * created that passes down children so a similar technique is used here to
 * avoid Provider update warnings for every atom
 * https://github.com/pmndrs/jotai/blob/39bc8b31d05835f4af83b3dcf0d2971f984aa52c/tests/testUtils.ts#L3
 */
module TestProvider = {
  @react.component
  let make = (~children: React.element) => children
}

module AsyncCounter = {
  @react.component
  let make = () => {
    // let _tripleCounter = Hooks.use(asyncDerivedAtom)
    let tripleCounter = Hooks.useReadable(asyncDerivedAtom)

    <> <div title="tripled-counter"> {tripleCounter->React.int} </div> </>
  }
}

module Counter = {
  @react.component
  let make = () => {
    let (counter, setCounter) = Hooks.use(counterAtom)
    let _counter = Hooks.useReadable(counterAtom)
    // let _doubleCounter = Hooks.use(doubleCounterDerivedAtom)
    let doubleCounter = Hooks.useReadable(doubleCounterDerivedAtom)
    let incDoubleCounter = Hooks.useReadable(incDoubleCounterDervivedAtom)
    let mixed = Hooks.useReadable(mixedDerivedAtom)
    let (writableDerivedCounter, addToWritableDerivedCounter) = Hooks.use(writableDerivedCounter)

    <div>
      <div title="counter"> {counter->React.int} </div>
      <div title="counter-2"> {mixed["counter"]->React.int} </div>
      <div title="message"> {mixed["message"]->React.string} </div>
      <div title="doubled-counter"> {doubleCounter->React.int} </div>
      <div title="inc-doubled-counter"> {incDoubleCounter->Int.toString->React.string} </div>
      <div title="tripled-counter"> {writableDerivedCounter->React.int} </div>
      <React.Suspense fallback={<div> {"loading"->React.string} </div>}>
        <AsyncCounter />
      </React.Suspense>
      <button title="increment-1" onClick={_ => setCounter(counter => counter + 1)}>
        {"increment-1"->React.string}
      </button>
      <button title="increment-2" onClick={_ => addToWritableDerivedCounter(123)}>
        {"increment-2"->React.string}
      </button>
    </div>
  }
}

module App = {
  @react.component
  let make = () => <TestProvider> <Counter /> </TestProvider>
}

describe("useCounter", () => {
  test(`Counter is ${initialCounter->Int.toString}`, () => {
    let app = <App />->render

    app->container->expect->toMatchSnapshot
  })

  test(`Counter is ${(initialCounter + 1)->Int.toString}`, () => {
    let app = <App />->render

    act(() => {
      app->getByText(~matcher=#Str("increment-1"))->FireEvent.click->ignore
    })

    act(() => {
      app->getByText(~matcher=#Str("increment-2"))->FireEvent.click->ignore
    })

    app->container->expect->toMatchSnapshot
  })
})
