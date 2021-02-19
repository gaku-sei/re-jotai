@module("jotai")
external useAtom: Atom.t<'value, Atom.Permissions.rw> => ('value, ('value => 'value) => unit) =
  "useAtom"

@module("jotai") @deprecated("Use useDerivedAtom instead")
external useDerivedAtomInternal: Atom.t<'value, [> Atom.Permissions.r]> => ('value, unit) =
  "useAtom"

let useDerivedAtom = atom => {
  let (value, ()) = @ocaml.warning("-3") useDerivedAtomInternal(atom)

  value
}
