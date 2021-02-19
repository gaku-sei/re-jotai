@module("jotai")
external use: Atom.t<'value, Atom.Permissions.rw> => ('value, ('value => 'value) => unit) =
  "useAtom"

@module("jotai")
external useReadableInternal: Atom.t<'value, [> Atom.Permissions.r]> => ('value, unit) = "useAtom"

let useReadable = atom => {
  let (value, ()) = @ocaml.warning("-3") useReadableInternal(atom)

  value
}
