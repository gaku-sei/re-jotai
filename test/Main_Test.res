open Jest
open Expect
open ReactTestingLibrary

let initialCounter = 42

let counterAtom = Jotai.atom(initialCounter)

let messageAtom = Jotai.atom("Welcome Jotai!")

let doubleCounterDerivedAtom = Jotai.derivedAtom(get => get(counterAtom) * 2)

let asyncDerivedAtom = Jotai.derivedAsyncAtom(get =>
  Js.Promise.make((~resolve, ~reject as _) => {
    let tripleCounter = get(counterAtom) * 3

    Js.Global.setTimeout(() => resolve(. tripleCounter), 300)->ignore
  })
)

module AsyncCounter = {
  @react.component
  let make = () => {
    // let _tripleCounter = Jotai.useAtom(asyncDerivedAtom)
    let tripleCounter = Jotai.useDerivedAtom(asyncDerivedAtom)

    <> <div title="tripled-counter"> {tripleCounter->React.int} </div> </>
  }
}

module Counter = {
  @react.component
  let make = () => {
    let (counter, setCounter) = Jotai.useAtom(counterAtom)
    let _counter = Jotai.useDerivedAtom(counterAtom)
    // let _doubleCounter = Jotai.useAtom(doubleCounterDerivedAtom)
    let doubleCounter = Jotai.useDerivedAtom(doubleCounterDerivedAtom)

    <div>
      <div title="counter"> {counter->React.int} </div>
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
  let make = () => <Jotai.Provider> <Counter /> </Jotai.Provider>
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
