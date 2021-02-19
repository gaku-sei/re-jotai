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

let asyncDerivedAtom = Atom.makeAsynDerived(getter =>
  Js.Promise.make((~resolve, ~reject as _) => {
    let tripleCounter = getter->Atom.get(counterAtom) * 3

    Js.Global.setTimeout(() => resolve(. tripleCounter), 300)->ignore
  })
)

module AsyncCounter = {
  @react.component
  let make = () => {
    // let _tripleCounter = Hooks.useAtom(asyncDerivedAtom)
    let tripleCounter = Hooks.useDerivedAtom(asyncDerivedAtom)

    <> <div title="tripled-counter"> {tripleCounter->React.int} </div> </>
  }
}

module Counter = {
  @react.component
  let make = () => {
    let (counter, setCounter) = Hooks.useAtom(counterAtom)
    let _counter = Hooks.useDerivedAtom(counterAtom)
    // let _doubleCounter = Hooks.useAtom(doubleCounterDerivedAtom)
    let doubleCounter = Hooks.useDerivedAtom(doubleCounterDerivedAtom)
    let mixed = Hooks.useDerivedAtom(mixedDerivedAtom)

    <div>
      <div title="counter"> {counter->React.int} </div>
      <div title="counter-2"> {mixed["counter"]->React.int} </div>
      <div title="message"> {mixed["message"]->React.string} </div>
      <div title="doubled-counter"> {doubleCounter->React.int} </div>
      <React.Suspense fallback={<div> {"loading"->React.string} </div>}>
        <AsyncCounter />
      </React.Suspense>
      <button title="increment" onClick={_ => setCounter(counter => counter + 1)}>
        {"increment"->React.string}
      </button>
    </div>
  }
}

module App = {
  @react.component
  let make = () => <Provider> <Counter /> </Provider>
}

describe("useCounter", () => {
  test(`Counter is ${initialCounter->Int.toString}`, () => {
    let app = <App />->render

    app->container->expect->toMatchSnapshot
  })

  test(`Counter is ${(initialCounter + 1)->Int.toString}`, () => {
    let app = <App />->render

    app->getByText(~matcher=#Str("increment"))->FireEvent.click->ignore

    app->container->expect->toMatchSnapshot
  })
})
