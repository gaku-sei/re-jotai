type w = [#writable]

type r = [#readable]

type rw = [r | w]

type atom<'value, 'access> constraint 'access = [< rw]

@module("jotai") external atom: 'value => atom<'value, rw> = "atom"

@module("jotai")
external derivedAtom: ((atom<'value, [> r]> => 'value) => 'derivedValue) => atom<'derivedValue, r> =
  "atom"

@module("jotai")
external derivedAsyncAtom: (
  (atom<'value, 'access> => 'value) => Js.Promise.t<'derivedValue>
) => atom<'derivedValue, r> = "atom"

@module("jotai")
external useAtom: atom<'value, rw> => ('value, ('value => 'value) => unit) = "useAtom"

@module("jotai")
external useDerivedAtom': atom<'value, [> r]> => ('value, unit) = "useAtom"

let useDerivedAtom = atom => {
  let (value, ()) = useDerivedAtom'(atom)

  value
}

module Provider = {
  @module("jotai") @react.component
  external make: (~children: React.element) => React.element = "Provider"
}
